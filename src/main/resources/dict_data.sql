-- ============================================
-- Geeker-Admin 字典管理数据
-- 表：sys_dict_type（字典类型）、sys_dict_data（字典数据）
-- 使用：在 geeker_admin 库中手动执行本脚本
-- ============================================

USE geeker_admin;

-- 建表（若不存在）
CREATE TABLE IF NOT EXISTS sys_dict_type (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '字典类型ID',
    name        VARCHAR(100) NOT NULL COMMENT '字典名称',
    type        VARCHAR(100) NOT NULL COMMENT '字典类型编码（唯一）',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    remark      VARCHAR(500) DEFAULT NULL COMMENT '备注',
    create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_type (type)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='字典类型表';

CREATE TABLE IF NOT EXISTS sys_dict_data (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '字典数据ID',
    dict_type   VARCHAR(100) NOT NULL COMMENT '所属字典类型编码',
    label       VARCHAR(100) NOT NULL COMMENT '字典标签',
    value       VARCHAR(100) NOT NULL COMMENT '字典键值',
    sort        INT          NOT NULL DEFAULT 1 COMMENT '显示排序',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    list_class  VARCHAR(50)  DEFAULT NULL COMMENT 'el-tag样式类型：primary/success/info/warning/danger',
    is_default  TINYINT      NOT NULL DEFAULT 0 COMMENT '是否默认：1-是 0-否',
    remark      VARCHAR(500) DEFAULT NULL COMMENT '备注',
    create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_dict_type (dict_type)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='字典数据表';

-- 清空现有字典数据
TRUNCATE TABLE sys_dict_type;
TRUNCATE TABLE sys_dict_data;

-- 插入字典类型
INSERT INTO sys_dict_type (id, name, type, status, remark) VALUES
(1, '系统状态',   'sys_status',     1, '通用启用/禁用状态，对应各管理页面的状态字段'),
(2, '用户性别',   'sys_user_sex',   1, '用户性别枚举'),
(3, '是否',       'sys_yes_no',     1, '通用是/否枚举'),
(4, '数据范围',   'sys_data_scope', 1, '账号数据权限范围，与后端 UserService.SCOPE_* 常量对应');

-- 插入字典数据
INSERT INTO sys_dict_data (dict_type, label, value, sort, status, list_class, is_default, remark) VALUES
('sys_status',     '启用',       '1', 1, 1, 'success', 1, NULL),
('sys_status',     '禁用',       '0', 2, 1, 'danger',  0, NULL),
('sys_user_sex',   '男',         '1', 1, 1, NULL,      1, NULL),
('sys_user_sex',   '女',         '2', 2, 1, NULL,      0, NULL),
('sys_user_sex',   '未知',       '0', 3, 1, NULL,      0, NULL),
('sys_yes_no',     '是',         '1', 1, 1, 'success', 1, NULL),
('sys_yes_no',     '否',         '0', 2, 1, 'danger',  0, NULL),
('sys_data_scope', '全部数据',   '1', 1, 1, NULL,      1, '对应 UserService.SCOPE_ALL'),
('sys_data_scope', '本部门',     '2', 2, 1, NULL,      0, '对应 UserService.SCOPE_DEPT'),
('sys_data_scope', '本部门及以下', '3', 3, 1, NULL,    0, '对应 UserService.SCOPE_DEPT_AND_CHILD');

-- 重置自增ID
ALTER TABLE sys_dict_type AUTO_INCREMENT = 5;
ALTER TABLE sys_dict_data AUTO_INCREMENT = 11;
