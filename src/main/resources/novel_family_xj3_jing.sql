-- ============================================================
-- 仙剑三同人 · 景家 测试数据
-- 背景：《仙剑奇侠传三》景天家庭 + 参考文件《人物设定_城镇迷宫女性篇_完善版》
-- 设计：景逸/朱珠/景天为核心；34 位城镇迷宫女性角色作为景天暧昧/羁绊对象
-- 幂等：可重复执行（先逻辑删除本脚本数据域再 upsert）
-- ============================================================

-- 1) 清理本脚本数据域（幂等）
UPDATE novel_relation SET deleted = 1 WHERE novel_id = 3 AND id BETWEEN 101 AND 137;
UPDATE novel_family_member SET deleted = 1 WHERE novel_id = 3 AND id BETWEEN 61 AND 97;
UPDATE novel_family SET deleted = 1 WHERE id = 8;

-- 2) 家族：景家（渝州永安当）
INSERT INTO novel_family (id, novel_id, name, alias, type, status, introduction, background, creed, territory, sort, created_by, created_at, updated_by, updated_at, deleted)
VALUES (8, 3, '景家', '永安当景家', 'MERCHANT', 'RISING',
        '渝州永安当的景家，当铺管事景逸夫妇育有一子景天。景天生性乐观机灵，重情重义，一路行侠仗义，与江湖中诸多奇女子结下不解之缘。',
        '景家世居渝州，景逸为永安当管事，与唐家堡掌门唐坤交好。当年正是景逸在大雪中拾得孤女雪见，交与唐坤收养。景天长大后重开永安当，虽出身市井，却屡次卷入仙魔大劫，终成一方传说。',
        '景家家训：人不可貌相，货不可估量；做人要讲义气。',
        '渝州·永安当', 2, 'admin', NOW(), 'admin', NOW(), 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), type = VALUES(type), status = VALUES(status), introduction = VALUES(introduction), background = VALUES(background), creed = VALUES(creed), territory = VALUES(territory), deleted = 0;

-- 3) 成员（37 人：核心 3 + 女性角色 34）
INSERT INTO novel_family_member (id, novel_id, family_id, name, alias, gender, generation, title, role_type, age, personality, appearance, bio, is_head, is_core, sort, created_by, created_at, updated_by, updated_at, deleted) VALUES
(61, 3, 8, '景逸', NULL, 'M', 'G1', '永安当管事', 'MAJOR_SUPPORT', 48, '忠厚老实，古道热肠', '眉目和善，常着粗布长衫', '永安当管事，景天之父，唐坤多年好友。当年在大雪中拾得女婴雪见，因无力照料交与唐坤收养。', 1, 0, 1, 'admin', NOW(), 'admin', NOW(), 0),
(62, 3, 8, '朱珠', NULL, 'F', 'G1', '景逸之妻', 'MINOR_SUPPORT', 44, '慈爱爽利', '面容温婉，笑意盈盈', '景逸之妻，景天之母，操持永安当家业，对儿子景天疼爱有加。', 0, 0, 2, 'admin', NOW(), 'admin', NOW(), 0),
(63, 3, 8, '景天', '景少侠', 'M', 'G2', '渝州永安当·少东家', 'PROTAGONIST', 20, '乐观贪财，重情重义', '眉清目秀，常带笑意', '景逸与朱珠之子，永安当少东家。生性乐天、爱财惜命，却屡屡为朋友两肋插刀，卷入仙魔大劫，与江湖众多奇女子结下或深或浅的缘分。', 0, 1, 3, 'admin', NOW(), 'admin', NOW(), 0),
(64, 3, 8, '苏沅', NULL, 'F', 'G2', '渝州西城商会·幕后执掌', 'MAJOR_SUPPORT', 26, '精明妩媚', '杏眼含波，妆饰华贵', '渝州西城商会暗中的执掌者，永安当一带江湖商贸都要给她面子，黑白两道通吃，是人间江湖强者。', 0, 0, 4, 'admin', NOW(), 'admin', NOW(), 0),
(65, 3, 8, '阮缃', NULL, 'F', 'G2', '宾化·城防谍报主事', 'MINOR_SUPPORT', 24, '温婉缜密', '书香气质，眉眼沉静', '宾化城暗中的城防主事，掌管密探与驿站消息，擅长迷香谍报，在宾化布下眼线。', 0, 0, 5, 'admin', NOW(), 'admin', NOW(), 0),
(66, 3, 8, '裴汀', NULL, 'F', 'G2', '镇江虎踞镖局·幕后掌权', 'MINOR_SUPPORT', 25, '利落飒爽', '劲装束发，眉锋凌厉', '镇江虎踞镖局背后真正的掌权女子，熟悉江上水匪势力，剑法利落，掌控码头货运与往来情报。', 0, 0, 6, 'admin', NOW(), 'admin', NOW(), 0),
(67, 3, 8, '唐蘅', NULL, 'F', 'G2', '唐家堡·用毒女长老', 'MAJOR_SUPPORT', 40, '沉静狠绝', '雍容贵妇，指尖藏毒', '唐家堡幕后的用毒女当家，唐雪见的族中长辈，外似雍容贵妇，谈笑间可取人性命。对雪见暗藏几分祖辈怜惜。', 0, 0, 7, 'admin', NOW(), 'admin', NOW(), 0),
(68, 3, 8, '秦菸', NULL, 'F', 'G2', '德阳·乡团首领', 'MINOR_SUPPORT', 27, '干练飒爽', '短衣束袖，腰挎短刃', '德阳本地乡团首领，与霹雳堂合作又互相提防，熟稔民间医毒，统领城中乡勇。', 0, 0, 8, 'admin', NOW(), 'admin', NOW(), 0),
(69, 3, 8, '柳眠', NULL, 'F', 'G2', '安宁村·女主人', 'MINOR_SUPPORT', 28, '温婉妖异', '白日笑颜，入夜妖影', '安宁村村长之妻，白日温婉周到，入夜化作妖影将村庄锁进美梦幻境，护村心切，并非自愿为祸。', 0, 0, 9, 'admin', NOW(), 'admin', NOW(), 0),
(70, 3, 8, '霜岚', NULL, 'F', 'G2', '蜀山·御剑女弟子', 'MAJOR_SUPPORT', 23, '冷面铁腕', '素青道袍，剑气凝霜', '蜀山派当代最出众的女弟子，清微门下剑心通明，奉命镇守主峰与锁妖塔外围，御剑时剑气凛冽如霜。', 0, 0, 10, 'admin', NOW(), 'admin', NOW(), 0),
(71, 3, 8, '雷潋', NULL, 'F', 'G2', '雷州·城主之女', 'MAJOR_SUPPORT', 22, '豪迈刚烈', '明艳张扬，雷电缠身', '雷州城主之女，雷灵珠异动之夜觉醒雷电之力，以比武招亲为名设擂搜罗能人，实为探查雷州异象。', 0, 0, 11, 'admin', NOW(), 'admin', NOW(), 0),
(72, 3, 8, '苗铃', NULL, 'F', 'G2', '蛮州·女祭司', 'MINOR_SUPPORT', 21, '坦率爽直', '蓝靛苗装，腕悬银铃', '蛮州苗寨的年轻女祭司，通晓蛊术巫术与百草解毒，与女娲遗族一脉有隐秘渊源。', 0, 0, 12, 'admin', NOW(), 'admin', NOW(), 0),
(73, 3, 8, '韶华', NULL, 'F', 'G2', '古城镇·幻境美人', 'MINOR_SUPPORT', 26, '痴守旧梦', '华裳云鬓，神色恍惚', '被封印在百年前古城幻影里的美人，操控古城幻境重现旧日繁华，守着城等着一个早已不会回来的人。', 0, 0, 13, 'admin', NOW(), 'admin', NOW(), 0),
(74, 3, 8, '曼珠', NULL, 'F', 'G2', '酆都·引魂使者', 'MINOR_SUPPORT', 25, '凄艳疏离', '红衣如彼岸花开，手提引魂灯', '酆都鬼城奈何桥畔的引魂使者，接引亡魂送人轮回，以灯照人心、以幻象试真心。', 0, 0, 14, 'admin', NOW(), 'admin', NOW(), 0),
(75, 3, 8, '寒酥', NULL, 'F', 'G2', '雪岭镇·猎户之女', 'MINOR_SUPPORT', 20, '直率利落', '皮裘劲装，眉睫沾雪', '雪岭镇猎户之女，善使猎弓与冰棱暗器，熟知雪原每一处冰窟兽道，是镇上最能打的姑娘。', 0, 0, 15, 'admin', NOW(), 'admin', NOW(), 0),
(76, 3, 8, '渔晚', NULL, 'F', 'G2', '安溪·渔家女', 'MINOR_SUPPORT', 19, '温柔质朴', '颈佩鲛珠，明眸如水', '安溪渔村姑娘，水性极佳，颈间佩着来历不明的鲛珠，能预知潮汛与水下动静，知晓海底城线索。', 0, 0, 16, 'admin', NOW(), 'admin', NOW(), 0),
(77, 3, 8, '王雪', NULL, 'F', 'G2', '璧山·猫妖', 'MINOR_SUPPORT', 18, '俏皮狡黠', '白衣少女，眉眼带三分狡黠', '璧山深处修炼百年的雪白猫妖，身法轻灵如风，惯在山道设绊藤戏弄行人，并非恶妖只是顽劣。', 0, 0, 17, 'admin', NOW(), 'admin', NOW(), 0),
(78, 3, 8, '苏酩漪', NULL, 'F', 'G2', '九龙坡·酒妖', 'MINOR_SUPPORT', 24, '豪爽率性', '绯衣醉眼，面若桃花', '千年美酒化形的绯衣女子，周身酒香馥郁，善以醉雾迷香困人，却从不害人性命，好酒成痴。', 0, 0, 18, 'admin', NOW(), 'admin', NOW(), 0),
(79, 3, 8, '葭溯', NULL, 'F', 'G2', '大渡口·滩泽妖', 'MINOR_SUPPORT', 23, '野媚灵动', '苇草缀身，眸含水泽', '大渡口河滩芦苇里诞生的妖，掌控芦苇淤泥与沼泽陷阱，木水双属性，常隐身茫茫芦荡。', 0, 0, 19, 'admin', NOW(), 'admin', NOW(), 0),
(80, 3, 8, '沧湄', NULL, 'F', 'G2', '长江·水灵', 'MINOR_SUPPORT', 25, '清柔执拗', '烟波行舟，容貌清柔', '长江水灵所化，掌管水道暗流与江雾，能掀江浪引漩涡截停航船，擅长水属性仙术。', 0, 0, 20, 'admin', NOW(), 'admin', NOW(), 0),
(81, 3, 8, '海若', NULL, 'F', 'G2', '蓬莱外海·海妖', 'MINOR_SUPPORT', 27, '疏离苍茫', '青碧鳞裙，踏浪而来', '蓬莱东渡外海的海妖，能掀吞舟巨浪、唤来鲸群开路，守着通往蓬莱的海上关隘，大海从不容情。', 0, 0, 21, 'admin', NOW(), 'admin', NOW(), 0),
(82, 3, 8, '云绡', NULL, 'F', 'G2', '蓬莱·守岛女仙', 'MINOR_SUPPORT', 29, '清冷仙气', '素白仙裙，周身海雾檀香', '蓬莱旧年的守岛女仙，不愿外人闯入秘境，精通防御仙术与幻术，擅长制造海市蜃楼。', 0, 0, 22, 'admin', NOW(), 'admin', NOW(), 0),
(83, 3, 8, '岑瑶', NULL, 'F', 'G2', '九顶山·山神之女', 'MINOR_SUPPORT', 23, '野性明媚', '草木青褐劲装，驱兽而行', '九顶山山神之女，掌控山岩落石与藤蔓，能驱使山中异兽，土系仙术强悍，镇守山道。', 0, 0, 23, 'admin', NOW(), 'admin', NOW(), 0),
(84, 3, 8, '炎绾', NULL, 'F', 'G2', '霹雳堂·女主事', 'MINOR_SUPPORT', 26, '刚烈果决', '红衣劲装，火药在手', '霹雳堂隐秘的火器毒术女首领，雷啸天之外暗中执掌火药毒烟，精通火雷术与机关火药。', 0, 0, 24, 'admin', NOW(), 'admin', NOW(), 0),
(85, 3, 8, '藤萝', NULL, 'F', 'G2', '古藤林·藤妖', 'MINOR_SUPPORT', 22, '执拗天真', '青藤罗裙，十指柔韧', '古藤林深处缠枝而生的藤萝精，藤蔓遍布整片林地，能操纵机关困住闯入者，捉人先要"审"清来意。', 0, 0, 25, 'admin', NOW(), 'admin', NOW(), 0),
(86, 3, 8, '拾磴', NULL, 'F', 'G2', '蜀山故道·石灵', 'MINOR_SUPPORT', 30, '沉静无波', '通体如青石雕琢', '蜀山故道尽头镇守千阶石磴的女石灵，受蜀山剑气浸染化形，操纵机关浮石与滚石落木，只认规矩。', 0, 0, 26, 'admin', NOW(), 'admin', NOW(), 0),
(87, 3, 8, '杳镜', NULL, 'F', 'G2', '神魔之井·镜魔女', 'MINOR_SUPPORT', 28, '无悲无喜', '身似古镜，映照人心', '神魔之井中段镇守的镜魔女，本体是一面古镜，能映出人心最深处的执念与恐惧，以幻象引渡来者。', 0, 0, 27, 'admin', NOW(), 'admin', NOW(), 0),
(88, 3, 8, '青梧', NULL, 'F', 'G2', '神树·守木之灵', 'MINOR_SUPPORT', 31, '沉静固执', '通体草木清芬，苍翠罗裙', '神树巨干根部化出的树灵，与树巅夕瑶相对，镇守神树根基，沉默寡言，只认神树为重。', 0, 0, 28, 'admin', NOW(), 'admin', NOW(), 0),
(89, 3, 8, '烟罗', NULL, 'F', 'G2', '锁妖塔·千年狐妖', 'MINOR_SUPPORT', 29, '媚骨天成', '青烟化形，笑里藏刀', '锁妖塔中段镇守的千年狐妖，曾惑乱众生被镇压入塔，以迷烟幻形考验闯入者，嘴硬心软。', 0, 0, 29, 'admin', NOW(), 'admin', NOW(), 0),
(90, 3, 8, '流萤', NULL, 'F', 'G2', '草海·萤火精灵', 'MINOR_SUPPORT', 19, '顽皮灵动', '周身笼着柔和萤光', '草海深处由万千萤火与草木灵气凝成的草精，能唤漫天萤火惑人视线，守护草海深处的灵物。', 0, 0, 30, 'admin', NOW(), 'admin', NOW(), 0),
(91, 3, 8, '紫烟', NULL, 'F', 'G2', '仙人洞·散修女仙', 'MINOR_SUPPORT', 32, '慵懒散漫', '道袍宽袖，丹香盈身', '隐居仙人洞深处的散修女仙，守着丹炉仙草与一洞奇珍，知晓不少上古仙门旧事，爱卖关子。', 0, 0, 31, 'admin', NOW(), 'admin', NOW(), 0),
(92, 3, 8, '赤烬', NULL, 'F', 'G2', '熔岩地狱·火魅', 'MINOR_SUPPORT', 26, '暴烈如火', '通体赤红，发梢燃火', '熔岩地狱深处由地火岩浆凝成的火魅，掌管地底岩浆潮与火系妖兵，性情暴烈一言不合便掀火雨。', 0, 0, 32, 'admin', NOW(), 'admin', NOW(), 0),
(93, 3, 8, '幽昙', NULL, 'F', 'G2', '黄泉路·鬼女', 'MINOR_SUPPORT', 27, '沉默寡言', '素衣幽灯，雾中立影', '黄泉路上引渡亡魂的鬼差女，手持幽蓝纸灯，以纸灯幻影与忘川雾气引人迷途，劝人回头。', 0, 0, 33, 'admin', NOW(), 'admin', NOW(), 0),
(94, 3, 8, '冰魄', NULL, 'F', 'G2', '冰风谷·冰妖', 'MINOR_SUPPORT', 28, '冷冽孤寂', '通体如冰雪雕琢，发垂冰凌', '冰风谷深处万年冰魄所化的女妖，镇守谷中最冷的玄冰之地，能召来暴风雪与冰锥，冷得不带人气。', 0, 0, 34, 'admin', NOW(), 'admin', NOW(), 0),
(95, 3, 8, '珊瑚', NULL, 'F', 'G2', '海底城·鲛人守将', 'MINOR_SUPPORT', 30, '冷冽重诺', '长发如海藻，鱼尾如纱', '海底城沉眠后苏醒的鲛人守将，守护水宫，能召来珊瑚屏障与水墙，重信重诺。', 0, 0, 35, 'admin', NOW(), 'admin', NOW(), 0),
(96, 3, 8, '承影', NULL, 'F', 'G2', '剑冢·剑灵', 'MINOR_SUPPORT', 33, '冷峻通透', '银白劲装，剑气凛冽', '剑冢深处上古名剑"承影"通灵所化的剑灵，评判来者是否配得上剑冢之剑——剑择心性不择强弱。', 0, 0, 36, 'admin', NOW(), 'admin', NOW(), 0),
(97, 3, 8, '飞琼', NULL, 'F', 'G2', '新仙界·守界仙娥', 'MINOR_SUPPORT', 34, '清冷高华', '衣袂如流霞翻卷', '新仙界灵台之上守界的九天仙娥，拨动云海星轨，只论天规，却为来者的执着微微侧目。', 0, 0, 37, 'admin', NOW(), 'admin', NOW(), 0);

-- 4) 关系（37 条：家庭 3 + 景天与女性角色 34）
INSERT INTO novel_relation (id, novel_id, source_type, source_id, target_type, target_id, relation_type, description, status, created_by, created_at, updated_by, updated_at, deleted) VALUES
(101, 3, 'MEMBER', 61, 'MEMBER', 62, 'SPOUSE', '景逸与朱珠夫妻', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(102, 3, 'MEMBER', 61, 'MEMBER', 63, 'FATHER_SON', '景逸与儿子景天', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(103, 3, 'MEMBER', 62, 'MEMBER', 63, 'MOTHER_SON', '朱珠与儿子景天', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(104, 3, 'MEMBER', 63, 'MEMBER', 64, 'LOVER', '景天与渝州商会女话事人苏沅的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(105, 3, 'MEMBER', 63, 'MEMBER', 65, 'LOVER', '景天与宾化谍报女首领阮缃的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(106, 3, 'MEMBER', 63, 'MEMBER', 66, 'LOVER', '景天与镇江镖局女当家裴汀的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(107, 3, 'MEMBER', 63, 'MEMBER', 67, 'CLOSE_FRIEND', '景天与唐家堡用毒长老唐蘅亦敌亦友', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(108, 3, 'MEMBER', 63, 'MEMBER', 68, 'LOVER', '景天与德阳乡勇女首领秦菸的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(109, 3, 'MEMBER', 63, 'MEMBER', 69, 'LOVER', '景天与安宁村幻梦女主人柳眠的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(110, 3, 'MEMBER', 63, 'MEMBER', 70, 'CLOSE_FRIEND', '景天与蜀山女剑仙霜岚试剑后惺惺相惜', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(111, 3, 'MEMBER', 63, 'MEMBER', 71, 'ENGAGED', '景天在雷州比武招亲胜出，与雷潋定下婚约', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(112, 3, 'MEMBER', 63, 'MEMBER', 72, 'LOVER', '景天与蛮州女祭司苗铃的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(113, 3, 'MEMBER', 63, 'MEMBER', 73, 'LOVER', '景天与古城幻境美人韶华的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(114, 3, 'MEMBER', 63, 'MEMBER', 74, 'LOVER', '景天与酆都引魂使者曼珠的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(115, 3, 'MEMBER', 63, 'MEMBER', 75, 'LOVER', '景天与雪岭猎户姑娘寒酥的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(116, 3, 'MEMBER', 63, 'MEMBER', 76, 'LOVER', '景天与安溪渔家女渔晚的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(117, 3, 'MEMBER', 63, 'MEMBER', 77, 'LOVER', '景天与璧山猫妖王雪的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(118, 3, 'MEMBER', 63, 'MEMBER', 78, 'LOVER', '景天与九龙坡酒妖苏酩漪的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(119, 3, 'MEMBER', 63, 'MEMBER', 79, 'LOVER', '景天与大渡口滩泽妖葭溯的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(120, 3, 'MEMBER', 63, 'MEMBER', 80, 'LOVER', '景天与长江水灵沧湄的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(121, 3, 'MEMBER', 63, 'MEMBER', 81, 'LOVER', '景天与蓬莱海妖海若的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(122, 3, 'MEMBER', 63, 'MEMBER', 82, 'LOVER', '景天与蓬莱守岛女仙云绡的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(123, 3, 'MEMBER', 63, 'MEMBER', 83, 'LOVER', '景天与九顶山山灵岑瑶的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(124, 3, 'MEMBER', 63, 'MEMBER', 84, 'LOVER', '景天与霹雳堂女主事炎绾的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(125, 3, 'MEMBER', 63, 'MEMBER', 85, 'LOVER', '景天与古藤林藤妖藤萝的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(126, 3, 'MEMBER', 63, 'MEMBER', 86, 'CLOSE_FRIEND', '景天与蜀道石灵拾磴以武会友', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(127, 3, 'MEMBER', 63, 'MEMBER', 87, 'LOVER', '景天与神魔之井镜魔女杳镜的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(128, 3, 'MEMBER', 63, 'MEMBER', 88, 'CLOSE_FRIEND', '景天与神树守木之灵青梧的草木之谊', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(129, 3, 'MEMBER', 63, 'MEMBER', 89, 'LOVER', '景天与锁妖塔千年狐妖烟罗的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(130, 3, 'MEMBER', 63, 'MEMBER', 90, 'LOVER', '景天与草海萤火精灵流萤的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(131, 3, 'MEMBER', 63, 'MEMBER', 91, 'LOVER', '景天与仙人洞散修女仙紫烟的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(132, 3, 'MEMBER', 63, 'MEMBER', 92, 'LOVER', '景天与熔岩火魅赤烬的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(133, 3, 'MEMBER', 63, 'MEMBER', 93, 'LOVER', '景天与黄泉路鬼女幽昙的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(134, 3, 'MEMBER', 63, 'MEMBER', 94, 'LOVER', '景天与冰风谷冰妖冰魄的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(135, 3, 'MEMBER', 63, 'MEMBER', 95, 'LOVER', '景天与海底城鲛人守将珊瑚的暧昧', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(136, 3, 'MEMBER', 63, 'MEMBER', 96, 'CLOSE_FRIEND', '景天与剑冢剑灵承影的剑灵之约', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0),
(137, 3, 'MEMBER', 63, 'MEMBER', 97, 'CLOSE_FRIEND', '景天与新仙界守界仙娥飞琼的仙缘', 'ACTIVE', 'admin', NOW(), 'admin', NOW(), 0);
