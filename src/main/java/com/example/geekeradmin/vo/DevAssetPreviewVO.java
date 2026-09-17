package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单预览 VO（列表项 + 从正文提取的封面图）
 * 用于「订单预览」菜单：按标签筛选资产，展示正文首图缩略图
 */
@Data
public class DevAssetPreviewVO {
    private Long id;
    private String title;
    private String description;
    private String type;
    private List<String> tags;
    /** 正文中提取的第一张图片地址（Markdown / HTML img），无图为 null */
    private String coverImage;
    private Integer isFavorite;
    private Integer usageCount;
    private LocalDateTime updatedAt;
}
