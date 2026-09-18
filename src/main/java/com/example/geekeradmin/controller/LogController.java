package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.common.BusinessType;
import com.example.geekeradmin.common.Log;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.LogQueryDTO;
import com.example.geekeradmin.entity.SysLog;
import com.example.geekeradmin.service.LogService;
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
 * 系统日志（操作/登录/异常）
 */
@RestController
@RequestMapping("/geeker/log")
public class LogController {

    @Autowired
    private LogService logService;

    /**
     * 分页查询日志列表
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> list(LogQueryDTO query) {
        Page<SysLog> page = logService.getLogPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 删除单条日志
     */
    @Log(title = "系统日志", businessType = BusinessType.DELETE)
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        logService.deleteById(id);
        return Result.success(null);
    }

    /**
     * 清空日志（logType 为空时清空全部）
     */
    @Log(title = "系统日志", businessType = BusinessType.DELETE)
    @DeleteMapping("/clean")
    public Result<?> clean(@RequestParam(required = false) Integer logType) {
        logService.clean(logType);
        return Result.success(null);
    }

    /**
     * 导出日志列表（CSV 格式，前端 http.download 为 POST 请求）
     */
    @PostMapping("/export")
    public void export(@RequestBody(required = false) LogQueryDTO query, HttpServletResponse response) throws Exception {
        List<SysLog> logs = logService.getAll(query == null ? new LogQueryDTO() : query);
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("UTF-8");
        String fileName = URLEncoder.encode("系统日志", StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment;filename=" + fileName + ".csv");
        // 写入 BOM 防止 Excel 打开中文乱码
        response.getOutputStream().write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        PrintWriter writer = response.getWriter();
        writer.println("日志ID,日志类型,操作模块,业务类型,操作人,请求方式,请求地址,操作IP,状态,耗时(ms),操作时间");
        for (SysLog item : logs) {
            writer.println(String.join(",",
                    String.valueOf(item.getId()),
                    logTypeLabel(item.getLogType()),
                    escape(item.getTitle()),
                    escape(item.getBusinessType()),
                    escape(item.getOperator()),
                    escape(item.getRequestMethod()),
                    escape(item.getRequestUrl()),
                    escape(item.getOperatorIp()),
                    item.getStatus() != null && item.getStatus() == 1 ? "成功" : "失败",
                    String.valueOf(item.getCostTime() == null ? 0 : item.getCostTime()),
                    item.getCreateTime() == null ? "" : item.getCreateTime().toString()));
        }
        writer.flush();
    }

    private String logTypeLabel(Integer logType) {
        if (logType == null) {
            return "";
        }
        switch (logType) {
            case 1:
                return "操作日志";
            case 2:
                return "登录日志";
            case 3:
                return "异常日志";
            default:
                return String.valueOf(logType);
        }
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
