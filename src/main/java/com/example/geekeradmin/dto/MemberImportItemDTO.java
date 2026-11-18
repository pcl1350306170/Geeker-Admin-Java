package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 成员批量导入的单条数据。
 * 字段类型刻意放宽（Object），以兼容手写 JSON 中的 true/false、字符串数字、字符串标签等写法。
 */
@Data
public class MemberImportItemDTO {
    /** 可选：覆盖顶层导入家族 */
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
    /** 年龄，兼容数字 / 字符串数字 */
    private Object age;
    /** 性格标签，兼容数组 / 逗号分隔字符串 */
    private Object personality;
    /** 外貌描述 */
    private String appearance;
    /** 人物小传 */
    private String bio;
    /** 是否家主，兼容 0/1、true/false */
    private Object isHead;
    /** 是否核心角色，兼容 0/1、true/false */
    private Object isCore;
    /** 排序，兼容数字 / 字符串数字 */
    private Object sort;
}
