package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 小说分页查询参数
 */
@Data
public class NovelQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 20;
    /** 搜索关键词（名称/别名/作者） */
    private String keyword;
    /** 状态 */
    private String status;
}
