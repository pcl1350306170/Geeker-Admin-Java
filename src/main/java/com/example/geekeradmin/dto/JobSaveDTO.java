package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 定时任务新增/编辑参数
 */
@Data
public class JobSaveDTO {
    private Long id;
    /** 任务名称 */
    private String jobName;
    /** 任务组名 */
    private String jobGroup;
    /** 调用目标字符串，格式：beanName.method(args) */
    private String invokeTarget;
    /** cron 执行表达式 */
    private String cronExpression;
    /** 是否并发执行：1-禁止 0-允许 */
    private Integer concurrent;
    /** 任务状态：1-正常 0-暂停 */
    private Integer status;
    /** 备注 */
    private String remark;
}
