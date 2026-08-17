package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 资产列表 VO（不含正文，保证列表加载速度）
 */
@Data
public class DevAssetListVO {
    private Long id;
    private String title;
    private String type;
    private String description;
    private String language;
    private List<String> tags;
    private Integer isFavorite;
    private Integer usageCount;
    private Long parentId;
    private LocalDateTime updatedAt;
}
