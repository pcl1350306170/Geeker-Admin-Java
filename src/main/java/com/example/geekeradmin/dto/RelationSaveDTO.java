package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 关系新增入参
 */
@Data
public class RelationSaveDTO {
    /** 发起端类型：MEMBER-成员 FAMILY-家族（必填） */
    private String sourceType;
    /** 发起端ID（必填） */
    private Long sourceId;
    /** 接收端类型：MEMBER-成员 FAMILY-家族（必填，与发起端类型一致） */
    private String targetType;
    /** 接收端ID（必填） */
    private Long targetId;
    /** 关系类型（字典 novel_relation_type，必填） */
    private String relationType;
    /** 所属小说ID（可不传，后端以发起端所属小说为准） */
    private Long novelId;
    /** 补充描述 */
    private String description;
    /** 关系状态：ACTIVE-存续 BROKEN-破裂，默认 ACTIVE */
    private String status;
}
