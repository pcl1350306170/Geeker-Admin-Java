package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 字典类型分页查询参数
 */
@Data
public class DictTypeQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    /** 字典名称（模糊匹配） */
    private String name;
    /** 字典类型编码（模糊匹配） */
    private String type;
    /** 状态：1-启用 / 0-禁用 */
    private Integer status;
}
