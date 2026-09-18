package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 系统日志（操作/登录/异常三类统一存储，log_type 区分）
 */
@Data
@TableName("sys_log")
public class SysLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 日志类型：1-操作日志 2-登录日志 3-异常日志 */
    private Integer logType;
    /** 操作模块/日志标题 */
    private String title;
    /** 业务类型：INSERT/UPDATE/DELETE/SELECT/EXPORT/LOGIN/LOGOUT/OTHER */
    private String businessType;
    /** 目标类.方法名 */
    private String method;
    /** 请求方式：GET/POST/PUT/DELETE */
    private String requestMethod;
    /** 请求URL */
    private String requestUrl;
    /** 请求参数（JSON） */
    private String requestParam;
    /** 返回结果（JSON） */
    private String responseResult;
    /** 操作人用户名 */
    private String operator;
    /** 操作人IP */
    private String operatorIp;
    /** 操作状态：1-成功 0-失败 */
    private Integer status;
    /** 错误信息 */
    private String errorMsg;
    /** 耗时（毫秒） */
    private Long costTime;
    /** 操作时间 */
    private LocalDateTime createTime;
}
