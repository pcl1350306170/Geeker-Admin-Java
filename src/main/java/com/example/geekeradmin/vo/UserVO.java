package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户列表响应（不含密码）
 */
@Data
public class UserVO {
    private Long id;
    private String username;
    private String nickname;
    private String avatar;
    private Integer status;
    /** 所属部门ID */
    private Long deptId;
    /** 所属部门名称（由 deptId 关联查出） */
    private String deptName;
    /** 数据范围：1-全部数据 / 2-本部门 / 3-本部门及以下 */
    private Integer dataScope;
    private LocalDateTime createTime;
}
