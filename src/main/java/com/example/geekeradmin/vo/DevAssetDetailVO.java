package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 资产详情 VO（含正文）
 */
@Data
public class DevAssetDetailVO {
    private Long id;
    private String title;
    private String type;
    private String description;
    private String content;
    private String language;
    private List<String> tags;
    private Integer isFavorite;
    private Integer usageCount;
    /** 来源资产ID */
    private Long parentId;
    /** 来源资产标题 */
    private String parentTitle;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
