package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.DevAssetQueryDTO;
import com.example.geekeradmin.dto.DevAssetSaveDTO;
import com.example.geekeradmin.entity.DevAsset;
import com.example.geekeradmin.entity.DevAssetUsage;
import com.example.geekeradmin.mapper.DevAssetMapper;
import com.example.geekeradmin.mapper.DevAssetUsageMapper;
import com.example.geekeradmin.vo.DevAssetDetailVO;
import com.example.geekeradmin.vo.DevAssetHomeVO;
import com.example.geekeradmin.vo.DevAssetListVO;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 开发资产库
 */
@Service
public class DevAssetService {

    /** 合法的资产类型 */
    private static final Set<String> ASSET_TYPES = Set.of(
            "CODE", "SOLUTION", "TROUBLESHOOTING", "PROCEDURE", "SNIPPET");

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private DevAssetMapper assetMapper;

    @Autowired
    private DevAssetUsageMapper usageMapper;

    @Autowired
    private DevAssetTagService tagService;

    /**
     * 分页查询 / 搜索（keyword 按空格拆分多关键词，权重排序）
     */
    public IPage<DevAssetListVO> getAssetPage(DevAssetQueryDTO query) {
        List<String> keywords = splitKeywords(query.getKeyword());
        IPage<DevAsset> page = assetMapper.searchAssetPage(
                new Page<>(query.getPageNum(), query.getPageSize()),
                keywords, query.getType(), query.getTag(), query.getIsFavorite());
        IPage<DevAssetListVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(this::toListVO).collect(Collectors.toList()));
        return voPage;
    }

    /**
     * 资产详情（记录一次 VIEW）
     */
    public DevAssetDetailVO getDetail(Long id) {
        DevAsset asset = getExistAsset(id);
        recordUsage(id, "VIEW");
        DevAssetDetailVO vo = new DevAssetDetailVO();
        vo.setId(asset.getId());
        vo.setTitle(asset.getTitle());
        vo.setType(asset.getType());
        vo.setDescription(asset.getDescription());
        vo.setContent(asset.getContent());
        vo.setLanguage(asset.getLanguage());
        vo.setTags(parseTags(asset.getTags()));
        vo.setIsFavorite(asset.getIsFavorite());
        vo.setUsageCount(asset.getUsageCount());
        vo.setParentId(asset.getParentId());
        if (asset.getParentId() != null) {
            DevAsset parent = assetMapper.selectById(asset.getParentId());
            if (parent != null && (parent.getDeleted() == null || parent.getDeleted() == 0)) {
                vo.setParentTitle(parent.getTitle());
            }
        }
        vo.setCreatedBy(asset.getCreatedBy());
        vo.setCreatedAt(asset.getCreatedAt());
        vo.setUpdatedAt(asset.getUpdatedAt());
        return vo;
    }

    /**
     * 新增资产
     */
    public Long addAsset(DevAssetSaveDTO dto) {
        validateSaveDTO(dto);
        DevAsset asset = new DevAsset();
        asset.setTitle(dto.getTitle().trim());
        asset.setType(dto.getType());
        asset.setDescription(dto.getDescription());
        asset.setContent(dto.getContent());
        asset.setLanguage(dto.getLanguage());
        asset.setTags(serializeTags(dto.getTags()));
        asset.setIsFavorite(0);
        asset.setUsageCount(0);
        asset.setDeleted(0);
        asset.setCreatedBy(getCurrentUsername());
        asset.setCreatedAt(LocalDateTime.now());
        asset.setUpdatedBy(asset.getCreatedBy());
        asset.setUpdatedAt(asset.getCreatedAt());
        assetMapper.insert(asset);
        // 新标签自动注册到标签字典
        tagService.registerTags(dto.getTags());
        return asset.getId();
    }

    /**
     * 编辑资产
     */
    public void updateAsset(Long id, DevAssetSaveDTO dto) {
        DevAsset asset = getExistAsset(id);
        validateSaveDTO(dto);
        asset.setTitle(dto.getTitle().trim());
        asset.setType(dto.getType());
        asset.setDescription(dto.getDescription());
        asset.setContent(dto.getContent());
        asset.setLanguage(dto.getLanguage());
        asset.setTags(serializeTags(dto.getTags()));
        asset.setUpdatedBy(getCurrentUsername());
        asset.setUpdatedAt(LocalDateTime.now());
        assetMapper.updateById(asset);
        // 新标签自动注册到标签字典
        tagService.registerTags(dto.getTags());
    }

    /**
     * 逻辑删除
     */
    public void deleteAsset(Long id) {
        DevAsset asset = getExistAsset(id);
        asset.setDeleted(1);
        asset.setUpdatedBy(getCurrentUsername());
        asset.setUpdatedAt(LocalDateTime.now());
        assetMapper.updateById(asset);
    }

    /**
     * 收藏 / 取消收藏
     */
    public Integer toggleFavorite(Long id) {
        DevAsset asset = getExistAsset(id);
        int favorite = asset.getIsFavorite() != null && asset.getIsFavorite() == 1 ? 0 : 1;
        LambdaUpdateWrapper<DevAsset> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(DevAsset::getId, id).set(DevAsset::getIsFavorite, favorite);
        assetMapper.update(null, wrapper);
        return favorite;
    }

    /**
     * 复制上报：usage_count + 1，并记录 COPY 日志
     */
    public void recordCopy(Long id) {
        getExistAsset(id);
        LambdaUpdateWrapper<DevAsset> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(DevAsset::getId, id).setSql("usage_count = usage_count + 1");
        assetMapper.update(null, wrapper);
        recordUsage(id, "COPY");
    }

    /**
     * 基于旧资产创建新资产（复制内容，标题加“ - 副本”，记录 parent_id）
     */
    public Long duplicateAsset(Long id) {
        DevAsset source = getExistAsset(id);
        DevAsset copy = new DevAsset();
        copy.setTitle(source.getTitle() + " - 副本");
        copy.setType(source.getType());
        copy.setDescription(source.getDescription());
        copy.setContent(source.getContent());
        copy.setLanguage(source.getLanguage());
        copy.setTags(source.getTags());
        copy.setIsFavorite(0);
        copy.setUsageCount(0);
        copy.setParentId(source.getId());
        copy.setDeleted(0);
        copy.setCreatedBy(getCurrentUsername());
        copy.setCreatedAt(LocalDateTime.now());
        copy.setUpdatedBy(copy.getCreatedBy());
        copy.setUpdatedAt(copy.getCreatedAt());
        assetMapper.insert(copy);
        return copy.getId();
    }

    /**
     * 首页聚合数据
     */
    public DevAssetHomeVO getHomeData() {
        DevAssetHomeVO vo = new DevAssetHomeVO();
        vo.setRecentUsed(assetMapper.selectRecentUsed(10).stream().map(this::toListVO).toList());

        LambdaQueryWrapper<DevAsset> favoriteWrapper = new LambdaQueryWrapper<>();
        favoriteWrapper.eq(DevAsset::getDeleted, 0)
                .eq(DevAsset::getIsFavorite, 1)
                .orderByDesc(DevAsset::getUpdatedAt)
                .last("LIMIT 10");
        vo.setFavorites(assetMapper.selectList(favoriteWrapper).stream().map(this::toListVO).toList());

        LambdaQueryWrapper<DevAsset> mostUsedWrapper = new LambdaQueryWrapper<>();
        mostUsedWrapper.eq(DevAsset::getDeleted, 0)
                .gt(DevAsset::getUsageCount, 0)
                .orderByDesc(DevAsset::getUsageCount)
                .orderByDesc(DevAsset::getUpdatedAt)
                .last("LIMIT 10");
        vo.setMostUsed(assetMapper.selectList(mostUsedWrapper).stream().map(this::toListVO).toList());

        LambdaQueryWrapper<DevAsset> updatedWrapper = new LambdaQueryWrapper<>();
        updatedWrapper.eq(DevAsset::getDeleted, 0)
                .orderByDesc(DevAsset::getUpdatedAt)
                .last("LIMIT 10");
        vo.setRecentUpdated(assetMapper.selectList(updatedWrapper).stream().map(this::toListVO).toList());
        return vo;
    }

    // ==================== 私有方法 ====================

    private DevAsset getExistAsset(Long id) {
        DevAsset asset = assetMapper.selectById(id);
        if (asset == null || (asset.getDeleted() != null && asset.getDeleted() == 1)) {
            throw new RuntimeException("资产不存在或已被删除");
        }
        return asset;
    }

    private void validateSaveDTO(DevAssetSaveDTO dto) {
        if (!StringUtils.hasText(dto.getTitle())) {
            throw new RuntimeException("标题不能为空");
        }
        if (!StringUtils.hasText(dto.getType()) || !ASSET_TYPES.contains(dto.getType())) {
            throw new RuntimeException("资产类型不合法");
        }
    }

    private void recordUsage(Long assetId, String action) {
        DevAssetUsage usage = new DevAssetUsage();
        usage.setAssetId(assetId);
        usage.setAction(action);
        usage.setCreatedBy(getCurrentUsername());
        usage.setCreatedAt(LocalDateTime.now());
        usageMapper.insert(usage);
    }

    /**
     * 关键词拆分：按空白字符切分，单个关键词整体匹配
     */
    private List<String> splitKeywords(String keyword) {
        if (!StringUtils.hasText(keyword)) {
            return new ArrayList<>();
        }
        return Arrays.stream(keyword.trim().split("\\s+"))
                .filter(StringUtils::hasText)
                .distinct()
                .collect(Collectors.toList());
    }

    private DevAssetListVO toListVO(DevAsset asset) {
        DevAssetListVO vo = new DevAssetListVO();
        vo.setId(asset.getId());
        vo.setTitle(asset.getTitle());
        vo.setType(asset.getType());
        vo.setDescription(asset.getDescription());
        vo.setLanguage(asset.getLanguage());
        vo.setTags(parseTags(asset.getTags()));
        vo.setIsFavorite(asset.getIsFavorite());
        vo.setUsageCount(asset.getUsageCount());
        vo.setParentId(asset.getParentId());
        vo.setUpdatedAt(asset.getUpdatedAt());
        return vo;
    }

    private List<String> parseTags(String tags) {
        if (!StringUtils.hasText(tags)) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(tags, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            // 兼容非 JSON 格式的旧数据
            return Arrays.asList(tags.split(","));
        }
    }

    private String serializeTags(List<String> tags) {
        if (tags == null || tags.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(tags.stream()
                    .filter(StringUtils::hasText)
                    .map(String::trim)
                    .distinct()
                    .toList());
        } catch (Exception e) {
            throw new RuntimeException("标签序列化失败");
        }
    }

    private String getCurrentUsername() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        return principal == null ? "" : principal.toString();
    }
}
