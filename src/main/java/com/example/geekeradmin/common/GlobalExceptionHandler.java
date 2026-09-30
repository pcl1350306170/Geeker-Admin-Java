package com.example.geekeradmin.common;

import com.example.geekeradmin.entity.SysLog;
import com.example.geekeradmin.service.LogService;
import com.example.geekeradmin.util.IpUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /** 异常日志 error_msg 最大存储长度 */
    private static final int MAX_ERROR_LENGTH = 5000;

    /** 系统异常对外统一返回的安全文案（绝不回显内部细节） */
    private static final String GENERIC_SYSTEM_ERROR = "服务器内部错误，请稍后重试";

    @Autowired
    private LogService logService;

    /**
     * 业务异常：由业务代码主动抛出，消息面向用户，可安全返回。
     * HTTP 状态取业务 code（限定 4xx）；前端 error 拦截器读取 body.msg 展示具体提示。
     */
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<Result<?>> handleBusinessException(BusinessException e, HttpServletRequest request) {
        log.warn("业务异常: {} (code={})", e.getMessage(), e.getCode());
        int code = e.getCode();
        HttpStatus resolved = HttpStatus.resolve(code);
        HttpStatus status = (resolved != null && resolved.is4xxClientError()) ? resolved : HttpStatus.BAD_REQUEST;
        return ResponseEntity.status(status).body(Result.error(code, e.getMessage()));
    }

    /**
     * 非法参数：均为开发者编写的校验文案，作为客户端错误（400）返回。
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Result<?>> handleIllegalArgumentException(IllegalArgumentException e, HttpServletRequest request) {
        log.warn("参数校验失败: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error(400, e.getMessage()));
    }

    /**
     * @Valid / @RequestBody 参数校验失败：返回首个字段错误提示（MethodArgumentNotValidException 是 BindException 子类）。
     */
    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    public ResponseEntity<Result<?>> handleValidation(BindException e, HttpServletRequest request) {
        String msg = "参数校验失败";
        FieldError fieldError = e.getBindingResult().getFieldError();
        if (fieldError != null && StringUtils.hasText(fieldError.getDefaultMessage())) {
            msg = fieldError.getDefaultMessage();
        }
        log.warn("请求参数校验失败: {}", msg);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error(400, msg));
    }

    /**
     * 请求方法与接口声明不一致（405）。
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<Result<?>> handleMethodNotSupported(HttpRequestMethodNotSupportedException e, HttpServletRequest request) {
        log.warn("请求方法不支持: {} {}，支持的方法: {}", request.getMethod(), request.getRequestURI(), e.getSupportedHttpMethods());
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).body(Result.error(405, "请求方法不支持"));
    }

    /**
     * 数据访问异常（SQL / MyBatis）：内部细节不外泄，仅记录到日志与异常日志表。
     */
    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<Result<?>> handleDataAccessException(DataAccessException e, HttpServletRequest request) {
        log.error("数据访问异常", e);
        recordExceptionLog(e, request);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Result.error(500, GENERIC_SYSTEM_ERROR));
    }

    /**
     * 其余未预期的运行时异常（NPE 等系统故障）：统一 500 + 通用文案，不回显内部信息。
     */
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Result<?>> handleRuntimeException(RuntimeException e, HttpServletRequest request) {
        log.error("系统运行时异常", e);
        recordExceptionLog(e, request);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Result.error(500, GENERIC_SYSTEM_ERROR));
    }

    /**
     * 兜底：任何其它异常，统一 500 + 通用文案，不回显内部信息。
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Result<?>> handleException(Exception e, HttpServletRequest request) {
        log.error("系统异常", e);
        recordExceptionLog(e, request);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Result.error(500, GENERIC_SYSTEM_ERROR));
    }

    /**
     * 记录一条异常日志（log_type=3），入库失败不影响异常响应。
     * 注意：error_msg 仅落库（服务端可见），不会返回给前端。
     */
    private void recordExceptionLog(Exception e, HttpServletRequest request) {
        try {
            SysLog sysLog = new SysLog();
            sysLog.setLogType(3);
            sysLog.setTitle("系统异常");
            sysLog.setBusinessType(BusinessType.OTHER.name());
            sysLog.setStatus(0);
            sysLog.setErrorMsg(truncate(buildDetail(e)));
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

    private String buildDetail(Exception e) {
        String msg = e.getMessage();
        return e.getClass().getSimpleName() + (StringUtils.hasText(msg) ? ": " + msg : "");
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
