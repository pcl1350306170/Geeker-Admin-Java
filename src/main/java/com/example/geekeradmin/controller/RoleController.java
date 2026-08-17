package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.RoleMenuSaveDTO;
import com.example.geekeradmin.service.RoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 角色管理（轻量方案：固定角色字典 + 菜单权限分配）
 */
@RestController
@RequestMapping("/geeker/role")
public class RoleController {

    @Autowired
    private RoleService roleService;

    /**
     * 角色列表（固定字典）
     */
    @GetMapping("/list")
    public Result<List<Map<String, Object>>> getRoleList() {
        return Result.success(roleService.getRoleList());
    }

    /**
     * 查询角色可见的菜单ID集合
     */
    @GetMapping("/menus")
    public Result<List<Long>> getRoleMenuIds(@RequestParam String role) {
        return Result.success(roleService.getRoleMenuIds(role));
    }

    /**
     * 保存角色的菜单权限
     */
    @PostMapping("/menus")
    public Result<?> saveRoleMenus(@RequestBody RoleMenuSaveDTO dto) {
        roleService.saveRoleMenus(dto.getRole(), dto.getMenuIds());
        return Result.success(null);
    }
}
