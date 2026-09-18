-- ============================================================
-- 仙剑三同人 · 景家 补充测试数据（同辈族人）
-- 设计：与景逸同辈（G1）与景天同辈（G2/G3）的景家族人
--       女性 10 人 + 男性 3 人；3 名男性均配置配偶、子女关系
-- 幂等：可重复执行（先逻辑删除本脚本数据域再 upsert）
-- ============================================================

-- 1) 清理本脚本数据域（幂等）
UPDATE novel_relation SET deleted = 1 WHERE novel_id = 3 AND id BETWEEN 138 AND 160;
UPDATE novel_family_member SET deleted = 1 WHERE novel_id = 3 AND id BETWEEN 98 AND 110;

-- 2) 新增成员（13 人：男性 3 + 女性 10）
INSERT INTO novel_family_member (id, novel_id, family_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted) VALUES
(98, 3, 8, '景盛', NULL, 'M', 'G1', '永安当二管事', 'MAJOR_SUPPORT', 52, '稳重老成，精于商道', '面容方正，蓄短须，常着墨色长衫', '景逸胞兄，永安当二管事。当年与景逸共同经营当铺，为人稳妥，族中大小事务多由他张罗。', 0, 0, 38, 'admin', NOW(), 'admin', NOW(), 0),
(99, 3, 8, '景淮', NULL, 'M', 'G1', '渝州绸缎行掌柜', 'MINOR_SUPPORT', 46, '机敏圆融，爱算小账', '眉目灵活，指尖常盘算珠', '景逸胞弟，在渝州城西经营绸缎行，与永安当互通有无，精于盘算，是景家最能经商的旁支。', 0, 0, 39, 'admin', NOW(), 'admin', NOW(), 0),
(100, 3, 8, '景曜', NULL, 'M', 'G2', '渝州武馆教习', 'MINOR_SUPPORT', 24, '爽朗仗义，好打抱不平', '身材颀长，虎口有茧', '景盛之子，景天堂兄。自幼习武，在渝州开武馆授徒，与景天交情甚笃。', 0, 0, 40, 'admin', NOW(), 'admin', NOW(), 0),
(101, 3, 8, '沈青萝', NULL, 'F', 'G1', '景盛之妻', 'MINOR_SUPPORT', 50, '温厚持家', '眉目慈和，衣饰素净', '景盛之妻，景曜、景嫣之母，操持景盛一房家务，对族中小辈多有照拂。', 0, 0, 41, 'admin', NOW(), 'admin', NOW(), 0),
(102, 3, 8, '杜若', NULL, 'F', 'G1', '景淮之妻', 'MINOR_SUPPORT', 44, '精明能干', '眉眼利落，善理账目', '景淮之妻，景萝之母，协助丈夫经营绸缎行，管账是一把好手。', 0, 0, 42, 'admin', NOW(), 'admin', NOW(), 0),
(103, 3, 8, '景芙', NULL, 'F', 'G1', '景逸之姐', 'MINOR_SUPPORT', 54, '爽直豁达', '鬓角微霜，精神矍铄', '景逸之姐，早年远嫁外地，夫家变故后携女景芸回到渝州，依景家而居。', 0, 0, 43, 'admin', NOW(), 'admin', NOW(), 0),
(104, 3, 8, '景菡', NULL, 'F', 'G1', '景逸之妹', 'MINOR_SUPPORT', 42, '淡泊娴静', '气质清雅，喜着淡青', '景逸之妹，未嫁，在渝州城外经营一间药铺，常为景家采办药材。', 0, 0, 44, 'admin', NOW(), 'admin', NOW(), 0),
(105, 3, 8, '景棠', NULL, 'F', 'G1', '景逸堂姐', 'EXTRA', 56, '热心好管闲事', '体态微丰，爱穿暗红', '景逸堂姐，族中辈分最长，景家红白喜事多由她出面张罗。', 0, 0, 45, 'admin', NOW(), 'admin', NOW(), 0),
(106, 3, 8, '景嫣', NULL, 'F', 'G2', '景盛之女', 'MINOR_SUPPORT', 22, '活泼爽利', '鹅蛋脸，眉目灵动', '景盛之女，景曜之妹，景天堂姐。在家帮忙当铺账房，性子泼辣爽快。', 0, 0, 46, 'admin', NOW(), 'admin', NOW(), 0),
(107, 3, 8, '景萝', NULL, 'F', 'G2', '景淮之女', 'MINOR_SUPPORT', 19, '聪慧机灵', '柳眉杏眼，笑意盈盈', '景淮之女，景天堂妹，随父打理绸缎行，精于珠算。', 0, 0, 47, 'admin', NOW(), 'admin', NOW(), 0),
(108, 3, 8, '景薇', NULL, 'F', 'G2', '景曜之妻', 'MINOR_SUPPORT', 23, '温婉贤淑', '面容清秀，笑意温柔', '景曜之妻，景芜之母。出身渝州书香门第，嫁入景家后相夫教女。', 0, 0, 48, 'admin', NOW(), 'admin', NOW(), 0),
(109, 3, 8, '景芸', NULL, 'F', 'G2', '景芙之女', 'EXTRA', 21, '文静内向', '眉目低垂，略带羞怯', '景芙之女，景天表姐。随母寄居景家，绣工极佳，替绸缎行做绣样。', 0, 0, 49, 'admin', NOW(), 'admin', NOW(), 0),
(110, 3, 8, '景芜', NULL, 'F', 'G3', '景曜之女', 'EXTRA', 8, '天真烂漫', '扎双髻，跑跳不停', '景曜与景薇之女，景天堂侄女，景家第四代小辈，最爱缠着景天讲故事。', 0, 0, 50, 'admin', NOW(), 'admin', NOW(), 0);

-- 3) 新增关系（23 条：配偶 3 + 父子/母子 7 + 同辈 9 + 旁系 4）
INSERT INTO novel_relation (id, novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted) VALUES
(138, 3, 'MEMBER', 98, 'MEMBER', 101, 'SPOUSE', '景盛与沈青萝夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(139, 3, 'MEMBER', 99, 'MEMBER', 102, 'SPOUSE', '景淮与杜若夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(140, 3, 'MEMBER', 100, 'MEMBER', 108, 'SPOUSE', '景曜与景薇夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(141, 3, 'MEMBER', 98, 'MEMBER', 100, 'FATHER_SON', '景盛与长子景曜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(142, 3, 'MEMBER', 98, 'MEMBER', 106, 'FATHER_DAUGHTER', '景盛与女儿景嫣', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(143, 3, 'MEMBER', 99, 'MEMBER', 107, 'FATHER_DAUGHTER', '景淮与女儿景萝', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(144, 3, 'MEMBER', 100, 'MEMBER', 110, 'FATHER_DAUGHTER', '景曜与女儿景芜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(145, 3, 'MEMBER', 101, 'MEMBER', 100, 'MOTHER_SON', '沈青萝与长子景曜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(146, 3, 'MEMBER', 101, 'MEMBER', 106, 'MOTHER_DAUGHTER', '沈青萝与女儿景嫣', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(147, 3, 'MEMBER', 102, 'MEMBER', 107, 'MOTHER_DAUGHTER', '杜若与女儿景萝', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(148, 3, 'MEMBER', 108, 'MEMBER', 110, 'MOTHER_DAUGHTER', '景薇与女儿景芜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(149, 3, 'MEMBER', 61, 'MEMBER', 98, 'BROTHERS', '景逸与胞兄景盛', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(150, 3, 'MEMBER', 61, 'MEMBER', 99, 'BROTHERS', '景逸与胞弟景淮', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(151, 3, 'MEMBER', 103, 'MEMBER', 61, 'SISTER_BROTHER', '景芙与弟弟景逸', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(152, 3, 'MEMBER', 61, 'MEMBER', 104, 'BROTHER_SISTER', '景逸与妹妹景菡', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(153, 3, 'MEMBER', 105, 'MEMBER', 61, 'COUSIN_PATERNAL', '景棠与堂弟景逸', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(154, 3, 'MEMBER', 100, 'MEMBER', 63, 'COUSIN_PATERNAL', '堂兄景曜与堂弟景天', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(155, 3, 'MEMBER', 106, 'MEMBER', 63, 'COUSIN_PATERNAL', '堂姐景嫣与堂弟景天', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(156, 3, 'MEMBER', 107, 'MEMBER', 63, 'COUSIN_PATERNAL', '堂妹景萝与堂兄景天', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(157, 3, 'MEMBER', 109, 'MEMBER', 63, 'COUSIN_PATERNAL', '表姐景芸与表弟景天', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(158, 3, 'MEMBER', 63, 'MEMBER', 110, 'UNCLE_NEPHEW', '堂叔景天与侄女景芜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(159, 3, 'MEMBER', 100, 'MEMBER', 106, 'BROTHER_SISTER', '景曜与妹妹景嫣', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(160, 3, 'MEMBER', 106, 'MEMBER', 110, 'UNCLE_NEPHEW', '姑姑景嫣与侄女景芜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);
