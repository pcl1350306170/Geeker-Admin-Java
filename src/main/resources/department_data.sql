-- ============================================
-- Geeker-Admin 部门管理数据
-- 表：sys_department（树形结构，parent_id=0 为顶级部门）
-- 使用：在 geeker_admin 库中手动执行本脚本
-- ============================================

USE geeker_admin;

-- 建表（若不存在）
CREATE TABLE IF NOT EXISTS sys_department (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '部门ID',
    parent_id   BIGINT       NOT NULL DEFAULT 0 COMMENT '上级部门ID，0为顶级',
    name        VARCHAR(50)  NOT NULL COMMENT '部门名称',
    code        VARCHAR(50)  DEFAULT NULL COMMENT '部门编码',
    leader      VARCHAR(50)  DEFAULT NULL COMMENT '负责人',
    phone       VARCHAR(20)  DEFAULT NULL COMMENT '联系电话',
    email       VARCHAR(50)  DEFAULT NULL COMMENT '邮箱',
    sort        INT          NOT NULL DEFAULT 1 COMMENT '显示排序',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    KEY idx_parent_id (parent_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='部门表';

-- 清空现有部门数据
TRUNCATE TABLE sys_department;

-- 插入部门数据
INSERT INTO sys_department (id, parent_id, name, code, leader, phone, email, sort, status) VALUES
(1, 0, '总公司',   'HQ',       '张三', '13800000000', 'hq@geeker.com',     1, 1),
(2, 1, '研发部',   'RD',       '李四', '13800000001', 'rd@geeker.com',     1, 1),
(3, 1, '市场部',   'MARKET',   '王五', '13800000002', 'market@geeker.com', 2, 1),
(4, 1, '财务部',   'FINANCE',  '赵六', '13800000003', 'finance@geeker.com',3, 1),
(5, 2, '前端组',   'RD_FE',    '孙七', '13800000004', 'fe@geeker.com',     1, 1),
(6, 2, '后端组',   'RD_BE',    '周八', '13800000005', 'be@geeker.com',     2, 1),
(7, 2, '测试组',   'RD_QA',    '吴九', '13800000006', 'qa@geeker.com',     3, 0);
