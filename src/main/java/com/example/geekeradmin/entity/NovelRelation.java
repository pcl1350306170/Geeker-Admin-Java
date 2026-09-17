package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 小说关系表（成员间 / 家族间）
 */
@Data
@TableName("novel_relation")
public class NovelRelation {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 所属小说ID */
    private Long novelId;
    /** 发起端类型：MEMBER-成员 FAMILY-家族 */
    private String sourceType;
    /** 发起端ID */
    private Long sourceId;
    /** 接收端类型：MEMBER-成员 FAMILY-家族 */
    private String targetType;
    /** 接收端ID */
    private Long targetId;
    /** 关系类型（字典 novel_relation_type） */
    private String relationType;
    /** 补充描述 */
    private String description;
    /** 关系状态：ACTIVE-存续 BROKEN-破裂 */
    private String status;
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
    private Integer deleted;
}
