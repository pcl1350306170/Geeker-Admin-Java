package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.JobLogQueryDTO;
import com.example.geekeradmin.dto.JobQueryDTO;
import com.example.geekeradmin.dto.JobSaveDTO;
import com.example.geekeradmin.entity.SysJob;
import com.example.geekeradmin.entity.SysJobLog;
import com.example.geekeradmin.mapper.SysJobLogMapper;
import com.example.geekeradmin.mapper.SysJobMapper;
import com.example.geekeradmin.schedule.ScheduledTaskManager;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.support.CronExpression;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * 定时任务服务：任务 CRUD + 动态调度联动 + 调度日志查询。
 */
@Service
public class JobService {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private SysJobMapper sysJobMapper;

    @Autowired
    private SysJobLogMapper sysJobLogMapper;

    @Autowired
    private ScheduledTaskManager scheduledTaskManager;

    /**
     * 分页查询任务
     */
    public Page<SysJob> getJobPage(JobQueryDTO query) {
        LambdaQueryWrapper<SysJob> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(query.getJobName()), SysJob::getJobName, query.getJobName())
                .eq(StringUtils.hasText(query.getJobGroup()), SysJob::getJobGroup, query.getJobGroup())
                .eq(query.getStatus() != null, SysJob::getStatus, query.getStatus())
                .orderByDesc(SysJob::getId);
        return sysJobMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
    }

    public SysJob getById(Long id) {
        return sysJobMapper.selectById(id);
    }

    /**
     * 新增任务
     */
    public void addJob(JobSaveDTO dto) {
        validate(dto);
        SysJob job = new SysJob();
        BeanUtils.copyProperties(dto, job);
        job.setId(null);
        if (!StringUtils.hasText(job.getJobGroup())) {
            job.setJobGroup("DEFAULT");
        }
        if (job.getConcurrent() == null) {
            job.setConcurrent(1);
        }
        if (job.getStatus() == null) {
            job.setStatus(0);
        }
        job.setCreateTime(LocalDateTime.now());
        job.setUpdateTime(LocalDateTime.now());
        sysJobMapper.insert(job);
        // 若新增即为启用状态，直接注册调度
        scheduledTaskManager.schedule(job);
    }

    /**
     * 编辑任务
     */
    public void updateJob(JobSaveDTO dto) {
        if (dto.getId() == null) {
            throw new RuntimeException("任务ID不能为空");
        }
        validate(dto);
        SysJob exist = sysJobMapper.selectById(dto.getId());
        if (exist == null) {
            throw new RuntimeException("任务不存在");
        }
        SysJob job = new SysJob();
        BeanUtils.copyProperties(dto, job);
        job.setUpdateTime(LocalDateTime.now());
        sysJobMapper.updateById(job);
        // 以最新配置重新注册调度
        SysJob latest = sysJobMapper.selectById(dto.getId());
        scheduledTaskManager.schedule(latest);
    }

    /**
     * 删除任务
     */
    public void deleteJob(Long id) {
        scheduledTaskManager.cancel(id);
        sysJobMapper.deleteById(id);
    }

    /**
     * 切换任务状态（启用/暂停）
     */
    public void changeStatus(Long id, Integer status) {
        SysJob exist = sysJobMapper.selectById(id);
        if (exist == null) {
            throw new RuntimeException("任务不存在");
        }
        SysJob job = new SysJob();
        job.setId(id);
        job.setStatus(status);
        job.setUpdateTime(LocalDateTime.now());
        sysJobMapper.updateById(job);
        exist.setStatus(status);
        if (status != null && status == ScheduledTaskManager.STATUS_RUNNING) {
            scheduledTaskManager.schedule(exist);
        } else {
            scheduledTaskManager.cancel(id);
        }
    }

    /**
     * 立即执行一次
     */
    public void runOnce(Long id) {
        SysJob job = sysJobMapper.selectById(id);
        if (job == null) {
            throw new RuntimeException("任务不存在");
        }
        scheduledTaskManager.runOnce(job);
    }

    /**
     * 预览 cron 未来若干次执行时间
     */
    public List<String> previewCron(String cron, int count) {
        scheduledTaskManager.validateCron(cron);
        CronExpression expression = CronExpression.parse(cron.trim());
        List<String> result = new ArrayList<>();
        LocalDateTime next = LocalDateTime.now();
        for (int i = 0; i < count; i++) {
            next = expression.next(next);
            if (next == null) {
                break;
            }
            result.add(next.format(FORMATTER));
        }
        return result;
    }

    // ==================== 调度日志 ====================

    public Page<SysJobLog> getJobLogPage(JobLogQueryDTO query) {
        LambdaQueryWrapper<SysJobLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(query.getJobId() != null, SysJobLog::getJobId, query.getJobId())
                .like(StringUtils.hasText(query.getJobName()), SysJobLog::getJobName, query.getJobName())
                .eq(StringUtils.hasText(query.getJobGroup()), SysJobLog::getJobGroup, query.getJobGroup())
                .eq(query.getStatus() != null, SysJobLog::getStatus, query.getStatus())
                .ge(StringUtils.hasText(query.getBeginTime()), SysJobLog::getCreateTime, query.getBeginTime())
                .le(StringUtils.hasText(query.getEndTime()), SysJobLog::getCreateTime, query.getEndTime())
                .orderByDesc(SysJobLog::getId);
        return sysJobLogMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
    }

    /**
     * 清空调度日志
     */
    public void cleanJobLog(Long jobId) {
        LambdaQueryWrapper<SysJobLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(jobId != null, SysJobLog::getJobId, jobId);
        sysJobLogMapper.delete(wrapper);
    }

    private void validate(JobSaveDTO dto) {
        if (!StringUtils.hasText(dto.getJobName())) {
            throw new RuntimeException("任务名称不能为空");
        }
        if (!StringUtils.hasText(dto.getInvokeTarget())) {
            throw new RuntimeException("调用目标不能为空");
        }
        scheduledTaskManager.validateCron(dto.getCronExpression());
    }
}
