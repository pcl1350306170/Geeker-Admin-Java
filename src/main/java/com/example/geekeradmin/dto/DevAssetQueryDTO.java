package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 开发资产分页查询参数
 */
@Data
public class DevAssetQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 20;
    /** 搜索关键词（空格分隔多个） */
    private String keyword;
    /** 资产类型 */
    private String type;
    /** 标签 */
    private String tag;
    /** 是否收藏 */
    private Integer isFavorite;
}
