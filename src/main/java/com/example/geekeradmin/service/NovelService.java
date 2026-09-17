package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.NovelQueryDTO;
import com.example.geekeradmin.dto.NovelSaveDTO;
import com.example.geekeradmin.entity.Novel;
import com.example.geekeradmin.entity.NovelFamily;
import com.example.geekeradmin.mapper.NovelFamilyMapper;
import com.example.geekeradmin.mapper.NovelMapper;
import com.example.geekeradmin.vo.NovelListVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 小说
 */
@Service
public class NovelService {

    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_DISABLED = "DISABLED";

    @Autowired
    private NovelMapper novelMapper;

    @Autowired
    private NovelFamilyMapper familyMapper;

    /**
     * 分页查询小说（含家族数统计）
     */
    public IPage<NovelListVO> getNovelPage(NovelQueryDTO query) {
        LambdaQueryWrapper<Novel> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Novel::getDeleted, 0);
        if (StringUtils.hasText(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            wrapper.and(w -> w.like(Novel::getName, kw)
                    .or().like(Novel::getAlias, kw)
                    .or().like(Novel::getAuthor, kw));
        }
        if (StringUtils.hasText(query.getStatus())) {
            wrapper.eq(Novel::getStatus, query.getStatus());
        }
        wrapper.orderByAsc(Novel::getSort).orderByDesc(Novel::getUpdatedAt);

        IPage<Novel> page = novelMapper.selectPage(
                new Page<>(query.getPageNum(), query.getPageSize()), wrapper);

        List<Long> ids = page.getRecords().stream().map(Novel::getId).toList();
        Map<Long, Long> familyCountMap = ids.isEmpty() ? Map.of() : countFamilies(ids);

        IPage<NovelListVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(n -> {
            NovelListVO vo = new NovelListVO();
            vo.setId(n.getId());
            vo.setName(n.getName());
            vo.setAlias(n.getAlias());
            vo.setAuthor(n.getAuthor());
            vo.setIntroduction(n.getIntroduction());
            vo.setStatus(n.getStatus());
            vo.setSort(n.getSort());
            vo.setFamilyCount(familyCountMap.getOrDefault(n.getId(), 0L));
            vo.setUpdatedAt(n.getUpdatedAt());
            return vo;
        }).collect(Collectors.toList()));
        return voPage;
    }

    /**
     * 全量未删除小说（供下拉选择）
     */
    public List<NovelListVO> getAllNovels() {
        return novelMapper.selectList(new LambdaQueryWrapper<Novel>()
                        .eq(Novel::getDeleted, 0)
                        .orderByAsc(Novel::getSort).orderByDesc(Novel::getUpdatedAt))
                .stream().map(n -> {
                    NovelListVO vo = new NovelListVO();
                    vo.setId(n.getId());
                    vo.setName(n.getName());
                    vo.setAlias(n.getAlias());
                    vo.setAuthor(n.getAuthor());
                    vo.setStatus(n.getStatus());
                    vo.setSort(n.getSort());
                    return vo;
                }).toList();
    }

    /**
     * 新增小说
     */
    public Long addNovel(NovelSaveDTO dto) {
        validateSaveDTO(dto);
        Novel novel = new Novel();
        applySaveDTO(novel, dto);
        novel.setDeleted(0);
        novel.setCreatedBy(getCurrentUsername());
        novel.setCreatedAt(LocalDateTime.now());
        novel.setUpdatedBy(novel.getCreatedBy());
        novel.setUpdatedAt(novel.getCreatedAt());
        novelMapper.insert(novel);
        return novel.getId();
    }

    /**
     * 编辑小说
     */
    public void updateNovel(Long id, NovelSaveDTO dto) {
        getExistNovel(id);
        validateSaveDTO(dto);
        Novel novel = getExistNovel(id);
        applySaveDTO(novel, dto);
        novel.setUpdatedBy(getCurrentUsername());
        novel.setUpdatedAt(LocalDateTime.now());
        novelMapper.updateById(novel);
    }

    /**
     * 删除小说：名下仍有未删除家族时禁止删除
     */
    public void deleteNovel(Long id) {
        getExistNovel(id);
        Long familyCount = familyMapper.selectCount(new LambdaQueryWrapper<NovelFamily>()
                .eq(NovelFamily::getDeleted, 0)
                .eq(NovelFamily::getNovelId, id));
        if (familyCount > 0) {
            throw new RuntimeException("该小说下仍有家族，请先删除其下家族后再删除");
        }
        LambdaUpdateWrapper<Novel> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Novel::getId, id)
                .set(Novel::getDeleted, 1)
                .set(Novel::getUpdatedBy, getCurrentUsername())
                .set(Novel::getUpdatedAt, LocalDateTime.now());
        novelMapper.update(null, wrapper);
    }

    // ==================== 私有方法 ====================

    private Novel getExistNovel(Long id) {
        Novel novel = novelMapper.selectById(id);
        if (novel == null || (novel.getDeleted() != null && novel.getDeleted() == 1)) {
            throw new RuntimeException("小说不存在或已被删除");
        }
        return novel;
    }

    private void validateSaveDTO(NovelSaveDTO dto) {
        if (!StringUtils.hasText(dto.getName())) {
            throw new RuntimeException("小说名称不能为空");
        }
        if (StringUtils.hasText(dto.getStatus()) && !STATUS_ACTIVE.equals(dto.getStatus())
                && !STATUS_DISABLED.equals(dto.getStatus())) {
            throw new RuntimeException("小说状态不合法：仅支持 ACTIVE（正常）或 DISABLED（停用）");
        }
    }

    private void applySaveDTO(Novel novel, NovelSaveDTO dto) {
        novel.setName(dto.getName().trim());
        novel.setAlias(dto.getAlias());
        novel.setAuthor(dto.getAuthor());
        novel.setIntroduction(dto.getIntroduction());
        novel.setStatus(StringUtils.hasText(dto.getStatus()) ? dto.getStatus() : STATUS_ACTIVE);
        novel.setSort(dto.getSort() == null ? 0 : dto.getSort());
    }

    private Map<Long, Long> countFamilies(List<Long> novelIds) {
        return familyMapper.selectList(new LambdaQueryWrapper<NovelFamily>()
                        .select(NovelFamily::getNovelId)
                        .eq(NovelFamily::getDeleted, 0)
                        .in(NovelFamily::getNovelId, novelIds))
                .stream()
                .collect(Collectors.groupingBy(NovelFamily::getNovelId, Collectors.counting()));
    }

    private String getCurrentUsername() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        return principal == null ? "" : principal.toString();
    }
}
