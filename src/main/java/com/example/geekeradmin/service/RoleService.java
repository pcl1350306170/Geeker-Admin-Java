package com.example.geekeradmin.service;

import com.example.geekeradmin.entity.SysMenu;
import com.example.geekeradmin.mapper.SysMenuMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.*;

/**
 * 角色管理（轻量方案）
 * 角色为固定字典（admin/user），不做角色表的 CRUD；
 * 角色与菜单的关系通过 sys_menu.roles（逗号分隔的角色编码）维护
 */
@Service
public class RoleService {

    public static final String ROLE_ADMIN = "admin";
    public static final String ROLE_USER = "user";

    /** 角色字典（固定） */
    private static final List<Map<String, Object>> ROLE_LIST = List.of(
            Map.of("code", ROLE_ADMIN, "name", "超级管理员", "description", "拥有系统全部权限", "menusFixed", true),
            Map.of("code", ROLE_USER, "name", "普通用户", "description", "拥有系统部分权限", "menusFixed", false)
    );

    @Autowired
    private SysMenuMapper menuMapper;

    /**
     * 角色列表（固定字典）
     */
    public List<Map<String, Object>> getRoleList() {
        return ROLE_LIST;
    }

    /**
     * 校验角色编码是否合法
     */
    public boolean isValidRole(String role) {
        return ROLE_ADMIN.equals(role) || ROLE_USER.equals(role);
    }

    /**
     * 查询角色可见的菜单ID集合（admin 可见全部）
     */
    public List<Long> getRoleMenuIds(String role) {
        if (!isValidRole(role)) {
            throw new RuntimeException("角色不存在：" + role);
        }
        List<SysMenu> allMenus = menuMapper.selectList(null);
        if (ROLE_ADMIN.equals(role)) {
            return allMenus.stream().map(SysMenu::getId).toList();
        }
        return allMenus.stream()
                .filter(menu -> containsRole(menu.getRoles(), role))
                .map(SysMenu::getId)
                .toList();
    }

    /**
     * 保存角色的菜单权限：批量更新 sys_menu.roles（admin 始终保留）
     */
    public void saveRoleMenus(String role, List<Long> menuIds) {
        if (!ROLE_USER.equals(role)) {
            throw new RuntimeException("超级管理员默认拥有全部菜单，不允许修改");
        }
        Set<Long> selectedIds = menuIds == null ? Set.of() : new HashSet<>(menuIds);
        List<SysMenu> allMenus = menuMapper.selectList(null);
        for (SysMenu menu : allMenus) {
            Set<String> roles = parseRoles(menu.getRoles());
            boolean before = roles.contains(role);
            boolean after = selectedIds.contains(menu.getId());
            if (before == after) {
                continue;
            }
            if (after) {
                roles.add(role);
            } else {
                roles.remove(role);
            }
            SysMenu update = new SysMenu();
            update.setId(menu.getId());
            update.setRoles(String.join(",", roles));
            menuMapper.updateById(update);
        }
    }

    /**
     * 判断逗号分隔的角色串中是否包含指定角色
     */
    public boolean containsRole(String roles, String role) {
        if (!StringUtils.hasText(roles)) {
            return false;
        }
        return Arrays.asList(roles.split(",")).contains(role);
    }

    private Set<String> parseRoles(String roles) {
        Set<String> result = new LinkedHashSet<>();
        if (StringUtils.hasText(roles)) {
            result.addAll(Arrays.asList(roles.split(",")));
        }
        // admin 始终可见
        result.add(ROLE_ADMIN);
        return result;
    }
}
