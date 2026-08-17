package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 开发资产库-使用记录表
 */
@Data
@TableName("dev_asset_usage")
public class DevAssetUsage {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long assetId;
    /** VIEW / COPY */
    private String action;
    private String createdBy;
    private LocalDateTime createdAt;
}
