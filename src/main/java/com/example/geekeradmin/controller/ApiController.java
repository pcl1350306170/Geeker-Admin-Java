package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.LoginDTO;
import com.example.geekeradmin.dto.LoginRespDTO;
import com.example.geekeradmin.entity.SysMenu;
import com.example.geekeradmin.entity.SysUser;
import com.example.geekeradmin.service.UserService;
import com.example.geekeradmin.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/geeker")
public class ApiController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public Result<LoginRespDTO> login(@RequestBody LoginDTO dto) {
        SysUser user = userService.findByUsername(dto.getUsername());
        if (user != null && BCrypt.checkpw(dto.getPassword(), user.getPassword())) {
            if (user.getStatus() != null && user.getStatus() == 0) {
                throw new RuntimeException("该账号已被禁用，请联系管理员");
            }
            String token = jwtUtil.generateToken(user.getUsername());
            return Result.success(new LoginRespDTO(token));
        }
        throw new RuntimeException("用户名或密码错误");
    }

    @GetMapping("/user/info")
    public Result<Map<String, Object>> getUserInfo(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        String username = jwtUtil.getUsernameFromToken(token);
        SysUser user = userService.findByUsername(username);
        Map<String, Object> info = new HashMap<>();
        info.put("nickname", user.getNickname());
        info.put("avatar", user.getAvatar());
        return Result.success(info);
    }

    @GetMapping("/menu/list")
    public Result<List<SysMenu>> getMenuList() {
        return Result.success(userService.getMenuList());
    }

    @GetMapping("/auth/buttons")
    public Result<Map<String, List<String>>> getAuthButtons() {
        Map<String, List<String>> buttons = new HashMap<>();
        buttons.put("useProTable", Arrays.asList("add", "batchAdd", "export", "batchDelete", "status"));
        buttons.put("authButton", Arrays.asList("add", "edit", "delete", "import", "export"));
        buttons.put("accountManage", Arrays.asList("add", "edit", "delete", "status", "resetPwd"));
        return Result.success(buttons);
    }

    @PostMapping("/logout")
    public Result<?> logout() {
        return Result.success(null);
    }
}
