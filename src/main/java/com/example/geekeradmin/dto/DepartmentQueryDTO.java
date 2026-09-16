package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 部门查询参数（树形列表，不分页）
 */
@Data
public class DepartmentQueryDTO {
    /** 部门名称（模糊匹配） */
    private String name;
    /** 状态：1-启用 / 0-禁用 */
    private Integer status;
}
