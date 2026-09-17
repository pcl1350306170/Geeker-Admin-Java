package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 字典数据新增/编辑参数
 */
@Data
public class DictDataSaveDTO {
    private Long id;
    private String dictType;
    private String label;
    private String value;
    private Integer sort;
    private Integer status;
    private String listClass;
    private Integer isDefault;
    private String remark;
}
