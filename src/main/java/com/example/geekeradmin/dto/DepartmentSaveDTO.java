package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 部门新增/编辑参数
 */
@Data
public class DepartmentSaveDTO {
    private Long id;
    /** 上级部门ID，0 表示顶级 */
    private Long parentId;
    private String name;
    private String code;
    private String leader;
    private String phone;
    private String email;
    private Integer sort;
    private Integer status;
}
