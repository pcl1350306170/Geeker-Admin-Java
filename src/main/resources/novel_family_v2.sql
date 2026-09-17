-- ============================================================
-- 小说家族管理 v2：新增"所属小说"层级
-- 1. 新建 novel 小说表
-- 2. novel_family / novel_family_member / novel_relation 增加 novel_id
-- 3. 菜单新增"小说管理"子菜单
-- 幂等：可重复执行
-- ============================================================

-- 1. 小说表
CREATE TABLE IF NOT EXISTS novel (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '小说ID',
  name VARCHAR(100) NOT NULL COMMENT '小说名称',
  alias VARCHAR(200) DEFAULT NULL COMMENT '别名',
  author VARCHAR(100) DEFAULT NULL COMMENT '作者',
  introduction VARCHAR(1000) DEFAULT NULL COMMENT '简介',
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE-连载/完结 DISABLED-停用',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序',
  created_by VARCHAR(64) DEFAULT NULL,
  created_at DATETIME DEFAULT NULL,
  updated_by VARCHAR(64) DEFAULT NULL,
  updated_at DATETIME DEFAULT NULL,
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常 1-已删除',
  PRIMARY KEY (id),
  KEY idx_novel_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小说';

-- 2. 业务表增加 novel_id（幂等：列不存在时才添加）
SET @fam = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'geeker_admin' AND TABLE_NAME = 'novel_family' AND COLUMN_NAME = 'novel_id');
SET @sql = IF(@fam = 0, 'ALTER TABLE novel_family ADD COLUMN novel_id BIGINT NOT NULL DEFAULT 0 COMMENT ''所属小说ID'' AFTER id, ADD KEY idx_family_novel (novel_id)', 'SELECT 1');
PREPARE s1 FROM @sql; EXECUTE s1; DEALLOCATE PREPARE s1;

SET @mem = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'geeker_admin' AND TABLE_NAME = 'novel_family_member' AND COLUMN_NAME = 'novel_id');
SET @sql = IF(@mem = 0, 'ALTER TABLE novel_family_member ADD COLUMN novel_id BIGINT NOT NULL DEFAULT 0 COMMENT ''所属小说ID'' AFTER family_id, ADD KEY idx_member_novel (novel_id)', 'SELECT 1');
PREPARE s2 FROM @sql; EXECUTE s2; DEALLOCATE PREPARE s2;

SET @rel = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'geeker_admin' AND TABLE_NAME = 'novel_relation' AND COLUMN_NAME = 'novel_id');
SET @sql = IF(@rel = 0, 'ALTER TABLE novel_relation ADD COLUMN novel_id BIGINT NOT NULL DEFAULT 0 COMMENT ''所属小说ID'' AFTER id, ADD KEY idx_relation_novel (novel_id)', 'SELECT 1');
PREPARE s3 FROM @sql; EXECUTE s3; DEALLOCATE PREPARE s3;

-- 3. 菜单：小说管理（置于家族管理之前）
INSERT INTO sys_menu (id, parent_id, path, name, component, redirect, icon, title, is_link, is_hide, is_full, is_affix, is_keep_alive, active_menu, sort, status, create_time, update_time, roles)
VALUES (113, 109, '/novelFamily/novel', 'novelFamilyNovel', '/novelFamily/novel/index', '', 'Notebook', '小说管理', '', 0, 0, 0, 1, '', 0, 1, NOW(), NOW(), 'admin,user')
ON DUPLICATE KEY UPDATE title = VALUES(title), sort = VALUES(sort), status = VALUES(status), component = VALUES(component), roles = VALUES(roles);
