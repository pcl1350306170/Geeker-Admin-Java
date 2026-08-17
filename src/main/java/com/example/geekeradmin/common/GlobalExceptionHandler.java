package com.example.geekeradmin.common;

import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public Result<?> handleRuntimeException(RuntimeException e) {
        Result<?> result = new Result<>();
        result.setCode(500);
        result.setMsg(e.getMessage());
        return result;
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        Result<?> result = new Result<>();
        result.setCode(500);
        result.setMsg("服务器内部错误");
        return result;
    }
}
