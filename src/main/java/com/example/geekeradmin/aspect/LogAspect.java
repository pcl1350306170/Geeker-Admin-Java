package com.example.geekeradmin.aspect;

import com.example.geekeradmin.common.Log;
import com.example.geekeradmin.dto.LoginDTO;
import com.example.geekeradmin.entity.SysLog;
import com.example.geekeradmin.service.LogService;
import com.example.geekeradmin.util.IpUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import java.lang.reflect.Method;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * 操作日志切面：拦截标注 @Log 的方法，自动采集请求信息并异步入库。
 */
@Aspect
@Component
public class LogAspect {

    private static final Logger log = LoggerFactory.getLogger(LogAspect.class);

    /** 单字段（请求参数/返回结果/错误信息）最大存储长度，超出截断 */
    private static final int MAX_TEXT_LENGTH = 5000;

    @Autowired
    private LogService logService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Around("@annotation(logAnnotation)")
    public Object around(ProceedingJoinPoint joinPoint, Log logAnnotation) throws Throwable {
        long start = System.currentTimeMillis();
        Object result = null;
        Throwable error = null;
        try {
            result = joinPoint.proceed();
            return result;
        } catch (Throwable e) {
            error = e;
            throw e;
        } finally {
            try {
                saveLog(joinPoint, logAnnotation, result, error, System.currentTimeMillis() - start);
            } catch (Exception e) {
                // 记录日志本身失败不能影响主业务
                log.error("保存操作日志失败: {}", e.getMessage(), e);
            }
        }
    }

    private void saveLog(ProceedingJoinPoint joinPoint, Log logAnnotation, Object result,
                         Throwable error, long costTime) {
        SysLog sysLog = new SysLog();
        sysLog.setLogType(logAnnotation.logType());
        sysLog.setTitle(logAnnotation.title());
        sysLog.setBusinessType(logAnnotation.businessType().name());
        sysLog.setCreateTime(LocalDateTime.now());
        sysLog.setCostTime(costTime);

        // 目标类.方法名
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        sysLog.setMethod(method.getDeclaringClass().getSimpleName() + "." + method.getName());

        // 请求信息
        HttpServletRequest request = currentRequest();
        if (request != null) {
            sysLog.setRequestMethod(request.getMethod());
            sysLog.setRequestUrl(truncate(request.getRequestURI()));
            sysLog.setOperatorIp(IpUtil.getIpAddress(request));
        }

        // 操作人：优先取认证上下文；登录接口无认证时从 LoginDTO 入参取用户名
        sysLog.setOperator(resolveOperator(joinPoint.getArgs()));

        // 请求参数
        if (logAnnotation.recordParams()) {
            sysLog.setRequestParam(truncate(toJson(filterArgs(joinPoint.getArgs()))));
        }

        // 返回结果 / 异常信息
        if (error != null) {
            sysLog.setStatus(0);
            sysLog.setErrorMsg(truncate(error.getMessage()));
        } else {
            sysLog.setStatus(1);
            if (logAnnotation.recordResult()) {
                sysLog.setResponseResult(truncate(toJson(result)));
            }
        }

        logService.saveLog(sysLog);
    }

    /**
     * 解析操作人用户名
     */
    private String resolveOperator(Object[] args) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() != null
                && StringUtils.hasText(authentication.getPrincipal().toString())
                && !"anonymousUser".equals(authentication.getPrincipal().toString())) {
            return authentication.getPrincipal().toString();
        }
        // 登录接口：从入参 LoginDTO 取用户名
        if (args != null) {
            for (Object arg : args) {
                if (arg instanceof LoginDTO loginDTO && StringUtils.hasText(loginDTO.getUsername())) {
                    return loginDTO.getUsername();
                }
            }
        }
        return null;
    }

    /**
     * 过滤掉无法/无需序列化的参数（Servlet 对象、文件上传等）
     */
    private Object filterArgs(Object[] args) {
        if (args == null || args.length == 0) {
            return null;
        }
        return Arrays.stream(args)
                .filter(arg -> !(arg instanceof HttpServletRequest)
                        && !(arg instanceof HttpServletResponse)
                        && !(arg instanceof MultipartFile)
                        && !(arg instanceof MultipartFile[]))
                .collect(Collectors.toList());
    }

    private HttpServletRequest currentRequest() {
        ServletRequestAttributes attributes =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attributes == null ? null : attributes.getRequest();
    }

    private String toJson(Object obj) {
        if (obj == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            return String.valueOf(obj);
        }
    }

    private String truncate(String text) {
        if (text == null) {
            return null;
        }
        return text.length() > MAX_TEXT_LENGTH ? text.substring(0, MAX_TEXT_LENGTH) : text;
    }
}
