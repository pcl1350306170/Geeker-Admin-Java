-- ================================================================
-- Geeker-Admin-Java 一体化初始化脚本
-- ----------------------------------------------------------------
-- 用途：从零建立 geeker_admin 库，包含全部表结构 + 运行所需种子数据
-- 生成：由 mysqldump 从运行中的开发库导出后合并，可重复执行
-- 执行：
--   mysql -h 127.0.0.1 -P 3307 -u root -p < geeker_admin_full.sql
--   或在 Navicat / DataGrip / IDEA Database 中直接 Run
-- ----------------------------------------------------------------
-- 表清单（14 张）：
--   sys_user / sys_menu / sys_department / sys_dict_type / sys_dict_data / sys_log
--   dev_asset / dev_asset_tag / dev_asset_usage / dev_asset_relation
--   novel / novel_family / novel_family_member / novel_relation
-- 种子数据：sys_* / dict（含日志类型字典 sys_log_type）/ novel* / dev_asset_tag（不含 dev_asset 业务数据与 sys_log 日志记录）
-- 默认账号：admin / user / gz，密码均为 123456（BCrypt 加密存储）
-- ================================================================

CREATE DATABASE IF NOT EXISTS `geeker_admin`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE `geeker_admin`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------- 清理旧表（幂等） ----------
DROP TABLE IF EXISTS `dev_asset`;
DROP TABLE IF EXISTS `dev_asset_relation`;
DROP TABLE IF EXISTS `dev_asset_tag`;
DROP TABLE IF EXISTS `dev_asset_usage`;
DROP TABLE IF EXISTS `novel`;
DROP TABLE IF EXISTS `novel_family`;
DROP TABLE IF EXISTS `novel_family_member`;
DROP TABLE IF EXISTS `novel_relation`;
DROP TABLE IF EXISTS `sys_department`;
DROP TABLE IF EXISTS `sys_dict_data`;
DROP TABLE IF EXISTS `sys_dict_type`;
DROP TABLE IF EXISTS `sys_log`;
DROP TABLE IF EXISTS `sys_menu`;
DROP TABLE IF EXISTS `sys_user`;

-- ================================================================
-- 一、表结构（DDL）
-- ================================================================

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_asset` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '资产ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型：CODE/SOLUTION/TROUBLESHOOTING/PROCEDURE/SNIPPET',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '简介（搜索结果摘要）',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '正文（Markdown）',
  `language` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '代码语言（非代码类型为空）',
  `tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '标签（JSON 数组字符串）',
  `is_favorite` tinyint NOT NULL DEFAULT '0' COMMENT '是否收藏：0否 1是',
  `usage_count` int NOT NULL DEFAULT '0' COMMENT '使用次数（复制一次 +1）',
  `parent_id` bigint DEFAULT NULL COMMENT '来源资产ID（基于旧资产创建）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人用户名',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人用户名',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除：0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_da_type` (`type`) USING BTREE,
  KEY `idx_da_favorite` (`is_favorite`) USING BTREE,
  KEY `idx_da_deleted` (`deleted`) USING BTREE,
  KEY `idx_da_usage_count` (`usage_count`) USING BTREE,
  KEY `idx_da_updated_at` (`updated_at`) USING BTREE,
  KEY `idx_da_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='开发资产库-资产主表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_asset_relation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `asset_id` bigint NOT NULL COMMENT '资产ID',
  `relate_id` bigint NOT NULL COMMENT '关联资产ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_dar_pair` (`asset_id`,`relate_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='开发资产库-资产关联表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_asset_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标签名',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序（越大越靠前）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_dat_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='开发资产库-标签字典表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dev_asset_usage` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `asset_id` bigint NOT NULL COMMENT '资产ID',
  `action` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '动作：VIEW/COPY',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '操作人用户名',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_dau_asset_id` (`asset_id`) USING BTREE,
  KEY `idx_dau_created_at` (`created_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='开发资产库-使用记录表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `novel` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '小说ID',
  `name` varchar(100) NOT NULL COMMENT '小说名称',
  `alias` varchar(200) DEFAULT NULL COMMENT '别名',
  `author` varchar(100) DEFAULT NULL COMMENT '作者',
  `introduction` varchar(1000) DEFAULT NULL COMMENT '简介',
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE-连载/完结 DISABLED-停用',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `created_by` varchar(64) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除：0-正常 1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_novel_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='小说';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `novel_family` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '家族ID',
  `novel_id` bigint NOT NULL DEFAULT '0' COMMENT '所属小说ID',
  `name` varchar(100) NOT NULL COMMENT '家族名称',
  `alias` varchar(200) DEFAULT NULL COMMENT '别称/称号',
  `type` varchar(50) DEFAULT NULL COMMENT '家族类型（字典 novel_family_type）',
  `status` varchar(50) DEFAULT NULL COMMENT '势力地位（字典 novel_family_status）',
  `introduction` varchar(1000) DEFAULT NULL COMMENT '简介',
  `background` text COMMENT '背景故事（Markdown）',
  `creed` varchar(500) DEFAULT NULL COMMENT '家训/祖训',
  `territory` varchar(200) DEFAULT NULL COMMENT '势力范围/封地',
  `emblem` varchar(500) DEFAULT NULL COMMENT '族徽图URL',
  `cover` varchar(500) DEFAULT NULL COMMENT '封面图URL',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除：0-正常 1-删除',
  PRIMARY KEY (`id`),
  KEY `idx_family_name` (`name`),
  KEY `idx_family_type` (`type`),
  KEY `idx_family_status` (`status`),
  KEY `idx_family_novel` (`novel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='小说家族表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `novel_family_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '成员ID',
  `family_id` bigint NOT NULL COMMENT '所属家族ID',
  `novel_id` bigint NOT NULL DEFAULT '0' COMMENT '所属小说ID',
  `name` varchar(100) NOT NULL COMMENT '姓名',
  `alias` varchar(200) DEFAULT NULL COMMENT '字/号/别称',
  `gender` varchar(10) DEFAULT NULL COMMENT '性别（字典 sys_user_sex）',
  `generation` varchar(50) DEFAULT NULL COMMENT '辈分',
  `title` varchar(100) DEFAULT NULL COMMENT '身份/头衔',
  `role_type` varchar(50) DEFAULT NULL COMMENT '角色定位（字典 novel_member_role）',
  `age` int DEFAULT NULL COMMENT '年龄',
  `personality` varchar(500) DEFAULT NULL COMMENT '性格标签（JSON 数组字符串）',
  `appearance` varchar(1000) DEFAULT NULL COMMENT '外貌描述',
  `bio` text COMMENT '人物小传',
  `is_head` tinyint NOT NULL DEFAULT '0' COMMENT '是否家主：1-是 0-否',
  `is_core` tinyint NOT NULL DEFAULT '0' COMMENT '是否核心角色：1-是 0-否',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除：0-正常 1-删除',
  PRIMARY KEY (`id`),
  KEY `idx_member_family` (`family_id`),
  KEY `idx_member_name` (`name`),
  KEY `idx_member_role` (`role_type`),
  KEY `idx_member_novel` (`novel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='小说家族成员表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `novel_relation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关系ID',
  `novel_id` bigint NOT NULL DEFAULT '0' COMMENT '所属小说ID',
  `source_type` varchar(20) NOT NULL COMMENT '发起端类型：MEMBER-成员 FAMILY-家族',
  `source_id` bigint NOT NULL COMMENT '发起端ID',
  `target_type` varchar(20) NOT NULL COMMENT '接收端类型：MEMBER-成员 FAMILY-家族',
  `target_id` bigint NOT NULL COMMENT '接收端ID',
  `relation_type` varchar(50) NOT NULL COMMENT '关系类型（字典 novel_relation_type）',
  `description` varchar(1000) DEFAULT NULL COMMENT '补充描述',
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '关系状态：ACTIVE-存续 BROKEN-破裂',
  `created_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除：0-正常 1-删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_relation` (`source_type`,`source_id`,`target_type`,`target_id`,`relation_type`),
  KEY `idx_relation_source` (`source_type`,`source_id`),
  KEY `idx_relation_target` (`target_type`,`target_id`),
  KEY `idx_relation_novel` (`novel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='小说关系表（成员间/家族间）';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_department` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '上级部门ID，0为顶级',
  `name` varchar(50) NOT NULL COMMENT '部门名称',
  `code` varchar(50) DEFAULT NULL COMMENT '部门编码',
  `leader` varchar(50) DEFAULT NULL COMMENT '负责人',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `sort` int NOT NULL DEFAULT '1' COMMENT '显示排序',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1-启用 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典数据ID',
  `dict_type` varchar(100) NOT NULL COMMENT '所属字典类型编码',
  `label` varchar(100) NOT NULL COMMENT '字典标签',
  `value` varchar(100) NOT NULL COMMENT '字典键值',
  `sort` int NOT NULL DEFAULT '1' COMMENT '显示排序',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1-启用 0-禁用',
  `list_class` varchar(50) DEFAULT NULL COMMENT 'el-tag样式类型：primary/success/info/warning/danger',
  `is_default` tinyint NOT NULL DEFAULT '0' COMMENT '是否默认：1-是 0-否',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_dict_type` (`dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典类型ID',
  `name` varchar(100) NOT NULL COMMENT '字典名称',
  `type` varchar(100) NOT NULL COMMENT '字典类型编码（唯一）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1-启用 0-禁用',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `log_type` tinyint NOT NULL DEFAULT '1' COMMENT '日志类型：1-操作日志 2-登录日志 3-异常日志',
  `title` varchar(255) DEFAULT NULL COMMENT '操作模块/日志标题',
  `business_type` varchar(32) DEFAULT NULL COMMENT '业务类型：INSERT/UPDATE/DELETE/SELECT/EXPORT/LOGIN/LOGOUT/OTHER',
  `method` varchar(255) DEFAULT NULL COMMENT '目标类.方法名',
  `request_method` varchar(16) DEFAULT NULL COMMENT '请求方式：GET/POST/PUT/DELETE',
  `request_url` varchar(500) DEFAULT NULL COMMENT '请求URL',
  `request_param` text COMMENT '请求参数（JSON）',
  `response_result` text COMMENT '返回结果（JSON）',
  `operator` varchar(64) DEFAULT NULL COMMENT '操作人用户名',
  `operator_ip` varchar(64) DEFAULT NULL COMMENT '操作人IP（兼容 X-Forwarded-For）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '操作状态：1-成功 0-失败',
  `error_msg` text COMMENT '错误信息',
  `cost_time` bigint DEFAULT '0' COMMENT '耗时（毫秒）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_log_type` (`log_type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统日志表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint DEFAULT '0' COMMENT '父菜单ID（0为顶级）',
  `path` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '路由路径',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '路由名称',
  `component` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '组件路径',
  `redirect` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '重定向地址',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '图标',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '菜单标题',
  `is_link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '外链地址',
  `is_hide` tinyint(1) DEFAULT '0' COMMENT '是否隐藏',
  `is_full` tinyint(1) DEFAULT '0' COMMENT '是否全屏',
  `is_affix` tinyint(1) DEFAULT '0' COMMENT '是否固定标签页',
  `is_keep_alive` tinyint(1) DEFAULT '1' COMMENT '是否缓存',
  `active_menu` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '高亮菜单路径',
  `sort` int DEFAULT '0' COMMENT '排序',
  `status` tinyint DEFAULT '1' COMMENT '状态：1-启用 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `roles` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'admin,user' COMMENT '可查看该菜单的角色编码(逗号分隔)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='系统菜单表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（BCrypt加密）',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '头像地址',
  `status` tinyint DEFAULT '1' COMMENT '状态：1-启用 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'user' COMMENT '角色编码(admin-超级管理员/user-普通用户)',
  `dept_id` bigint DEFAULT NULL COMMENT '所属部门ID（关联 sys_department.id）',
  `data_scope` tinyint NOT NULL DEFAULT '1' COMMENT '数据范围：1-全部 2-本部门 3-本部门及以下',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_username` (`username`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='系统用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

-- ================================================================
-- 二、种子数据（DML）
-- ================================================================

INSERT INTO `sys_user` (`id`, `username`, `password`, `nickname`, `avatar`, `status`, `create_time`, `update_time`, `role`, `dept_id`, `data_scope`) VALUES (1,'admin','$2b$10$GKzTF9axLDOjMNeceM1wJera9gbbMEYJr7wwJcQiZ1xN1LRtp90wC','管理员','https://example.com/avatar.jpg',1,'2026-08-17 14:55:27','2026-08-17 17:36:43','admin',NULL,1),(2,'user','$2b$10$GKzTF9axLDOjMNeceM1wJera9gbbMEYJr7wwJcQiZ1xN1LRtp90wC','普通用户','https://example.com/avatar.jpg',1,'2026-08-17 14:55:27','2026-08-17 15:29:05','user',NULL,1),(5,'gz','$2a$10$yu1HgKLdLa28atCt24ShIO6lP1lh02kXWIQDoPINOznImA4VR3i96','狗子','https://cdn.jsdelivr.net/gh/pcl1350306170/image-cdn@refs/heads/main/Upload/竖屏-已处理-3hyphn.jpg',1,'2026-08-17 16:32:52','2026-08-17 18:00:32','user',NULL,1);
INSERT INTO `sys_menu` (`id`, `parent_id`, `path`, `name`, `component`, `redirect`, `icon`, `title`, `is_link`, `is_hide`, `is_full`, `is_affix`, `is_keep_alive`, `active_menu`, `sort`, `status`, `create_time`, `update_time`, `roles`) VALUES (1,0,'/home/index','home','/home/index','','HomeFilled','首页','',0,0,1,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(2,0,'/dataScreen','dataScreen','/dataScreen/index','','Histogram','数据大屏','',0,1,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 18:02:47','admin'),(3,0,'/proTable','proTable','','/proTable/useProTable','MessageBox','超级表格','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(4,3,'/proTable/useProTable','useProTable','/proTable/useProTable/index','','Menu','使用 ProTable','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(5,4,'/proTable/useProTable/detail/:id','useProTableDetail','/proTable/useProTable/detail','','Menu','ProTable 详情1','',1,0,0,1,'/proTable/useProTable',1,1,'2026-08-17 15:46:30','2026-08-17 17:27:32','admin,user'),(6,3,'/proTable/useTreeFilter','useTreeFilter','/proTable/useTreeFilter/index','','Menu','使用 TreeFilter','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(7,3,'/proTable/useTreeFilter/detail/:id','useTreeFilterDetail','/proTable/useTreeFilter/detail','','Menu','TreeFilter 详情','',1,0,0,1,'/proTable/useTreeFilter',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(8,3,'/proTable/useSelectFilter','useSelectFilter','/proTable/useSelectFilter/index','','Menu','使用 SelectFilter','',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(9,3,'/proTable/treeProTable','treeProTable','/proTable/treeProTable/index','','Menu','树形 ProTable','',0,0,0,1,'',5,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(10,3,'/proTable/complexProTable','complexProTable','/proTable/complexProTable/index','','Menu','复杂 ProTable','',0,0,0,1,'',6,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(11,3,'/proTable/document','proTableDocument','/proTable/document/index','','Menu','ProTable 文档','https://juejin.cn/post/7166068828202336263/#heading-14',0,0,0,1,'',7,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(12,0,'/auth','auth','','/auth/menu','Lock','权限管理','',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 18:02:47','admin'),(13,12,'/auth/menu','authMenu','/auth/menu/index','','Menu','菜单权限','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 18:02:47','admin'),(14,12,'/auth/button','authButton','/auth/button/index','','Menu','按钮权限','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(15,0,'/assembly','assembly','','/assembly/guide','Briefcase','常用组件','',0,0,0,1,'',5,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(16,15,'/assembly/guide','guide','/assembly/guide/index','','Menu','引导页','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(17,15,'/assembly/tabs','tabs','/assembly/tabs/index','','Menu','标签页操作','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(18,17,'/assembly/tabs/detail/:id','tabsDetail','/assembly/tabs/detail','','Menu','Tab 详情','',1,0,0,1,'/assembly/tabs',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(19,15,'/assembly/selectIcon','selectIcon','/assembly/selectIcon/index','','Menu','图标选择器','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(20,15,'/assembly/selectFilter','selectFilter','/assembly/selectFilter/index','','Menu','分类筛选器','',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(21,15,'/assembly/treeFilter','treeFilter','/assembly/treeFilter/index','','Menu','树形筛选器','',0,0,0,1,'',5,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(22,15,'/assembly/svgIcon','svgIcon','/assembly/svgIcon/index','','Menu','SVG 图标','',0,0,0,1,'',6,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(23,15,'/assembly/uploadFile','uploadFile','/assembly/uploadFile/index','','Menu','文件上传','',0,0,0,1,'',7,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(24,15,'/assembly/batchImport','batchImport','/assembly/batchImport/index','','Menu','批量添加数据','',0,0,0,1,'',8,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(25,15,'/assembly/wangEditor','wangEditor','/assembly/wangEditor/index','','Menu','富文本编辑器','',0,0,0,1,'',9,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(26,15,'/assembly/draggable','draggable','/assembly/draggable/index','','Menu','拖拽组件','',0,0,0,1,'',10,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(27,0,'/dashboard','dashboard','','/dashboard/dataVisualize','Odometer','Dashboard','',0,0,0,1,'',6,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(28,27,'/dashboard/dataVisualize','dataVisualize','/dashboard/dataVisualize/index','','Menu','数据可视化','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(29,0,'/form','form','','/form/proForm','Tickets','表单 Form','',0,0,0,1,'',7,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(30,29,'/form/proForm','proForm','/form/proForm/index','','Menu','超级 Form','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(31,29,'/form/basicForm','basicForm','/form/basicForm/index','','Menu','基础 Form','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(32,29,'/form/validateForm','validateForm','/form/validateForm/index','','Menu','校验 Form','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(33,29,'/form/dynamicForm','dynamicForm','/form/dynamicForm/index','','Menu','动态 Form','',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(34,0,'/echarts','echarts','','/echarts/waterChart','TrendCharts','ECharts','',0,0,0,1,'',8,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(35,34,'/echarts/waterChart','waterChart','/echarts/waterChart/index','','Menu','水型图','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(36,34,'/echarts/columnChart','columnChart','/echarts/columnChart/index','','Menu','柱状图','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(37,34,'/echarts/lineChart','lineChart','/echarts/lineChart/index','','Menu','折线图','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(38,34,'/echarts/pieChart','pieChart','/echarts/pieChart/index','','Menu','饼图','',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(39,34,'/echarts/radarChart','radarChart','/echarts/radarChart/index','','Menu','雷达图','',0,0,0,1,'',5,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(40,34,'/echarts/nestedChart','nestedChart','/echarts/nestedChart/index','','Menu','嵌套环形图','',0,0,0,1,'',6,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(41,0,'/directives','directives','','/directives/copyDirect','Stamp','自定义指令','',0,0,0,1,'',9,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(42,41,'/directives/copyDirect','copyDirect','/directives/copyDirect/index','','Menu','复制指令','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(43,41,'/directives/watermarkDirect','watermarkDirect','/directives/watermarkDirect/index','','Menu','水印指令','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(44,41,'/directives/dragDirect','dragDirect','/directives/dragDirect/index','','Menu','拖拽指令','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(45,41,'/directives/debounceDirect','debounceDirect','/directives/debounceDirect/index','','Menu','防抖指令','',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(46,41,'/directives/throttleDirect','throttleDirect','/directives/throttleDirect/index','','Menu','节流指令','',0,0,0,1,'',5,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(47,41,'/directives/longpressDirect','longpressDirect','/directives/longpressDirect/index','','Menu','长按指令','',0,0,0,1,'',6,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(48,0,'/menu','menu','','/menu/menu1','List','菜单嵌套','',0,0,0,1,'',10,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(49,48,'/menu/menu1','menu1','/menu/menu1/index','','Menu','菜单1','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(50,48,'/menu/menu2','menu2','','/menu/menu2/menu21','Menu','菜单2','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(51,50,'/menu/menu2/menu21','menu21','/menu/menu2/menu21/index','','Menu','菜单2-1','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(52,50,'/menu/menu2/menu22','menu22','','/menu/menu2/menu22/menu221','Menu','菜单2-2','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(53,52,'/menu/menu2/menu22/menu221','menu221','/menu/menu2/menu22/menu221/index','','Menu','菜单2-2-1','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(54,52,'/menu/menu2/menu22/menu222','menu222','/menu/menu2/menu22/menu222/index','','Menu','菜单2-2-2','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(55,50,'/menu/menu2/menu23','menu23','/menu/menu2/menu23/index','','Menu','菜单2-3','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(56,48,'/menu/menu3','menu3','/menu/menu3/index','','Menu','菜单3','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(57,0,'/system','system','','/system/accountManage','Tools','系统管理','',0,0,0,1,'',11,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(58,57,'/system/accountManage','accountManage','/system/accountManage/index','','Menu','账号管理','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(59,57,'/system/roleManage','roleManage','/system/roleManage/index','','Menu','角色管理','',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(60,57,'/system/menuMange','menuMange','/system/menuMange/index','','Menu','菜单管理','',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(61,57,'/system/departmentManage','departmentManage','/system/departmentManage/index','','Menu','部门管理','',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(62,57,'/system/dictManage','dictManage','/system/dictManage/index','','Menu','字典管理','',0,0,0,1,'',5,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(63,57,'/system/timingTask','timingTask','/system/timingTask/index','','Menu','定时任务','',0,0,0,1,'',6,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(64,57,'/system/systemLog','systemLog','/system/systemLog/index','','Menu','系统日志','',0,0,0,1,'',7,1,'2026-08-17 15:46:30','2026-08-17 18:02:48','admin'),(65,0,'/link','link','','/link/bing','Paperclip','外部链接','',0,0,0,1,'',12,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(66,65,'/link/bing','bing','/link/bing/index','','Menu','Bing 内嵌','',0,0,0,1,'',1,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(67,65,'/link/gitee','gitee','/link/gitee/index','','Menu','Gitee 仓库','https://gitee.com/HalseySpicy/Geeker-Admin',0,0,0,1,'',2,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(68,65,'/link/github','github','/link/github/index','','Menu','GitHub 仓库','https://github.com/HalseySpicy/Geeker-Admin',0,0,0,1,'',3,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(69,65,'/link/docs','docs','/link/docs/index','','Menu','项目文档','https://docs.spicyboy.cn',0,0,0,1,'',4,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(70,65,'/link/juejin','juejin','/link/juejin/index','','Menu','掘金主页','https://juejin.cn/user/3263814531551816/posts',0,0,0,1,'',5,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(71,0,'/about/index','about','/about/index','','InfoFilled','关于项目','',0,0,0,1,'',13,1,'2026-08-17 15:46:30','2026-08-17 15:46:30','admin,user'),(100,0,'/devAssets','devAssets','','/devAssets/index','FolderOpened','开发资产库','',0,0,0,1,'',14,1,'2026-08-17 18:24:05','2026-08-17 18:24:05','admin,user'),(101,100,'/devAssets/index','devAssetsIndex','/devAssets/index','','Search','资产首页','',0,0,0,1,'',1,1,'2026-08-17 18:24:05','2026-08-17 18:24:05','admin,user'),(102,100,'/devAssets/list','devAssetsList','/devAssets/list','','Files','全部资产','',0,0,0,1,'',2,1,'2026-08-17 18:24:05','2026-08-17 18:24:05','admin,user'),(103,100,'/devAssets/favorite','devAssetsFavorite','/devAssets/favorite','','Star','我的收藏','',0,0,0,1,'',3,1,'2026-08-17 18:24:05','2026-08-17 18:24:05','admin,user'),(104,100,'/devAssets/detail/:id','devAssetsDetail','/devAssets/detail','','Menu','资产详情','',1,0,0,1,'/devAssets/list',4,1,'2026-08-17 18:24:05','2026-08-17 18:24:05','admin,user'),(105,100,'/devAssets/create','devAssetsCreate','/devAssets/edit','','Menu','新增资产','',1,0,0,1,'/devAssets/list',5,1,'2026-08-17 18:24:05','2026-08-17 18:24:05','admin,user'),(106,100,'/devAssets/edit/:id','devAssetsEdit','/devAssets/edit','','Menu','编辑资产','',1,0,0,1,'/devAssets/list',6,1,'2026-08-17 18:24:05','2026-08-17 18:24:05','admin,user'),(107,100,'/devAssets/tags','devAssetsTags','/devAssets/tags','','PriceTag','标签管理','',0,0,0,1,'',7,1,'2026-08-17 20:10:31','2026-08-17 20:10:31','admin,user'),(108,100,'/devAssets/orderPreview','devAssetsOrderPreview','/devAssets/orderPreview','','Picture','订单预览','',0,0,0,1,'',8,1,'2026-09-17 11:02:26','2026-09-17 11:02:26','admin,user'),(109,0,'/novelFamily','novelFamily','','/novelFamily/family','Collection','小说家族','',0,0,0,1,'',13,1,'2026-09-17 13:26:39','2026-09-17 13:26:39','admin,user'),(110,109,'/novelFamily/family','novelFamilyFamily','/novelFamily/family/index','','Menu','家族管理','',0,0,0,1,'',1,1,'2026-09-17 13:26:39','2026-09-17 13:26:39','admin,user'),(111,109,'/novelFamily/member','novelFamilyMember','/novelFamily/member/index','','Menu','成员管理','',0,0,0,1,'',2,1,'2026-09-17 13:26:39','2026-09-17 13:26:39','admin,user'),(112,109,'/novelFamily/graph','novelFamilyGraph','/novelFamily/graph/index','','Menu','关系图谱','',0,0,0,1,'',3,1,'2026-09-17 13:26:39','2026-09-17 13:26:39','admin,user'),(113,109,'/novelFamily/novel','novelFamilyNovel','/novelFamily/novel/index','','Notebook','小说管理','',0,0,0,1,'',0,1,'2026-09-17 14:14:29','2026-09-17 14:14:29','admin,user');
INSERT INTO `sys_department` (`id`, `parent_id`, `name`, `code`, `leader`, `phone`, `email`, `sort`, `status`, `create_time`) VALUES (1,0,'总公司','HQ','张三','13800000000','hq@geeker.com',1,1,'2026-09-16 14:24:35'),(2,1,'研发部','RD','李四','13800000001','rd@geeker.com',1,1,'2026-09-16 14:24:35'),(3,1,'市场部','MARKET','王五','13800000002','market@geeker.com',2,1,'2026-09-16 14:24:35'),(4,1,'财务部','FINANCE','赵六','13800000003','finance@geeker.com',3,1,'2026-09-16 14:24:35'),(5,2,'前端组','RD_FE','孙七','13800000004','fe@geeker.com',1,1,'2026-09-16 14:24:35'),(6,2,'后端组','RD_BE','周八','13800000005','be@geeker.com',2,1,'2026-09-16 14:24:35'),(7,2,'测试组','RD_QA','吴九','13800000006','qa@geeker.com',3,0,'2026-09-16 14:24:35');
INSERT INTO `sys_dict_type` (`id`, `name`, `type`, `status`, `remark`, `create_time`, `update_time`) VALUES (1,'系统状态','sys_status',1,'通用启用/禁用状态，对应各管理页面的状态字段','2026-09-17 13:01:23','2026-09-17 13:01:23'),(2,'用户性别','sys_user_sex',1,'用户性别枚举','2026-09-17 13:01:23','2026-09-17 13:01:23'),(3,'是否','sys_yes_no',1,'通用是/否枚举','2026-09-17 13:01:23','2026-09-17 13:01:23'),(4,'数据范围','sys_data_scope',1,'账号数据权限范围，与后端 UserService.SCOPE_* 常量对应','2026-09-17 13:01:23','2026-09-17 13:01:23'),(5,'家族类型','novel_family_type',1,'小说家族管理-家族类型枚举','2026-09-17 13:26:39','2026-09-17 13:26:39'),(6,'势力地位','novel_family_status',1,'小说家族管理-家族势力地位','2026-09-17 13:26:39','2026-09-17 13:26:39'),(7,'角色定位','novel_member_role',1,'小说家族管理-成员角色定位','2026-09-17 13:26:39','2026-09-17 13:26:39'),(8,'关系类型','novel_relation_type',1,'小说家族管理-成员间/家族间关系类型','2026-09-17 13:26:39','2026-09-17 13:26:39'),(9,'日志类型','sys_log_type',1,'系统日志-日志类型枚举','2026-09-18 00:00:00','2026-09-18 00:00:00');
INSERT INTO `sys_dict_data` (`id`, `dict_type`, `label`, `value`, `sort`, `status`, `list_class`, `is_default`, `remark`, `create_time`, `update_time`) VALUES (1,'sys_status','启用','1',1,1,'success',1,NULL,'2026-09-17 13:01:23','2026-09-17 13:01:23'),(2,'sys_status','禁用','0',2,1,'danger',0,NULL,'2026-09-17 13:01:23','2026-09-17 13:01:23'),(3,'sys_user_sex','男','1',1,1,NULL,1,NULL,'2026-09-17 13:01:23','2026-09-17 13:01:23'),(4,'sys_user_sex','女','2',2,1,NULL,0,NULL,'2026-09-17 13:01:23','2026-09-17 13:01:23'),(5,'sys_user_sex','未知','0',3,1,NULL,0,NULL,'2026-09-17 13:01:23','2026-09-17 13:01:23'),(6,'sys_yes_no','是','1',1,1,'success',1,NULL,'2026-09-17 13:01:23','2026-09-17 13:01:23'),(7,'sys_yes_no','否','0',2,1,'danger',0,NULL,'2026-09-17 13:01:23','2026-09-17 13:01:23'),(8,'sys_data_scope','全部数据','1',1,1,NULL,1,'对应 UserService.SCOPE_ALL','2026-09-17 13:01:23','2026-09-17 13:01:23'),(9,'sys_data_scope','本部门','2',2,1,NULL,0,'对应 UserService.SCOPE_DEPT','2026-09-17 13:01:23','2026-09-17 13:01:23'),(10,'sys_data_scope','本部门及以下','3',3,1,NULL,0,'对应 UserService.SCOPE_DEPT_AND_CHILD','2026-09-17 13:01:23','2026-09-17 13:01:23'),(11,'novel_family_type','皇族','ROYAL',1,1,'danger',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(12,'novel_family_type','世家','NOBLE',2,1,'primary',1,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(13,'novel_family_type','宗门','SECT',3,1,'success',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(14,'novel_family_type','官宦','OFFICIAL',4,1,'warning',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(15,'novel_family_type','商贾','MERCHANT',5,1,'info',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(16,'novel_family_type','隐世','HERMIT',6,1,'info',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(17,'novel_family_type','魔道','DEMONIC',7,1,'danger',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(18,'novel_family_type','其他','OTHER',8,1,'info',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(19,'novel_family_status','一流','TOP',1,1,'danger',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(20,'novel_family_status','二流','SECOND',2,1,'warning',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(21,'novel_family_status','三流','THIRD',3,1,'primary',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(22,'novel_family_status','末流','WEAK',4,1,'info',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(23,'novel_family_status','新兴','RISING',5,1,'success',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(24,'novel_family_status','没落','DECLINING',6,1,'info',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(25,'novel_member_role','主角','PROTAGONIST',1,1,'danger',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(26,'novel_member_role','重要配角','MAJOR_SUPPORT',2,1,'warning',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(27,'novel_member_role','普通配角','MINOR_SUPPORT',3,1,'primary',1,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(28,'novel_member_role','龙套','EXTRA',4,1,'info',0,NULL,'2026-09-17 13:26:39','2026-09-17 13:26:39'),(29,'novel_relation_type','父子','FATHER_SON',1,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(30,'novel_relation_type','母子','MOTHER_SON',2,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(31,'novel_relation_type','父女','FATHER_DAUGHTER',3,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(32,'novel_relation_type','母女','MOTHER_DAUGHTER',4,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(33,'novel_relation_type','兄弟','BROTHERS',5,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(34,'novel_relation_type','姐妹','SISTERS',6,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(35,'novel_relation_type','兄妹','BROTHER_SISTER',7,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(36,'novel_relation_type','姐弟','SISTER_BROTHER',8,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(37,'novel_relation_type','祖孙','GRANDPARENT',9,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(38,'novel_relation_type','叔侄','UNCLE_NEPHEW',10,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(39,'novel_relation_type','堂亲','COUSIN_PATERNAL',11,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(40,'novel_relation_type','表亲','COUSIN_MATERNAL',12,1,'primary',0,'血缘','2026-09-17 13:26:39','2026-09-17 13:26:39'),(41,'novel_relation_type','夫妻','SPOUSE',13,1,'danger',0,'婚姻','2026-09-17 13:26:39','2026-09-17 13:26:39'),(42,'novel_relation_type','未婚夫妻','ENGAGED',14,1,'danger',0,'婚姻','2026-09-17 13:26:39','2026-09-17 13:26:39'),(43,'novel_relation_type','前夫妻','EX_SPOUSE',15,1,'info',0,'婚姻','2026-09-17 13:26:39','2026-09-17 13:26:39'),(44,'novel_relation_type','恋人','LOVER',16,1,'danger',0,'情义','2026-09-17 13:26:39','2026-09-17 13:26:39'),(45,'novel_relation_type','师徒','MASTER_APPRENTICE',17,1,'warning',0,'情义','2026-09-17 13:26:39','2026-09-17 13:26:39'),(46,'novel_relation_type','同门','FELLOW',18,1,'warning',0,'情义','2026-09-17 13:26:39','2026-09-17 13:26:39'),(47,'novel_relation_type','主仆','MASTER_SERVANT',19,1,'info',0,'情义','2026-09-17 13:26:39','2026-09-17 13:26:39'),(48,'novel_relation_type','君臣','SOVEREIGN_MINISTER',20,1,'warning',0,'情义','2026-09-17 13:26:39','2026-09-17 13:26:39'),(49,'novel_relation_type','挚友','CLOSE_FRIEND',21,1,'success',0,'情义','2026-09-17 13:26:39','2026-09-17 13:26:39'),(50,'novel_relation_type','恩人','BENEFACTOR',22,1,'success',0,'情义','2026-09-17 13:26:39','2026-09-17 13:26:39'),(51,'novel_relation_type','盟友','ALLY',23,1,'success',0,'立场','2026-09-17 13:26:39','2026-09-17 13:26:39'),(52,'novel_relation_type','敌对','ENEMY',24,1,'danger',0,'立场','2026-09-17 13:26:39','2026-09-17 13:26:39'),(53,'novel_relation_type','联姻','MARRIAGE_ALLIANCE',25,1,'danger',0,'立场','2026-09-17 13:26:39','2026-09-17 13:26:39'),(54,'novel_relation_type','依附','DEPENDENT',26,1,'info',0,'立场','2026-09-17 13:26:39','2026-09-17 13:26:39'),(55,'novel_relation_type','仇敌','SWORN_ENEMY',27,1,'danger',0,'立场','2026-09-17 13:26:39','2026-09-17 13:26:39'),(56,'sys_log_type','操作日志','1',1,1,'primary',1,NULL,'2026-09-18 00:00:00','2026-09-18 00:00:00'),(57,'sys_log_type','登录日志','2',2,1,'success',0,NULL,'2026-09-18 00:00:00','2026-09-18 00:00:00'),(58,'sys_log_type','异常日志','3',3,1,'danger',0,NULL,'2026-09-18 00:00:00','2026-09-18 00:00:00');
INSERT INTO `dev_asset_tag` (`id`, `name`, `sort`, `created_at`) VALUES (1,'CSS',0,'2026-08-17 20:10:31'),(2,'小技巧',0,'2026-08-17 20:10:31'),(3,'Vue3',0,'2026-08-17 20:10:31'),(4,'Sortable',0,'2026-08-17 20:10:31'),(5,'拖拽',0,'2026-08-17 20:10:31'),(6,'ArkTS',0,'2026-08-17 20:10:31'),(7,'HarmonyOS',0,'2026-08-17 20:10:31'),(8,'踩坑',0,'2026-08-17 20:10:31'),(9,'Vue2',0,'2026-08-17 20:10:31'),(10,'JavaScript',0,'2026-08-17 20:10:31'),(11,'TypeScript',0,'2026-08-17 20:10:31'),(12,'SCSS',0,'2026-08-17 20:10:31'),(13,'Git',0,'2026-08-17 20:10:31'),(14,'Node',0,'2026-08-17 20:10:31'),(15,'Linux',0,'2026-08-17 20:10:31'),(16,'Docker',0,'2026-08-17 20:10:31'),(21,'定制',0,'2026-08-17 20:17:59'),(22,'诊室屏',0,'2026-08-17 20:19:48'),(23,'漳州联勤保障部队909',0,'2026-08-17 20:19:48'),(24,'二维码',0,'2026-08-17 20:19:48'),(25,'重庆儿童医院宜宾院区',0,'2026-08-17 20:21:25'),(26,'苏州大学附属第二医院',0,'2026-08-17 20:23:09'),(27,'苏州大学',0,'2026-08-17 20:23:09'),(28,'北京大学第三医院秦皇岛医院',0,'2026-08-18 09:02:07'),(29,'临朐县中医院',0,'2026-08-18 09:10:58'),(30,'山西省中西医结合医院',0,'2026-08-18 09:12:47'),(31,'双人诊室屏',0,'2026-08-18 09:12:47'),(32,'南通大学附属医院',0,'2026-08-18 09:19:03'),(33,'动态诊室屏',0,'2026-08-18 09:19:03'),(34,'阳泉市中心医院',0,'2026-08-18 09:19:54'),(35,'候诊屏',0,'2026-08-18 09:21:30'),(36,'自贡四院',0,'2026-08-18 09:21:30'),(37,'列表候诊屏',0,'2026-08-18 09:21:30'),(38,'河北省中医院',0,'2026-08-18 09:22:09'),(39,'第三方上屏',0,'2026-08-18 09:22:09'),(40,'江苏省中医院溧阳分院',0,'2026-08-18 09:22:44'),(41,'南昌市立',0,'2026-08-18 09:23:26'),(42,'排班',0,'2026-08-18 09:23:26'),(43,'南昌市立医院新院区',0,'2026-08-18 09:23:26'),(44,'长横屏',0,'2026-08-18 09:24:24'),(45,'常州市晋陵康复医院',0,'2026-08-18 09:24:24'),(46,'宝鸡中医院西院区',0,'2026-08-18 09:25:44'),(47,'南通市肿瘤医院',0,'2026-08-18 09:33:38'),(48,'叫号',0,'2026-08-18 09:33:38'),(49,'青岛海慈',0,'2026-08-18 09:34:10'),(50,'宝鸡中医院',0,'2026-08-18 09:34:38'),(51,'叫号器',0,'2026-08-18 09:35:53'),(52,'德州市立',0,'2026-08-18 09:35:53'),(53,'报到机',0,'2026-08-18 09:36:57'),(54,'武义县',0,'2026-08-18 09:36:57'),(55,'回诊自动',0,'2026-08-18 09:36:57'),(56,'武义县中医院新院区',0,'2026-08-18 09:36:57'),(57,'上饶市人民医院',0,'2026-08-18 09:37:27'),(58,'宝应县妇幼保健院',0,'2026-08-18 09:37:55'),(59,'打印小票',0,'2026-08-18 09:37:55'),(60,'扬州定制',0,'2026-08-18 09:40:08'),(61,'自动报到',0,'2026-08-18 09:40:08'),(62,'单页面',0,'2026-08-18 09:40:08'),(63,'取号机',0,'2026-08-18 09:41:13'),(64,'自贡',0,'2026-08-18 09:41:13'),(65,'自定义按钮',0,'2026-08-18 09:41:13'),(66,'909',0,'2026-08-18 09:41:46'),(67,'信息发布',0,'2026-08-18 09:42:53'),(68,'宝鸡',0,'2026-08-18 09:42:53'),(69,'三亚国康医院',0,'2026-08-18 09:43:39'),(70,'切屏',0,'2026-08-18 09:43:39'),(71,'西乡县新东方医院',0,'2026-08-18 09:44:26'),(72,'自贡市第四人民医院',0,'2026-08-18 09:45:42'),(73,'窗口屏',0,'2026-08-18 09:46:35'),(74,'婺源县妇幼保健院',0,'2026-08-18 09:46:35'),(75,'门诊',0,'2026-08-18 09:50:21'),(76,'java',0,'2026-08-18 09:50:21'),(77,'服务端',0,'2026-08-18 09:50:21'),(78,'yml',0,'2026-08-18 09:50:21'),(79,'配置',0,'2026-08-18 09:50:21'),(80,'门诊后台',0,'2026-08-18 09:50:21'),(81,'版本',0,'2026-08-18 09:53:40'),(82,'web',0,'2026-08-18 09:53:40'),(83,'模板',0,'2026-08-18 11:00:12'),(84,'老交互',0,'2026-08-18 11:00:12'),(85,'1.5.0',0,'2026-08-18 11:00:12'),(86,'门诊模板1.5.0之前的开发',0,'2026-08-18 11:00:12'),(87,'low-code-template-resource',0,'2026-08-18 11:00:12'),(88,'前端',0,'2026-08-18 11:14:17'),(89,'日志',0,'2026-08-18 11:14:17'),(90,'localStorage',0,'2026-08-18 11:14:17'),(91,'病房',0,'2026-08-18 11:25:48'),(92,'mysql',0,'2026-08-18 11:27:01'),(93,'密码',0,'2026-08-18 11:27:01'),(94,'账号',0,'2026-08-18 11:27:01'),(95,'头部组件',0,'2026-08-18 13:12:50'),(96,'Geeker',0,'2026-08-18 13:22:19'),(97,'Geeker admin',0,'2026-08-18 13:22:19'),(98,'运行版本',0,'2026-08-18 13:22:19'),(99,'java版本',0,'2026-08-18 13:22:19'),(100,'资产管理',0,'2026-08-18 15:03:19'),(101,'需求',0,'2026-08-18 15:03:19'),(102,'CeruMusic',0,'2026-08-18 15:36:15'),(103,'音乐播放器',0,'2026-08-18 15:36:15'),(104,'桌面端',0,'2026-08-18 15:36:15'),(105,'版本信息',0,'2026-08-18 15:36:15'),(106,'Dashy',0,'2026-08-18 15:47:51'),(107,'应用启动',0,'2026-08-18 15:56:22'),(108,'flow launcher',0,'2026-08-18 15:56:22'),(109,'mage',0,'2026-08-18 16:02:39'),(110,'appsmith',0,'2026-08-18 16:12:24'),(111,'server',0,'2026-08-18 16:12:24'),(112,'低代码',0,'2026-08-18 16:12:24'),(113,'directus',0,'2026-08-18 16:25:46'),(114,'后端即服务',0,'2026-08-18 16:25:46'),(115,'服务',0,'2026-08-18 16:25:46'),(116,'medusa',0,'2026-08-18 16:32:40'),(117,'业务后端框架',0,'2026-08-18 16:32:40'),(118,'电商领域模块',0,'2026-08-18 16:32:40'),(119,'Ghost',0,'2026-08-18 16:44:43'),(120,'Strapi',0,'2026-08-18 16:51:53'),(121,'Headless CMS 框架',0,'2026-08-18 16:51:53'),(122,'qoder',0,'2026-08-19 09:48:10'),(123,'病毒防护',0,'2026-08-19 09:48:10'),(124,'IDE',0,'2026-08-19 09:48:11'),(125,'git记录',0,'2026-08-19 14:05:58'),(126,'上屏逻辑',0,'2026-08-19 15:45:44'),(127,'主题',0,'2026-08-20 10:37:04'),(128,'theme',0,'2026-08-20 10:37:04'),(129,'GPT',0,'2026-08-20 10:37:04'),(130,'定时',0,'2026-08-20 15:17:05'),(131,'AI',0,'2026-08-31 09:36:05'),(132,'播客',0,'2026-08-31 09:36:05'),(133,'skill',0,'2026-08-31 09:36:05'),(134,'绘本提示词',0,'2026-08-31 10:05:51'),(135,'全栈',0,'2026-08-31 17:11:10'),(136,'IDEA配置',0,'2026-08-31 17:11:10'),(137,'本地服务端',0,'2026-08-31 19:19:09'),(138,'vue.config.js',0,'2026-08-31 19:19:09'),(139,'门诊自助机',0,'2026-08-31 19:26:05'),(140,'python',0,'2026-09-01 13:48:47'),(141,'配置和日志',0,'2026-09-01 13:48:47'),(142,'绘本',0,'2026-09-01 15:58:50'),(143,'pdf',0,'2026-09-01 15:58:50'),(144,'看板',0,'2026-09-03 09:46:32'),(145,'AI播客',0,'2026-09-03 11:22:45'),(146,'绘本图片',0,'2026-09-03 11:22:45'),(147,'AI播客脚本',0,'2026-09-03 15:38:03'),(148,'资产',0,'2026-09-03 15:48:23'),(149,'提示词',0,'2026-09-04 09:14:30'),(150,'作图',0,'2026-09-04 09:14:30'),(151,'全局弹窗、',0,'2026-09-04 17:53:36'),(152,'南通附院',0,'2026-09-14 11:17:24'),(153,'中间层',0,'2026-09-14 11:17:24'),(154,'科室',0,'2026-09-14 11:17:24'),(155,'门诊特殊订单',0,'2026-09-15 10:03:56');
INSERT INTO `novel` (`id`, `name`, `alias`, `author`, `introduction`, `status`, `sort`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted`) VALUES (1,'红楼梦','石头记','曹雪芹','中国古典四大名著之首，以贾史王薛四大家族由盛而衰为线索，展现封建家族的人情百态与命运沉浮。','ACTIVE',1,'admin','2026-09-17 14:25:59','admin','2026-09-17 14:25:59',0),(2,'TestNovelB',NULL,'tester',NULL,'ACTIVE',0,'admin','2026-09-17 14:26:47','admin','2026-09-17 14:26:47',1),(3,'仙剑三同人','仙剑奇侠传三·同人','佚名','以《仙剑奇侠传三》唐家堡为背景的同人故事：蜀中唐门由盛转衰之际，大小姐唐雪见与永安当伙计景天的命运因一枚玉佩而交织，江湖恩怨、家族权斗与仙缘奇遇层层展开。','ACTIVE',2,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0);
INSERT INTO `novel_family` (`id`, `novel_id`, `name`, `alias`, `type`, `status`, `introduction`, `background`, `creed`, `territory`, `emblem`, `cover`, `sort`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted`) VALUES (1,1,'贾府','金陵贾氏·荣宁二府','NOBLE','TOP','《红楼梦》第一豪门，宁荣二公之后，分荣国府、宁国府两房，一门双国公。','宁国公贾演、荣国公贾源兄弟以军功起家，世袭国公。荣府以贾母为尊，宁府以贾敬一支传承。元春封妃后贾府一度烈火烹油，后遭抄家没落。','诗礼传家','金陵·荣宁街',NULL,NULL,1,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(2,1,'史府','金陵史氏·保龄侯府','NOBLE','SECOND','贾母娘家，保龄侯尚书令史公之后，一门双侯。','史公为尚书令，封保龄侯。后代史鼐袭保龄侯、史鼎封忠靖侯。族中女儿史太君嫁入荣国府为贾母。','诗书簪缨','金陵',NULL,NULL,2,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(3,1,'王府','金陵王氏·都太尉统制县伯','OFFICIAL','TOP','都太尉统制县伯王公之后，王子腾官至九省统制，为四大家族官场支柱。','王家以军功起家，王子腾历任京营节度使、九省统制，权倾一时。王夫人、王熙凤、薛姨妈皆王家女儿，与贾薛两家深度联姻。','东海白玉床','金陵',NULL,NULL,3,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(4,1,'薛府','金陵薛氏·紫薇舍人之后','MERCHANT','DECLINING','紫薇舍人薛公之后，领内帑钱粮、采办杂料的皇商世家。','薛家世代为皇商，家资巨富，护官符称\"珍珠如土金如铁\"。薛蟠打死人命后家道渐衰，薛姨妈携子女投靠贾府。','珍珠如土金如铁','金陵',NULL,NULL,4,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(6,2,'TestFamB',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,'admin','2026-09-17 14:26:47','admin','2026-09-17 14:26:47',1),(7,3,'唐家','唐家堡','SECT','DECLINING','蜀中唐家堡，江湖赫赫有名的唐门所在。世代精研机关暗器与毒术，门规森严，唯毒术不传女。第三十一代掌门唐坤年老病重，家族内斗渐起，昔日武林大族正走向没落。','唐门地处渝州唐家堡，以暗器、毒术名震江湖，为武林四大门派之一。掌门唐坤武功高强、交游广阔，因长子唐丰早逝，将雪天拾得的孤女雪见收为孙女，宠爱有加。唐坤病重后，七子唐益勾结霹雳堂意图夺位，唐门陷入内乱。','唐门家训：守正持毒，护族为先。','渝州·唐家堡',NULL,NULL,1,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0);
INSERT INTO `novel_family_member` (`id`, `family_id`, `novel_id`, `name`, `alias`, `gender`, `generation`, `title`, `role_type`, `age`, `personality`, `appearance`, `bio`, `is_head`, `is_core`, `sort`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted`) VALUES (1,1,1,'贾母','史太君','F','G1','荣国府太夫人','MAJOR_SUPPORT',75,'[\"慈爱\",\"精明\",\"风趣\"]','鬓发如银，慈眉善目','金陵史侯之女，贾代善之妻，荣国府最高权威，孙辈中最疼爱宝玉与黛玉。',1,1,1,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(2,1,1,'贾赦',NULL,'M','G2','一等将军','MAJOR_SUPPORT',60,'[\"荒淫\",\"贪婪\"]',NULL,'贾母长子，袭一等将军，昏聩好色，曾强纳贾母丫鬟鸳鸯为妾未遂。',0,1,2,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(3,1,1,'邢夫人',NULL,'F','G2',NULL,'MINOR_SUPPORT',55,'[\"愚昧\",\"顺从\"]',NULL,'贾赦继室，一味承顺贾赦，不闻不问府中事。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(4,1,1,'贾政',NULL,'M','G2','工部员外郎','MAJOR_SUPPORT',55,'[\"端方\",\"迂腐\"]',NULL,'贾母次子，任工部员外郎，恪守礼教，对宝玉管教严苛。',0,1,3,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(5,1,1,'王夫人',NULL,'F','G2',NULL,'MAJOR_SUPPORT',50,'[\"慈善\",\"冷漠\"]',NULL,'贾政正妻，金陵王家小姐，贾宝玉之母，表面念佛吃斋，实则城府极深。',0,1,4,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(6,1,1,'贾珠',NULL,'M','G3',NULL,'MINOR_SUPPORT',20,'[\"好学\"]',NULL,'贾政长子，十四岁进学，青年早逝，留妻李纨与子贾兰。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(7,1,1,'李纨',NULL,'F','G3',NULL,'MINOR_SUPPORT',32,'[\"贞静\",\"淡泊\"]',NULL,'贾珠之妻，贾兰之母，青年守寡，随分从时，后因儿子科举高中凤冠霞帔。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(8,1,1,'贾兰',NULL,'M','G4',NULL,'MINOR_SUPPORT',10,'[\"勤奋\"]',NULL,'贾珠遗腹子，勤学上进，后科举高中，重振家声。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(9,1,1,'贾宝玉','怡红公子','M','G3',NULL,'PROTAGONIST',14,'[\"叛逆\",\"痴情\",\"灵秀\"]','面若中秋之月，色如春晓之花','贾政次子，衔玉而生，小说第一主角，鄙弃功名利禄，与黛玉情投意合。',0,1,5,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(10,1,1,'贾元春',NULL,'F','G3','贤德妃','MAJOR_SUPPORT',27,'[\"贤孝\"]',NULL,'贾政长女，入宫选为女史，后封凤藻宫尚书加封贤德妃，省亲大观园，贾府盛极而衰的转折。',0,0,6,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(11,1,1,'贾迎春',NULL,'F','G3',NULL,'MINOR_SUPPORT',17,'[\"懦弱\"]',NULL,'贾赦庶女，诨名\"二木头\"，老实懦弱，后被父亲许嫁孙绍祖受虐而死。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(12,1,1,'贾探春',NULL,'F','G3',NULL,'MAJOR_SUPPORT',13,'[\"精明\",\"果敢\",\"志高\"]',NULL,'贾政庶女，赵姨娘所生，诨名\"玫瑰花\"，理家兴利除弊，才自精明志自高，后远嫁海疆。',0,1,7,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(13,1,1,'贾惜春',NULL,'F','G3',NULL,'MINOR_SUPPORT',11,'[\"孤僻\"]',NULL,'宁府贾敬之女，贾珍胞妹，寄住荣国府，冷心冷面，后看破红尘出家为尼。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(14,1,1,'贾环',NULL,'M','G3',NULL,'EXTRA',10,'[\"猥琐\"]',NULL,'贾政庶子，赵姨娘所生，举止猥琐，与宝玉不睦。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(15,1,1,'贾琏',NULL,'M','G3','同知','MAJOR_SUPPORT',26,'[\"风流\",\"纨绔\"]',NULL,'贾赦之子，捐五品同知，荣国府外务当家人，生性风流。',0,1,8,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(16,1,1,'王熙凤','凤辣子','F','G3',NULL,'MAJOR_SUPPORT',25,'[\"精明\",\"狠辣\",\"泼辣\"]','一双丹凤三角眼，两弯柳叶吊梢眉','贾琏之妻，金陵王家小姐，荣国府实际管家，机关算尽，权术过人，后积劳病故。',0,1,9,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(17,1,1,'贾巧姐',NULL,'F','G4',NULL,'EXTRA',5,'[]',NULL,'贾琏与王熙凤之女，生于七夕，刘姥姥为之取名，贾府败落后被刘姥姥救出。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(18,1,1,'林黛玉','颦儿','F','G3',NULL,'PROTAGONIST',13,'[\"敏感\",\"多才\",\"孤高\"]','两弯似蹙非蹙罥烟眉，一双似喜非喜含露目','贾敏之女，父母双亡后寄居荣国府，才华绝代，与宝玉互为知己，泪尽而亡。',0,1,10,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(19,1,1,'贾珍',NULL,'M','G3','威烈将军','MAJOR_SUPPORT',40,'[\"荒淫\",\"纨绔\"]',NULL,'宁府贾敬之子，袭三品爵威烈将军，任贾氏族长，宁国府在他手中乌烟瘴气。',0,1,11,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(20,1,1,'尤氏',NULL,'F','G3',NULL,'MINOR_SUPPORT',38,'[\"贤淑\",\"软弱\"]',NULL,'贾珍继室，贾蓉继母，贤惠有余而无力约束宁府。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(21,1,1,'贾蓉',NULL,'M','G4','监生','MINOR_SUPPORT',18,'[\"纨绔\"]',NULL,'贾珍之子，贾琏堂侄，捐监生，与父亲一同胡作非为。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(22,2,1,'史鼐',NULL,'M','G2','保龄侯','MAJOR_SUPPORT',50,'[\"守成\"]',NULL,'史家当家人，袭保龄侯，贾母之侄，史湘云的叔父。',1,1,12,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(23,2,1,'史鼎',NULL,'M','G2','忠靖侯','MINOR_SUPPORT',48,'[]',NULL,'史家一门双侯之一，封忠靖侯，贾母之侄。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(24,2,1,'史湘云','枕霞旧友','F','G3',NULL,'MAJOR_SUPPORT',15,'[\"豪爽\",\"才思敏捷\",\"心直口快\"]','蜂腰猿背，鹤势螂形','贾母侄孙女，父母早亡，依叔婶度日，醉卧芍药裀，诗社活跃人物，后嫁卫若兰。',0,1,13,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(25,3,1,'王子腾',NULL,'M','G2','九省统制','MAJOR_SUPPORT',52,'[\"权谋\"]',NULL,'王家掌门人，历任京营节度使、九省统制，四大家族官场上的最大靠山。',1,1,14,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(26,3,1,'王子胜',NULL,'M','G2',NULL,'EXTRA',45,'[]',NULL,'王子腾之弟。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(27,3,1,'王仁',NULL,'M','G3',NULL,'EXTRA',28,'[\"贪婪\"]',NULL,'王熙凤之兄，为人贪婪，贾府败落后卖巧姐，人称\"狼舅\"。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(28,4,1,'薛姨妈','薛王氏','F','G2',NULL,'MAJOR_SUPPORT',45,'[\"慈和\"]',NULL,'王夫人同胞妹妹，嫁入薛家，丈夫早逝，携薛蟠薛宝钗进京投靠贾府。',1,1,15,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(29,4,1,'薛蟠','呆霸王','M','G3','皇商','MAJOR_SUPPORT',20,'[\"粗野\",\"骄横\"]',NULL,'薛姨妈之子，袭皇商之业，仗势打死人命，人称\"呆霸王\"。',0,1,16,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(30,4,1,'薛宝钗','蘅芜君','F','G3',NULL,'MAJOR_SUPPORT',15,'[\"稳重\",\"豁达\",\"博学\"]','脸若银盆，眼如水杏','薛姨妈之女，德才兼备，随分守时，后与宝玉成婚，宝玉出家后独守空闺。',0,1,17,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(31,4,1,'薛宝琴',NULL,'F','G3',NULL,'MINOR_SUPPORT',14,'[\"聪慧\",\"开朗\"]',NULL,'薛蝌之妹，薛家旁支，才貌双全，曾许配梅翰林之子。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(32,4,1,'薛蝌',NULL,'M','G3',NULL,'MINOR_SUPPORT',19,'[\"忠厚\"]',NULL,'薛宝琴之兄，为人忠厚，护送妹妹进京待嫁。',0,0,0,'admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(33,6,2,'BM1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,'admin','2026-09-17 14:26:47','admin','2026-09-17 14:26:47',1),(34,6,2,'BM2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,'admin','2026-09-17 14:26:47','admin','2026-09-17 14:26:47',1),(41,7,3,'唐坤','唐门掌门','M','G1','唐门第三十一代掌门·堡主','MAJOR_SUPPORT',72,'威严持重，外冷内热','银发长髯，深目有神，惯着玄色锦袍','唐门掌门、唐家堡堡主，武功高强、交游广阔。对养孙女雪见宠爱有加，倾囊传授毕生所学，因门规毒术不传女而留有遗憾。临终前将雪见托付给景天。',1,1,1,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(42,7,3,'唐泰','三叔公','M','G1','唐门长老','MINOR_SUPPORT',65,'好胜心强，固守门规','方脸浓眉，身形魁梧','唐坤之弟、唐门长老。唐坤病重后觊觎掌门之位，在比武夺位中连胜三场，最终败于雪见与景天联手，不得不交出掌门令牌。',0,0,2,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(43,7,3,'唐丰',NULL,'M','G2','已故长子','EXTRA',NULL,'温厚谦和',NULL,'唐坤长子，雪见的养父（名义）。早年夫妇意外身故，唐坤遂将大雪中拾得的雪见权作丰儿后人抚育，聊表哀思。',0,0,3,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(44,7,3,'唐益','七叔','M','G2','唐门弟子','MAJOR_SUPPORT',45,'阴狠狡诈，野心勃勃','面容阴鸷，目带凶光','唐坤第七子，雪见的七叔。勾结霹雳堂罗如烈谋害唐坤，逼雪见交出掌门令牌，暗算景天，事败后成为唐门叛逆。',0,1,4,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(45,7,3,'唐若兰',NULL,'F','G2','唐坤之女','EXTRA',NULL,'温婉沉静',NULL,'唐坤之女，唐芷芸之母，早逝。其女唐芷芸由唐坤抚养长大。',0,0,5,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(46,7,3,'唐奉',NULL,'M','G2','执令长老','MINOR_SUPPORT',58,'公正耿直','清瘦矍铄，目光沉稳','唐门长老，唐坤族弟。比武夺位时主持公道，在众人不服之际仍将掌门令牌交予胜出的雪见。',0,1,6,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(47,7,3,'唐雪见','雪见·唐女侠','F','G3','大小姐·第三十二代掌门','PROTAGONIST',18,'刁蛮任性，心地纯善','明眸皓齿，娇俏灵动','唐门大小姐、唐坤最宠爱的孙女。真实身份为神树果实所化，幼时被景逸在雪中拾得交由唐坤收养。尽得祖父武功医术真传，唯毒术因门规不传女。经历家变后与景天结为夫妻，成为永安当老板娘。',0,1,7,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(48,7,3,'景天',NULL,'M','G3','渝州永安当·少东家','MAJOR_SUPPORT',20,'乐观贪财，重情重义','眉清目秀，常带笑意','永安当伙计出身，景逸之子。因修补紫砂壶与雪见相识，卷入唐门与蜀山的纷争。曾为救雪见身中毒针，与雪见生死与共，最终结为夫妻，两人携手重开永安当。',0,1,8,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(49,7,3,'唐芷芸',NULL,'F','G3','唐门弟子','MAJOR_SUPPORT',19,'阴险善妒','容貌清秀，眉眼间却带着刻薄','唐坤外孙女，自幼嫉妒雪见受宠。唐坤病逝后当众朗读其遗笔记，揭穿雪见并非唐家血脉，迫使雪见离开唐家堡。',0,0,9,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(50,7,3,'唐恒',NULL,'M','G3','唐门弟子','MINOR_SUPPORT',22,'性情淡泊','眉目温和，气质清雅','雪见的堂兄，唐门年轻一辈弟子，与雪见一同长大，对雪见颇为照顾。',0,0,10,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(51,7,3,'唐念雪',NULL,'F','G4','唐门晚辈','EXTRA',12,'天真活泼','扎着双髻，伶俐可爱','唐恒之女，雪见的堂侄，唐家第四代小辈，常在唐家堡庭院中玩耍。',0,0,11,'admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(52,7,3,'杨幂','','女','G2','','MAJOR_SUPPORT',44,NULL,'唐芷芸母亲','',0,0,0,'gz','2026-09-17 15:19:07','gz','2026-09-17 15:43:03',0);
INSERT INTO `novel_relation` (`id`, `novel_id`, `source_type`, `source_id`, `target_type`, `target_id`, `relation_type`, `description`, `status`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted`) VALUES (1,1,'MEMBER',1,'MEMBER',2,'MOTHER_SON','贾母与长子贾赦','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 14:26:47',0),(2,1,'MEMBER',1,'MEMBER',4,'MOTHER_SON','贾母与次子贾政','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(3,1,'MEMBER',1,'MEMBER',9,'GRANDPARENT','祖母与孙儿','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(4,1,'MEMBER',1,'MEMBER',18,'GRANDPARENT','外祖母与外孙女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(5,1,'MEMBER',2,'MEMBER',3,'SPOUSE','贾赦与邢夫人夫妻','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(6,1,'MEMBER',2,'MEMBER',15,'FATHER_SON','贾赦与贾琏父子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(7,1,'MEMBER',2,'MEMBER',11,'FATHER_DAUGHTER','贾赦与贾迎春父女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(8,1,'MEMBER',2,'MEMBER',4,'BROTHERS','贾赦与贾政兄弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(9,1,'MEMBER',4,'MEMBER',5,'SPOUSE','贾政与王夫人夫妻','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(10,1,'MEMBER',4,'MEMBER',6,'FATHER_SON','贾政与贾珠父子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(11,1,'MEMBER',4,'MEMBER',9,'FATHER_SON','贾政与贾宝玉父子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(12,1,'MEMBER',4,'MEMBER',10,'FATHER_DAUGHTER','贾政与贾元春父女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(13,1,'MEMBER',4,'MEMBER',12,'FATHER_DAUGHTER','贾政与贾探春父女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(14,1,'MEMBER',4,'MEMBER',14,'FATHER_SON','贾政与贾环父子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(15,1,'MEMBER',5,'MEMBER',9,'MOTHER_SON','王夫人与贾宝玉母子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(16,1,'MEMBER',5,'MEMBER',10,'MOTHER_DAUGHTER','王夫人与贾元春母女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(17,1,'MEMBER',6,'MEMBER',7,'SPOUSE','贾珠与李纨夫妻','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(18,1,'MEMBER',6,'MEMBER',8,'FATHER_SON','贾珠与贾兰父子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(19,1,'MEMBER',7,'MEMBER',8,'MOTHER_SON','李纨与贾兰母子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(20,1,'MEMBER',15,'MEMBER',16,'SPOUSE','贾琏与王熙凤夫妻','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(21,1,'MEMBER',15,'MEMBER',17,'FATHER_DAUGHTER','贾琏与贾巧姐父女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(22,1,'MEMBER',16,'MEMBER',17,'MOTHER_DAUGHTER','王熙凤与贾巧姐母女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(23,1,'MEMBER',19,'MEMBER',20,'SPOUSE','贾珍与尤氏夫妻','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(24,1,'MEMBER',19,'MEMBER',21,'FATHER_SON','贾珍与贾蓉父子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(25,1,'MEMBER',19,'MEMBER',9,'COUSIN_PATERNAL','宁荣二府同宗堂兄弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(26,1,'MEMBER',19,'MEMBER',15,'COUSIN_PATERNAL','宁荣二府同宗堂兄弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(27,1,'MEMBER',15,'MEMBER',9,'COUSIN_PATERNAL','贾琏与贾宝玉堂兄弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(28,1,'MEMBER',10,'MEMBER',9,'SISTER_BROTHER','贾元春与贾宝玉姐弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(29,1,'MEMBER',12,'MEMBER',9,'BROTHER_SISTER','贾探春与贾宝玉兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(30,1,'MEMBER',11,'MEMBER',9,'COUSIN_PATERNAL','贾迎春与贾宝玉堂兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(31,1,'MEMBER',13,'MEMBER',9,'COUSIN_PATERNAL','贾惜春与贾宝玉堂兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(32,1,'MEMBER',18,'MEMBER',9,'COUSIN_MATERNAL','姑表兄妹（林黛玉之母贾敏为贾政之妹）','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(33,1,'MEMBER',18,'MEMBER',9,'LOVER','宝黛知己恋人','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(34,1,'MEMBER',9,'MEMBER',30,'COUSIN_MATERNAL','姨表姐弟（薛宝钗之母为王夫人之妹）','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(35,1,'MEMBER',9,'MEMBER',30,'SPOUSE','后四十回贾宝玉与薛宝钗成婚','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(36,1,'MEMBER',16,'MEMBER',9,'COUSIN_MATERNAL','王熙凤与贾宝玉表姐弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(37,1,'MEMBER',12,'MEMBER',18,'CLOSE_FRIEND','大观园诗社知交','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(38,1,'MEMBER',22,'MEMBER',24,'UNCLE_NEPHEW','史鼐与史湘云叔侄','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(39,1,'MEMBER',23,'MEMBER',24,'UNCLE_NEPHEW','史鼎与史湘云叔侄','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(40,1,'MEMBER',22,'MEMBER',23,'BROTHERS','史鼐与史鼎兄弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(41,1,'MEMBER',1,'MEMBER',24,'GRANDPARENT','贾母为史湘云姑祖母','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(42,1,'MEMBER',25,'MEMBER',26,'BROTHERS','王子腾与王子胜兄弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(43,1,'MEMBER',25,'MEMBER',5,'BROTHER_SISTER','王子腾与王夫人兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(44,1,'MEMBER',25,'MEMBER',16,'UNCLE_NEPHEW','王子腾与王熙凤伯侄','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(45,1,'MEMBER',25,'MEMBER',27,'UNCLE_NEPHEW','王子腾与王仁伯侄','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(46,1,'MEMBER',5,'MEMBER',28,'SISTERS','王夫人与薛姨妈同胞姐妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(47,1,'MEMBER',25,'MEMBER',28,'BROTHER_SISTER','王子腾与薛姨妈兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(48,1,'MEMBER',28,'MEMBER',29,'MOTHER_SON','薛姨妈与薛蟠母子','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(49,1,'MEMBER',28,'MEMBER',30,'MOTHER_DAUGHTER','薛姨妈与薛宝钗母女','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(50,1,'MEMBER',29,'MEMBER',30,'BROTHER_SISTER','薛蟠与薛宝钗兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(51,1,'MEMBER',32,'MEMBER',31,'BROTHER_SISTER','薛蝌与薛宝琴兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(52,1,'MEMBER',29,'MEMBER',32,'COUSIN_PATERNAL','薛蟠与薛蝌堂兄弟','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(53,1,'MEMBER',16,'MEMBER',30,'COUSIN_MATERNAL','王熙凤与薛宝钗表姐妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(54,1,'MEMBER',16,'MEMBER',28,'UNCLE_NEPHEW','王熙凤与薛姨妈姑侄','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(55,1,'MEMBER',24,'MEMBER',18,'CLOSE_FRIEND','史湘云与林黛玉诗社挚友','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(56,1,'MEMBER',9,'MEMBER',24,'COUSIN_MATERNAL','贾宝玉与史湘云表兄妹','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(57,1,'FAMILY',1,'FAMILY',2,'MARRIAGE_ALLIANCE','贾母史太君出自史家','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(58,1,'FAMILY',1,'FAMILY',3,'MARRIAGE_ALLIANCE','王夫人、王熙凤出自王家','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(59,1,'FAMILY',1,'FAMILY',4,'MARRIAGE_ALLIANCE','贾宝玉迎娶薛宝钗','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(60,1,'FAMILY',3,'FAMILY',4,'MARRIAGE_ALLIANCE','薛姨妈为王家小姐','ACTIVE','admin','2026-09-17 13:53:17','admin','2026-09-17 13:53:17',0),(61,2,'MEMBER',33,'MEMBER',34,'BROTHERS',NULL,'ACTIVE','admin','2026-09-17 14:26:47','admin','2026-09-17 14:26:47',1),(71,3,'MEMBER',41,'MEMBER',43,'FATHER_SON','唐坤与长子唐丰','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(72,3,'MEMBER',41,'MEMBER',44,'FATHER_SON','唐坤与第七子唐益','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(73,3,'MEMBER',41,'MEMBER',45,'FATHER_DAUGHTER','唐坤与女儿唐若兰','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(74,3,'MEMBER',41,'MEMBER',42,'BROTHERS','唐坤与三弟唐泰','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(75,3,'MEMBER',41,'MEMBER',47,'GRANDPARENT','唐坤与收养孙女唐雪见','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(76,3,'MEMBER',41,'MEMBER',49,'GRANDPARENT','唐坤与外孙女唐芷芸','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(77,3,'MEMBER',41,'MEMBER',50,'GRANDPARENT','唐坤与侄孙唐恒','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(78,3,'MEMBER',41,'MEMBER',46,'BROTHERS','唐坤与族弟唐奉','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(79,3,'MEMBER',41,'MEMBER',48,'CLOSE_FRIEND','唐坤与忘年交景天，临终托付雪见','ACTIVE','admin','2026-09-17 15:14:53','gz','2026-09-17 15:58:15',1),(80,3,'MEMBER',43,'MEMBER',47,'FATHER_DAUGHTER','养父唐丰与雪见（名义）','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(81,3,'MEMBER',43,'MEMBER',45,'BROTHER_SISTER','唐丰与妹妹唐若兰','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(82,3,'MEMBER',45,'MEMBER',44,'SISTER_BROTHER','唐若兰与弟弟唐益','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(83,3,'MEMBER',45,'MEMBER',49,'MOTHER_DAUGHTER','唐若兰与女儿唐芷芸','ACTIVE','admin','2026-09-17 15:14:53','gz','2026-09-17 15:25:42',1),(84,3,'MEMBER',44,'MEMBER',47,'UNCLE_NEPHEW','七叔唐益与侄女雪见','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(85,3,'MEMBER',42,'MEMBER',47,'UNCLE_NEPHEW','叔公唐泰与侄孙雪见','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(86,3,'MEMBER',50,'MEMBER',47,'COUSIN_PATERNAL','堂兄唐恒与堂妹雪见','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(87,3,'MEMBER',50,'MEMBER',51,'FATHER_DAUGHTER','唐恒与女儿唐念雪','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(88,3,'MEMBER',47,'MEMBER',51,'UNCLE_NEPHEW','堂姑雪见与侄女唐念雪','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(89,3,'MEMBER',47,'MEMBER',48,'SPOUSE','雪见与景天结为夫妻','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(90,3,'MEMBER',44,'MEMBER',41,'SWORN_ENEMY','唐益勾结霹雳堂谋害唐坤','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(91,3,'MEMBER',49,'MEMBER',47,'ENEMY','唐芷芸揭穿雪见身世，视其为敌','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(92,3,'MEMBER',46,'MEMBER',44,'ENEMY','执令长老唐奉与叛逆唐益对立','ACTIVE','admin','2026-09-17 15:14:53','admin','2026-09-17 15:14:53',0),(93,3,'MEMBER',52,'MEMBER',49,'MOTHER_DAUGHTER','','ACTIVE','gz','2026-09-17 15:25:17','gz','2026-09-17 15:25:17',0),(94,3,'MEMBER',45,'MEMBER',49,'SISTERS','','ACTIVE','gz','2026-09-17 15:26:24','gz','2026-09-17 15:41:10',1),(95,3,'MEMBER',47,'MEMBER',42,'ENEMY','???????????????','ACTIVE','admin','2026-09-17 15:30:34','admin','2026-09-17 15:31:49',1),(96,3,'MEMBER',45,'MEMBER',49,'UNCLE_NEPHEW','','ACTIVE','gz','2026-09-17 15:41:37','gz','2026-09-17 15:41:37',0),(97,3,'MEMBER',52,'MEMBER',44,'SPOUSE','','BROKEN','gz','2026-09-17 15:42:23','gz','2026-09-17 15:42:23',0);

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- 初始化完成
-- 前端登录：admin / 123456（超级管理员，全部菜单+按钮权限）
--           user  / 123456（普通用户，受限菜单）
--           gz    / 123456（普通用户，测试账号）
-- ================================================================
