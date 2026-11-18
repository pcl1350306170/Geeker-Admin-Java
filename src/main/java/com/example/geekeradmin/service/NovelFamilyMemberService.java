package com.example.geekeradmin.service;

import com.example.geekeradmin.common.BusinessException;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.MemberImportDTO;
import com.example.geekeradmin.dto.MemberImportItemDTO;
import com.example.geekeradmin.dto.MemberQueryDTO;
import com.example.geekeradmin.dto.MemberSaveDTO;
import com.example.geekeradmin.entity.Novel;
import com.example.geekeradmin.entity.NovelFamily;
import com.example.geekeradmin.entity.NovelFamilyMember;
import com.example.geekeradmin.entity.NovelRelation;
import com.example.geekeradmin.entity.SysDictData;
import com.example.geekeradmin.mapper.NovelFamilyMapper;
import com.example.geekeradmin.mapper.NovelFamilyMemberMapper;
import com.example.geekeradmin.mapper.NovelMapper;
import com.example.geekeradmin.mapper.NovelRelationMapper;
import com.example.geekeradmin.vo.MemberDetailVO;
import com.example.geekeradmin.vo.MemberImportResultVO;
import com.example.geekeradmin.vo.MemberListVO;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 小说家族成员
 */
@Service
public class NovelFamilyMemberService {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    /** 单次批量导入条数上限 */
    private static final int MAX_IMPORT_SIZE = 500;

    @Autowired
    private NovelFamilyMemberMapper memberMapper;

    @Autowired
    private NovelFamilyMapper familyMapper;

    @Autowired
    private NovelRelationMapper relationMapper;

    @Autowired
    private NovelMapper novelMapper;

    @Autowired
    private DictService dictService;

    /**
     * 分页查询成员（含所属家族名）
     */
    public IPage<MemberListVO> getMemberPage(MemberQueryDTO query) {
        LambdaQueryWrapper<NovelFamilyMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NovelFamilyMember::getDeleted, 0);
        if (StringUtils.hasText(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            wrapper.and(w -> w.like(NovelFamilyMember::getName, kw)
                    .or().like(NovelFamilyMember::getAlias, kw)
                    .or().like(NovelFamilyMember::getTitle, kw));
        }
        if (query.getFamilyId() != null) {
            wrapper.eq(NovelFamilyMember::getFamilyId, query.getFamilyId());
        }
        if (query.getNovelId() != null) {
            wrapper.eq(NovelFamilyMember::getNovelId, query.getNovelId());
        }
        if (StringUtils.hasText(query.getGeneration())) {
            wrapper.eq(NovelFamilyMember::getGeneration, query.getGeneration());
        }
        if (StringUtils.hasText(query.getRoleType())) {
            wrapper.eq(NovelFamilyMember::getRoleType, query.getRoleType());
        }
        if (query.getIsCore() != null) {
            wrapper.eq(NovelFamilyMember::getIsCore, query.getIsCore());
        }
        wrapper.orderByAsc(NovelFamilyMember::getSort).orderByDesc(NovelFamilyMember::getUpdatedAt);

        IPage<NovelFamilyMember> page = memberMapper.selectPage(
                new Page<>(query.getPageNum(), query.getPageSize()), wrapper);

        List<Long> familyIds = page.getRecords().stream()
                .map(NovelFamilyMember::getFamilyId).distinct().toList();
        Map<Long, String> familyNameMap = familyIds.isEmpty() ? Map.of()
                : familyMapper.selectBatchIds(familyIds).stream()
                        .filter(f -> f.getDeleted() == null || f.getDeleted() == 0)
                        .collect(Collectors.toMap(NovelFamily::getId, NovelFamily::getName));
        Map<Long, String> novelNameMap = getNovelNameMap(page.getRecords());

        IPage<MemberListVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(m -> {
            MemberListVO vo = new MemberListVO();
            vo.setId(m.getId());
            vo.setFamilyId(m.getFamilyId());
            vo.setFamilyName(familyNameMap.get(m.getFamilyId()));
            vo.setNovelId(m.getNovelId());
            vo.setNovelName(novelNameMap.get(m.getNovelId()));
            vo.setName(m.getName());
            vo.setAlias(m.getAlias());
            vo.setGender(m.getGender());
            vo.setGeneration(m.getGeneration());
            vo.setTitle(m.getTitle());
            vo.setRoleType(m.getRoleType());
            vo.setAge(m.getAge());
            vo.setIsHead(m.getIsHead());
            vo.setIsCore(m.getIsCore());
            vo.setSort(m.getSort());
            vo.setUpdatedAt(m.getUpdatedAt());
            return vo;
        }).collect(Collectors.toList()));
        return voPage;
    }

    /**
     * 成员详情（含家族名、性格标签）
     */
    public MemberDetailVO getMemberDetail(Long id) {
        NovelFamilyMember member = getExistMember(id);
        MemberDetailVO vo = new MemberDetailVO();
        vo.setId(member.getId());
        vo.setFamilyId(member.getFamilyId());
        vo.setFamilyName(getFamilyName(member.getFamilyId()));
        vo.setNovelId(member.getNovelId());
        vo.setNovelName(getNovelName(member.getNovelId()));
        vo.setName(member.getName());
        vo.setAlias(member.getAlias());
        vo.setGender(member.getGender());
        vo.setGeneration(member.getGeneration());
        vo.setTitle(member.getTitle());
        vo.setRoleType(member.getRoleType());
        vo.setAge(member.getAge());
        vo.setPersonality(parsePersonality(member.getPersonality()));
        vo.setAppearance(member.getAppearance());
        vo.setBio(member.getBio());
        vo.setIsHead(member.getIsHead());
        vo.setIsCore(member.getIsCore());
        vo.setSort(member.getSort());
        vo.setCreatedBy(member.getCreatedBy());
        vo.setCreatedAt(member.getCreatedAt());
        vo.setUpdatedAt(member.getUpdatedAt());
        return vo;
    }

    /**
     * 新增成员
     */
    public Long addMember(MemberSaveDTO dto) {
        validateSaveDTO(dto);
        NovelFamilyMember member = new NovelFamilyMember();
        applySaveDTO(member, dto);
        member.setDeleted(0);
        member.setCreatedBy(getCurrentUsername());
        member.setCreatedAt(LocalDateTime.now());
        member.setUpdatedBy(member.getCreatedBy());
        member.setUpdatedAt(member.getCreatedAt());
        memberMapper.insert(member);
        return member.getId();
    }

    /**
     * 批量导入成员：先全量校验，任一校验不通过则整批不写库（事务内）。
     * 校验通过后按数组顺序写入，未指定 sort 时自动接当前家族最大排序递增。
     */
    @Transactional(rollbackFor = Exception.class)
    public MemberImportResultVO importMembers(MemberImportDTO dto) {
        if (dto == null || dto.getFamilyId() == null) {
            throw new BusinessException("请选择导入目标家族");
        }
        NovelFamily baseFamily = familyMapper.selectById(dto.getFamilyId());
        if (baseFamily == null || (baseFamily.getDeleted() != null && baseFamily.getDeleted() == 1)) {
            throw new BusinessException("导入目标家族不存在或已被删除");
        }
        List<MemberImportItemDTO> items = dto.getMembers();
        if (items == null || items.isEmpty()) {
            throw new BusinessException("导入数据为空，至少提供一条成员");
        }
        if (items.size() > MAX_IMPORT_SIZE) {
            throw new BusinessException("单次最多导入 " + MAX_IMPORT_SIZE + " 条成员");
        }

        Set<String> roleValues = dictService.getEnabledDictDataByType("novel_member_role").stream()
                .map(SysDictData::getValue)
                .filter(StringUtils::hasText)
                .collect(Collectors.toSet());

        MemberImportResultVO result = new MemberImportResultVO();
        result.setTotal(items.size());

        Map<Long, NovelFamily> familyCache = new HashMap<>();
        familyCache.put(baseFamily.getId(), baseFamily);
        Map<Long, Set<String>> existingNameCache = new HashMap<>();
        Map<Long, Set<String>> batchNameCache = new HashMap<>();
        Map<Long, Integer> nextSortCache = new HashMap<>();
        List<NovelFamilyMember> pending = new ArrayList<>();

        for (int i = 0; i < items.size(); i++) {
            int no = i + 1;
            MemberImportItemDTO item = items.get(i);
            if (item == null) {
                result.getErrors().add(new MemberImportResultVO.ErrorItem(no, "", "数据项为空"));
                continue;
            }

            Long familyId = item.getFamilyId() != null ? item.getFamilyId() : baseFamily.getId();
            NovelFamily family = loadFamilyForImport(familyId, familyCache);
            String itemName = item.getName() == null ? "" : item.getName().trim();
            if (family == null) {
                result.getErrors().add(new MemberImportResultVO.ErrorItem(no, itemName, "家族不存在或已被删除"));
                continue;
            }
            if (!Objects.equals(family.getNovelId(), baseFamily.getNovelId())) {
                result.getErrors().add(new MemberImportResultVO.ErrorItem(no, itemName,
                        "不能跨小说导入，成员所属家族须与所选家族同属一部小说"));
                continue;
            }

            List<String> itemErrors = new ArrayList<>();
            if (!StringUtils.hasText(itemName)) {
                itemErrors.add("姓名不能为空");
            } else if (itemName.length() > 100) {
                itemErrors.add("姓名长度不能超过 100 个字符");
            }
            checkLength(item.getAlias(), 200, "字/号/别称", itemErrors);
            checkLength(item.getGeneration(), 50, "辈分", itemErrors);
            checkLength(item.getTitle(), 100, "身份/头衔", itemErrors);
            checkLength(item.getAppearance(), 1000, "外貌描述", itemErrors);
            checkLength(item.getBio(), 20000, "人物小传", itemErrors);

            String roleType = StringUtils.hasText(item.getRoleType()) ? item.getRoleType().trim() : null;
            if (roleType != null && !roleValues.contains(roleType)) {
                itemErrors.add("角色定位「" + item.getRoleType() + "」不在字典 novel_member_role 中");
            }

            String gender = normalizeGender(item.getGender());
            if (StringUtils.hasText(item.getGender()) && gender == null) {
                itemErrors.add("性别「" + item.getGender() + "」不支持，请使用 M/F/男/女/未知");
            }

            Integer age = parseInteger(item.getAge());
            if (item.getAge() != null && age == null) {
                itemErrors.add("年龄必须是整数");
            } else if (age != null && (age < 0 || age > 9999)) {
                itemErrors.add("年龄必须在 0-9999 之间");
            }

            Integer isHead = parseFlag01(item.getIsHead(), "是否家主", itemErrors);
            Integer isCore = parseFlag01(item.getIsCore(), "核心角色", itemErrors);

            Integer sort = parseInteger(item.getSort());
            if (item.getSort() != null && (sort == null || sort < 0)) {
                itemErrors.add("排序必须是非负整数");
            }

            List<String> personality = parsePersonalityInput(item.getPersonality());
            String personalityJson = serializePersonality(personality);
            if (personalityJson != null && personalityJson.length() > 500) {
                itemErrors.add("性格标签总长度超出限制（最多 500 字符）");
            }

            if (StringUtils.hasText(itemName)) {
                Set<String> existingNames = existingNameCache.computeIfAbsent(familyId, this::loadExistingNames);
                if (existingNames.contains(itemName)) {
                    itemErrors.add("该家族已存在同名成员「" + itemName + "」");
                } else {
                    Set<String> batchNames = batchNameCache.computeIfAbsent(familyId, k -> new HashSet<>());
                    if (!batchNames.add(itemName)) {
                        itemErrors.add("本批数据中存在重复姓名「" + itemName + "」");
                    }
                }
            }

            if (!itemErrors.isEmpty()) {
                result.getErrors().add(new MemberImportResultVO.ErrorItem(no, itemName, String.join("；", itemErrors)));
                continue;
            }

            Integer autoSort = nextSortCache.computeIfAbsent(familyId, this::loadNextSort);
            int finalSort = sort != null ? sort : autoSort;
            nextSortCache.put(familyId, Math.max(autoSort, finalSort + 1));

            MemberSaveDTO saveDTO = new MemberSaveDTO();
            saveDTO.setFamilyId(familyId);
            saveDTO.setName(itemName);
            saveDTO.setAlias(item.getAlias());
            saveDTO.setGender(gender);
            saveDTO.setGeneration(item.getGeneration());
            saveDTO.setTitle(item.getTitle());
            saveDTO.setRoleType(roleType);
            saveDTO.setAge(age);
            saveDTO.setPersonality(personality);
            saveDTO.setAppearance(item.getAppearance());
            saveDTO.setBio(item.getBio());
            saveDTO.setIsHead(isHead);
            saveDTO.setIsCore(isCore);
            saveDTO.setSort(finalSort);

            NovelFamilyMember member = new NovelFamilyMember();
            applySaveDTO(member, saveDTO, family);
            member.setDeleted(0);
            member.setCreatedBy(getCurrentUsername());
            member.setCreatedAt(LocalDateTime.now());
            member.setUpdatedBy(member.getCreatedBy());
            member.setUpdatedAt(member.getCreatedAt());
            pending.add(member);
        }

        if (!result.getErrors().isEmpty()) {
            result.setOk(false);
            result.setSuccessCount(0);
            return result;
        }

        for (NovelFamilyMember member : pending) {
            memberMapper.insert(member);
            result.getIds().add(member.getId());
        }
        result.setOk(true);
        result.setSuccessCount(pending.size());
        return result;
    }

    /**
     * 编辑成员
     */
    public void updateMember(Long id, MemberSaveDTO dto) {
        getExistMember(id);
        validateSaveDTO(dto);
        NovelFamilyMember member = getExistMember(id);
        applySaveDTO(member, dto);
        member.setUpdatedBy(getCurrentUsername());
        member.setUpdatedAt(LocalDateTime.now());
        memberMapper.updateById(member);
    }

    /**
     * 删除成员：逻辑删除成员并级联逻辑删除其相关关系
     */
    @Transactional(rollbackFor = Exception.class)
    public void deleteMember(Long id) {
        getExistMember(id);
        LambdaUpdateWrapper<NovelFamilyMember> memberWrapper = new LambdaUpdateWrapper<>();
        memberWrapper.eq(NovelFamilyMember::getId, id)
                .set(NovelFamilyMember::getDeleted, 1)
                .set(NovelFamilyMember::getUpdatedBy, getCurrentUsername())
                .set(NovelFamilyMember::getUpdatedAt, LocalDateTime.now());
        memberMapper.update(null, memberWrapper);

        LambdaUpdateWrapper<NovelRelation> relationWrapper = new LambdaUpdateWrapper<>();
        relationWrapper.eq(NovelRelation::getDeleted, 0).eq(NovelRelation::getSourceType, "MEMBER")
                .and(w -> w.eq(NovelRelation::getSourceId, id).or().eq(NovelRelation::getTargetId, id))
                .set(NovelRelation::getDeleted, 1)
                .set(NovelRelation::getUpdatedBy, getCurrentUsername())
                .set(NovelRelation::getUpdatedAt, LocalDateTime.now());
        relationMapper.update(null, relationWrapper);
    }

    // ==================== 私有方法 ====================

    // ==================== 批量导入辅助 ====================

    /**
     * 加载并缓存导入目标家族（无效家族缓存为 null）
     */
    private NovelFamily loadFamilyForImport(Long familyId, Map<Long, NovelFamily> cache) {
        if (cache.containsKey(familyId)) {
            return cache.get(familyId);
        }
        NovelFamily family = familyMapper.selectById(familyId);
        if (family != null && family.getDeleted() != null && family.getDeleted() == 1) {
            family = null;
        }
        cache.put(familyId, family);
        return family;
    }

    /**
     * 查询家族内未删除成员姓名集合（用于重名校验）
     */
    private Set<String> loadExistingNames(Long familyId) {
        LambdaQueryWrapper<NovelFamilyMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NovelFamilyMember::getFamilyId, familyId)
                .eq(NovelFamilyMember::getDeleted, 0);
        return memberMapper.selectList(wrapper).stream()
                .map(NovelFamilyMember::getName)
                .filter(StringUtils::hasText)
                .map(String::trim)
                .collect(Collectors.toSet());
    }

    /**
     * 家族内下一个排序值（当前最大 sort + 1）
     */
    private Integer loadNextSort(Long familyId) {
        LambdaQueryWrapper<NovelFamilyMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NovelFamilyMember::getFamilyId, familyId)
                .eq(NovelFamilyMember::getDeleted, 0)
                .orderByDesc(NovelFamilyMember::getSort)
                .last("LIMIT 1");
        NovelFamilyMember last = memberMapper.selectOne(wrapper);
        return last == null || last.getSort() == null ? 1 : last.getSort() + 1;
    }

    private void checkLength(String value, int max, String field, List<String> errors) {
        if (value != null && value.length() > max) {
            errors.add(field + "长度不能超过 " + max + " 个字符");
        }
    }

    /**
     * 性别归一化为 M / F / 未知；无法识别返回 null
     */
    private String normalizeGender(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String text = value.trim();
        String key = text.toLowerCase();
        if ("m".equals(key) || "male".equals(key) || "男".equals(text)) {
            return "M";
        }
        if ("f".equals(key) || "female".equals(key) || "女".equals(text)) {
            return "F";
        }
        if ("未知".equals(text) || "unknown".equals(key) || "u".equals(key)) {
            return "未知";
        }
        return null;
    }

    /**
     * 宽松整数解析：支持数字与字符串数字，非整数返回 null
     */
    private Integer parseInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            double d = number.doubleValue();
            if (d != Math.rint(d) || d > Integer.MAX_VALUE || d < Integer.MIN_VALUE) {
                return null;
            }
            return (int) d;
        }
        String text = value.toString().trim();
        if (!text.matches("-?\\d+")) {
            return null;
        }
        try {
            return Integer.parseInt(text);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * 宽松 0/1 解析：支持 0/1、true/false、"0"/"1"
     */
    private Integer parseFlag01(Object value, String field, List<String> errors) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Boolean b) {
            return b ? 1 : 0;
        }
        if (value instanceof Number number) {
            double d = number.doubleValue();
            if (d == 0) {
                return 0;
            }
            if (d == 1) {
                return 1;
            }
            errors.add(field + "只能是 0 或 1");
            return 0;
        }
        String text = value.toString().trim().toLowerCase();
        if ("1".equals(text) || "true".equals(text)) {
            return 1;
        }
        if ("0".equals(text) || "false".equals(text)) {
            return 0;
        }
        errors.add(field + "只能是 0/1 或 true/false");
        return 0;
    }

    /**
     * 性格标签宽松解析：数组或逗号分隔字符串
     */
    private List<String> parsePersonalityInput(Object value) {
        List<String> list = new ArrayList<>();
        if (value == null) {
            return list;
        }
        if (value instanceof List<?> raw) {
            for (Object item : raw) {
                if (item != null && StringUtils.hasText(item.toString())) {
                    list.add(item.toString().trim());
                }
            }
        } else {
            for (String part : value.toString().split("[,，、|]")) {
                if (StringUtils.hasText(part)) {
                    list.add(part.trim());
                }
            }
        }
        return list.stream().distinct().toList();
    }

    private NovelFamilyMember getExistMember(Long id) {
        NovelFamilyMember member = memberMapper.selectById(id);
        if (member == null || (member.getDeleted() != null && member.getDeleted() == 1)) {
            throw new BusinessException("成员不存在或已被删除");
        }
        return member;
    }

    private void validateSaveDTO(MemberSaveDTO dto) {
        if (dto.getFamilyId() == null) {
            throw new BusinessException("所属家族不能为空");
        }
        NovelFamily family = familyMapper.selectById(dto.getFamilyId());
        if (family == null || (family.getDeleted() != null && family.getDeleted() == 1)) {
            throw new BusinessException("所属家族不存在或已被删除");
        }
        if (!StringUtils.hasText(dto.getName())) {
            throw new BusinessException("成员姓名不能为空");
        }
    }

    private void applySaveDTO(NovelFamilyMember member, MemberSaveDTO dto) {
        NovelFamily family = familyMapper.selectById(dto.getFamilyId());
        applySaveDTO(member, dto, family);
    }

    private void applySaveDTO(NovelFamilyMember member, MemberSaveDTO dto, NovelFamily family) {
        member.setFamilyId(dto.getFamilyId());
        // 所属小说以所属家族为准
        member.setNovelId(family == null ? null : family.getNovelId());
        member.setName(dto.getName().trim());
        member.setAlias(dto.getAlias());
        // 性别统一为 M/F/未知，兼容历史中文值
        String normalizedGender = normalizeGender(dto.getGender());
        member.setGender(normalizedGender != null ? normalizedGender : dto.getGender());
        member.setGeneration(dto.getGeneration());
        member.setTitle(dto.getTitle());
        member.setRoleType(dto.getRoleType());
        member.setAge(dto.getAge());
        member.setPersonality(serializePersonality(dto.getPersonality()));
        member.setAppearance(dto.getAppearance());
        member.setBio(dto.getBio());
        member.setIsHead(dto.getIsHead() == null ? 0 : dto.getIsHead());
        member.setIsCore(dto.getIsCore() == null ? 0 : dto.getIsCore());
        member.setSort(dto.getSort() == null ? 0 : dto.getSort());
    }

    private String getFamilyName(Long familyId) {
        NovelFamily family = familyMapper.selectById(familyId);
        return family == null ? null : family.getName();
    }

    /**
     * 批量查询小说名称
     */
    private Map<Long, String> getNovelNameMap(List<NovelFamilyMember> members) {
        List<Long> novelIds = members.stream()
                .map(NovelFamilyMember::getNovelId)
                .filter(java.util.Objects::nonNull)
                .distinct().toList();
        if (novelIds.isEmpty()) {
            return Map.of();
        }
        return novelMapper.selectBatchIds(novelIds).stream()
                .filter(n -> n.getDeleted() == null || n.getDeleted() == 0)
                .collect(Collectors.toMap(Novel::getId, Novel::getName, (a, b) -> a));
    }

    private String getNovelName(Long novelId) {
        if (novelId == null) {
            return null;
        }
        Novel novel = novelMapper.selectById(novelId);
        return novel == null || (novel.getDeleted() != null && novel.getDeleted() == 1) ? null : novel.getName();
    }

    private List<String> parsePersonality(String personality) {
        if (!StringUtils.hasText(personality)) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(personality, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            // 兼容非 JSON 格式的旧数据
            return java.util.Arrays.asList(personality.split(","));
        }
    }

    private String serializePersonality(List<String> personality) {
        if (personality == null || personality.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(personality.stream()
                    .filter(StringUtils::hasText)
                    .map(String::trim)
                    .distinct()
                    .toList());
        } catch (Exception e) {
            throw new BusinessException("性格标签序列化失败");
        }
    }

    private String getCurrentUsername() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        return principal == null ? "" : principal.toString();
    }
}
