package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 系统日志分页查询参数
 */
@Data
public class LogQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    /** 日志类型：1-操作 2-登录 3-异常 */
    private Integer logType;
    /** 业务类型 */
    private String businessType;
    /** 操作人（模糊匹配） */
    private String operator;
    /** 操作状态：1-成功 0-失败 */
    private Integer status;
    /** 开始时间（yyyy-MM-dd HH:mm:ss） */
    private String beginTime;
    /** 结束时间（yyyy-MM-dd HH:mm:ss） */
    private String endTime;
}
