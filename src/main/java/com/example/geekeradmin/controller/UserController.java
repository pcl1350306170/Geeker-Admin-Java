package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.UserQueryDTO;
import com.example.geekeradmin.dto.UserSaveDTO;
import com.example.geekeradmin.service.UserService;
import com.example.geekeradmin.vo.UserVO;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 账号管理（用户管理）
 */
@RestController
@RequestMapping("/geeker/user")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 分页查询用户列表
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> list(UserQueryDTO query) {
        Page<UserVO> page = userService.getUserPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 新增用户
     */
    @PostMapping
    public Result<?> add(@RequestBody UserSaveDTO dto) {
        userService.addUser(dto);
        return Result.success(null);
    }

    /**
     * 编辑用户
     */
    @PutMapping
    public Result<?> update(@RequestBody UserSaveDTO dto) {
        userService.updateUser(dto);
        return Result.success(null);
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        userService.deleteUser(id);
        return Result.success(null);
    }

    /**
     * 切换用户状态
     */
    @PutMapping("/status")
    public Result<?> changeStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());
        userService.changeStatus(id, status);
        return Result.success(null);
    }

    /**
     * 重置密码（重置为 123456）
     */
    @PutMapping("/resetPwd")
    public Result<?> resetPwd(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        userService.resetPassword(id);
        return Result.success(null);
    }

    /**
     * 导出用户列表（CSV 格式，前端 http.download 为 POST 请求）
     */
    @PostMapping("/export")
    public void export(HttpServletResponse response) throws Exception {
        List<UserVO> users = userService.getAllUsers();
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("UTF-8");
        String fileName = URLEncoder.encode("用户列表", StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment;filename=" + fileName + ".csv");
        // 写入 BOM 防止 Excel 打开中文乱码
        response.getOutputStream().write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        PrintWriter writer = response.getWriter();
        writer.println("ID,用户名,昵称,头像,状态,创建时间");
        for (UserVO user : users) {
            writer.println(String.join(",",
                    String.valueOf(user.getId()),
                    escape(user.getUsername()),
                    escape(user.getNickname()),
                    escape(user.getAvatar()),
                    user.getStatus() != null && user.getStatus() == 1 ? "启用" : "禁用",
                    user.getCreateTime() == null ? "" : user.getCreateTime().toString()));
        }
        writer.flush();
    }

    private String escape(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(",") || value.contains("\"")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
