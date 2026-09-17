package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 家族新增/编辑入参
 */
@Data
public class FamilySaveDTO {
    /** 家族名称（必填） */
    private String name;
    /** 别称/称号 */
    private String alias;
    /** 家族类型（字典 novel_family_type） */
    private String type;
    /** 势力地位（字典 novel_family_status） */
    private String status;
    /** 简介 */
    private String introduction;
    /** 背景故事（Markdown） */
    private String background;
    /** 家训/祖训 */
    private String creed;
    /** 势力范围/封地 */
    private String territory;
    /** 族徽图URL */
    private String emblem;
    /** 封面图URL */
    private String cover;
    /** 排序 */
    private Integer sort;
}
