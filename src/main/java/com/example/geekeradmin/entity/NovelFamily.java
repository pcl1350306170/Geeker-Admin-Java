package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 小说家族表
 */
@Data
@TableName("novel_family")
public class NovelFamily {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 家族名称 */
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
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
    private Integer deleted;
}
