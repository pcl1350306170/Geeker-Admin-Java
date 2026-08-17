package com.example.geekeradmin.entity;

import lombok.Data;

@Data
public class MenuMeta {
    private String icon;
    private String title;
    private String isLink;
    private boolean isHide;
    private boolean isFull;
    private boolean isAffix;
    private boolean isKeepAlive;
    private String activeMenu;
}
