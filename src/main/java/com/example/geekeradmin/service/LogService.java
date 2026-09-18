package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.LogQueryDTO;
import com.example.geekeradmin.entity.SysLog;
import com.example.geekeradmin.mapper.SysLogMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 系统日志服务
 */
@Service
public class LogService {

    @Autowired
    private SysLogMapper sysLogMapper;

    /**
     * 分页查询日志
     */
    public Page<SysLog> getLogPage(LogQueryDTO query) {
        Page<SysLog> page = sysLogMapper.selectPage(
                new Page<>(query.getPageNum(), query.getPageSize()), buildWrapper(query));
        return page;
    }

    /**
     * 查询日志列表（导出用，不分页）
     */
    public List<SysLog> getAll(LogQueryDTO query) {
        return sysLogMapper.selectList(buildWrapper(query));
    }

    /**
     * 异步保存日志（不阻塞主请求，失败仅记录不影响业务）
     */
    @Async("logTaskExecutor")
    public void saveLog(SysLog sysLog) {
        if (sysLog.getCreateTime() == null) {
            sysLog.setCreateTime(LocalDateTime.now());
        }
        sysLogMapper.insert(sysLog);
    }

    /**
     * 删除单条日志
     */
    public void deleteById(Long id) {
        sysLogMapper.deleteById(id);
    }

    /**
     * 清空日志（可按日志类型清理，logType 为 null 时清空全部）
     */
    public void clean(Integer logType) {
        LambdaQueryWrapper<SysLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(logType != null, SysLog::getLogType, logType);
        sysLogMapper.delete(wrapper);
    }

    private LambdaQueryWrapper<SysLog> buildWrapper(LogQueryDTO query) {
        LambdaQueryWrapper<SysLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(query.getLogType() != null, SysLog::getLogType, query.getLogType())
                .eq(StringUtils.hasText(query.getBusinessType()), SysLog::getBusinessType, query.getBusinessType())
                .like(StringUtils.hasText(query.getOperator()), SysLog::getOperator, query.getOperator())
                .eq(query.getStatus() != null, SysLog::getStatus, query.getStatus())
                .ge(StringUtils.hasText(query.getBeginTime()), SysLog::getCreateTime, query.getBeginTime())
                .le(StringUtils.hasText(query.getEndTime()), SysLog::getCreateTime, query.getEndTime())
                .orderByDesc(SysLog::getId);
        return wrapper;
    }
}
