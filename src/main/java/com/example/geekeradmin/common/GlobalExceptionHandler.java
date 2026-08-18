package com.example.geekeradmin.common;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * 请求方法与接口声明不一致（405），记录请求路径便于排查
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    @ResponseStatus(HttpStatus.METHOD_NOT_ALLOWED)
    public Result<?> handleMethodNotSupported(HttpRequestMethodNotSupportedException e, HttpServletRequest request) {
        log.warn("请求方法不支持: {} {}，支持的方法: {}", request.getMethod(), request.getRequestURI(), e.getSupportedHttpMethods());
        Result<?> result = new Result<>();
        result.setCode(405);
        result.setMsg("请求方法不支持: " + e.getMessage());
        return result;
    }

    @ExceptionHandler(RuntimeException.class)
    public Result<?> handleRuntimeException(RuntimeException e) {
        log.error("业务异常: {}", e.getMessage(), e);
        Result<?> result = new Result<>();
        result.setCode(500);
        result.setMsg(e.getMessage());
        return result;
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        log.error("系统异常: {}", e.getMessage(), e);
        Result<?> result = new Result<>();
        result.setCode(500);
        result.setMsg("服务器内部错误: " + e.getMessage());
        return result;
    }
}
