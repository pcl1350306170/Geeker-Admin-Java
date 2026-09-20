package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.common.BusinessType;
import com.example.geekeradmin.common.Log;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.JobLogQueryDTO;
import com.example.geekeradmin.dto.JobQueryDTO;
import com.example.geekeradmin.dto.JobSaveDTO;
import com.example.geekeradmin.entity.SysJob;
import com.example.geekeradmin.entity.SysJobLog;
import com.example.geekeradmin.service.JobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 定时任务管理（可视化调度中心）
 */
@RestController
@RequestMapping("/geeker/job")
public class JobController {

    @Autowired
    private JobService jobService;

    /**
     * 分页查询任务列表
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> list(JobQueryDTO query) {
        Page<SysJob> page = jobService.getJobPage(query);
        return Result.success(buildPageData(page));
    }

    /**
     * 任务详情
     */
    @GetMapping("/{id}")
    public Result<SysJob> detail(@PathVariable Long id) {
        return Result.success(jobService.getById(id));
    }

    /**
     * 新增任务
     */
    @Log(title = "定时任务", businessType = BusinessType.INSERT)
    @PostMapping
    public Result<?> add(@RequestBody JobSaveDTO dto) {
        jobService.addJob(dto);
        return Result.success(null);
    }

    /**
     * 编辑任务
     */
    @Log(title = "定时任务", businessType = BusinessType.UPDATE)
    @PutMapping
    public Result<?> update(@RequestBody JobSaveDTO dto) {
        jobService.updateJob(dto);
        return Result.success(null);
    }

    /**
     * 删除任务
     */
    @Log(title = "定时任务", businessType = BusinessType.DELETE)
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        jobService.deleteJob(id);
        return Result.success(null);
    }

    /**
     * 切换任务状态（启用/暂停）
     */
    @Log(title = "定时任务", businessType = BusinessType.UPDATE)
    @PutMapping("/changeStatus")
    public Result<?> changeStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());
        jobService.changeStatus(id, status);
        return Result.success(null);
    }

    /**
     * 立即执行一次
     */
    @Log(title = "定时任务", businessType = BusinessType.OTHER)
    @PutMapping("/run/{id}")
    public Result<?> run(@PathVariable Long id) {
        jobService.runOnce(id);
        return Result.success(null);
    }

    /**
     * 预览 cron 未来执行时间（默认返回 5 次）
     */
    @GetMapping("/previewCron")
    public Result<List<String>> previewCron(@RequestParam String cron,
                                            @RequestParam(defaultValue = "5") Integer count) {
        return Result.success(jobService.previewCron(cron, count));
    }

    /**
     * 分页查询调度日志
     */
    @GetMapping("/log/list")
    public Result<Map<String, Object>> logList(JobLogQueryDTO query) {
        Page<SysJobLog> page = jobService.getJobLogPage(query);
        return Result.success(buildPageData(page));
    }

    /**
     * 清空调度日志（jobId 为空时清空全部）
     */
    @Log(title = "定时任务", businessType = BusinessType.DELETE)
    @DeleteMapping("/log/clean")
    public Result<?> cleanLog(@RequestParam(required = false) Long jobId) {
        jobService.cleanJobLog(jobId);
        return Result.success(null);
    }

    private Map<String, Object> buildPageData(Page<?> page) {
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return data;
    }
}
