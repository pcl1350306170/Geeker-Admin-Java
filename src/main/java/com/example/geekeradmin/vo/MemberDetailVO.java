package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 成员详情 VO
 */
@Data
public class MemberDetailVO {
    private Long id;
    private Long familyId;
    private String familyName;
    /** 所属小说ID */
    private Long novelId;
    /** 所属小说名称 */
    private String novelName;
    private String name;
    private String alias;
    private String gender;
    private String generation;
    private String title;
    private String roleType;
    private Integer age;
    /** 性格标签 */
    private List<String> personality;
    private String appearance;
    private String bio;
    private Integer isHead;
    private Integer isCore;
    private Integer sort;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
