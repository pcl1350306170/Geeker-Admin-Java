package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 定时任务分页查询参数
 */
@Data
public class JobQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    /** 任务名称（模糊匹配） */
    private String jobName;
    /** 任务组名 */
    private String jobGroup;
    /** 任务状态：1-正常 0-暂停 */
    private Integer status;
}
