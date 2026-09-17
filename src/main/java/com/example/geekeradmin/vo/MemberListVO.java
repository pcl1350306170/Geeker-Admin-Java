package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 成员列表 VO
 */
@Data
public class MemberListVO {
    private Long id;
    private Long familyId;
    private String familyName;
    private String name;
    private String alias;
    private String gender;
    private String generation;
    private String title;
    private String roleType;
    private Integer age;
    private Integer isHead;
    private Integer isCore;
    private Integer sort;
    private LocalDateTime updatedAt;
}
