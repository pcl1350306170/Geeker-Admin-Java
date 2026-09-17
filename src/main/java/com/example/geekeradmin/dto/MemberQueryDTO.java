package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 成员分页查询参数
 */
@Data
public class MemberQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 20;
    /** 搜索关键词（姓名/字/号/头衔） */
    private String keyword;
    /** 所属家族ID */
    private Long familyId;
    /** 辈分 */
    private String generation;
    /** 角色定位 */
    private String roleType;
    /** 是否核心角色 */
    private Integer isCore;
}
