package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 用户新增/编辑参数
 * 注意：password 为前端 MD5 处理后的值，与登录流程保持一致
 */
@Data
public class UserSaveDTO {
    private Long id;
    private String username;
    private String password;
    private String nickname;
    private String avatar;
    private Integer status;
}
