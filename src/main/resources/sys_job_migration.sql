-- ================================================================
-- 定时任务模块 增量迁移脚本（sys_job / sys_job_log）
-- ----------------------------------------------------------------
-- 用途：在【已存在数据】的 geeker_admin 库上增量创建定时任务相关表，
--       不会 DROP 其它业务表，可安全重复执行。
-- 执行：
--   mysql -h 127.0.0.1 -P 3307 -u root -p geeker_admin < sys_job_migration.sql
--   或在 Navicat / DataGrip / IDEA Database 中直接 Run
-- 说明：全量初始化请改用 geeker_admin_full.sql（该脚本已含以下表）
-- ================================================================

USE `geeker_admin`;

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `sys_job` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(255) NOT NULL COMMENT '调用目标字符串（beanName.method(args)）',
  `cron_expression` varchar(64) NOT NULL COMMENT 'cron 执行表达式',
  `concurrent` tinyint NOT NULL DEFAULT '1' COMMENT '是否并发执行：1-禁止 0-允许',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '任务状态：1-正常 0-暂停',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_job_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务表';

CREATE TABLE IF NOT EXISTS `sys_job_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `job_id` bigint NOT NULL COMMENT '任务ID',
  `job_name` varchar(64) DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(64) DEFAULT NULL COMMENT '任务组名',
  `invoke_target` varchar(255) DEFAULT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) DEFAULT NULL COMMENT '执行信息',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '执行状态：1-成功 0-失败',
  `exception_info` text COMMENT '异常信息',
  `cost_time` bigint DEFAULT '0' COMMENT '耗时（毫秒）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
  PRIMARY KEY (`id`),
  KEY `idx_job_log_job_id` (`job_id`),
  KEY `idx_job_log_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务调度日志表';

-- 示例任务（默认暂停 status=0，可在页面手动启用）
INSERT INTO `sys_job` (`id`, `job_name`, `job_group`, `invoke_target`, `cron_expression`, `concurrent`, `status`, `remark`)
SELECT * FROM (
  SELECT 1 AS id, '清理历史系统日志' AS job_name, 'DEFAULT' AS job_group, 'sampleTask.cleanExpiredLog(30)' AS invoke_target,
         '0 0 3 * * ?' AS cron_expression, 1 AS concurrent, 0 AS status, '每天凌晨3点清理30天前的系统日志（默认暂停，可手动启用）' AS remark
  UNION ALL
  SELECT 2, '统计开发资产总数', 'DEFAULT', 'sampleTask.countDevAsset()', '0 0/30 * * * ?', 1, 0, '每30分钟统计一次开发资产总数并打印（演示用，默认暂停）'
  UNION ALL
  SELECT 3, '演示-带参任务', 'DEFAULT', 'sampleTask.showMessage(''定时任务运行中'')', '0/30 * * * * ?', 1, 0, '每30秒打印一次消息（演示用，默认暂停）'
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM `sys_job` WHERE `sys_job`.`id` = seed.id);
