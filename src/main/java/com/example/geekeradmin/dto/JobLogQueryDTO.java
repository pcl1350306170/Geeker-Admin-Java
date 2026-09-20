package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 定时任务调度日志分页查询参数
 */
@Data
public class JobLogQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    /** 任务ID */
    private Long jobId;
    /** 任务名称（模糊匹配） */
    private String jobName;
    /** 任务组名 */
    private String jobGroup;
    /** 执行状态：1-成功 0-失败 */
    private Integer status;
    /** 开始时间（yyyy-MM-dd HH:mm:ss） */
    private String beginTime;
    /** 结束时间（yyyy-MM-dd HH:mm:ss） */
    private String endTime;
}
