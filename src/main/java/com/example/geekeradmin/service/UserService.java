package com.example.geekeradmin.service;

import com.example.geekeradmin.entity.MenuMeta;
import com.example.geekeradmin.entity.SysMenu;
import com.example.geekeradmin.entity.SysUser;
import com.example.geekeradmin.mapper.SysMenuMapper;
import com.example.geekeradmin.mapper.SysUserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysMenuMapper menuMapper;

    public SysUser findByUsername(String username) {
        return userMapper.selectByUsername(username);
    }

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

    private List<SysMenu> buildTree(List<SysMenu> menus, Long parentId) {
        return menus.stream()
                .filter(menu -> menu.getParentId().equals(parentId))
                .peek(menu -> menu.setChildren(buildTree(menus, menu.getId())))
                .collect(Collectors.toList());
    }
}
