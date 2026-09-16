package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 部门（树形结构，parentId=0 为顶级部门）
 */
@Data
@TableName("sys_department")
public class SysDepartment {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 上级部门ID，0 表示顶级 */
    private Long parentId;
    /** 部门名称 */
    private String name;
    /** 部门编码 */
    private String code;
    /** 负责人 */
    private String leader;
    /** 联系电话 */
    private String phone;
    /** 邮箱 */
    private String email;
    /** 显示排序 */
    private Integer sort;
    /** 状态：1-启用 / 0-禁用 */
    private Integer status;
    private LocalDateTime createTime;

    /** 子部门（非数据库字段，构建树时填充） */
    @TableField(exist = false)
    private List<SysDepartment> children;
}
