package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.MemberQueryDTO;
import com.example.geekeradmin.dto.MemberSaveDTO;
import com.example.geekeradmin.entity.Novel;
import com.example.geekeradmin.entity.NovelFamily;
import com.example.geekeradmin.entity.NovelFamilyMember;
import com.example.geekeradmin.entity.NovelRelation;
import com.example.geekeradmin.mapper.NovelFamilyMapper;
import com.example.geekeradmin.mapper.NovelFamilyMemberMapper;
import com.example.geekeradmin.mapper.NovelMapper;
import com.example.geekeradmin.mapper.NovelRelationMapper;
import com.example.geekeradmin.vo.MemberDetailVO;
import com.example.geekeradmin.vo.MemberListVO;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 小说家族成员
 */
@Service
public class NovelFamilyMemberService {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private NovelFamilyMemberMapper memberMapper;

    @Autowired
    private NovelFamilyMapper familyMapper;

    @Autowired
    private NovelRelationMapper relationMapper;

    @Autowired
    private NovelMapper novelMapper;

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

    private NovelFamilyMember getExistMember(Long id) {
        NovelFamilyMember member = memberMapper.selectById(id);
        if (member == null || (member.getDeleted() != null && member.getDeleted() == 1)) {
            throw new RuntimeException("成员不存在或已被删除");
        }
        return member;
    }

    private void validateSaveDTO(MemberSaveDTO dto) {
        if (dto.getFamilyId() == null) {
            throw new RuntimeException("所属家族不能为空");
        }
        NovelFamily family = familyMapper.selectById(dto.getFamilyId());
        if (family == null || (family.getDeleted() != null && family.getDeleted() == 1)) {
            throw new RuntimeException("所属家族不存在或已被删除");
        }
        if (!StringUtils.hasText(dto.getName())) {
            throw new RuntimeException("成员姓名不能为空");
        }
    }

    private void applySaveDTO(NovelFamilyMember member, MemberSaveDTO dto) {
        member.setFamilyId(dto.getFamilyId());
        // 所属小说以所属家族为准
        NovelFamily family = familyMapper.selectById(dto.getFamilyId());
        member.setNovelId(family.getNovelId());
        member.setName(dto.getName().trim());
        member.setAlias(dto.getAlias());
        member.setGender(dto.getGender());
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
            throw new RuntimeException("性格标签序列化失败");
        }
    }

    private String getCurrentUsername() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        return principal == null ? "" : principal.toString();
    }
}
