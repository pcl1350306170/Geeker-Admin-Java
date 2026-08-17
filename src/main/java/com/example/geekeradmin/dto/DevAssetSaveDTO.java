package com.example.geekeradmin.dto;

import lombok.Data;

import java.util.List;

/**
 * 开发资产新增/编辑入参
 */
@Data
public class DevAssetSaveDTO {
    /** 资产类型：CODE/SOLUTION/TROUBLESHOOTING/PROCEDURE/SNIPPET */
    private String type;
    private String title;
    private String description;
    /** Markdown 正文 */
    private String content;
    private String language;
    private List<String> tags;
}
