package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_user")
public class SysUser {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String password;
    private String nickname;
    private String avatar;
    private Integer status;
    /** 角色编码：admin-超级管理员 / user-普通用户（role 为 MySQL 保留字，需反引号） */
    @TableField("`role`")
    private String role;
    /** 所属部门ID（关联 sys_department.id） */
    private Long deptId;
    /** 数据范围：1-全部数据 / 2-本部门 / 3-本部门及以下（admin 强制为全部） */
    private Integer dataScope;
    private LocalDateTime createTime;
}
