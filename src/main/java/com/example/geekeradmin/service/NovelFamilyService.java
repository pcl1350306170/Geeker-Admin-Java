package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.FamilyQueryDTO;
import com.example.geekeradmin.dto.FamilySaveDTO;
import com.example.geekeradmin.entity.Novel;
import com.example.geekeradmin.entity.NovelFamily;
import com.example.geekeradmin.entity.NovelFamilyMember;
import com.example.geekeradmin.entity.NovelRelation;
import com.example.geekeradmin.mapper.NovelFamilyMapper;
import com.example.geekeradmin.mapper.NovelFamilyMemberMapper;
import com.example.geekeradmin.mapper.NovelMapper;
import com.example.geekeradmin.mapper.NovelRelationMapper;
import com.example.geekeradmin.vo.FamilyDetailVO;
import com.example.geekeradmin.vo.FamilyListVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 小说家族
 */
@Service
public class NovelFamilyService {

    @Autowired
    private NovelFamilyMapper familyMapper;

    @Autowired
    private NovelFamilyMemberMapper memberMapper;

    @Autowired
    private NovelRelationMapper relationMapper;

    @Autowired
    private NovelMapper novelMapper;

    /**
     * 分页查询家族（含成员数 / 核心角色数统计）
     */
    public IPage<FamilyListVO> getFamilyPage(FamilyQueryDTO query) {
        LambdaQueryWrapper<NovelFamily> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NovelFamily::getDeleted, 0);
        if (StringUtils.hasText(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            wrapper.and(w -> w.like(NovelFamily::getName, kw)
                    .or().like(NovelFamily::getAlias, kw)
                    .or().like(NovelFamily::getIntroduction, kw));
        }
        if (StringUtils.hasText(query.getType())) {
            wrapper.eq(NovelFamily::getType, query.getType());
        }
        if (StringUtils.hasText(query.getStatus())) {
            wrapper.eq(NovelFamily::getStatus, query.getStatus());
        }
        if (query.getNovelId() != null) {
            wrapper.eq(NovelFamily::getNovelId, query.getNovelId());
        }
        wrapper.orderByAsc(NovelFamily::getSort).orderByDesc(NovelFamily::getUpdatedAt);

        IPage<NovelFamily> page = familyMapper.selectPage(
                new Page<>(query.getPageNum(), query.getPageSize()), wrapper);

        List<Long> ids = page.getRecords().stream().map(NovelFamily::getId).toList();
        Map<Long, Integer> memberCountMap = ids.isEmpty() ? Collections.emptyMap() : countMembers(ids, false);
        Map<Long, Integer> coreCountMap = ids.isEmpty() ? Collections.emptyMap() : countMembers(ids, true);
        Map<Long, String> novelNameMap = getNovelNameMap(page.getRecords());

        IPage<FamilyListVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(f -> {
            FamilyListVO vo = new FamilyListVO();
            vo.setId(f.getId());
            vo.setNovelId(f.getNovelId());
            vo.setNovelName(novelNameMap.get(f.getNovelId()));
            vo.setName(f.getName());
            vo.setAlias(f.getAlias());
            vo.setType(f.getType());
            vo.setStatus(f.getStatus());
            vo.setIntroduction(f.getIntroduction());
            vo.setEmblem(f.getEmblem());
            vo.setCover(f.getCover());
            vo.setMemberCount(memberCountMap.getOrDefault(f.getId(), 0));
            vo.setCoreCount(coreCountMap.getOrDefault(f.getId(), 0));
            vo.setUpdatedAt(f.getUpdatedAt());
            return vo;
        }).collect(Collectors.toList()));
        return voPage;
    }

    /**
     * 家族详情（含成员数 / 核心角色数 / 家主姓名）
     */
    public FamilyDetailVO getFamilyDetail(Long id) {
        NovelFamily family = getExistFamily(id);
        FamilyDetailVO vo = new FamilyDetailVO();
        vo.setId(family.getId());
        vo.setNovelId(family.getNovelId());
        vo.setNovelName(getNovelName(family.getNovelId()));
        vo.setName(family.getName());
        vo.setAlias(family.getAlias());
        vo.setType(family.getType());
        vo.setStatus(family.getStatus());
        vo.setIntroduction(family.getIntroduction());
        vo.setBackground(family.getBackground());
        vo.setCreed(family.getCreed());
        vo.setTerritory(family.getTerritory());
        vo.setEmblem(family.getEmblem());
        vo.setCover(family.getCover());
        vo.setSort(family.getSort());
        vo.setMemberCount(countMembers(List.of(id), false).getOrDefault(id, 0));
        vo.setCoreCount(countMembers(List.of(id), true).getOrDefault(id, 0));
        vo.setHeadName(getHeadName(id));
        vo.setCreatedBy(family.getCreatedBy());
        vo.setCreatedAt(family.getCreatedAt());
        vo.setUpdatedAt(family.getUpdatedAt());
        return vo;
    }

    /**
     * 新增家族
     */
    public Long addFamily(FamilySaveDTO dto) {
        validateSaveDTO(dto);
        NovelFamily family = new NovelFamily();
        applySaveDTO(family, dto);
        family.setDeleted(0);
        family.setCreatedBy(getCurrentUsername());
        family.setCreatedAt(LocalDateTime.now());
        family.setUpdatedBy(family.getCreatedBy());
        family.setUpdatedAt(family.getCreatedAt());
        familyMapper.insert(family);
        return family.getId();
    }

    /**
     * 编辑家族
     */
    public void updateFamily(Long id, FamilySaveDTO dto) {
        NovelFamily family = getExistFamily(id);
        validateSaveDTO(dto);
        applySaveDTO(family, dto);
        family.setUpdatedBy(getCurrentUsername());
        family.setUpdatedAt(LocalDateTime.now());
        familyMapper.updateById(family);
    }

    /**
     * 删除家族：家族下存在成员时禁止删除；否则逻辑删除家族并级联逻辑删除其家族间关系
     */
    public void deleteFamily(Long id) {
        getExistFamily(id);
        LambdaQueryWrapper<NovelFamilyMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(NovelFamilyMember::getDeleted, 0).eq(NovelFamilyMember::getFamilyId, id);
        if (memberMapper.selectCount(memberWrapper) > 0) {
            throw new RuntimeException("该家族下仍有成员，请先移除成员后再删除");
        }
        LambdaUpdateWrapper<NovelFamily> familyWrapper = new LambdaUpdateWrapper<>();
        familyWrapper.eq(NovelFamily::getId, id).set(NovelFamily::getDeleted, 1)
                .set(NovelFamily::getUpdatedBy, getCurrentUsername())
                .set(NovelFamily::getUpdatedAt, LocalDateTime.now());
        familyMapper.update(null, familyWrapper);

        // 级联逻辑删除与该家族相关的家族间关系
        LambdaUpdateWrapper<NovelRelation> relationWrapper = new LambdaUpdateWrapper<>();
        relationWrapper.eq(NovelRelation::getDeleted, 0).eq(NovelRelation::getSourceType, "FAMILY")
                .and(w -> w.eq(NovelRelation::getSourceId, id).or().eq(NovelRelation::getTargetId, id))
                .set(NovelRelation::getDeleted, 1)
                .set(NovelRelation::getUpdatedBy, getCurrentUsername())
                .set(NovelRelation::getUpdatedAt, LocalDateTime.now());
        relationMapper.update(null, relationWrapper);
    }

    // ==================== 私有方法 ====================

    private NovelFamily getExistFamily(Long id) {
        NovelFamily family = familyMapper.selectById(id);
        if (family == null || (family.getDeleted() != null && family.getDeleted() == 1)) {
            throw new RuntimeException("家族不存在或已被删除");
        }
        return family;
    }

    private void validateSaveDTO(FamilySaveDTO dto) {
        if (!StringUtils.hasText(dto.getName())) {
            throw new RuntimeException("家族名称不能为空");
        }
        if (dto.getNovelId() == null) {
            throw new RuntimeException("所属小说不能为空");
        }
        Novel novel = novelMapper.selectById(dto.getNovelId());
        if (novel == null || (novel.getDeleted() != null && novel.getDeleted() == 1)) {
            throw new RuntimeException("所属小说不存在或已被删除");
        }
    }

    private void applySaveDTO(NovelFamily family, FamilySaveDTO dto) {
        family.setNovelId(dto.getNovelId());
        family.setName(dto.getName().trim());
        family.setAlias(dto.getAlias());
        family.setType(dto.getType());
        family.setStatus(dto.getStatus());
        family.setIntroduction(dto.getIntroduction());
        family.setBackground(dto.getBackground());
        family.setCreed(dto.getCreed());
        family.setTerritory(dto.getTerritory());
        family.setEmblem(dto.getEmblem());
        family.setCover(dto.getCover());
        family.setSort(dto.getSort() == null ? 0 : dto.getSort());
    }

    /**
     * 按家族统计成员数 / 核心角色数
     */
    private Map<Long, Integer> countMembers(List<Long> familyIds, boolean coreOnly) {
        LambdaQueryWrapper<NovelFamilyMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.select(NovelFamilyMember::getFamilyId)
                .eq(NovelFamilyMember::getDeleted, 0)
                .in(NovelFamilyMember::getFamilyId, familyIds);
        if (coreOnly) {
            wrapper.eq(NovelFamilyMember::getIsCore, 1);
        }
        return memberMapper.selectList(wrapper).stream()
                .collect(Collectors.groupingBy(NovelFamilyMember::getFamilyId, Collectors.summingInt(m -> 1)));
    }

    /**
     * 批量查询小说名称（用于列表 VO 组装）
     */
    private Map<Long, String> getNovelNameMap(List<NovelFamily> families) {
        List<Long> novelIds = families.stream()
                .map(NovelFamily::getNovelId)
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

    private String getHeadName(Long familyId) {
        LambdaQueryWrapper<NovelFamilyMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NovelFamilyMember::getDeleted, 0)
                .eq(NovelFamilyMember::getFamilyId, familyId)
                .eq(NovelFamilyMember::getIsHead, 1)
                .last("LIMIT 1");
        NovelFamilyMember head = memberMapper.selectOne(wrapper);
        return head == null ? null : head.getName();
    }

    private String getCurrentUsername() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        return principal == null ? "" : principal.toString();
    }
}
