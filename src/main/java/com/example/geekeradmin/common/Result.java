package com.example.geekeradmin.common;

import lombok.Data;

@Data
public class Result<T> {
    private int code;
    private String msg = "";
    private T data;

    public static <T> Result<T> success(T data) {
        Result<T> r = new Result<>();
        r.code = 200;
        r.data = data;
        return r;
    }

    public static <T> Result<T> error(int code, String msg) {
        Result<T> r = new Result<>();
        r.code = code;
        r.msg = msg;
        return r;
    }
}
