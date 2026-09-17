package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 小说家族成员表
 */
@Data
@TableName("novel_family_member")
public class NovelFamilyMember {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 所属家族ID */
    private Long familyId;
    /** 姓名 */
    private String name;
    /** 字/号/别称 */
    private String alias;
    /** 性别（字典 sys_user_sex） */
    private String gender;
    /** 辈分 */
    private String generation;
    /** 身份/头衔 */
    private String title;
    /** 角色定位（字典 novel_member_role） */
    private String roleType;
    /** 年龄 */
    private Integer age;
    /** 性格标签（JSON 数组字符串） */
    private String personality;
    /** 外貌描述 */
    private String appearance;
    /** 人物小传 */
    private String bio;
    /** 是否家主：1-是 0-否 */
    private Integer isHead;
    /** 是否核心角色：1-是 0-否 */
    private Integer isCore;
    /** 排序 */
    private Integer sort;
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
    private Integer deleted;
}
