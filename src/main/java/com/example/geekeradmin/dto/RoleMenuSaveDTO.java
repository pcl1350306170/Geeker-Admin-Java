package com.example.geekeradmin.dto;

import lombok.Data;

import java.util.List;

/**
 * 保存角色菜单权限参数
 */
@Data
public class RoleMenuSaveDTO {
    /** 角色编码 */
    private String role;
    /** 该角色可见的菜单ID集合 */
    private List<Long> menuIds;
}
