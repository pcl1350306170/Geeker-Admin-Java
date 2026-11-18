-- ============================================================
-- 《烟雨江湖》洛阳扬威镖局万家
-- 目标小说：novel_id = 4（烟雨江湖）
-- 人物：万震山（G1，老太爷）→ 万青山（G2，家主）→ 夫人香湘
-- 关系：父子、夫妻
-- 执行方式：mysql --execute="source D:/CODE/Java/Geeker-Admin-Java/src/main/resources/novel_family_yanyu_wan.sql"
-- ============================================================

START TRANSACTION;

SET @novel := 4;

INSERT INTO novel_family
(novel_id, name, alias, type, status, introduction, background, creed, territory, emblem, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, '洛阳万家', '万·扬威镖局', 'NOBLE', 'SECOND',
 '洛阳东关扬威镖局东家，与西关郑氏千里镖局并称西郑东万。',
 '万震山以一双铁掌在东关立起扬威镖局的旗号，最盛时镖路直通幽燕。万青山接掌后把镖局做到东城最大，与郑家争镖路也互相帮衬；如今镖局表面风光，暗里被几家新起的脚行分走生意。',
 '镖旗不倒，镖银不失',
 '洛阳·东关扬威镖局、洛水镖路',
 '铁掌托旗',
 9, 'admin', NOW(), 'admin', NOW(), 0);
SET @fw := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@fw, @novel, '万震山', '字镇远', 'M', 'G1', '万家老太爷·扬威镖局创始人', 'MINOR_SUPPORT', 78,
 '["火爆","护短","念旧"]', '虎背熊腰，白发如雪，双掌指节粗大，掌背有一道陈年刀疤',
 '扬威镖局创始人，绰号铁掌震山。年轻时在洛阳东关一拳打翻十三坞的马匪头子，立起扬威的旗号，最盛时镖路直通幽燕。与郑千里是斗了半辈子的老对手，也是一起喝过半夜酒的老友。晚年手抖得端不稳茶，仍每天清早去摸一遍镖局的镖旗。',
 0, 1, 1, 'admin', NOW(), 'admin', NOW(), 0);
SET @wan_g1 := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@fw, @novel, '万青山', '字映川', 'M', 'G2', '万家家主·扬威镖局总镖头', 'MAJOR_SUPPORT', 47,
 '["沉稳","守信","外柔内刚"]', '身形挺拔，眉目方正，常着玄色劲装，腰间一柄雁翎刀',
 '扬威镖局现任总镖头。接镖局二十年，把东关一间小院做成洛阳东城最大的镖局，与郑家既争镖路又互相帮衬。为人比父亲沉得住气，最恨镖局里有人仗势欺人；遇上丢了镖的散户，他宁可自己垫银子也要把镖找回来。',
 1, 1, 2, 'admin', NOW(), 'admin', NOW(), 0);
SET @wan_head := LAST_INSERT_ID();

INSERT INTO novel_family_member
(family_id, novel_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@fw, @novel, '香湘', NULL, 'F', 'G2', '万家主母·镖局内务掌事', 'MINOR_SUPPORT', 43,
 '["温婉","果断","嘴甜心细"]', '眉眼柔和，鬓边一支银簪，袖口常沾着药末',
 '万青山之妻，镖局内务与伤药掌事。原是洛水边香家车马行的女儿，一手金疮药方极灵；她管着镖局的账、马料与伤号，镖师们受了伤都先喊一声香嫂子。她与万青山是少年夫妻，曾陪他走过那趟丢了镖的黑风岭，回来后缝了半夜的镖旗。',
 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0);
SET @wan_w := LAST_INSERT_ID();

INSERT INTO novel_relation
(novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted)
VALUES
(@novel, 'MEMBER', @wan_g1, 'MEMBER', @wan_head, 'FATHER_SON', '万震山之子万青山', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(@novel, 'MEMBER', @wan_head, 'MEMBER', @wan_w, 'SPOUSE', '万青山与发妻香湘', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);

COMMIT;
