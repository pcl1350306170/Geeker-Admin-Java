-- =============================================
-- 角色管理（轻量方案）数据库变更
-- 执行方式: source D:/CODE/Java/Geeker-Admin-Java/src/main/resources/role_data.sql
-- =============================================
USE geeker_admin;

-- 1. sys_user 增加角色编码字段
ALTER TABLE sys_user ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'user' COMMENT '角色编码(admin-超级管理员/user-普通用户)';
UPDATE sys_user SET role = 'admin' WHERE username = 'admin';

-- 2. sys_menu 增加可见角色字段（逗号分隔的角色编码，默认所有角色可见）
ALTER TABLE sys_menu ADD COLUMN roles VARCHAR(100) NOT NULL DEFAULT 'admin,user' COMMENT '可查看该菜单的角色编码(逗号分隔)';
