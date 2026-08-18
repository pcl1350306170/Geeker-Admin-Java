package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 标签字典返回（含使用数量，用于删除前提示）
 */
@Data
public class DevAssetTagVO {
    private Long id;
    private String name;
    private Integer sort;
    /** 使用该标签的资产数量 */
    private Long usageCount;
    private LocalDateTime createdAt;
}
