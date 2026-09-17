package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 字典数据分页查询参数
 */
@Data
public class DictDataQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    /** 所属字典类型编码（精确匹配） */
    private String dictType;
    /** 字典标签（模糊匹配） */
    private String label;
    /** 状态：1-启用 / 0-禁用 */
    private Integer status;
}
