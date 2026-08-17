package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 开发资产库-资产主表
 */
@Data
@TableName("dev_asset")
public class DevAsset {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    /** CODE / SOLUTION / TROUBLESHOOTING / PROCEDURE / SNIPPET */
    private String type;
    private String description;
    /** Markdown 正文 */
    private String content;
    private String language;
    /** 标签（JSON 数组字符串） */
    private String tags;
    private Integer isFavorite;
    private Integer usageCount;
    private Long parentId;
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
    private Integer deleted;
}
