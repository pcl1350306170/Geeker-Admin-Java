-- ============================================
-- 个人开发资产库 V1.0 建表脚本
-- 表前缀：dev_asset（独立命名空间，不影响现有表）
-- ============================================

USE geeker_admin;

-- ----------------------------
-- 资产主表
-- ----------------------------
DROP TABLE IF EXISTS dev_asset;
CREATE TABLE dev_asset (
    id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '资产ID',
    title         VARCHAR(200) NOT NULL COMMENT '标题',
    type          VARCHAR(20)  NOT NULL COMMENT '类型：CODE/SOLUTION/TROUBLESHOOTING/PROCEDURE/SNIPPET',
    description   VARCHAR(500) DEFAULT NULL COMMENT '简介（搜索结果摘要）',
    content       LONGTEXT     COMMENT '正文（Markdown）',
    language      VARCHAR(30)  DEFAULT NULL COMMENT '代码语言（非代码类型为空）',
    tags          VARCHAR(500) DEFAULT NULL COMMENT '标签（JSON 数组字符串）',
    is_favorite   TINYINT      NOT NULL DEFAULT 0 COMMENT '是否收藏：0否 1是',
    usage_count   INT          NOT NULL DEFAULT 0 COMMENT '使用次数（复制一次 +1）',
    parent_id     BIGINT       DEFAULT NULL COMMENT '来源资产ID（基于旧资产创建）',
    created_by    VARCHAR(50)  DEFAULT NULL COMMENT '创建人用户名',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by    VARCHAR(50)  DEFAULT NULL COMMENT '更新人用户名',
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted       TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否 1是',
    PRIMARY KEY (id),
    KEY idx_da_type (type),
    KEY idx_da_favorite (is_favorite),
    KEY idx_da_deleted (deleted),
    KEY idx_da_usage_count (usage_count),
    KEY idx_da_updated_at (updated_at),
    KEY idx_da_parent_id (parent_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '开发资产库-资产主表';

-- ----------------------------
-- 资产使用记录表
-- ----------------------------
DROP TABLE IF EXISTS dev_asset_usage;
CREATE TABLE dev_asset_usage (
    id         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    asset_id   BIGINT      NOT NULL COMMENT '资产ID',
    action     VARCHAR(10) NOT NULL COMMENT '动作：VIEW/COPY',
    created_by VARCHAR(50) DEFAULT NULL COMMENT '操作人用户名',
    created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    PRIMARY KEY (id),
    KEY idx_dau_asset_id (asset_id),
    KEY idx_dau_created_at (created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '开发资产库-使用记录表';

-- ----------------------------
-- 资产关联表（相关资产，V1 简单关联）
-- ----------------------------
DROP TABLE IF EXISTS dev_asset_relation;
CREATE TABLE dev_asset_relation (
    id        BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    asset_id  BIGINT NOT NULL COMMENT '资产ID',
    relate_id BIGINT NOT NULL COMMENT '关联资产ID',
    PRIMARY KEY (id),
    UNIQUE KEY uk_dar_pair (asset_id, relate_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '开发资产库-资产关联表';

-- ============================================
-- 开发资产库菜单数据（接入现有动态菜单体系）
-- sys_menu 现有数据 ID 到 71，AUTO_INCREMENT 已重置为 72
-- ============================================
INSERT INTO sys_menu (id, parent_id, path, name, component, redirect, icon, title, is_link, is_hide, is_full, is_affix, is_keep_alive, active_menu, sort, status, roles) VALUES
(100, 0,    '/devAssets',              'devAssets',        '',                          '/devAssets/index', 'FolderOpened', '开发资产库', '', 0, 0, 0, 1, '', 14, 1, 'admin,user'),
(101, 100,  '/devAssets/index',        'devAssetsIndex',   '/devAssets/index',          '',                 'Search',       '资产首页',   '', 0, 0, 0, 1, '', 1, 1, 'admin,user'),
(102, 100,  '/devAssets/list',         'devAssetsList',    '/devAssets/list',           '',                 'Files',        '全部资产',   '', 0, 0, 0, 1, '', 2, 1, 'admin,user'),
(103, 100,  '/devAssets/favorite',     'devAssetsFavorite','/devAssets/favorite',       '',                 'Star',         '我的收藏',   '', 0, 0, 0, 1, '', 3, 1, 'admin,user'),
(104, 100,  '/devAssets/detail/:id',   'devAssetsDetail',  '/devAssets/detail',         '',                 'Menu',         '资产详情',   '', 1, 0, 0, 1, '/devAssets/list', 4, 1, 'admin,user'),
(105, 100,  '/devAssets/create',       'devAssetsCreate',  '/devAssets/edit',           '',                 'Menu',         '新增资产',   '', 1, 0, 0, 1, '/devAssets/list', 5, 1, 'admin,user'),
(106, 100,  '/devAssets/edit/:id',     'devAssetsEdit',    '/devAssets/edit',           '',                 'Menu',         '编辑资产',   '', 1, 0, 0, 1, '/devAssets/list', 6, 1, 'admin,user');

-- ============================================
-- 示例数据（可用于搜索验收，不需要可删除）
-- ============================================
INSERT INTO dev_asset (title, type, description, content, language, tags, created_by) VALUES
('CSS 多行文字省略', 'SNIPPET', '多行文本超出后显示省略号的 CSS 方案',
 '## 多行文字省略\n\n```css\ndisplay: -webkit-box;\n-webkit-line-clamp: 2;\n-webkit-box-orient: vertical;\noverflow: hidden;\n```\n\n> 修改 `-webkit-line-clamp` 的值即可控制显示行数。',
 'css', '["CSS","小技巧"]', 'admin'),
('Vue3 Sortable.js 基础拖拽排序方案', 'SOLUTION', 'Vue3 中使用 Sortable.js 实现列表拖拽排序的基础方案',
 '## 需求背景\n\n列表需要支持拖拽排序。\n\n## 核心代码\n\n```javascript\nimport Sortable from "sortablejs";\nimport { onMounted, ref } from "vue";\n\nconst listRef = ref(null);\n\nonMounted(() => {\n  new Sortable(listRef.value, {\n    animation: 150,\n    onEnd(evt) {\n      console.log(evt.oldIndex, evt.newIndex);\n    }\n  });\n});\n```\n\n## 注意事项\n\n- 需要在 DOM 渲染完成后再初始化\n- 数据源顺序需要同步更新',
 'javascript', '["Vue3","Sortable","拖拽"]', 'admin'),
('ArkTS @Entry 组件只能有一个 root node', 'TROUBLESHOOTING', 'In an @Entry decorated component, the build method can have only one root node',
 '## 问题\n\n```\nIn an @Entry decorated component, the build method can have only one root node\n```\n\n## 原因\n\n@Entry 装饰的组件 build 方法只允许一个根节点。\n\n## 解决方案\n\n用单个容器（Column / Row / Stack）包裹所有子组件。\n\n## 注意事项\n\n非 @Entry 组件不受此限制。',
 '', '["ArkTS","HarmonyOS","踩坑"]', 'admin');
