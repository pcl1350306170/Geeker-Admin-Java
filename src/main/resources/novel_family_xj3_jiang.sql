-- ============================================================
-- 仙剑三同人 · 姜国龙家 测试数据（景天前世家族）
-- 第一代：姜皇 + 王后陶虹 + 贤妃蒋欣 / 德妃唐嫣 / 丽妃刘诗诗
-- 第二代：太子龙阳（景天前世，陶虹生）、公主龙葵（陶虹生）
-- 幂等：可重复执行（先逻辑删除本脚本数据域再 upsert）
-- ============================================================

-- 1) 清理本脚本数据域（幂等）
UPDATE novel_relation SET deleted = 1 WHERE novel_id = 3 AND id BETWEEN 169 AND 177;
UPDATE novel_family_member SET deleted = 1 WHERE novel_id = 3 AND id BETWEEN 115 AND 121;
UPDATE novel_family SET deleted = 1 WHERE novel_id = 3 AND id = 9;

-- 2) 新增家族：姜国龙家
INSERT INTO novel_family (id, novel_id, name, alias, type, status, introduction, sort, created_by, created_at, updated_by, updated_at, deleted) VALUES
(9, 3, '姜国龙家', '姜国', 'ROYAL', 'DECLINING', '景天前世姜国王族。姜皇与王后陶虹之子龙阳即景天前世，女龙葵。姜国遭杨国兵祸，国灭族亡，唯余兄妹二人（龙阳战死、龙葵以身祭剑魂寄魔剑）。', 30, 'admin', NOW(), 'admin', NOW(), 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), alias = VALUES(alias), type = VALUES(type), status = VALUES(status), introduction = VALUES(introduction), sort = VALUES(sort), deleted = 0;

-- 3) 新增成员（7 人）
INSERT INTO novel_family_member (id, novel_id, family_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted) VALUES
(115, 3, 9, '姜皇', NULL, 'M', 'G1', '姜国君主', 'MAJOR_SUPPORT', 55, '威严持重，忧国忧民', '龙眉凤目，帝服加身', '姜国君主，龙阳、龙葵之父。姜国兵败杨国时身死，临终将复国遗愿托付太子龙阳。', 1, 1, 1, 'admin', NOW(), 'admin', NOW(), 0),
(116, 3, 9, '陶虹', NULL, 'F', 'G1', '姜国王后', 'MAJOR_SUPPORT', 50, '温婉贤淑，护子如命', '仪态端庄，眉目含慈', '姜国王后，龙阳（景天前世）、龙葵之生母。国破时为护子女甘愿赴死，是龙阳心中最深的牵挂。', 0, 1, 2, 'admin', NOW(), 'admin', NOW(), 0),
(117, 3, 9, '蒋欣', NULL, 'F', 'G1', '贤妃', 'MINOR_SUPPORT', 45, '端庄持重，明理知礼', '气质清雅，言行有度', '姜皇贤妃，与王后陶虹同处后宫，育有皇子前早逝，于龙阳、龙葵视如己出。', 0, 0, 3, 'admin', NOW(), 'admin', NOW(), 0),
(118, 3, 9, '唐嫣', NULL, 'F', 'G1', '德妃', 'MINOR_SUPPORT', 44, '聪慧机敏，善解人意', '眉目含情，笑靥如花', '姜皇德妃，擅长音律，常伴君侧，姜国覆灭后下落不明。', 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0),
(119, 3, 9, '刘诗诗', NULL, 'F', 'G1', '丽妃', 'MINOR_SUPPORT', 42, '温婉淡雅，不争不抢', '清丽脱俗，气质出尘', '姜皇丽妃，为人淡泊，喜好丹青，与龙葵情同母女。', 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0),
(120, 3, 9, '龙阳', '景天前世', 'M', 'G2', '姜国太子', 'PROTAGONIST', 24, '坚毅果敢，重情重义', '英姿勃发，眉眼与景天有七八分相似', '姜国太子，王后陶虹之子，龙葵之兄。姜国灭国后承先父遗志试图复国，最终战死，转世为景天。', 0, 1, 6, 'admin', NOW(), 'admin', NOW(), 0),
(121, 3, 9, '龙葵', NULL, 'F', 'G2', '姜国公主', 'MAJOR_SUPPORT', 18, '温柔执拗，爱兄至深', '楚楚可怜，眉目如画', '姜国公主，龙阳之妹。国破后为助兄长以身祭剑，魂魄寄于魔剑千年，后被景天（龙阳转世）自剑中唤醒。', 0, 0, 7, 'admin', NOW(), 'admin', NOW(), 0)
ON DUPLICATE KEY UPDATE family_id = VALUES(family_id), name = VALUES(name), alias = VALUES(alias), gender = VALUES(gender), generation = VALUES(generation), title = VALUES(title), role_type = VALUES(role_type), age = VALUES(age), personality = VALUES(personality), appearance = VALUES(appearance), bio = VALUES(bio), is_head = VALUES(is_head), is_core = VALUES(is_core), sort = VALUES(sort), deleted = 0;

-- 4) 新增关系（9 条：夫妻/妃嫔 4 + 父子/母子 4 + 兄妹 1）
INSERT INTO novel_relation (id, novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted) VALUES
(169, 3, 'MEMBER', 115, 'MEMBER', 116, 'SPOUSE', '姜皇与王后陶虹（结发夫妻）', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(170, 3, 'MEMBER', 115, 'MEMBER', 117, 'SPOUSE', '姜皇与贤妃蒋欣', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(171, 3, 'MEMBER', 115, 'MEMBER', 118, 'SPOUSE', '姜皇与德妃唐嫣', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(172, 3, 'MEMBER', 115, 'MEMBER', 119, 'SPOUSE', '姜皇与丽妃刘诗诗', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(173, 3, 'MEMBER', 115, 'MEMBER', 120, 'FATHER_SON', '姜皇与太子龙阳', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(174, 3, 'MEMBER', 115, 'MEMBER', 121, 'FATHER_DAUGHTER', '姜皇与公主龙葵', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(175, 3, 'MEMBER', 116, 'MEMBER', 120, 'MOTHER_SON', '王后陶虹与龙阳（生母）', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(176, 3, 'MEMBER', 116, 'MEMBER', 121, 'MOTHER_DAUGHTER', '王后陶虹与龙葵（生母）', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(177, 3, 'MEMBER', 120, 'MEMBER', 121, 'BROTHER_SISTER', '太子龙阳与公主龙葵（兄妹）', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0)
ON DUPLICATE KEY UPDATE source_type = VALUES(source_type), source_id = VALUES(source_id), target_type = VALUES(target_type), target_id = VALUES(target_id), relation_type = VALUES(relation_type), description = VALUES(description), status = VALUES(status), deleted = 0;
