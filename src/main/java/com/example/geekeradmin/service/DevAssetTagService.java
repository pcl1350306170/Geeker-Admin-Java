package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.geekeradmin.entity.DevAsset;
import com.example.geekeradmin.entity.DevAssetTag;
import com.example.geekeradmin.mapper.DevAssetMapper;
import com.example.geekeradmin.mapper.DevAssetTagMapper;
import com.example.geekeradmin.vo.DevAssetTagVO;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 开发资产库-标签字典管理
 * 说明：本表只维护"有哪些标签可选"，资产的标签仍保存在 dev_asset.tags（JSON 数组），
 * 资产搜索路径不经过本表，不影响搜索性能。
 */
@Service
public class DevAssetTagService {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private DevAssetTagMapper tagMapper;

    @Autowired
    private DevAssetMapper assetMapper;

    /**
     * 全部标签（sort 倒序、名称正序），附带使用数量
     */
    public List<DevAssetTagVO> listAll() {
        LambdaQueryWrapper<DevAssetTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(DevAssetTag::getSort).orderByAsc(DevAssetTag::getName);
        return tagMapper.selectList(wrapper).stream().map(this::toVO).toList();
    }

    /**
     * 新增标签（名称去重）
     */
    public Long addTag(String name, Integer sort) {
        String trimmed = validateName(name);
        if (existsByName(trimmed, null)) {
            throw new RuntimeException("标签「" + trimmed + "」已存在");
        }
        DevAssetTag tag = new DevAssetTag();
        tag.setName(trimmed);
        tag.setSort(sort == null ? 0 : sort);
        tag.setCreatedAt(LocalDateTime.now());
        tagMapper.insert(tag);
        return tag.getId();
    }

    /**
     * 修改标签（改名时同步更新所有资产中的标签值）
     */
    @Transactional
    public void updateTag(Long id, String name, Integer sort) {
        DevAssetTag tag = tagMapper.selectById(id);
        if (tag == null) {
            throw new RuntimeException("标签不存在");
        }
        String newName = validateName(name);
        if (!newName.equals(tag.getName()) && existsByName(newName, id)) {
            throw new RuntimeException("标签「" + newName + "」已存在");
        }
        // 改名时同步替换资产 tags JSON 中的旧标签名
        if (!newName.equals(tag.getName())) {
            replaceTagNameInAssets(tag.getName(), newName);
        }
        tag.setName(newName);
        if (sort != null) {
            tag.setSort(sort);
        }
        tagMapper.updateById(tag);
    }

    /**
     * 删除标签（有资产在使用时禁止删除，避免产生无主标签）
     */
    public void deleteTag(Long id) {
        DevAssetTag tag = tagMapper.selectById(id);
        if (tag == null) {
            throw new RuntimeException("标签不存在");
        }
        long usageCount = countAssetByTag(tag.getName());
        if (usageCount > 0) {
            throw new RuntimeException("标签「" + tag.getName() + "」正在被 " + usageCount + " 个资产使用，请先移除后再删除");
        }
        tagMapper.deleteById(id);
    }

    /**
     * 保存资产时自动注册新标签（由 DevAssetService 调用），保证字典与实际使用同步
     */
    public void registerTags(List<String> tagNames) {
        if (tagNames == null || tagNames.isEmpty()) {
            return;
        }
        for (String name : tagNames) {
            if (!StringUtils.hasText(name)) {
                continue;
            }
            String trimmed = name.trim();
            if (trimmed.length() <= 50 && !existsByName(trimmed, null)) {
                DevAssetTag tag = new DevAssetTag();
                tag.setName(trimmed);
                tag.setSort(0);
                tag.setCreatedAt(LocalDateTime.now());
                tagMapper.insert(tag);
            }
        }
    }

    // ==================== 私有方法 ====================

    private String validateName(String name) {
        if (!StringUtils.hasText(name)) {
            throw new RuntimeException("标签名不能为空");
        }
        String trimmed = name.trim();
        if (trimmed.length() > 50) {
            throw new RuntimeException("标签名长度不能超过 50");
        }
        return trimmed;
    }

    private boolean existsByName(String name, Long excludeId) {
        LambdaQueryWrapper<DevAssetTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DevAssetTag::getName, name);
        if (excludeId != null) {
            wrapper.ne(DevAssetTag::getId, excludeId);
        }
        return tagMapper.selectCount(wrapper) > 0;
    }

    /**
     * 统计使用该标签的资产数量（精确匹配 JSON 数组中的 "标签名"）
     */
    private long countAssetByTag(String tagName) {
        LambdaQueryWrapper<DevAsset> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DevAsset::getDeleted, 0).like(DevAsset::getTags, "\"" + tagName + "\"");
        return assetMapper.selectCount(wrapper);
    }

    /**
     * 标签改名：把资产 tags JSON 中的旧名替换为新名（数据量为个人级，逐条更新即可）
     */
    private void replaceTagNameInAssets(String oldName, String newName) {
        LambdaQueryWrapper<DevAsset> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DevAsset::getDeleted, 0).like(DevAsset::getTags, "\"" + oldName + "\"");
        List<DevAsset> assets = assetMapper.selectList(wrapper);
        for (DevAsset asset : assets) {
            try {
                List<String> tags = objectMapper.readValue(asset.getTags(), new TypeReference<List<String>>() {});
                List<String> replaced = tags.stream().map(t -> oldName.equals(t) ? newName : t).toList();
                DevAsset update = new DevAsset();
                update.setId(asset.getId());
                update.setTags(objectMapper.writeValueAsString(replaced));
                assetMapper.updateById(update);
            } catch (Exception ignored) {
                // 兼容非 JSON 旧数据：直接字符串替换
                DevAsset update = new DevAsset();
                update.setId(asset.getId());
                update.setTags(asset.getTags().replace("\"" + oldName + "\"", "\"" + newName + "\""));
                assetMapper.updateById(update);
            }
        }
    }

    private DevAssetTagVO toVO(DevAssetTag tag) {
        DevAssetTagVO vo = new DevAssetTagVO();
        vo.setId(tag.getId());
        vo.setName(tag.getName());
        vo.setSort(tag.getSort());
        vo.setUsageCount(countAssetByTag(tag.getName()));
        vo.setCreatedAt(tag.getCreatedAt());
        return vo;
    }
}
