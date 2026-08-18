package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 开发资产库-标签字典（只维护可选标签名，资产标签仍存 dev_asset.tags）
 */
@Data
@TableName("dev_asset_tag")
public class DevAssetTag {
    private Long id;
    private String name;
    private Integer sort;
    private LocalDateTime createdAt;
}
