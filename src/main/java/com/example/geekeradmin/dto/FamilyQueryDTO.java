package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 家族分页查询参数
 */
@Data
public class FamilyQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 20;
    /** 搜索关键词（名称/别称/简介） */
    private String keyword;
    /** 家族类型 */
    private String type;
    /** 势力地位 */
    private String status;
}
