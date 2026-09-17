package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 字典类型新增/编辑参数
 */
@Data
public class DictTypeSaveDTO {
    private Long id;
    private String name;
    private String type;
    private Integer status;
    private String remark;
}
