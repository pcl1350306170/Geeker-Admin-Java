package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.geekeradmin.entity.MenuMeta;
import com.example.geekeradmin.entity.SysMenu;
import com.example.geekeradmin.mapper.SysMenuMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class MenuService {

    @Autowired
    private SysMenuMapper menuMapper;

    /**
     * 登录后的动态路由菜单（仅启用状态，带 meta 结构）
     */
    public List<SysMenu> getMenuList() {
        List<SysMenu> allMenus = menuMapper.selectAllEnabled();
        allMenus.forEach(menu -> {
            MenuMeta meta = new MenuMeta();
            meta.setIcon(menu.getIcon());
            meta.setTitle(menu.getTitle());
            meta.setIsLink(menu.getIsLink());
            meta.setHide(menu.getIsHide() == 1);
            meta.setFull(menu.getIsFull() == 1);
            meta.setAffix(menu.getIsAffix() == 1);
            meta.setKeepAlive(menu.getIsKeepAlive() == 1);
            meta.setActiveMenu(menu.getActiveMenu());
            menu.setMeta(meta);
        });
        return buildTree(allMenus, 0L);
    }

    /**
     * 菜单权限页面的完整菜单树（含禁用菜单，不带 meta）
     */
    public List<SysMenu> getMenuAllTree() {
        LambdaQueryWrapper<SysMenu> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(SysMenu::getSort).orderByAsc(SysMenu::getId);
        List<SysMenu> allMenus = menuMapper.selectList(wrapper);
        return buildTree(allMenus, 0L);
    }

    /**
     * 新增菜单
     */
    public void addMenu(SysMenu menu) {
        if (!StringUtils.hasText(menu.getTitle())) {
            throw new RuntimeException("菜单标题不能为空");
        }
        if (menu.getParentId() == null) {
            menu.setParentId(0L);
        }
        if (menu.getStatus() == null) {
            menu.setStatus(1);
        }
        menuMapper.insert(menu);
    }

    /**
     * 编辑菜单
     */
    public void updateMenu(SysMenu menu) {
        if (menu.getId() == null) {
            throw new RuntimeException("菜单ID不能为空");
        }
        if (menu.getParentId() != null && menu.getParentId().equals(menu.getId())) {
            throw new RuntimeException("上级菜单不能选择自己");
        }
        menuMapper.updateById(menu);
    }

    /**
     * 删除菜单（存在子菜单时禁止删除）
     */
    public void deleteMenu(Long id) {
        SysMenu menu = menuMapper.selectById(id);
        if (menu == null) {
            throw new RuntimeException("菜单不存在");
        }
        LambdaQueryWrapper<SysMenu> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysMenu::getParentId, id);
        if (menuMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("该菜单存在子菜单，请先删除子菜单");
        }
        menuMapper.deleteById(id);
    }

    private List<SysMenu> buildTree(List<SysMenu> menus, Long parentId) {
        return menus.stream()
                .filter(menu -> menu.getParentId().equals(parentId))
                .peek(menu -> menu.setChildren(buildTree(menus, menu.getId())))
                .toList();
    }
}
