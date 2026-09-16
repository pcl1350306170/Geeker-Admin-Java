-- ============================================
-- 用户数据权限：增量脚本（在已有 geeker_admin 库上执行一次）
-- 设计说明：
--   为 sys_user 增加 data_scope 列，控制该用户在“账号管理”中可见的数据范围；
--   admin 角色始终视为全部数据，不受该字段限制。
--   需先执行 user_dept_upgrade.sql（data_scope 位于 dept_id 之后）。
--   注意：MySQL 8 的 ALTER TABLE ADD COLUMN 不支持 IF NOT EXISTS，
--   若列已存在会报错，忽略即可。
-- ============================================

USE geeker_admin;

-- ----------------------------
-- sys_user 增加数据范围字段：1-全部数据 2-本部门 3-本部门及以下
-- ----------------------------
ALTER TABLE sys_user
    ADD COLUMN data_scope TINYINT NOT NULL DEFAULT 1 COMMENT '数据范围：1-全部 2-本部门 3-本部门及以下' AFTER dept_id;
