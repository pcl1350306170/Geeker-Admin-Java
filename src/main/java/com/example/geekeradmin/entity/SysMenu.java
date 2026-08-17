package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.List;

@Data
@TableName("sys_menu")
public class SysMenu {
    private Long id;
    private Long parentId;
    private String path;
    private String name;
    private String component;
    private String redirect;
    private String icon;
    private String title;
    private String isLink;
    private Integer isHide;
    private Integer isFull;
    private Integer isAffix;
    private Integer isKeepAlive;
    private String activeMenu;
    private Integer sort;
    private Integer status;
    /** 可查看该菜单的角色编码（逗号分隔，如 admin,user） */
    private String roles;

    @TableField(exist = false)
    private List<SysMenu> children;

    @TableField(exist = false)
    private MenuMeta meta;
}
