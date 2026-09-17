package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 关系 VO（两端带显示名）
 */
@Data
public class RelationVO {
    private Long id;
    private String sourceType;
    private Long sourceId;
    /** 发起端显示名（成员姓名 / 家族名） */
    private String sourceName;
    /** 发起端附加信息（成员所属家族名） */
    private String sourceSub;
    private String targetType;
    private Long targetId;
    /** 接收端显示名（成员姓名 / 家族名） */
    private String targetName;
    /** 接收端附加信息（成员所属家族名） */
    private String targetSub;
    private String relationType;
    private String description;
    private String status;
    private String createdBy;
    private LocalDateTime createdAt;
}
