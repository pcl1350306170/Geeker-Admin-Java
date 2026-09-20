package com.example.geekeradmin.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.geekeradmin.entity.DevAsset;
import com.example.geekeradmin.entity.SysLog;
import com.example.geekeradmin.mapper.DevAssetMapper;
import com.example.geekeradmin.mapper.SysLogMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

/**
 * 演示用定时任务处理器（bean 名称为 sampleTask）
 * 注意：invokeTarget 格式必须为 sampleTask.method(args)
 */
@Component("sampleTask")
public class SampleTask {

    private static final Logger logger = LoggerFactory.getLogger(SampleTask.class);

    @Autowired
    private SysLogMapper sysLogMapper;

    @Autowired
    private DevAssetMapper devAssetMapper;

    /**
     * 清理指定天数前的系统日志
     *
     * @param days 保留最近 N 天的日志
     */
    public void cleanExpiredLog(int days) {
        logger.info("开始执行清理历史系统日志任务，保留 {} 天", days);
        LocalDateTime threshold = LocalDateTime.now().minus(days, ChronoUnit.DAYS);
        LambdaQueryWrapper<SysLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(SysLog::getCreateTime, threshold);
        int deletedCount = sysLogMapper.delete(wrapper);
        logger.info("已清理 {} 条过期系统日志", deletedCount);
    }

    /**
     * 统计开发资产总数（打印到控制台）
     */
    public void countDevAsset() {
        // MyBatis-Plus 逻辑删除过滤由条件决定，这里统计所有未删除的资产
        long count = devAssetMapper.selectCount(new LambdaQueryWrapper<DevAsset>().eq(DevAsset::getDeleted, 0));
        logger.info("当前开发资产总数：{}", count);
    }

    /**
     * 演示带参任务
     *
     * @param message 消息内容
     */
    public void showMessage(String message) {
        logger.info("【演示】收到消息：{}", message);
    }

    /**
     * 无参数演示任务
     */
    public void noParams() {
        logger.info("定时任务运行中（无参数示例）");
    }
}
