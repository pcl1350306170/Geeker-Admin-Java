package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 家族列表 VO
 */
@Data
public class FamilyListVO {
    private Long id;
    private String name;
    private String alias;
    private String type;
    private String status;
    private String introduction;
    private String emblem;
    private String cover;
    /** 成员数 */
    private Integer memberCount;
    /** 核心角色数 */
    private Integer coreCount;
    private LocalDateTime updatedAt;
}
