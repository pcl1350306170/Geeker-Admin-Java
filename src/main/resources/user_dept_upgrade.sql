-- ============================================
-- 用户关联部门：增量脚本（在已有 geeker_admin 库上执行一次）
-- 设计说明：
--   为 sys_user 增加 dept_id 列，关联 sys_department.id；
--   需先执行 department_data.sql 创建 sys_department 表。
--   注意：MySQL 8 的 ALTER TABLE ADD COLUMN 不支持 IF NOT EXISTS，
--   若列已存在会报错，忽略即可。
-- ============================================

USE geeker_admin;

-- ----------------------------
-- sys_user 增加所属部门字段
-- ----------------------------
ALTER TABLE sys_user
    ADD COLUMN dept_id BIGINT DEFAULT NULL COMMENT '所属部门ID（关联 sys_department.id）' AFTER `role`;

-- ----------------------------
-- 可选：为已有账号设置示例部门（按需修改用户名与部门ID）
-- 部门ID参考 department_data.sql：1-总公司 2-研发部 3-市场部 4-财务部 5-前端组 6-后端组 7-测试组
-- ----------------------------
-- UPDATE sys_user SET dept_id = 1 WHERE username = 'admin';
