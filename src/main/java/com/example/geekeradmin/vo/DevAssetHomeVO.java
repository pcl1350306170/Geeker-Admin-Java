package com.example.geekeradmin.vo;

import lombok.Data;

import java.util.List;

/**
 * 资产库首页聚合数据
 */
@Data
public class DevAssetHomeVO {
    /** 最近使用（最多 10 条） */
    private List<DevAssetListVO> recentUsed;
    /** 收藏 */
    private List<DevAssetListVO> favorites;
    /** 常用资产（按使用次数） */
    private List<DevAssetListVO> mostUsed;
    /** 最近更新 */
    private List<DevAssetListVO> recentUpdated;
}
