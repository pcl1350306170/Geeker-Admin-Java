package com.example.geekeradmin.common;

/**
 * 业务异常：由业务代码主动抛出，携带面向用户的可读提示。
 * 与系统异常区分开——业务异常的消息可安全返回给前端，
 * 系统异常（NPE、数据访问异常等）对外只返回通用文案，细节仅记录到日志。
 */
public class BusinessException extends RuntimeException {

    /** 对外返回的业务状态码，同时作为 HTTP 响应状态（限制在 4xx 客户端错误范围） */
    private final int code;

    public BusinessException(String message) {
        this(400, message);
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
