package com.example.geekeradmin.common;

import java.lang.annotation.*;

/**
 * 操作日志注解：标注在 Controller 方法上，由 LogAspect 自动采集。
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Log {

    /** 日志类型：1-操作 2-登录 3-异常，默认操作日志 */
    int logType() default 1;

    /** 操作模块/标题 */
    String title() default "";

    /** 业务类型 */
    BusinessType businessType() default BusinessType.OTHER;

    /** 是否记录请求参数 */
    boolean recordParams() default true;

    /** 是否记录返回结果 */
    boolean recordResult() default true;
}
