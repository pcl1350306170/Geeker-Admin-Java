package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.entity.SysMenu;
import com.example.geekeradmin.service.MenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 菜单权限管理（菜单的树形 CRUD）
 */
@RestController
@RequestMapping("/geeker/menu")
public class MenuController {

    @Autowired
    private MenuService menuService;

    /**
     * 完整菜单树（菜单权限页面用，含禁用菜单，不分页）
     */
    @GetMapping("/all")
    public Result<List<SysMenu>> getMenuAll() {
        return Result.success(menuService.getMenuAllTree());
    }

    /**
     * 新增菜单
     */
    @PostMapping
    public Result<?> addMenu(@RequestBody SysMenu menu) {
        menuService.addMenu(menu);
        return Result.success(null);
    }

    /**
     * 编辑菜单
     */
    @PutMapping
    public Result<?> updateMenu(@RequestBody SysMenu menu) {
        menuService.updateMenu(menu);
        return Result.success(null);
    }

    /**
     * 删除菜单
     */
    @DeleteMapping("/{id}")
    public Result<?> deleteMenu(@PathVariable Long id) {
        menuService.deleteMenu(id);
        return Result.success(null);
    }
}
