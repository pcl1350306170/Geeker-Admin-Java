package com.example.geekeradmin.dto;

import lombok.Data;

@Data
public class LoginRespDTO {
    private String access_token;

    public LoginRespDTO(String token) {
        this.access_token = token;
    }
}
