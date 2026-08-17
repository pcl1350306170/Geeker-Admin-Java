package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 用户分页查询参数
 */
@Data
public class UserQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    private String username;
    private String nickname;
    private Integer status;
}
