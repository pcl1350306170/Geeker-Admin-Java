package com.example.geekeradmin.util;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

/**
 * 定时任务调用目标解析与执行工具。
 * <p>
 * invokeTarget 格式：beanName.methodName(arg1,arg2,...)，例如：
 * <ul>
 *   <li>sampleTask.noParams()</li>
 *   <li>sampleTask.cleanExpiredLog(30)</li>
 *   <li>sampleTask.showMessage('定时任务运行中')</li>
 * </ul>
 * 出于安全考虑，仅允许调用 {@link #ALLOWED_PACKAGE} 包下的 Spring Bean，避免任意反射调用。
 */
@Component
public class JobInvokeUtil implements ApplicationContextAware {

    /** 允许被定时任务调用的 Bean 所在包（白名单） */
    private static final String ALLOWED_PACKAGE = "com.example.geekeradmin.task";

    private ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }

    /**
     * 解析并执行调用目标字符串
     */
    public void invoke(String invokeTarget) throws Exception {
        if (!StringUtils.hasText(invokeTarget)) {
            throw new IllegalArgumentException("调用目标字符串不能为空");
        }
        int openIdx = invokeTarget.indexOf('(');
        int closeIdx = invokeTarget.lastIndexOf(')');
        if (openIdx < 0 || closeIdx < 0 || closeIdx < openIdx) {
            throw new IllegalArgumentException("调用目标格式错误，正确格式：beanName.method(args)");
        }
        String beanMethod = invokeTarget.substring(0, openIdx).trim();
        String argsStr = invokeTarget.substring(openIdx + 1, closeIdx).trim();

        int dotIdx = beanMethod.lastIndexOf('.');
        if (dotIdx <= 0 || dotIdx == beanMethod.length() - 1) {
            throw new IllegalArgumentException("调用目标格式错误，缺少 beanName 或 methodName");
        }
        String beanName = beanMethod.substring(0, dotIdx);
        String methodName = beanMethod.substring(dotIdx + 1);

        Object bean;
        try {
            bean = applicationContext.getBean(beanName);
        } catch (BeansException e) {
            throw new IllegalArgumentException("未找到名为 [" + beanName + "] 的 Spring Bean");
        }
        // 安全校验：仅允许白名单包下的 Bean
        String beanPackage = bean.getClass().getPackageName();
        if (!beanPackage.startsWith(ALLOWED_PACKAGE)) {
            throw new SecurityException("禁止调用非任务包 [" + ALLOWED_PACKAGE + "] 下的 Bean：" + beanName);
        }

        List<Object> args = parseArgs(argsStr);
        Method targetMethod = findMethod(bean.getClass(), methodName, args);
        if (targetMethod == null) {
            throw new NoSuchMethodException("在 [" + beanName + "] 中未找到匹配的方法：" + methodName
                    + "，参数个数=" + args.size());
        }
        Object[] convertedArgs = convertArgs(targetMethod, args);
        targetMethod.invoke(bean, convertedArgs);
    }

    /**
     * 查找方法名一致且参数个数一致的方法
     */
    private Method findMethod(Class<?> clazz, String methodName, List<Object> args) {
        for (Method method : clazz.getMethods()) {
            if (method.getName().equals(methodName) && method.getParameterCount() == args.size()) {
                return method;
            }
        }
        return null;
    }

    /**
     * 按方法形参类型转换实参
     */
    private Object[] convertArgs(Method method, List<Object> args) {
        Class<?>[] paramTypes = method.getParameterTypes();
        Object[] result = new Object[args.size()];
        for (int i = 0; i < args.size(); i++) {
            result[i] = convert(argOrNull(args.get(i)), paramTypes[i]);
        }
        return result;
    }

    private Object argOrNull(Object arg) {
        return arg;
    }

    private Object convert(Object value, Class<?> targetType) {
        if (value == null) {
            return null;
        }
        if (targetType.isInstance(value)) {
            return value;
        }
        String str = value.toString();
        if (targetType == String.class) {
            return str;
        }
        if (targetType == int.class || targetType == Integer.class) {
            return Integer.valueOf(str);
        }
        if (targetType == long.class || targetType == Long.class) {
            return Long.valueOf(str);
        }
        if (targetType == double.class || targetType == Double.class) {
            return Double.valueOf(str);
        }
        if (targetType == float.class || targetType == Float.class) {
            return Float.valueOf(str);
        }
        if (targetType == boolean.class || targetType == Boolean.class) {
            return Boolean.valueOf(str);
        }
        // 其它类型直接返回原值，交由反射校验
        return value;
    }

    /**
     * 解析参数字符串为参数列表：
     * 支持 '字符串'、"字符串"、整数、小数、布尔值；逗号分隔（引号内的逗号不分割）。
     */
    private List<Object> parseArgs(String argsStr) {
        List<Object> args = new ArrayList<>();
        if (!StringUtils.hasText(argsStr)) {
            return args;
        }
        StringBuilder current = new StringBuilder();
        char quote = 0;
        for (int i = 0; i < argsStr.length(); i++) {
            char c = argsStr.charAt(i);
            if (quote != 0) {
                if (c == quote) {
                    quote = 0;
                } else {
                    current.append(c);
                }
                continue;
            }
            if (c == '\'' || c == '"') {
                quote = c;
                // 标记为字符串：用特殊包装区分裸字符串与数字
                current.append('\u0001');
                continue;
            }
            if (c == ',') {
                args.add(toArg(current.toString()));
                current.setLength(0);
                continue;
            }
            current.append(c);
        }
        if (current.length() > 0 || argsStr.endsWith(",")) {
            args.add(toArg(current.toString()));
        }
        return args;
    }

    private Object toArg(String raw) {
        if (raw.startsWith("\u0001")) {
            // 引号包裹的字符串
            return raw.substring(1);
        }
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) {
            return null;
        }
        if (trimmed.equalsIgnoreCase("true") || trimmed.equalsIgnoreCase("false")) {
            return Boolean.valueOf(trimmed);
        }
        try {
            if (trimmed.contains(".")) {
                return Double.valueOf(trimmed);
            }
            return Long.valueOf(trimmed);
        } catch (NumberFormatException e) {
            return trimmed;
        }
    }
}
