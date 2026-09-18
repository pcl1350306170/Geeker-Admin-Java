package com.example.geekeradmin.common;

import com.example.geekeradmin.entity.SysLog;
import com.example.geekeradmin.service.LogService;
import com.example.geekeradmin.util.IpUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /** 异常日志 error_msg 最大存储长度 */
    private static final int MAX_ERROR_LENGTH = 5000;

    @Autowired
    private LogService logService;

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
    public Result<?> handleRuntimeException(RuntimeException e, HttpServletRequest request) {
        log.error("业务异常: {}", e.getMessage(), e);
        recordExceptionLog(e, request);
        Result<?> result = new Result<>();
        result.setCode(500);
        result.setMsg(e.getMessage());
        return result;
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e, HttpServletRequest request) {
        log.error("系统异常: {}", e.getMessage(), e);
        recordExceptionLog(e, request);
        Result<?> result = new Result<>();
        result.setCode(500);
        result.setMsg("服务器内部错误: " + e.getMessage());
        return result;
    }

    /**
     * 记录一条异常日志（log_type=3），异步入库，失败不影响异常响应
     */
    private void recordExceptionLog(Exception e, HttpServletRequest request) {
        try {
            SysLog sysLog = new SysLog();
            sysLog.setLogType(3);
            sysLog.setTitle("系统异常");
            sysLog.setBusinessType(BusinessType.OTHER.name());
            sysLog.setStatus(0);
            sysLog.setErrorMsg(truncate(e.getMessage()));
            sysLog.setCreateTime(LocalDateTime.now());
            if (request != null) {
                sysLog.setRequestMethod(request.getMethod());
                sysLog.setRequestUrl(truncate(request.getRequestURI()));
                sysLog.setOperatorIp(IpUtil.getIpAddress(request));
            }
            sysLog.setOperator(currentUsername());
            logService.saveLog(sysLog);
        } catch (Exception ignore) {
            log.error("记录异常日志失败: {}", ignore.getMessage());
        }
    }

    private String currentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            return null;
        }
        String name = authentication.getPrincipal().toString();
        return (!StringUtils.hasText(name) || "anonymousUser".equals(name)) ? null : name;
    }

    private String truncate(String text) {
        if (text == null) {
            return null;
        }
        return text.length() > MAX_ERROR_LENGTH ? text.substring(0, MAX_ERROR_LENGTH) : text;
    }
}
