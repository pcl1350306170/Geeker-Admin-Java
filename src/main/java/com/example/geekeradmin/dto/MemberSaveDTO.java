package com.example.geekeradmin.dto;

import lombok.Data;

import java.util.List;

/**
 * 成员新增/编辑入参
 */
@Data
public class MemberSaveDTO {
    /** 所属家族ID（必填） */
    private Long familyId;
    /** 姓名（必填） */
    private String name;
    /** 字/号/别称 */
    private String alias;
    /** 性别 */
    private String gender;
    /** 辈分 */
    private String generation;
    /** 身份/头衔 */
    private String title;
    /** 角色定位（字典 novel_member_role） */
    private String roleType;
    /** 年龄 */
    private Integer age;
    /** 性格标签 */
    private List<String> personality;
    /** 外貌描述 */
    private String appearance;
    /** 人物小传 */
    private String bio;
    /** 是否家主 */
    private Integer isHead;
    /** 是否核心角色 */
    private Integer isCore;
    /** 排序 */
    private Integer sort;
}
