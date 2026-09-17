-- ============================================================
-- 《红楼梦》四大家族测试数据
-- 家族 4 个（贾/史/王/薛）+ 成员 32 名 + 关系 60 条
-- 幂等：执行前清空 novel_ 三表（当前表中均为此前联调产生的测试脏数据）
-- 字典编码依据：novel_family_type / novel_family_status / novel_member_role / novel_relation_type
-- ============================================================

DELETE FROM novel_relation;
DELETE FROM novel_family_member;
DELETE FROM novel_family;

-- ---------- 家族 ----------
INSERT INTO novel_family (id, name, alias, type, status, introduction, background, creed, territory, emblem, cover, sort, created_by, created_at, updated_by, updated_at, deleted) VALUES
(1, '贾府', '金陵贾氏·荣宁二府', 'NOBLE', 'TOP', '《红楼梦》第一豪门，宁荣二公之后，分荣国府、宁国府两房，一门双国公。', '宁国公贾演、荣国公贾源兄弟以军功起家，世袭国公。荣府以贾母为尊，宁府以贾敬一支传承。元春封妃后贾府一度烈火烹油，后遭抄家没落。', '诗礼传家', '金陵·荣宁街', NULL, NULL, 1, 'admin', NOW(), 'admin', NOW(), 0),
(2, '史府', '金陵史氏·保龄侯府', 'NOBLE', 'SECOND', '贾母娘家，保龄侯尚书令史公之后，一门双侯。', '史公为尚书令，封保龄侯。后代史鼐袭保龄侯、史鼎封忠靖侯。族中女儿史太君嫁入荣国府为贾母。', '诗书簪缨', '金陵', NULL, NULL, 2, 'admin', NOW(), 'admin', NOW(), 0),
(3, '王府', '金陵王氏·都太尉统制县伯', 'OFFICIAL', 'TOP', '都太尉统制县伯王公之后，王子腾官至九省统制，为四大家族官场支柱。', '王家以军功起家，王子腾历任京营节度使、九省统制，权倾一时。王夫人、王熙凤、薛姨妈皆王家女儿，与贾薛两家深度联姻。', '东海白玉床', '金陵', NULL, NULL, 3, 'admin', NOW(), 'admin', NOW(), 0),
(4, '薛府', '金陵薛氏·紫薇舍人之后', 'MERCHANT', 'DECLINING', '紫薇舍人薛公之后，领内帑钱粮、采办杂料的皇商世家。', '薛家世代为皇商，家资巨富，护官符称"珍珠如土金如铁"。薛蟠打死人命后家道渐衰，薛姨妈携子女投靠贾府。', '珍珠如土金如铁', '金陵', NULL, NULL, 4, 'admin', NOW(), 'admin', NOW(), 0);

-- ---------- 成员 ----------
INSERT INTO novel_family_member (id, family_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted) VALUES
-- 贾府
(1, 1, '贾母', '史太君', 'F', 'G1', '荣国府太夫人', 'MAJOR_SUPPORT', 75, '["慈爱","精明","风趣"]', '鬓发如银，慈眉善目', '金陵史侯之女，贾代善之妻，荣国府最高权威，孙辈中最疼爱宝玉与黛玉。', 1, 1, 1, 'admin', NOW(), 'admin', NOW(), 0),
(2, 1, '贾赦', NULL, 'M', 'G2', '一等将军', 'MAJOR_SUPPORT', 60, '["荒淫","贪婪"]', NULL, '贾母长子，袭一等将军，昏聩好色，曾强纳贾母丫鬟鸳鸯为妾未遂。', 0, 1, 2, 'admin', NOW(), 'admin', NOW(), 0),
(3, 1, '邢夫人', NULL, 'F', 'G2', NULL, 'MINOR_SUPPORT', 55, '["愚昧","顺从"]', NULL, '贾赦继室，一味承顺贾赦，不闻不问府中事。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(4, 1, '贾政', NULL, 'M', 'G2', '工部员外郎', 'MAJOR_SUPPORT', 55, '["端方","迂腐"]', NULL, '贾母次子，任工部员外郎，恪守礼教，对宝玉管教严苛。', 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0),
(5, 1, '王夫人', NULL, 'F', 'G2', NULL, 'MAJOR_SUPPORT', 50, '["慈善","冷漠"]', NULL, '贾政正妻，金陵王家小姐，贾宝玉之母，表面念佛吃斋，实则城府极深。', 0, 1, 4, 'admin', NOW(), 'admin', NOW(), 0),
(6, 1, '贾珠', NULL, 'M', 'G3', NULL, 'MINOR_SUPPORT', 20, '["好学"]', NULL, '贾政长子，十四岁进学，青年早逝，留妻李纨与子贾兰。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(7, 1, '李纨', NULL, 'F', 'G3', NULL, 'MINOR_SUPPORT', 32, '["贞静","淡泊"]', NULL, '贾珠之妻，贾兰之母，青年守寡，随分从时，后因儿子科举高中凤冠霞帔。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(8, 1, '贾兰', NULL, 'M', 'G4', NULL, 'MINOR_SUPPORT', 10, '["勤奋"]', NULL, '贾珠遗腹子，勤学上进，后科举高中，重振家声。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(9, 1, '贾宝玉', '怡红公子', 'M', 'G3', NULL, 'PROTAGONIST', 14, '["叛逆","痴情","灵秀"]', '面若中秋之月，色如春晓之花', '贾政次子，衔玉而生，小说第一主角，鄙弃功名利禄，与黛玉情投意合。', 0, 1, 5, 'admin', NOW(), 'admin', NOW(), 0),
(10, 1, '贾元春', NULL, 'F', 'G3', '贤德妃', 'MAJOR_SUPPORT', 27, '["贤孝"]', NULL, '贾政长女，入宫选为女史，后封凤藻宫尚书加封贤德妃，省亲大观园，贾府盛极而衰的转折。', 0, 0, 6, 'admin', NOW(), 'admin', NOW(), 0),
(11, 1, '贾迎春', NULL, 'F', 'G3', NULL, 'MINOR_SUPPORT', 17, '["懦弱"]', NULL, '贾赦庶女，诨名"二木头"，老实懦弱，后被父亲许嫁孙绍祖受虐而死。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(12, 1, '贾探春', NULL, 'F', 'G3', NULL, 'MAJOR_SUPPORT', 13, '["精明","果敢","志高"]', NULL, '贾政庶女，赵姨娘所生，诨名"玫瑰花"，理家兴利除弊，才自精明志自高，后远嫁海疆。', 0, 1, 7, 'admin', NOW(), 'admin', NOW(), 0),
(13, 1, '贾惜春', NULL, 'F', 'G3', NULL, 'MINOR_SUPPORT', 11, '["孤僻"]', NULL, '宁府贾敬之女，贾珍胞妹，寄住荣国府，冷心冷面，后看破红尘出家为尼。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(14, 1, '贾环', NULL, 'M', 'G3', NULL, 'EXTRA', 10, '["猥琐"]', NULL, '贾政庶子，赵姨娘所生，举止猥琐，与宝玉不睦。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(15, 1, '贾琏', NULL, 'M', 'G3', '同知', 'MAJOR_SUPPORT', 26, '["风流","纨绔"]', NULL, '贾赦之子，捐五品同知，荣国府外务当家人，生性风流。', 0, 1, 8, 'admin', NOW(), 'admin', NOW(), 0),
(16, 1, '王熙凤', '凤辣子', 'F', 'G3', NULL, 'MAJOR_SUPPORT', 25, '["精明","狠辣","泼辣"]', '一双丹凤三角眼，两弯柳叶吊梢眉', '贾琏之妻，金陵王家小姐，荣国府实际管家，机关算尽，权术过人，后积劳病故。', 0, 1, 9, 'admin', NOW(), 'admin', NOW(), 0),
(17, 1, '贾巧姐', NULL, 'F', 'G4', NULL, 'EXTRA', 5, '[]', NULL, '贾琏与王熙凤之女，生于七夕，刘姥姥为之取名，贾府败落后被刘姥姥救出。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(18, 1, '林黛玉', '颦儿', 'F', 'G3', NULL, 'PROTAGONIST', 13, '["敏感","多才","孤高"]', '两弯似蹙非蹙罥烟眉，一双似喜非喜含露目', '贾敏之女，父母双亡后寄居荣国府，才华绝代，与宝玉互为知己，泪尽而亡。', 0, 1, 10, 'admin', NOW(), 'admin', NOW(), 0),
(19, 1, '贾珍', NULL, 'M', 'G3', '威烈将军', 'MAJOR_SUPPORT', 40, '["荒淫","纨绔"]', NULL, '宁府贾敬之子，袭三品爵威烈将军，任贾氏族长，宁国府在他手中乌烟瘴气。', 0, 1, 11, 'admin', NOW(), 'admin', NOW(), 0),
(20, 1, '尤氏', NULL, 'F', 'G3', NULL, 'MINOR_SUPPORT', 38, '["贤淑","软弱"]', NULL, '贾珍继室，贾蓉继母，贤惠有余而无力约束宁府。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(21, 1, '贾蓉', NULL, 'M', 'G4', '监生', 'MINOR_SUPPORT', 18, '["纨绔"]', NULL, '贾珍之子，贾琏堂侄，捐监生，与父亲一同胡作非为。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
-- 史府
(22, 2, '史鼐', NULL, 'M', 'G2', '保龄侯', 'MAJOR_SUPPORT', 50, '["守成"]', NULL, '史家当家人，袭保龄侯，贾母之侄，史湘云的叔父。', 1, 1, 12, 'admin', NOW(), 'admin', NOW(), 0),
(23, 2, '史鼎', NULL, 'M', 'G2', '忠靖侯', 'MINOR_SUPPORT', 48, '[]', NULL, '史家一门双侯之一，封忠靖侯，贾母之侄。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(24, 2, '史湘云', '枕霞旧友', 'F', 'G3', NULL, 'MAJOR_SUPPORT', 15, '["豪爽","才思敏捷","心直口快"]', '蜂腰猿背，鹤势螂形', '贾母侄孙女，父母早亡，依叔婶度日，醉卧芍药裀，诗社活跃人物，后嫁卫若兰。', 0, 1, 13, 'admin', NOW(), 'admin', NOW(), 0),
-- 王府
(25, 3, '王子腾', NULL, 'M', 'G2', '九省统制', 'MAJOR_SUPPORT', 52, '["权谋"]', NULL, '王家掌门人，历任京营节度使、九省统制，四大家族官场上的最大靠山。', 1, 1, 14, 'admin', NOW(), 'admin', NOW(), 0),
(26, 3, '王子胜', NULL, 'M', 'G2', NULL, 'EXTRA', 45, '[]', NULL, '王子腾之弟。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(27, 3, '王仁', NULL, 'M', 'G3', NULL, 'EXTRA', 28, '["贪婪"]', NULL, '王熙凤之兄，为人贪婪，贾府败落后卖巧姐，人称"狼舅"。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
-- 薛府
(28, 4, '薛姨妈', '薛王氏', 'F', 'G2', NULL, 'MAJOR_SUPPORT', 45, '["慈和"]', NULL, '王夫人同胞妹妹，嫁入薛家，丈夫早逝，携薛蟠薛宝钗进京投靠贾府。', 1, 1, 15, 'admin', NOW(), 'admin', NOW(), 0),
(29, 4, '薛蟠', '呆霸王', 'M', 'G3', '皇商', 'MAJOR_SUPPORT', 20, '["粗野","骄横"]', NULL, '薛姨妈之子，袭皇商之业，仗势打死人命，人称"呆霸王"。', 0, 1, 16, 'admin', NOW(), 'admin', NOW(), 0),
(30, 4, '薛宝钗', '蘅芜君', 'F', 'G3', NULL, 'MAJOR_SUPPORT', 15, '["稳重","豁达","博学"]', '脸若银盆，眼如水杏', '薛姨妈之女，德才兼备，随分守时，后与宝玉成婚，宝玉出家后独守空闺。', 0, 1, 17, 'admin', NOW(), 'admin', NOW(), 0),
(31, 4, '薛宝琴', NULL, 'F', 'G3', NULL, 'MINOR_SUPPORT', 14, '["聪慧","开朗"]', NULL, '薛蝌之妹，薛家旁支，才貌双全，曾许配梅翰林之子。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0),
(32, 4, '薛蝌', NULL, 'M', 'G3', NULL, 'MINOR_SUPPORT', 19, '["忠厚"]', NULL, '薛宝琴之兄，为人忠厚，护送妹妹进京待嫁。', 0, 0, 0, 'admin', NOW(), 'admin', NOW(), 0);

-- ---------- 关系 ----------
INSERT INTO novel_relation (id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted) VALUES
-- 贾府内部
(1, 'MEMBER', 1, 'MEMBER', 2, 'MOTHER_SON', '贾母与长子贾赦', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(2, 'MEMBER', 1, 'MEMBER', 4, 'MOTHER_SON', '贾母与次子贾政', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(3, 'MEMBER', 1, 'MEMBER', 9, 'GRANDPARENT', '祖母与孙儿', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(4, 'MEMBER', 1, 'MEMBER', 18, 'GRANDPARENT', '外祖母与外孙女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(5, 'MEMBER', 2, 'MEMBER', 3, 'SPOUSE', '贾赦与邢夫人夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(6, 'MEMBER', 2, 'MEMBER', 15, 'FATHER_SON', '贾赦与贾琏父子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(7, 'MEMBER', 2, 'MEMBER', 11, 'FATHER_DAUGHTER', '贾赦与贾迎春父女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(8, 'MEMBER', 2, 'MEMBER', 4, 'BROTHERS', '贾赦与贾政兄弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(9, 'MEMBER', 4, 'MEMBER', 5, 'SPOUSE', '贾政与王夫人夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(10, 'MEMBER', 4, 'MEMBER', 6, 'FATHER_SON', '贾政与贾珠父子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(11, 'MEMBER', 4, 'MEMBER', 9, 'FATHER_SON', '贾政与贾宝玉父子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(12, 'MEMBER', 4, 'MEMBER', 10, 'FATHER_DAUGHTER', '贾政与贾元春父女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(13, 'MEMBER', 4, 'MEMBER', 12, 'FATHER_DAUGHTER', '贾政与贾探春父女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(14, 'MEMBER', 4, 'MEMBER', 14, 'FATHER_SON', '贾政与贾环父子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(15, 'MEMBER', 5, 'MEMBER', 9, 'MOTHER_SON', '王夫人与贾宝玉母子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(16, 'MEMBER', 5, 'MEMBER', 10, 'MOTHER_DAUGHTER', '王夫人与贾元春母女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(17, 'MEMBER', 6, 'MEMBER', 7, 'SPOUSE', '贾珠与李纨夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(18, 'MEMBER', 6, 'MEMBER', 8, 'FATHER_SON', '贾珠与贾兰父子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(19, 'MEMBER', 7, 'MEMBER', 8, 'MOTHER_SON', '李纨与贾兰母子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(20, 'MEMBER', 15, 'MEMBER', 16, 'SPOUSE', '贾琏与王熙凤夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(21, 'MEMBER', 15, 'MEMBER', 17, 'FATHER_DAUGHTER', '贾琏与贾巧姐父女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(22, 'MEMBER', 16, 'MEMBER', 17, 'MOTHER_DAUGHTER', '王熙凤与贾巧姐母女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(23, 'MEMBER', 19, 'MEMBER', 20, 'SPOUSE', '贾珍与尤氏夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(24, 'MEMBER', 19, 'MEMBER', 21, 'FATHER_SON', '贾珍与贾蓉父子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(25, 'MEMBER', 19, 'MEMBER', 9, 'COUSIN_PATERNAL', '宁荣二府同宗堂兄弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(26, 'MEMBER', 19, 'MEMBER', 15, 'COUSIN_PATERNAL', '宁荣二府同宗堂兄弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(27, 'MEMBER', 15, 'MEMBER', 9, 'COUSIN_PATERNAL', '贾琏与贾宝玉堂兄弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(28, 'MEMBER', 10, 'MEMBER', 9, 'SISTER_BROTHER', '贾元春与贾宝玉姐弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(29, 'MEMBER', 12, 'MEMBER', 9, 'BROTHER_SISTER', '贾探春与贾宝玉兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(30, 'MEMBER', 11, 'MEMBER', 9, 'COUSIN_PATERNAL', '贾迎春与贾宝玉堂兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(31, 'MEMBER', 13, 'MEMBER', 9, 'COUSIN_PATERNAL', '贾惜春与贾宝玉堂兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(32, 'MEMBER', 18, 'MEMBER', 9, 'COUSIN_MATERNAL', '姑表兄妹（林黛玉之母贾敏为贾政之妹）', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(33, 'MEMBER', 18, 'MEMBER', 9, 'LOVER', '宝黛知己恋人', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(34, 'MEMBER', 9, 'MEMBER', 30, 'COUSIN_MATERNAL', '姨表姐弟（薛宝钗之母为王夫人之妹）', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(35, 'MEMBER', 9, 'MEMBER', 30, 'SPOUSE', '后四十回贾宝玉与薛宝钗成婚', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(36, 'MEMBER', 16, 'MEMBER', 9, 'COUSIN_MATERNAL', '王熙凤与贾宝玉表姐弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(37, 'MEMBER', 12, 'MEMBER', 18, 'CLOSE_FRIEND', '大观园诗社知交', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
-- 史府
(38, 'MEMBER', 22, 'MEMBER', 24, 'UNCLE_NEPHEW', '史鼐与史湘云叔侄', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(39, 'MEMBER', 23, 'MEMBER', 24, 'UNCLE_NEPHEW', '史鼎与史湘云叔侄', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(40, 'MEMBER', 22, 'MEMBER', 23, 'BROTHERS', '史鼐与史鼎兄弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(41, 'MEMBER', 1, 'MEMBER', 24, 'GRANDPARENT', '贾母为史湘云姑祖母', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
-- 王府
(42, 'MEMBER', 25, 'MEMBER', 26, 'BROTHERS', '王子腾与王子胜兄弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(43, 'MEMBER', 25, 'MEMBER', 5, 'BROTHER_SISTER', '王子腾与王夫人兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(44, 'MEMBER', 25, 'MEMBER', 16, 'UNCLE_NEPHEW', '王子腾与王熙凤伯侄', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(45, 'MEMBER', 25, 'MEMBER', 27, 'UNCLE_NEPHEW', '王子腾与王仁伯侄', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
-- 薛府
(46, 'MEMBER', 5, 'MEMBER', 28, 'SISTERS', '王夫人与薛姨妈同胞姐妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(47, 'MEMBER', 25, 'MEMBER', 28, 'BROTHER_SISTER', '王子腾与薛姨妈兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(48, 'MEMBER', 28, 'MEMBER', 29, 'MOTHER_SON', '薛姨妈与薛蟠母子', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(49, 'MEMBER', 28, 'MEMBER', 30, 'MOTHER_DAUGHTER', '薛姨妈与薛宝钗母女', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(50, 'MEMBER', 29, 'MEMBER', 30, 'BROTHER_SISTER', '薛蟠与薛宝钗兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(51, 'MEMBER', 32, 'MEMBER', 31, 'BROTHER_SISTER', '薛蝌与薛宝琴兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(52, 'MEMBER', 29, 'MEMBER', 32, 'COUSIN_PATERNAL', '薛蟠与薛蝌堂兄弟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
-- 跨府
(53, 'MEMBER', 16, 'MEMBER', 30, 'COUSIN_MATERNAL', '王熙凤与薛宝钗表姐妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(54, 'MEMBER', 16, 'MEMBER', 28, 'UNCLE_NEPHEW', '王熙凤与薛姨妈姑侄', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(55, 'MEMBER', 24, 'MEMBER', 18, 'CLOSE_FRIEND', '史湘云与林黛玉诗社挚友', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(56, 'MEMBER', 9, 'MEMBER', 24, 'COUSIN_MATERNAL', '贾宝玉与史湘云表兄妹', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
-- 家族间联姻
(57, 'FAMILY', 1, 'FAMILY', 2, 'MARRIAGE_ALLIANCE', '贾母史太君出自史家', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(58, 'FAMILY', 1, 'FAMILY', 3, 'MARRIAGE_ALLIANCE', '王夫人、王熙凤出自王家', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(59, 'FAMILY', 1, 'FAMILY', 4, 'MARRIAGE_ALLIANCE', '贾宝玉迎娶薛宝钗', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(60, 'FAMILY', 3, 'FAMILY', 4, 'MARRIAGE_ALLIANCE', '薛姨妈为王家小姐', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);
