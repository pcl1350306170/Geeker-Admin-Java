package com.example.geekeradmin.util;

import org.springframework.security.crypto.bcrypt.BCrypt;

public class PasswordEncoderUtil {
    public static void main(String[] args) {
        String md5Password = "e10adc3949ba59abbe56e057f20f883e";
        String bcryptHash = BCrypt.hashpw(md5Password, BCrypt.gensalt());
        System.out.println("BCrypt hash of MD5('123456'): " + bcryptHash);

        boolean matches = BCrypt.checkpw(md5Password, bcryptHash);
        System.out.println("Verify: " + matches);
    }
}
