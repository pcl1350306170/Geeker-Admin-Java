-- ============================================================
-- 红楼梦测试数据挂载到"小说"维度
-- 幂等：可重复执行
-- ============================================================

INSERT INTO novel (id, name, alias, author, introduction, status, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES (1, '红楼梦', '石头记', '曹雪芹', '中国古典四大名著之首，以贾史王薛四大家族由盛而衰为线索，展现封建家族的人情百态与命运沉浮。', 'ACTIVE', 1, 'admin', NOW(), 'admin', NOW(), 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), alias = VALUES(alias), author = VALUES(author), introduction = VALUES(introduction), deleted = 0;

UPDATE novel_family SET novel_id = 1 WHERE deleted = 0 AND novel_id = 0;
UPDATE novel_family_member SET novel_id = 1 WHERE deleted = 0 AND novel_id = 0;
UPDATE novel_relation SET novel_id = 1 WHERE deleted = 0 AND novel_id = 0;
