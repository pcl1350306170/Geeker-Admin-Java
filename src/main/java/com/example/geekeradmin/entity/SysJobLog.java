package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 定时任务调度日志（对应 sys_job_log 表）
 */
@Data
@TableName("sys_job_log")
public class SysJobLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 任务ID */
    private Long jobId;
    /** 任务名称 */
    private String jobName;
    /** 任务组名 */
    private String jobGroup;
    /** 调用目标字符串 */
    private String invokeTarget;
    /** 执行信息 */
    private String jobMessage;
    /** 执行状态：1-成功 0-失败 */
    private Integer status;
    /** 异常信息 */
    private String exceptionInfo;
    /** 耗时（毫秒） */
    private Long costTime;
    /** 执行时间 */
    private LocalDateTime createTime;
}
