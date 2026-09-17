package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 小说新增/编辑入参
 */
@Data
public class NovelSaveDTO {
    /** 小说名称（必填） */
    private String name;
    /** 别名 */
    private String alias;
    /** 作者 */
    private String author;
    /** 简介 */
    private String introduction;
    /** 状态：ACTIVE-正常 DISABLED-停用，默认 ACTIVE */
    private String status;
    /** 排序 */
    private Integer sort;
}
