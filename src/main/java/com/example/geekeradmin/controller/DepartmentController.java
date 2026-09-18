package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.BusinessType;
import com.example.geekeradmin.common.Log;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.DepartmentQueryDTO;
import com.example.geekeradmin.dto.DepartmentSaveDTO;
import com.example.geekeradmin.entity.SysDepartment;
import com.example.geekeradmin.service.DepartmentService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * 部门管理（树形 CRUD）
 */
@RestController
@RequestMapping("/geeker/department")
public class DepartmentController {

    @Autowired
    private DepartmentService departmentService;

    /**
     * 部门树（不分页，支持按名称/状态过滤）
     */
    @GetMapping("/tree")
    public Result<List<SysDepartment>> tree(DepartmentQueryDTO query) {
        return Result.success(departmentService.getDepartmentTree(query));
    }

    /**
     * 新增部门
     */
    @Log(title = "部门管理", businessType = BusinessType.INSERT)
    @PostMapping
    public Result<?> add(@RequestBody DepartmentSaveDTO dto) {
        departmentService.addDepartment(dto);
        return Result.success(null);
    }

    /**
     * 编辑部门
     */
    @Log(title = "部门管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public Result<?> update(@RequestBody DepartmentSaveDTO dto) {
        departmentService.updateDepartment(dto);
        return Result.success(null);
    }

    /**
     * 删除部门
     */
    @Log(title = "部门管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        departmentService.deleteDepartment(id);
        return Result.success(null);
    }

    /**
     * 切换部门状态
     */
    @Log(title = "部门管理", businessType = BusinessType.UPDATE)
    @PutMapping("/status")
    public Result<?> changeStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());
        departmentService.changeStatus(id, status);
        return Result.success(null);
    }

    /**
     * 导出部门列表（CSV 格式，前端 http.download 为 POST 请求）
     */
    @Log(title = "部门管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response) throws Exception {
        List<SysDepartment> departments = departmentService.getAllFlat();
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("UTF-8");
        String fileName = URLEncoder.encode("部门列表", StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment;filename=" + fileName + ".csv");
        // 写入 BOM 防止 Excel 打开中文乱码
        response.getOutputStream().write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        PrintWriter writer = response.getWriter();
        writer.println("ID,上级部门ID,部门名称,部门编码,负责人,联系电话,邮箱,排序,状态,创建时间");
        for (SysDepartment dept : departments) {
            writer.println(String.join(",",
                    String.valueOf(dept.getId()),
                    String.valueOf(dept.getParentId()),
                    escape(dept.getName()),
                    escape(dept.getCode()),
                    escape(dept.getLeader()),
                    escape(dept.getPhone()),
                    escape(dept.getEmail()),
                    String.valueOf(dept.getSort()),
                    dept.getStatus() != null && dept.getStatus() == 1 ? "启用" : "禁用",
                    dept.getCreateTime() == null ? "" : dept.getCreateTime().toString()));
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
