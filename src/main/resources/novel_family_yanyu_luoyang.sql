-- ============================================================
-- 《烟雨江湖》洛阳八大世家测试数据
-- 目标小说：novel_id = 4（烟雨江湖）
-- 结构：每家 G1 老太君/老太爷 1 人；G2 家主 1 + 正妻 1 + 妾室 2~3；G3 子女 1~3
-- 关系：父子/母子/父女/母女、夫妻、兄弟姐妹
-- 执行方式：mysql --execute="source D:/CODE/Java/Geeker-Admin-Java/src/main/resources/novel_family_yanyu_luoyang.sql"
-- ============================================================

START TRANSACTION;

SET @novel := 4;

-- ---------------- 一、洛阳赵氏 · 盐运 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳赵氏', '赵·盐运世家', 'NOBLE', 'TOP',
 '洛阳八大世家之首，掌河东盐引与南市盐栈，鼎盛时人称赵半城。',
 '赵家祖上为前朝盐铁转运使属吏，入洛后以盐引起家。第三代赵守拙打通河东盐路，洛阳城里半数盐栈都姓赵；十年前盐引案发，赵家折了半副家业，自此由明转暗，把盐运做成官私两道的灰色生意。',
 '盐可通百业，信不可失一诺',
 '洛阳·南市盐栈、河东三井',
 '赤盐纹（盐晶与秤砣交叠）',
 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @f1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f1, @novel, '赵守拙', '字退之', 'M', 'G1', '赵家老太爷·前代家主', 'MINOR_SUPPORT', 78,
 '["沉稳","守旧","护短"]', '鹤发束冠，左目微眇，常着酱色直裰，手里一根乌木拐杖',
 '赵家第三代盐商，年轻时单枪匹马打通洛阳到河东的盐路，人称赵半城。晚年因盐引案折了半副家业，从此退居后堂，只在小辈争得不可开交时敲一记拐杖。他嘴上说不管事，赵家每一张盐引的底细都还在他脑子里。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @z_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f1, @novel, '赵承宗', '字继业', 'M', 'G2', '赵氏家主·盐运总舵', 'MAJOR_SUPPORT', 45,
 '["精明","隐忍","多疑"]', '面白无须，指节戴一枚旧玉扳指，笑意总不到眼底',
 '赵家现任家主，掌南市盐栈与河东两处盐井。接手时赵家只剩三成盐引，他用十年把盐路做成官盐私运两不误的灰色生意，与洛阳府衙、漕帮都有往来。对老太爷表面恭顺，暗中却在一步步挪动族产，连发妻都摸不清他到底想做什么。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @z_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f1, @novel, '沈玉容', NULL, 'F', 'G2', '赵家主母·内账掌事', 'MINOR_SUPPORT', 43,
 '["端方","精明","外冷内热"]', '妆容素净，腕上一只翡翠镯，说话不急不缓',
 '洛阳绸缎商沈家之女，赵承宗发妻。嫁入赵家时带来沈家半条绸缎街作嫁妆，替赵家补上盐引案的亏空。她掌赵家内账，眼里揉不得沙子，却对妾室柳氏多有回护，只因柳氏替赵家挡过一次官差。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @z_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f1, @novel, '柳如烟', NULL, 'F', 'G2', '赵家二夫人', 'EXTRA', 38,
 '["圆滑","机敏","重情"]', '眼尾微挑，常着一身水红罗裙，抱一面旧琵琶',
 '原是洛阳教坊的歌伎，被赵承宗赎身纳为二夫人。她擅琵琶，知情识趣，是赵承宗在外应酬时的门面；暗里替赵家打探盐商与官府的动静，消息比账房还灵。她知道自己进不了赵家族谱的正页，却把女儿明萱护得极紧。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @z_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f1, @novel, '苏婉清', NULL, 'F', 'G2', '赵家三夫人', 'EXTRA', 32,
 '["质朴","刚直","记仇"]', '肤色被灶火与日头磨得偏深，手指关节粗大，不施粉黛',
 '河东盐工之女，父亲死在盐井塌方后被赵家收养，后纳为三夫人。她识字不多，却记得每一口盐井的深浅与盐工的姓名；替赵家安抚盐工，是赵承宗最不敢轻慢的人。她从不争宠，只在盐工被克扣时开口。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @z_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f1, @novel, '赵明远', '字昭行', 'M', 'G3', '赵家嫡长子', 'MAJOR_SUPPORT', 22,
 '["锐气","理想主义","倔强"]', '身量挺拔，眉目像母亲，常着一身半旧的青衫',
 '自幼被当作家主接班人养，读过书也下过盐井。他看不惯父亲的灰色手段，暗中与洛阳府一位年轻推官往来，想借官府之力把赵家的盐路洗白。父子二人为此在祠堂里吵过三次，每次都被老太爷一记拐杖压下去。',
 0, 1, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @z_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f1, @novel, '赵明萱', NULL, 'F', 'G3', '赵家二小姐', 'MINOR_SUPPORT', 19,
 '["灵慧","任性","慕强"]', '眉眼肖母，鬓边常簪一朵新鲜石榴花，笑起来有两个梨涡',
 '琵琶得柳氏真传，是洛阳花会上年年夺魁的人。她与钱家少卿有一段说不清的交情，被赵承宗当作联姻筹码。她嘴上应着，心里却在盘算怎样让这桩婚事黄掉，又不至于连累母亲。',
 0, 0, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @z_k2 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @z_g1, 'MEMBER', @z_head, 'FATHER_SON', '赵守拙之子赵承宗', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_head, 'MEMBER', @z_w, 'SPOUSE', '赵承宗与发妻沈玉容', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_head, 'MEMBER', @z_c1, 'SPOUSE', '赵承宗与二夫人柳如烟', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_head, 'MEMBER', @z_c2, 'SPOUSE', '赵承宗与三夫人苏婉清', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_head, 'MEMBER', @z_k1, 'FATHER_SON', '赵承宗之子赵明远', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_w, 'MEMBER', @z_k1, 'MOTHER_SON', '沈玉容之子赵明远', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_head, 'MEMBER', @z_k2, 'FATHER_DAUGHTER', '赵承宗之女赵明萱', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_c1, 'MEMBER', @z_k2, 'MOTHER_DAUGHTER', '柳如烟之女赵明萱', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @z_k1, 'MEMBER', @z_k2, 'BROTHER_SISTER', '赵明远与妹妹赵明萱', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

-- ---------------- 二、洛阳钱氏 · 钱庄票号 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳钱氏', '钱·票号世家', 'NOBLE', 'TOP',
 '洛阳票号第一家，洛阳钱通九省，掌八省汇兑与典当。',
 '钱家祖上在洛阳南市开一间小钱柜，第三代钱老夫人陈氏守寡后独撑票号四十年，把分号开到九省。钱通海接掌后广结官府、漕帮与盐商，坏账从不出门，钱家的银车成了洛阳城里最稳当的招牌。',
 '银走人情前，账留三分底',
 '洛阳·南市钱庄总号、九省分号',
 '双钱衔算盘',
 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @f2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '陈氏', '钱门陈氏', 'F', 'G1', '钱家老太君·前代当家', 'MINOR_SUPPORT', 76,
 '["果决","精明","护犊"]', '银发盘髻，手捻一串沉香佛珠，眼不济却耳极灵',
 '钱家上一代当家人。丈夫早逝，她一个女人撑起钱家票号四十年，创下洛阳钱通九省的名头。如今眼睛不好了，仍要人每天念一遍各分号的银根；谁家分号短了银子，她只听念账的口气就能听出来。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '钱通海', '字汇川', 'M', 'G2', '钱氏家主·总号大掌柜', 'MAJOR_SUPPORT', 50,
 '["圆滑","谨慎","爱财"]', '微胖，笑起来两眼成缝，袖里总揣一把金算盘',
 '钱家票号大掌柜出身，现任家主。十六岁进票号当学徒，三十岁掌洛阳总号，最信银子要走在人情前面。与洛阳府、漕帮、盐商都有银钱往来，手段圆滑，坏账从不出门，连老太君都夸他比上一辈更会做人。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '顾云裳', NULL, 'F', 'G2', '钱家主母·内柜掌事', 'MINOR_SUPPORT', 47,
 '["端庄","严厉","有主见"]', '衣饰素净，发间一支白玉簪，目光清正',
 '苏州顾氏绸庄之女。嫁入钱家后掌总号内柜，是钱通海唯一敢把账本交出去的人；她定下钱家不放印子钱的规矩，替钱家挡了不少骂名。对三位妾室不亲不疏，只认账目与规矩。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '姚金娘', NULL, 'F', 'G2', '钱家二夫人', 'EXTRA', 40,
 '["泼辣","爽利","贪小"]', '走路带风，腰间挂一串铜钥匙，说话嗓门不小',
 '原是钱家钱庄的跑街娘子，因替钱家追回一笔死账被纳。她走街串巷，洛阳城里谁家缺银子、谁家要典当，她比户部还清楚；钱通海许多生意都是她先探的路。与何氏一向不对付，却都怕顾氏。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '白素娥', NULL, 'F', 'G2', '钱家三夫人', 'EXTRA', 35,
 '["温顺","细致","怯懦"]', '身形纤细，常穿月白衫子，说话轻声细语',
 '洛阳白家药铺之女，温顺寡言。擅记账，一手小楷写得极工整；替钱家管着城外三处田庄的租册，闲时在佛堂抄经，是钱通海歇脚时最愿意见的人。她唯一的儿子少康体弱，她把半副心思都放在孩子身上。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '何小满', NULL, 'F', 'G2', '钱家四夫人', 'EXTRA', 28,
 '["隐忍","节俭","敏感"]', '身量小巧，鬓边总别一根素银钗，衣裳洗得发白',
 '陕州逃荒来的孤女，被钱家收作婢女，后纳为四夫人。她吃过苦，最知道银子的分量；管着钱家厨房与下人月钱，账目清楚得让人挑不出错，却总被姚氏压一头。她不说，心里都记着。',
 0, 0, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_c3 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '钱少卿', '字子佩', 'M', 'G3', '钱家少掌柜', 'MAJOR_SUPPORT', 25,
 '["自负","机敏","野心"]', '面如冠玉，身着宝蓝锦袍，算盘不离手',
 '总号少掌柜，打得一手好算盘，也学了一身父亲的本事。他不甘只做钱家的钱，暗中放贷给洛阳几家镖局，想把手伸进江湖。与赵家明萱的婚事是他自己点头的，可他心里清楚，那桩婚事里掺着盐引。',
 0, 1, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '钱少薇', NULL, 'F', 'G3', '钱家二小姐', 'MINOR_SUPPORT', 21,
 '["爽利","好胜","重义"]', '常着一身窄袖骑装，腕上缠着护腕，肤色是跑马晒出来的',
 '性子泼辣，骑术极好，常替钱家押送银车。她与赵家明萱交好，却看不起赵家拿女人换盐引的做法。她私下替镖局放过两笔银子，连父亲都不知道。',
 0, 0, 8, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_k2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f2, @novel, '钱少康', '字子安', 'M', 'G3', '钱家三少爷', 'MINOR_SUPPORT', 17,
 '["文静","聪慧","怯弱"]', '身形清瘦，面色偏白，手里总卷着一册书',
 '体弱多病，读书却极有天分，被钱老夫人寄望走科举路子，替钱家换一个官身。他不爱算盘，爱读史书，最佩服的是那些不肯替豪强做账的清官。',
 0, 0, 9, 'admin', NOW(), 'admin', NOW(), 0);
SET @q_k3 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @q_g1, 'MEMBER', @q_head, 'MOTHER_SON', '钱门陈氏之子钱通海', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_head, 'MEMBER', @q_w, 'SPOUSE', '钱通海与发妻顾云裳', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_head, 'MEMBER', @q_c1, 'SPOUSE', '钱通海与二夫人姚金娘', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_head, 'MEMBER', @q_c2, 'SPOUSE', '钱通海与三夫人白素娥', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_head, 'MEMBER', @q_c3, 'SPOUSE', '钱通海与四夫人何小满', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_head, 'MEMBER', @q_k1, 'FATHER_SON', '钱通海之子钱少卿', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_w, 'MEMBER', @q_k1, 'MOTHER_SON', '顾云裳之子钱少卿', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_head, 'MEMBER', @q_k2, 'FATHER_DAUGHTER', '钱通海之女钱少薇', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_c1, 'MEMBER', @q_k2, 'MOTHER_DAUGHTER', '姚金娘之女钱少薇', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_head, 'MEMBER', @q_k3, 'FATHER_SON', '钱通海之子钱少康', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_c2, 'MEMBER', @q_k3, 'MOTHER_SON', '白素娥之子钱少康', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_k1, 'MEMBER', @q_k2, 'BROTHER_SISTER', '钱少卿与妹妹钱少薇', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_k1, 'MEMBER', @q_k3, 'BROTHERS', '钱少卿与弟弟钱少康', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @q_k2, 'MEMBER', @q_k3, 'SISTER_BROTHER', '钱少薇与弟弟钱少康', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

-- ---------------- 三、洛阳孙氏 · 药材 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳孙氏', '孙·药材世家', 'NOBLE', 'SECOND',
 '洛阳药材行会之首，坐拥川、广、怀三条药路，济世堂名满中原。',
 '孙济世游方行医起家，一把银针救过前朝总兵，得赠杏林匾额。孙承药接手后把一间药铺做成垄断三条药路的行会，与江湖各派以药材换人情，黑白两道都要给三分面子。',
 '药不掺假，方不负人',
 '洛阳·济世堂、城南药市',
 '杏林双叶',
 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @f3 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f3, @novel, '孙济世', '字怀仁', 'M', 'G1', '孙家老太爷·济世堂老医', 'MINOR_SUPPORT', 81,
 '["仁厚","固执","淡泊"]', '白须垂胸，指节因常年抓药而粗糙，走路仍不用人扶',
 '年轻时游方行医，一把银针救过前朝一位总兵的命，得赠杏林匾额。晚年闭门著《洛阳本草》，常说药可救人，也可杀人。他不管行会生意，只在孙家药方出了岔子时拄杖出门。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @s_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f3, @novel, '孙承药', '字继先', 'M', 'G2', '孙氏家主·药材行会会首', 'MAJOR_SUPPORT', 52,
 '["温和","老练","重信"]', '面容和善，蓄短须，身上总带一点淡淡的药香',
 '济世堂东家，掌洛阳药材行会。把孙家从一间药铺做成垄断川、广、怀三条药路的行会首领；与江湖各派都有药材换人情的往来，是洛阳城里少有的黑白两道都给面子的人。他信奉药路即人路，从不把药价抬到别人活不下去。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @s_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f3, @novel, '冯慧娘', NULL, 'F', 'G2', '孙家主母', 'MINOR_SUPPORT', 49,
 '["爽直","严谨","护短"]', '手脚利落，常挽着袖子，腰间系一条药囊',
 '冯家药农之女，识药如识人。嫁入孙家后亲自带人进山采药，定下孙家药不掺假的铁规；与丈夫一个唱红脸一个唱白脸，把行会里几个刺头收拾得服服帖帖。她最恨拿假药换银子的人。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @s_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f3, @novel, '周小蝶', NULL, 'F', 'G2', '孙家二夫人·坐堂女医', 'EXTRA', 41,
 '["冷静","清高","多思"]', '指间常夹一支细毫，衣着素净，说话不急',
 '原为济世堂坐堂女医，擅妇科，医术得孙济世亲传，洛阳城里的夫人小姐都认她的方子。她与冯氏面和心不和，却都真心护着孙家的招牌。私下替一位不宜露面的客人诊过脉，这事她连丈夫都没说。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @s_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f3, @novel, '林半夏', NULL, 'F', 'G2', '孙家三夫人', 'EXTRA', 36,
 '["野性","直率","认死理"]', '皮肤是山风吹出来的麦色，发间常插一把野草',
 '名字取自药材，本是山上采药女。熟悉洛阳周边每一座山的药性，能凭气味辨出年份；孙承药纳她，一半是情，一半是为了那几片绝壁上的野生黄芪。她进山从不走现成的路，只认自己的脚。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @s_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f3, @novel, '孙明医', '字济之', 'M', 'G3', '孙家嫡长子', 'MAJOR_SUPPORT', 24,
 '["豪爽","好动","不务正业"]', '身形结实，手掌有采药磨出的薄茧，笑起来很响',
 '名字是老太爷取的，盼他承济世二字。他医术尚可，心思却全在江湖上，常跟着镖局的人往山里跑，采药兼练拳。父亲骂他不务正业，老太爷却说他身上有自己年轻时的影子。',
 0, 1, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @s_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f3, @novel, '孙明芷', NULL, 'F', 'G3', '孙家二小姐·坐堂女医', 'MINOR_SUPPORT', 20,
 '["清冷","缜密","心软"]', '眉目清淡，一双手极稳，诊脉时垂着眼',
 '坐堂女医，性子清冷，一手脉诊极准。她暗中替一位朝廷钦犯看过伤，这事只有她自己知道。母亲周小蝶问她怕不怕，她说医者只认脉，不认人。',
 0, 0, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @s_k2 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @s_g1, 'MEMBER', @s_head, 'FATHER_SON', '孙济世之子孙承药', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_head, 'MEMBER', @s_w, 'SPOUSE', '孙承药与发妻冯慧娘', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_head, 'MEMBER', @s_c1, 'SPOUSE', '孙承药与二夫人周小蝶', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_head, 'MEMBER', @s_c2, 'SPOUSE', '孙承药与三夫人林半夏', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_head, 'MEMBER', @s_k1, 'FATHER_SON', '孙承药之子孙明医', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_w, 'MEMBER', @s_k1, 'MOTHER_SON', '冯慧娘之子孙明医', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_head, 'MEMBER', @s_k2, 'FATHER_DAUGHTER', '孙承药之女孙明芷', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_c1, 'MEMBER', @s_k2, 'MOTHER_DAUGHTER', '周小蝶之女孙明芷', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @s_k1, 'MEMBER', @s_k2, 'BROTHER_SISTER', '孙明医与妹妹孙明芷', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

-- ---------------- 四、洛阳李氏 · 漕运 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳李氏', '李·漕运世家', 'NOBLE', 'SECOND',
 '洛水漕运之主，掌洛阳码头与一百八十艘漕船，货通南北。',
 '李家鼎盛时漕船三百，李老夫人王氏在丈夫死于漕帮火并后独闯总舵讨回船队。李漕生接掌后缩船保码头，把洛水码头做成洛阳最赚钱的货栈，与漕帮、盐商、镖局分成共利。',
 '船行水上，义字压舱',
 '洛阳·洛水码头、漕船坞',
 '洛水帆影',
 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @f4 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '王氏', '李门王氏', 'F', 'G1', '李家老太君·前代主母', 'MINOR_SUPPORT', 74,
 '["刚毅","节俭","念旧"]', '素衣银簪，腕上一只旧银镯，背脊仍挺得直',
 '李家上一代主母。丈夫在世时李家漕船三百艘，她管着船工家眷的粮米；丈夫死在漕帮火并后，是她一介女流去漕帮总舵讨回了李家的船。她至今记得那日总舵堂上十七把交椅的次序。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '李漕生', '字济川', 'M', 'G2', '李氏家主·漕运总舵', 'MAJOR_SUPPORT', 48,
 '["务实","圆滑","多谋"]', '皮肤被河风吹得偏黑，腰间一把旧铜尺，说话慢条斯理',
 '现任家主，掌李家漕运与洛水码头。名字是父亲按漕运生计取的；他接手后把漕船减到一百八十艘，却把洛水码头做成洛阳最赚钱的货栈，与漕帮、盐商、镖局都有抽成。他常说船少了不要紧，码头在，李家就在。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '郑淑仪', NULL, 'F', 'G2', '李家主母·码头账事', 'MINOR_SUPPORT', 46,
 '["果敢","硬气","护短"]', '身量高挑，眉目爽利，常穿深青窄袖，说话干脆',
 '郑家镖局出身，是郑老太爷的侄女。嫁入李家时带着郑家的镖路作嫁妆；她管码头上的账与船工的抚恤，做事比男人还硬，船工都叫她李门郑娘。她与郑家镖局至今保持着一份说不清的香火情。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '杨涟漪', NULL, 'F', 'G2', '李家二夫人', 'EXTRA', 39,
 '["爽朗","泼辣","念情"]', '头发常松松挽着，耳边一对银坠子，笑起来声音清亮',
 '洛水上的船娘，歌声极好。原是李家漕船上的船娘，被李漕生看上纳为二夫人；她熟悉洛水每一处暗礁与水匪的规矩，替李家挡过两次劫船。她闲来仍在船头唱歌，船工听见就知道李家船队平安回来了。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '胡月奴', NULL, 'F', 'G2', '李家三夫人', 'EXTRA', 33,
 '["温柔","机灵","恋家"]', '深目高鼻，发间缠着彩绳，身上有淡淡的香料味',
 '胡商之女，随父从西域来洛阳。会几种西域言语，替李家与胡商做香料、毛皮的转手生意；她性子软，却把李家码头的胡商账目理得清清楚楚。她最怕的是有一天父亲要回西域，把她也带走。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '李长风', '字万里', 'M', 'G3', '李家嫡长子', 'MAJOR_SUPPORT', 23,
 '["意气","果决","好胜"]', '肩宽背直，常赤脚在码头上走，手掌有撑船磨出的厚茧',
 '自幼在码头上长大，水性极好，能独自撑船过洛水险滩。他不愿接手账房，一心要把李家漕船重新扩回三百艘，常与父亲为此争执。老太君嘴上骂他莽撞，暗里却把压箱底的旧船契翻出来给他看。',
 0, 1, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '李长歌', NULL, 'F', 'G3', '李家二小姐', 'MINOR_SUPPORT', 18,
 '["明快","大胆","重情"]', '眉眼像母亲，发间爱簪一朵白茉莉，走路轻快',
 '嗓子承了母亲的船歌，是洛水上一绝。她常随船队走货，暗地里替李家留意水匪的动静。她与郑家一位年轻镖师有过一面之缘，回来后在船头唱了半个月的曲，谁问也不说为什么。',
 0, 0, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_k2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f4, @novel, '李长庚', '字少白', 'M', 'G3', '李家三少爷', 'MINOR_SUPPORT', 15,
 '["腼腆","聪颖","好奇"]', '身量未长足，眉目清秀，常抱着一本番语册子',
 '年纪最小，跟着胡商学算学与番语，被李漕生当作将来打通西域商路的种子。他羡慕大哥能上船，也羡慕二姐能唱歌，自己却只敢在码头边看船来船往。',
 0, 0, 8, 'admin', NOW(), 'admin', NOW(), 0);
SET @l_k3 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @l_g1, 'MEMBER', @l_head, 'MOTHER_SON', '李门王氏之子李漕生', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_head, 'MEMBER', @l_w, 'SPOUSE', '李漕生与发妻郑淑仪', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_head, 'MEMBER', @l_c1, 'SPOUSE', '李漕生与二夫人杨涟漪', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_head, 'MEMBER', @l_c2, 'SPOUSE', '李漕生与三夫人胡月奴', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_head, 'MEMBER', @l_k1, 'FATHER_SON', '李漕生之子李长风', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_w, 'MEMBER', @l_k1, 'MOTHER_SON', '郑淑仪之子李长风', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_head, 'MEMBER', @l_k2, 'FATHER_DAUGHTER', '李漕生之女李长歌', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_c1, 'MEMBER', @l_k2, 'MOTHER_DAUGHTER', '杨涟漪之女李长歌', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_head, 'MEMBER', @l_k3, 'FATHER_SON', '李漕生之子李长庚', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_c2, 'MEMBER', @l_k3, 'MOTHER_SON', '胡月奴之子李长庚', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_k1, 'MEMBER', @l_k2, 'BROTHER_SISTER', '李长风与妹妹李长歌', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_k1, 'MEMBER', @l_k3, 'BROTHERS', '李长风与弟弟李长庚', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @l_k2, 'MEMBER', @l_k3, 'SISTER_BROTHER', '李长歌与弟弟李长庚', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

-- ---------------- 五、洛阳周氏 · 兵器铸造 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳周氏', '周·兵器世家', 'NOBLE', 'SECOND',
 '洛阳兵器铸造第一家，铁山坊刀剑甲胄名动江湖。',
 '周家祖上为前朝军器监匠户，周铁山打的刀能断三枚铜钱。周铸把铁匠铺做成洛阳最大兵器作坊，替镖局、军营、江湖客打兵器，却守死不铸暗器、不铸毒刃的祖训。',
 '不铸暗器，不铸毒刃',
 '洛阳·铁山坊、北邙炉场',
 '三锤叠火',
 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @f5 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '周铁山', '字镇岳', 'M', 'G1', '周家老太爷·铁山坊老炉头', 'MINOR_SUPPORT', 79,
 '["倔强","寡言","重诺"]', '赤膊时满背烫疤，手掌如铁，白发用一根铁簪束着',
 '洛阳铁山坊老炉头。祖上为前朝军器监匠户，他打的刀能斩断三枚铜钱；年轻时曾为一位落难将军铸剑，那柄剑后来在江湖上掀起一场血案，他从此闭口不谈，只在每年那将军的忌日多烧一炉炭。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '周铸', '字成器', 'M', 'G2', '周氏家主·铁山坊东家', 'MAJOR_SUPPORT', 47,
 '["沉稳","守规矩","认死理"]', '肩膀宽阔，手臂有新旧交叠的烫痕，说话简短',
 '铁山坊东家，掌洛阳兵器行。把铁山坊从一间铁匠铺做成洛阳最大的兵器作坊，替镖局、军营、江湖客都打兵器，也守着不铸暗器、不铸毒刃的祖训。有人出十倍价钱要他打一支透骨钉，他把人连人带银扔出了门。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '秦素问', NULL, 'F', 'G2', '周家主母·炉料掌事', 'MINOR_SUPPORT', 44,
 '["冷静","强硬","有谋"]', '衣着利落，手指修长，袖口常沾着一点铁灰',
 '秦家铁矿石商之女。嫁入周家后掌炉料与账目，能一眼看出铁矿石的成色；她替周家挡下过官府的兵器查抄，把一炉谋逆的刀说成了农具。周铸在外硬，她在内更硬，铁山坊的账从没人敢糊弄。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '岳红绡', NULL, 'F', 'G2', '周家二夫人·试剑人', 'EXTRA', 37,
 '["冷傲","爽利","重情"]', '身形颀长，右肩有一道旧剑伤，眼神极利',
 '原为江湖女剑客，重伤后被周铸所救。剑法犀利，伤好后留在铁山坊做试剑人，替周家试出无数好刀；她与周铸是主仆也是知己，却始终不肯正式入门，说进了门就试不出好剑了。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '方小炉', NULL, 'F', 'G2', '周家三夫人·女炉头', 'EXTRA', 31,
 '["憨厚","勤快","倔"]', '身形壮实，两臂有力，手上全是烫疤，爱穿粗布短打',
 '铁山坊学徒出身，名字是周铁山取的。从小在炉边长大，能凭火色判断钢水的火候；是周家唯一的女炉头，性子憨直，认准的活儿九头牛也拉不回来。她打的菜刀在洛阳厨行里小有名气。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '韩杏儿', NULL, 'F', 'G2', '周家四夫人', 'EXTRA', 27,
 '["温软","灵巧","会来事"]', '圆脸，笑起来嘴角有个小窝，身上总带着饭菜香',
 '洛阳杏花楼酒家的厨娘，做得一手好菜。周铸常去她的酒家吃饭，吃着吃着就把人娶回了家；她不会打铁，却把铁山坊上下的饭食与人心都拢得暖和。谁家炉子灭了火，先想到的是去她灶上借个火。',
 0, 0, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_c3 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '周鼎', '字承炉', 'M', 'G3', '周家嫡长子', 'MAJOR_SUPPORT', 21,
 '["专注","木讷","执拗"]', '身形高大，眉目沉静，手臂上的肌肉是常年抡锤练出来的',
 '名字压着百炼成钢、一言九鼎的意思，臂力惊人，十六岁就能独立开炉。他痴迷于复原一种失传的百炼钢法，常把自己关在炉房三天不出来。父亲说他钻牛角尖，老太爷却把自己的旧锤给了他。',
 0, 1, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f5, @novel, '周铃', NULL, 'F', 'G3', '周家二小姐', 'MINOR_SUPPORT', 16,
 '["跳脱","勇莽","爱笑"]', '扎两条短辫，腰间别着一对小巧短剑，走路一蹦一跳',
 '自幼跟着岳氏学剑，又偷学炉上的手艺，打了一对薄如蝉翼的短剑；她性子野，常女扮男装混进镖队出城。母亲岳红绡骂她不像话，转头却替她把剑刃重新磨了一遍。',
 0, 0, 8, 'admin', NOW(), 'admin', NOW(), 0);
SET @zh_k2 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @zh_g1, 'MEMBER', @zh_head, 'FATHER_SON', '周铁山之子周铸', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_head, 'MEMBER', @zh_w, 'SPOUSE', '周铸与发妻秦素问', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_head, 'MEMBER', @zh_c1, 'SPOUSE', '周铸与二夫人岳红绡', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_head, 'MEMBER', @zh_c2, 'SPOUSE', '周铸与三夫人方小炉', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_head, 'MEMBER', @zh_c3, 'SPOUSE', '周铸与四夫人韩杏儿', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_head, 'MEMBER', @zh_k1, 'FATHER_SON', '周铸之子周鼎', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_w, 'MEMBER', @zh_k1, 'MOTHER_SON', '秦素问之子周鼎', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_head, 'MEMBER', @zh_k2, 'FATHER_DAUGHTER', '周铸之女周铃', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_c1, 'MEMBER', @zh_k2, 'MOTHER_DAUGHTER', '岳红绡之女周铃', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zh_k1, 'MEMBER', @zh_k2, 'BROTHER_SISTER', '周鼎与妹妹周铃', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

-- ---------------- 六、洛阳吴氏 · 酒楼 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳吴氏', '吴·酒楼世家', 'NOBLE', 'SECOND',
 '洛阳南市第一楼醉仙楼东家，创洛阳十二味，三教九流汇集之地。',
 '吴老夫人柳氏守着丈夫留下的醉仙楼四十年，把一间小酒肆做成南市第一楼，立下楼上不探客来历的规矩。吴醉仙接掌后开到三家分号，养一班说书人聚客，酒楼成了洛阳消息最灵的地方。',
 '客不问出处，酒不短分毫',
 '洛阳·南市醉仙楼三号',
 '酒旗衔月',
 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @f6 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f6, @novel, '柳氏', '吴门柳氏', 'F', 'G1', '吴家老太君·醉仙楼老东家', 'MINOR_SUPPORT', 72,
 '["豁达","精明","嘴严"]', '圆脸慈眉，鬓边一朵旧绢花，手里一把蒲扇',
 '醉仙楼老东家。丈夫是醉仙楼创始人，死后她守着酒楼四十年，把一间小酒肆做成洛阳南市第一楼；她最得意的不是菜，是楼上从不打探客人的来历这条规矩。谁在楼上说了什么，她听过就忘。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @w_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f6, @novel, '吴醉仙', '字逢春', 'M', 'G2', '吴氏家主·醉仙楼东家', 'MAJOR_SUPPORT', 46,
 '["豪爽","圆滑","好热闹"]', '身形微胖，笑声爽朗，腰上挂一串酒葫芦',
 '现任东家，名字是母亲改的。他把醉仙楼从一间酒楼扩成三家分号，创洛阳十二味，又养了一班说书人替酒楼聚客；他爱交朋友，三教九流都能在楼上喝一杯。他记性好，谁爱吃什么菜，第二次来就不用问。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @w_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f6, @novel, '许清欢', NULL, 'F', 'G2', '吴家主母·酒窖掌事', 'MINOR_SUPPORT', 43,
 '["爽利","细心","嘴硬心软"]', '眉眼利落，围裙上总沾着一点酒渍，说话快',
 '许家酒坊之女，酿酒的祖传手艺。嫁入吴家后掌酒窖与后厨，醉仙楼的醉仙酿就是她改的方子；她嘴上嫌吴醉仙太爱交朋友，暗里却替他把关每一位贵客。她最恨有人在酒里掺水。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @w_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f6, @novel, '沈碧桃', NULL, 'F', 'G2', '吴家二夫人·楼中歌者', 'EXTRA', 36,
 '["温柔","通透","藏得住事"]', '眼波柔和，常着藕色衣裙，怀抱一面月琴',
 '原是醉仙楼唱曲的姑娘。一曲《洛阳夜》唱得满楼客静；她被吴醉仙纳后仍上台唱曲，是醉仙楼招客的招牌，也是各方消息的汇聚处。她听得多了，自然知道什么该忘、什么该记。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @w_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f6, @novel, '金巧巧', NULL, 'F', 'G2', '吴家三夫人', 'EXTRA', 30,
 '["活泼","精明","爱美"]', '鬓边常换新鲜珠花，笑起来眼睛弯成月牙，身上有果酒香',
 '胡商酒肆的掌柜之女。会调西域果酒，替吴家添了胡姬酒这一路生意；她爱笑爱闹，把醉仙楼的后院经营得像个小小的胡市。她与沈氏一个唱曲一个调酒，把南市的夜拢得热热闹闹。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @w_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f6, @novel, '吴酌', '字品之', 'M', 'G3', '吴家嫡长子', 'MAJOR_SUPPORT', 20,
 '["洒脱","机灵","好胜"]', '身形清瘦，衣着讲究，手里常执一把折扇',
 '名字取斟酌之意，自幼学品酒；他不爱读书，却能把洛阳城里每一家酒楼的招牌菜说得头头是道，正悄悄筹备自己的第四家分号。父亲说他毛躁，他说等分号开起来，看谁还说毛躁。',
 0, 1, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @w_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f6, @novel, '吴小满', NULL, 'F', 'G3', '吴家二小姐', 'MINOR_SUPPORT', 17,
 '["娇俏","痴情","敏感"]', '梳双环髻，穿鹅黄衫子，笑起来声音像铃',
 '嗓子清亮，接母亲的班在楼上唱曲；她与一位常来的年轻剑客互生情意，却连对方真名都不知道。她把这桩心事只唱进曲里，沈碧桃听出来了，也没点破。',
 0, 0, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @w_k2 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @w_g1, 'MEMBER', @w_head, 'MOTHER_SON', '吴门柳氏之子吴醉仙', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_head, 'MEMBER', @w_w, 'SPOUSE', '吴醉仙与发妻许清欢', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_head, 'MEMBER', @w_c1, 'SPOUSE', '吴醉仙与二夫人沈碧桃', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_head, 'MEMBER', @w_c2, 'SPOUSE', '吴醉仙与三夫人金巧巧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_head, 'MEMBER', @w_k1, 'FATHER_SON', '吴醉仙之子吴酌', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_w, 'MEMBER', @w_k1, 'MOTHER_SON', '许清欢之子吴酌', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_head, 'MEMBER', @w_k2, 'FATHER_DAUGHTER', '吴醉仙之女吴小满', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_c1, 'MEMBER', @w_k2, 'MOTHER_DAUGHTER', '沈碧桃之女吴小满', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @w_k1, 'MEMBER', @w_k2, 'BROTHER_SISTER', '吴酌与妹妹吴小满', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

-- ---------------- 七、洛阳郑氏 · 镖局 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳郑氏', '郑·镖局世家', 'NOBLE', 'SECOND',
 '洛阳镖局之首，千里镖局走洛阳至长安最险一路，从未失镖。',
 '郑千里独走十三省得名郑千里，晚年废了一条腿仍守镖局门口。郑镖接旗后缩镖路为五省，把洛阳到长安的险路走成铁招牌，与漕帮、盐商、官府立下镖银分成的默契。',
 '镖在人在，镖失人亡',
 '洛阳·西关镖局、黑风岭镖路',
 '铁拐挑旗',
 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @f7 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '郑千里', '字行远', 'M', 'G1', '郑家老太爷·千里镖局老总镖头', 'MINOR_SUPPORT', 77,
 '["豪迈","守义","倔"]', '白发独眼，左脸一道旧疤，拄一根铁拐，坐姿仍像在马上',
 '千里镖局老总镖头。年轻时独走十三省，从未失镖，江湖上送他郑千里的名号；晚年一条腿废在刀伤上，仍每天在镖局门口坐一个时辰，看后辈走镖。他说镖旗不是布，是郑家人的脸。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '郑镖', '字守旗', 'M', 'G2', '郑氏家主·总镖头', 'MAJOR_SUPPORT', 49,
 '["沉稳","守信","狠"]', '国字脸，右眉一道刀痕，腰间一柄厚背刀，站如铁塔',
 '现任总镖头，接父亲的镖旗。他把郑家镖路从十三省缩到五省，却把洛阳到长安这条最险的路走成了铁招牌；与漕帮、盐商、官府都有镖银分成的默契。下手时从不留余地，对兄弟却从不含糊。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '孟三娘', NULL, 'F', 'G2', '郑家主母·副总镖头', 'MINOR_SUPPORT', 45,
 '["泼辣","果决","护短"]', '身形高挑，眉目英气，一柄大刀从不离身',
 '孟家拳馆出身，一手大刀使得极好。嫁入郑家后做了镖局的副总镖头，专管女镖师与内宅；她曾在黑风岭独退十七骑，救回整队镖银，镖局上下都服她。她骂人凶，护人更凶。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '马飞燕', NULL, 'F', 'G2', '郑家二夫人·飞镖镖师', 'EXTRA', 38,
 '["直爽","悍勇","好胜"]', '肤色微深，扎高马尾，腰挎两把短刀，走路带风',
 '原是塞外马帮的女骑士。骑术无双，替郑家走最急的飞镖；她性子直，与孟三娘常拌嘴，却也是最信得过的搭档。她在塞外还有一队旧部，每年秋天都会托人送一坛马奶酒来。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '罗青鸾', NULL, 'F', 'G2', '郑家三夫人·枪法教头', 'EXTRA', 32,
 '["冷冽","坚韧","记仇"]', '身量清瘦，一杆银枪从不离手，眼底常压着一层冷意',
 '罗家枪法传人，因家道中落投郑家。一杆银枪使得出神入化，是镖局里唯一能跟郑镖对拆三十招的人；她心里藏着一段灭门的旧仇，进郑家这些年从未提起。她只教儿子枪，不教他恨。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '曹阿蛮', NULL, 'F', 'G2', '郑家四夫人', 'EXTRA', 26,
 '["憨直","勤恳","害羞"]', '身量结实，手臂有力，常穿粗布短打，笑起来有些局促',
 '洛阳城外猎户之女，力大过人。能单手提起百斤镖箱，是镖局里最不起眼也最能吃苦的人；她喜欢郑一镖，却不敢说。每次郑一镖出镖，她都把镖箱多捆一道绳。',
 0, 0, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_c3 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '郑一镖', '字清平', 'M', 'G3', '郑家嫡长子', 'MAJOR_SUPPORT', 24,
 '["正直","温和","优柔"]', '眉目端正，身上有股少年人的清正气，刀佩在左腰',
 '名字是老太爷取的，盼他一辈子只走一趟镖也清清白白；他刀法得孟氏真传，镖路上的规矩比谁都熟，只是心太软。黑风岭上遇着落难的劫匪，他宁可自己赔镖银也不肯下死手。',
 0, 1, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '郑双燕', NULL, 'F', 'G3', '郑家二小姐·镖师', 'MINOR_SUPPORT', 19,
 '["飒爽","直率","要强"]', '扎马尾，着短打，腰间两把短刀，眼神亮得像刀光',
 '骑马如飞，善使双短刀；她跟着马氏走飞镖，是镖局里最年轻的镖师，也是曹阿蛮心里那个人。她嘴上嫌曹阿蛮管得宽，出征前却总把最重的那口箱子留给她提。',
 0, 0, 8, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_k2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f7, @novel, '郑三宝', '字小宝', 'M', 'G3', '郑家三少爷', 'MINOR_SUPPORT', 14,
 '["机灵","好动","敏感"]', '个头不高，眼睛极亮，手里常攥一根短木枪',
 '年纪最小，枪法却学得最快；罗青鸾把灭门旧仇压在心底，只教他枪，不教他恨。他隐约知道母亲有事瞒着，却懂事地不问，只在练枪时比谁都用力。',
 0, 0, 9, 'admin', NOW(), 'admin', NOW(), 0);
SET @zheng_k3 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @zheng_g1, 'MEMBER', @zheng_head, 'FATHER_SON', '郑千里之子郑镖', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_head, 'MEMBER', @zheng_w, 'SPOUSE', '郑镖与发妻孟三娘', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_head, 'MEMBER', @zheng_c1, 'SPOUSE', '郑镖与二夫人马飞燕', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_head, 'MEMBER', @zheng_c2, 'SPOUSE', '郑镖与三夫人罗青鸾', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_head, 'MEMBER', @zheng_c3, 'SPOUSE', '郑镖与四夫人曹阿蛮', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_head, 'MEMBER', @zheng_k1, 'FATHER_SON', '郑镖之子郑一镖', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_w, 'MEMBER', @zheng_k1, 'MOTHER_SON', '孟三娘之子郑一镖', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_head, 'MEMBER', @zheng_k2, 'FATHER_DAUGHTER', '郑镖之女郑双燕', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_c1, 'MEMBER', @zheng_k2, 'MOTHER_DAUGHTER', '马飞燕之女郑双燕', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_head, 'MEMBER', @zheng_k3, 'FATHER_SON', '郑镖之子郑三宝', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_c2, 'MEMBER', @zheng_k3, 'MOTHER_SON', '罗青鸾之子郑三宝', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_k1, 'MEMBER', @zheng_k2, 'BROTHER_SISTER', '郑一镖与妹妹郑双燕', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_k1, 'MEMBER', @zheng_k3, 'BROTHERS', '郑一镖与弟弟郑三宝', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @zheng_k2, 'MEMBER', @zheng_k3, 'SISTER_BROTHER', '郑双燕与弟弟郑三宝', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

-- ---------------- 八、洛阳王氏 · 书院讼事 ----------------
INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳王氏', '王·书院世家', 'NOBLE', 'THIRD',
 '洛阳鸿儒书院山长之家，兼理讼事，文名与讼名并重。',
 '王鸿儒科场失意后办书院，教出三位进士，兼替百姓写状纸，人称王青天。王敬之接掌时只剩三间破屋，靠替商贾打官司挣回一座新院，也把洛阳半数讼案攥成了人脉。',
 '读书明理，执笔持正',
 '洛阳·鸿儒书院、府前讼馆',
 '青简悬笔',
 8, 'admin', NOW(), 'admin', NOW(), 0);
SET @f8 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f8, @novel, '王鸿儒', '字砚秋', 'M', 'G1', '王家老太爷·鸿儒书院山长', 'MINOR_SUPPORT', 80,
 '["清高","刚直","固执"]', '清瘦，长衫洗得发白，手持一卷旧书，走路慢而稳',
 '前朝举人，科场失意后办书院，教出过三位进士；他兼替人写状纸、理讼事，洛阳百姓叫他王青天，官府却叫他王麻烦。他至今不肯让书院挂任何商号的匾，说读书人的门楣不能沾铜臭。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @wang_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f8, @novel, '王敬之', '字慎言', 'M', 'G2', '王氏家主·山长兼讼会会首', 'MAJOR_SUPPORT', 48,
 '["儒雅","善辩","城府"]', '面容清癯，着一身竹青长衫，说话温文，目光却极深',
 '现任山长，兼洛阳讼师行会会首。他接书院时只剩三间破屋，靠替商贾打官司挣回一座新院；他嘴上讲仁义，手里却把洛阳一半的讼案攥成了人脉网。父亲骂他把书院办成讼师铺子，他说先让书院活下去再谈斯文。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @wang_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f8, @novel, '崔文君', NULL, 'F', 'G2', '王家主母·女学掌教', 'MINOR_SUPPORT', 48,
 '["清雅","刚直","爱面子"]', '梳高髻，插一支素玉钗，衣饰讲究而不张扬',
 '崔家书香门第之女，工诗词。嫁入王家后掌书院女学，教洛阳闺秀读书识字；她看不惯丈夫把书院变成讼师铺子，常在人前与他争一句斯文扫地。争完了，夜里还是替他把状纸上的字句润色一遍。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @wang_w := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f8, @novel, '谢兰因', NULL, 'F', 'G2', '王家二夫人·琴师', 'EXTRA', 40,
 '["温婉","聪慧","谨慎"]', '眉眼柔和，指尖有抚琴磨出的薄茧，常着浅碧色衣裙',
 '原是洛阳教坊的琴师。琴艺清绝，被王敬之纳后仍教女学里的姑娘抚琴；她替王家结交了不少官眷，也听了不少不该听的私话。她知道哪些话该带回来，哪些话该烂在肚子里。',
 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0);
SET @wang_c1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f8, @novel, '杜若蘅', NULL, 'F', 'G2', '王家三夫人', 'EXTRA', 34,
 '["淡雅","隐忍","通透"]', '衣着素淡，身上有淡淡的药香与沉香气，说话轻缓',
 '药商之女，擅医理与香道。她替书院照料学子与女眷的病痛，也替王敬之调安神香；她心里明白自己只是王家的体面摆设，却不争不闹。她常说人活一世，能把别人的急痛缓一缓，就不算白活。',
 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0);
SET @wang_c2 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f8, @novel, '王怀瑾', '字握瑜', 'M', 'G3', '王家嫡长子', 'MAJOR_SUPPORT', 22,
 '["清正","孤傲","理想主义"]', '身形清瘦，眉目疏朗，常着一身洗旧的书生袍',
 '书院最年轻的讲书，文章写得漂亮，却厌恶父亲拿官司换人情；他一心想考功名，走一条干净的路。他在书院讲《论语》讲到君子不器时，台下有人笑，他也笑，笑完继续讲。',
 0, 1, 6, 'admin', NOW(), 'admin', NOW(), 0);
SET @wang_k1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@f8, @novel, '王怀瑜', NULL, 'F', 'G3', '王家二小姐', 'MINOR_SUPPORT', 18,
 '["聪慧","沉静","有分寸"]', '眉眼清秀，常着月白衫裙，腕上戴一只旧玉镯',
 '琴棋书画皆通，尤其一手字承了母亲的家学；她常替父亲誊写状纸，因而知道王家许多见不得光的官司。她从不外说，只在抄到冤情处把笔顿一顿。',
 0, 0, 7, 'admin', NOW(), 'admin', NOW(), 0);
SET @wang_k2 := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @wang_g1, 'MEMBER', @wang_head, 'FATHER_SON', '王鸿儒之子王敬之', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_head, 'MEMBER', @wang_w, 'SPOUSE', '王敬之与发妻崔文君', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_head, 'MEMBER', @wang_c1, 'SPOUSE', '王敬之与二夫人谢兰因', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_head, 'MEMBER', @wang_c2, 'SPOUSE', '王敬之与三夫人杜若蘅', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_head, 'MEMBER', @wang_k1, 'FATHER_SON', '王敬之之子王怀瑾', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_w, 'MEMBER', @wang_k1, 'MOTHER_SON', '崔文君之子王怀瑾', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_head, 'MEMBER', @wang_k2, 'FATHER_DAUGHTER', '王敬之之女王怀瑜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_c1, 'MEMBER', @wang_k2, 'MOTHER_DAUGHTER', '谢兰因之女王怀瑜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wang_k1, 'MEMBER', @wang_k2, 'BROTHER_SISTER', '王怀瑾与妹妹王怀瑜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

COMMIT;
