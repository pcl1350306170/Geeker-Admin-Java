-- ============================================
-- 个人开发资产库：标签管理增量脚本（在已有 dev_asset 库上执行）
-- 设计说明：
--   dev_asset_tag 只是"标签字典表"，维护有哪些标签名可选；
--   资产的标签仍保存在 dev_asset.tags（JSON 数组），搜索路径完全不变。
-- ============================================

USE geeker_admin;

-- ----------------------------
-- 标签字典表
-- ----------------------------
CREATE TABLE IF NOT EXISTS dev_asset_tag (
    id         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '标签ID',
    name       VARCHAR(50) NOT NULL COMMENT '标签名',
    sort       INT         NOT NULL DEFAULT 0 COMMENT '排序（越大越靠前）',
    created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_dat_name (name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '开发资产库-标签字典表';

-- ----------------------------
-- 菜单：标签管理（挂在开发资产库下，ID 107）
-- ----------------------------
INSERT INTO sys_menu (id, parent_id, path, name, component, redirect, icon, title, is_link, is_hide, is_full, is_affix, is_keep_alive, active_menu, sort, status, roles) VALUES
(107, 100, '/devAssets/tags', 'devAssetsTags', '/devAssets/tags', '', 'PriceTag', '标签管理', '', 0, 0, 0, 1, '', 7, 1, 'admin,user');

-- ----------------------------
-- 初始标签：现有资产中已使用的标签 + 常用建议标签
-- ----------------------------
INSERT IGNORE INTO dev_asset_tag (name, sort) VALUES
('CSS', 0), ('小技巧', 0),
('Vue3', 0), ('Sortable', 0), ('拖拽', 0),
('ArkTS', 0), ('HarmonyOS', 0), ('踩坑', 0),
('Vue2', 0), ('JavaScript', 0), ('TypeScript', 0), ('SCSS', 0),
('Git', 0), ('Node', 0), ('Linux', 0), ('Docker', 0);
