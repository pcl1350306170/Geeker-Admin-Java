-- ============================================
-- 小说家族管理：建表 + 字典 + 菜单脚本
-- 表：novel_family（家族）、novel_family_member（成员）、novel_relation（关系）
-- 字典：novel_family_type / novel_family_status / novel_member_role / novel_relation_type
-- 菜单：小说家族（顶级）-> 家族管理 / 成员管理 / 关系图谱
-- 使用：在 geeker_admin 库中手动执行本脚本（可重复执行，幂等）
-- ============================================

USE geeker_admin;

-- ==================== 1. 建表 ====================

CREATE TABLE IF NOT EXISTS novel_family (
    id           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '家族ID',
    name         VARCHAR(100) NOT NULL COMMENT '家族名称',
    alias        VARCHAR(200) DEFAULT NULL COMMENT '别称/称号',
    type         VARCHAR(50)  DEFAULT NULL COMMENT '家族类型（字典 novel_family_type）',
    status       VARCHAR(50)  DEFAULT NULL COMMENT '势力地位（字典 novel_family_status）',
    introduction VARCHAR(1000) DEFAULT NULL COMMENT '简介',
    background   TEXT         DEFAULT NULL COMMENT '背景故事（Markdown）',
    creed        VARCHAR(500) DEFAULT NULL COMMENT '家训/祖训',
    territory    VARCHAR(200) DEFAULT NULL COMMENT '势力范围/封地',
    emblem       VARCHAR(500) DEFAULT NULL COMMENT '族徽图URL',
    cover        VARCHAR(500) DEFAULT NULL COMMENT '封面图URL',
    sort         INT          NOT NULL DEFAULT 0 COMMENT '排序',
    created_by   VARCHAR(64)  DEFAULT NULL COMMENT '创建人',
    created_at   DATETIME     DEFAULT NULL COMMENT '创建时间',
    updated_by   VARCHAR(64)  DEFAULT NULL COMMENT '更新人',
    updated_at   DATETIME     DEFAULT NULL COMMENT '更新时间',
    deleted      TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常 1-删除',
    PRIMARY KEY (id),
    KEY idx_family_name (name),
    KEY idx_family_type (type),
    KEY idx_family_status (status)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '小说家族表';

CREATE TABLE IF NOT EXISTS novel_family_member (
    id           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '成员ID',
    family_id    BIGINT       NOT NULL COMMENT '所属家族ID',
    name         VARCHAR(100) NOT NULL COMMENT '姓名',
    alias        VARCHAR(200) DEFAULT NULL COMMENT '字/号/别称',
    gender       VARCHAR(10)  DEFAULT NULL COMMENT '性别（字典 sys_user_sex）',
    generation   VARCHAR(50)  DEFAULT NULL COMMENT '辈分',
    title        VARCHAR(100) DEFAULT NULL COMMENT '身份/头衔',
    role_type    VARCHAR(50)  DEFAULT NULL COMMENT '角色定位（字典 novel_member_role）',
    age          INT          DEFAULT NULL COMMENT '年龄',
    personality  VARCHAR(500) DEFAULT NULL COMMENT '性格标签（JSON 数组字符串）',
    appearance   VARCHAR(1000) DEFAULT NULL COMMENT '外貌描述',
    bio          TEXT         DEFAULT NULL COMMENT '人物小传',
    is_head      TINYINT      NOT NULL DEFAULT 0 COMMENT '是否家主：1-是 0-否',
    is_core      TINYINT      NOT NULL DEFAULT 0 COMMENT '是否核心角色：1-是 0-否',
    sort         INT          NOT NULL DEFAULT 0 COMMENT '排序',
    created_by   VARCHAR(64)  DEFAULT NULL COMMENT '创建人',
    created_at   DATETIME     DEFAULT NULL COMMENT '创建时间',
    updated_by   VARCHAR(64)  DEFAULT NULL COMMENT '更新人',
    updated_at   DATETIME     DEFAULT NULL COMMENT '更新时间',
    deleted      TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常 1-删除',
    PRIMARY KEY (id),
    KEY idx_member_family (family_id),
    KEY idx_member_name (name),
    KEY idx_member_role (role_type)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '小说家族成员表';

CREATE TABLE IF NOT EXISTS novel_relation (
    id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '关系ID',
    source_type   VARCHAR(20)  NOT NULL COMMENT '发起端类型：MEMBER-成员 FAMILY-家族',
    source_id     BIGINT       NOT NULL COMMENT '发起端ID',
    target_type   VARCHAR(20)  NOT NULL COMMENT '接收端类型：MEMBER-成员 FAMILY-家族',
    target_id     BIGINT       NOT NULL COMMENT '接收端ID',
    relation_type VARCHAR(50)  NOT NULL COMMENT '关系类型（字典 novel_relation_type）',
    description   VARCHAR(1000) DEFAULT NULL COMMENT '补充描述',
    status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT '关系状态：ACTIVE-存续 BROKEN-破裂',
    created_by    VARCHAR(64)  DEFAULT NULL COMMENT '创建人',
    created_at    DATETIME     DEFAULT NULL COMMENT '创建时间',
    updated_by    VARCHAR(64)  DEFAULT NULL COMMENT '更新人',
    updated_at    DATETIME     DEFAULT NULL COMMENT '更新时间',
    deleted       TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常 1-删除',
    PRIMARY KEY (id),
    UNIQUE KEY uk_relation (source_type, source_id, target_type, target_id, relation_type),
    KEY idx_relation_source (source_type, source_id),
    KEY idx_relation_target (target_type, target_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '小说关系表（成员间/家族间）';

-- ==================== 2. 字典数据（幂等：先删后插） ====================

DELETE FROM sys_dict_data WHERE dict_type IN ('novel_family_type', 'novel_family_status', 'novel_member_role', 'novel_relation_type');
DELETE FROM sys_dict_type WHERE type IN ('novel_family_type', 'novel_family_status', 'novel_member_role', 'novel_relation_type');

INSERT INTO sys_dict_type (name, type, status, remark) VALUES
('家族类型',   'novel_family_type',   1, '小说家族管理-家族类型枚举'),
('势力地位',   'novel_family_status', 1, '小说家族管理-家族势力地位'),
('角色定位',   'novel_member_role',   1, '小说家族管理-成员角色定位'),
('关系类型',   'novel_relation_type', 1, '小说家族管理-成员间/家族间关系类型');

INSERT INTO sys_dict_data (dict_type, label, value, sort, status, list_class, is_default, remark) VALUES
-- 家族类型
('novel_family_type', '皇族', 'ROYAL',  1, 1, 'danger',  0, NULL),
('novel_family_type', '世家', 'NOBLE',  2, 1, 'primary', 1, NULL),
('novel_family_type', '宗门', 'SECT',   3, 1, 'success', 0, NULL),
('novel_family_type', '官宦', 'OFFICIAL', 4, 1, 'warning', 0, NULL),
('novel_family_type', '商贾', 'MERCHANT', 5, 1, 'info',    0, NULL),
('novel_family_type', '隐世', 'HERMIT', 6, 1, 'info',    0, NULL),
('novel_family_type', '魔道', 'DEMONIC', 7, 1, 'danger',  0, NULL),
('novel_family_type', '其他', 'OTHER',  8, 1, 'info',    0, NULL),
-- 势力地位
('novel_family_status', '一流', 'TOP',    1, 1, 'danger',  0, NULL),
('novel_family_status', '二流', 'SECOND', 2, 1, 'warning', 0, NULL),
('novel_family_status', '三流', 'THIRD',  3, 1, 'primary', 0, NULL),
('novel_family_status', '末流', 'WEAK',   4, 1, 'info',    0, NULL),
('novel_family_status', '新兴', 'RISING', 5, 1, 'success', 0, NULL),
('novel_family_status', '没落', 'DECLINING', 6, 1, 'info',   0, NULL),
-- 角色定位
('novel_member_role', '主角',     'PROTAGONIST', 1, 1, 'danger',  0, NULL),
('novel_member_role', '重要配角', 'MAJOR_SUPPORT', 2, 1, 'warning', 0, NULL),
('novel_member_role', '普通配角', 'MINOR_SUPPORT', 3, 1, 'primary', 1, NULL),
('novel_member_role', '龙套',     'EXTRA',       4, 1, 'info',    0, NULL),
-- 关系类型（血缘 / 婚姻 / 情义 / 立场）
('novel_relation_type', '父子',   'FATHER_SON',   1, 1, 'primary', 0, '血缘'),
('novel_relation_type', '母子',   'MOTHER_SON',   2, 1, 'primary', 0, '血缘'),
('novel_relation_type', '父女',   'FATHER_DAUGHTER', 3, 1, 'primary', 0, '血缘'),
('novel_relation_type', '母女',   'MOTHER_DAUGHTER', 4, 1, 'primary', 0, '血缘'),
('novel_relation_type', '兄弟',   'BROTHERS',     5, 1, 'primary', 0, '血缘'),
('novel_relation_type', '姐妹',   'SISTERS',      6, 1, 'primary', 0, '血缘'),
('novel_relation_type', '兄妹',   'BROTHER_SISTER', 7, 1, 'primary', 0, '血缘'),
('novel_relation_type', '姐弟',   'SISTER_BROTHER', 8, 1, 'primary', 0, '血缘'),
('novel_relation_type', '祖孙',   'GRANDPARENT',  9, 1, 'primary', 0, '血缘'),
('novel_relation_type', '叔侄',   'UNCLE_NEPHEW', 10, 1, 'primary', 0, '血缘'),
('novel_relation_type', '堂亲',   'COUSIN_PATERNAL', 11, 1, 'primary', 0, '血缘'),
('novel_relation_type', '表亲',   'COUSIN_MATERNAL', 12, 1, 'primary', 0, '血缘'),
('novel_relation_type', '夫妻',   'SPOUSE',       13, 1, 'danger',  0, '婚姻'),
('novel_relation_type', '未婚夫妻', 'ENGAGED',     14, 1, 'danger',  0, '婚姻'),
('novel_relation_type', '前夫妻',  'EX_SPOUSE',    15, 1, 'info',    0, '婚姻'),
('novel_relation_type', '恋人',   'LOVER',        16, 1, 'danger',  0, '情义'),
('novel_relation_type', '师徒',   'MASTER_APPRENTICE', 17, 1, 'warning', 0, '情义'),
('novel_relation_type', '同门',   'FELLOW',       18, 1, 'warning', 0, '情义'),
('novel_relation_type', '主仆',   'MASTER_SERVANT', 19, 1, 'info',    0, '情义'),
('novel_relation_type', '君臣',   'SOVEREIGN_MINISTER', 20, 1, 'warning', 0, '情义'),
('novel_relation_type', '挚友',   'CLOSE_FRIEND', 21, 1, 'success', 0, '情义'),
('novel_relation_type', '恩人',   'BENEFACTOR',   22, 1, 'success', 0, '情义'),
('novel_relation_type', '盟友',   'ALLY',         23, 1, 'success', 0, '立场'),
('novel_relation_type', '敌对',   'ENEMY',        24, 1, 'danger',  0, '立场'),
('novel_relation_type', '联姻',   'MARRIAGE_ALLIANCE', 25, 1, 'danger', 0, '立场'),
('novel_relation_type', '依附',   'DEPENDENT',    26, 1, 'info',    0, '立场'),
('novel_relation_type', '仇敌',   'SWORN_ENEMY',  27, 1, 'danger',  0, '立场');

-- ==================== 3. 菜单数据（幂等：先删后插） ====================

DELETE FROM sys_menu WHERE path IN ('/novelFamily', '/novelFamily/family', '/novelFamily/member', '/novelFamily/graph');

INSERT INTO sys_menu (parent_id, path, name, component, redirect, icon, title, is_link, is_hide, is_full, is_affix, is_keep_alive, active_menu, sort, status, roles)
VALUES (0, '/novelFamily', 'novelFamily', '', '/novelFamily/family', 'Collection', '小说家族', '', 0, 0, 0, 1, '', 13, 1, 'admin,user');

SET @novel_family_parent_id = LAST_INSERT_ID();

INSERT INTO sys_menu (parent_id, path, name, component, redirect, icon, title, is_link, is_hide, is_full, is_affix, is_keep_alive, active_menu, sort, status, roles)
VALUES
(@novel_family_parent_id, '/novelFamily/family',  'novelFamilyFamily',  '/novelFamily/family/index',  '', 'Menu', '家族管理', '', 0, 0, 0, 1, '', 1, 1, 'admin,user'),
(@novel_family_parent_id, '/novelFamily/member',  'novelFamilyMember',  '/novelFamily/member/index',  '', 'Menu', '成员管理', '', 0, 0, 0, 1, '', 2, 1, 'admin,user'),
(@novel_family_parent_id, '/novelFamily/graph',   'novelFamilyGraph',   '/novelFamily/graph/index',   '', 'Menu', '关系图谱', '', 0, 0, 0, 1, '', 3, 1, 'admin,user');
