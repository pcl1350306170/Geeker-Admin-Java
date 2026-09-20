package com.example.geekeradmin.schedule;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.geekeradmin.entity.SysJob;
import com.example.geekeradmin.entity.SysJobLog;
import com.example.geekeradmin.mapper.SysJobLogMapper;
import com.example.geekeradmin.mapper.SysJobMapper;
import com.example.geekeradmin.util.JobInvokeUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 动态定时任务调度管理器。
 * <p>
 * 基于 {@link ThreadPoolTaskScheduler} + {@link CronTrigger} 实现运行时动态注册/取消任务，
 * 应用启动后自动加载数据库中状态为「正常」的任务。每次执行都会写入 sys_job_log 调度日志。
 */
@Component
public class ScheduledTaskManager implements ApplicationRunner {

    private static final Logger logger = LoggerFactory.getLogger(ScheduledTaskManager.class);

    /** 任务状态：正常 */
    public static final int STATUS_RUNNING = 1;

    /** 并发策略：禁止并发 */
    public static final int CONCURRENT_FORBID = 1;

    @Autowired
    private ThreadPoolTaskScheduler taskScheduler;

    @Autowired
    private JobInvokeUtil jobInvokeUtil;

    @Autowired
    private SysJobMapper sysJobMapper;

    @Autowired
    private SysJobLogMapper sysJobLogMapper;

    /** jobId -> 已注册的调度句柄 */
    private final Map<Long, ScheduledFuture<?>> scheduledFutures = new ConcurrentHashMap<>();

    /** jobId -> 是否正在执行（用于禁止并发） */
    private final Map<Long, AtomicBoolean> runningFlags = new ConcurrentHashMap<>();

    /**
     * 应用启动完成后，加载所有启用状态的任务
     */
    @Override
    public void run(ApplicationArguments args) {
        LambdaQueryWrapper<SysJob> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysJob::getStatus, STATUS_RUNNING);
        List<SysJob> jobs = sysJobMapper.selectList(wrapper);
        for (SysJob job : jobs) {
            try {
                schedule(job);
            } catch (Exception e) {
                logger.error("启动加载定时任务失败，jobId={}, cron={}", job.getId(), job.getCronExpression(), e);
            }
        }
        logger.info("定时任务初始化完成，已加载 {} 个启用任务", jobs.size());
    }

    /**
     * 注册（或重新注册）一个 cron 任务
     */
    public void schedule(SysJob job) {
        cancel(job.getId());
        if (job.getStatus() == null || job.getStatus() != STATUS_RUNNING) {
            return;
        }
        validateCron(job.getCronExpression());
        CronTrigger trigger = new CronTrigger(job.getCronExpression());
        ScheduledFuture<?> future = taskScheduler.schedule(createRunnable(job), trigger);
        if (future != null) {
            scheduledFutures.put(job.getId(), future);
            logger.info("定时任务已注册：jobId={}, name={}, cron={}", job.getId(), job.getJobName(), job.getCronExpression());
        }
    }

    /**
     * 取消一个已注册的任务
     */
    public void cancel(Long jobId) {
        ScheduledFuture<?> future = scheduledFutures.remove(jobId);
        if (future != null) {
            future.cancel(false);
            logger.info("定时任务已取消：jobId={}", jobId);
        }
    }

    /**
     * 立即执行一次（异步，不阻塞调用线程）
     */
    public void runOnce(SysJob job) {
        taskScheduler.execute(createRunnable(job));
    }

    /**
     * 构造带日志记录与并发控制的任务执行体
     */
    private Runnable createRunnable(SysJob job) {
        return () -> {
            AtomicBoolean running = runningFlags.computeIfAbsent(job.getId(), k -> new AtomicBoolean(false));
            boolean forbidConcurrent = job.getConcurrent() != null && job.getConcurrent() == CONCURRENT_FORBID;
            if (forbidConcurrent && !running.compareAndSet(false, true)) {
                logger.warn("任务[{}]上一次执行尚未结束，本次触发被跳过", job.getJobName());
                return;
            }
            long start = System.currentTimeMillis();
            SysJobLog jobLog = new SysJobLog();
            jobLog.setJobId(job.getId());
            jobLog.setJobName(job.getJobName());
            jobLog.setJobGroup(job.getJobGroup());
            jobLog.setInvokeTarget(job.getInvokeTarget());
            jobLog.setCreateTime(LocalDateTime.now());
            try {
                jobInvokeUtil.invoke(job.getInvokeTarget());
                jobLog.setStatus(1);
                jobLog.setJobMessage("执行成功");
            } catch (Exception e) {
                Throwable cause = e.getCause() != null ? e.getCause() : e;
                jobLog.setStatus(0);
                jobLog.setJobMessage("执行失败");
                jobLog.setExceptionInfo(truncate(stackTraceToString(cause), 2000));
                logger.error("定时任务执行失败：jobId={}, name={}", job.getId(), job.getJobName(), cause);
            } finally {
                jobLog.setCostTime(System.currentTimeMillis() - start);
                if (forbidConcurrent) {
                    running.set(false);
                }
                try {
                    sysJobLogMapper.insert(jobLog);
                } catch (Exception ex) {
                    logger.error("写入调度日志失败：jobId={}", job.getId(), ex);
                }
            }
        };
    }

    /**
     * 校验 cron 表达式合法性（Spring CronExpression 支持 6 段式，含 ? 与 步长）
     */
    public void validateCron(String cron) {
        if (cron == null || cron.trim().isEmpty()) {
            throw new IllegalArgumentException("cron 表达式不能为空");
        }
        try {
            new CronTrigger(cron.trim());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("cron 表达式非法：" + cron);
        }
    }

    private String stackTraceToString(Throwable t) {
        StringBuilder sb = new StringBuilder();
        sb.append(t.getClass().getName()).append(": ").append(t.getMessage()).append("\n");
        for (StackTraceElement el : t.getStackTrace()) {
            sb.append("\tat ").append(el).append("\n");
        }
        return sb.toString();
    }

    private String truncate(String text, int max) {
        if (text == null) {
            return null;
        }
        return text.length() <= max ? text : text.substring(0, max);
    }
}
