package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 家族详情 VO
 */
@Data
public class FamilyDetailVO {
    private Long id;
    /** 所属小说ID */
    private Long novelId;
    /** 所属小说名称 */
    private String novelName;
    private String name;
    private String alias;
    private String type;
    private String status;
    private String introduction;
    private String background;
    private String creed;
    private String territory;
    private String emblem;
    private String cover;
    private Integer sort;
    /** 成员数 */
    private Integer memberCount;
    /** 核心角色数 */
    private Integer coreCount;
    /** 家主姓名 */
    private String headName;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
