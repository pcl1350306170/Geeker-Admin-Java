-- ============================================
-- 「订单预览」菜单迁移脚本（用于已初始化的现有库）
-- 作用：在「开发资产库」父菜单下新增「订单预览」菜单
-- 说明：dev_asset.sql 已包含该菜单（全新安装无需执行本脚本）；
--       现有库执行本脚本即可，可重复执行（幂等）。
-- ============================================

USE geeker_admin;

-- 取「开发资产库」父菜单 ID（默认种子数据为 100）
SET @parent_id = (SELECT id FROM sys_menu WHERE path = '/devAssets' LIMIT 1);

-- 幂等：先按 path 删除旧记录，再插入
DELETE FROM sys_menu WHERE path = '/devAssets/orderPreview';

INSERT INTO sys_menu
    (parent_id, path, name, component, redirect, icon, title,
     is_link, is_hide, is_full, is_affix, is_keep_alive, active_menu, sort, status, roles)
VALUES
    (@parent_id, '/devAssets/orderPreview', 'devAssetsOrderPreview', '/devAssets/orderPreview', '', 'Picture', '订单预览',
     '', 0, 0, 0, 1, '', 8, 1, 'admin,user');
