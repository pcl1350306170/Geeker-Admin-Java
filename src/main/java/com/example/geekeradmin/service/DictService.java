package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.DictDataQueryDTO;
import com.example.geekeradmin.dto.DictDataSaveDTO;
import com.example.geekeradmin.dto.DictTypeQueryDTO;
import com.example.geekeradmin.dto.DictTypeSaveDTO;
import com.example.geekeradmin.entity.SysDictData;
import com.example.geekeradmin.entity.SysDictType;
import com.example.geekeradmin.mapper.SysDictDataMapper;
import com.example.geekeradmin.mapper.SysDictTypeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 字典管理（字典类型 + 字典数据），内置本地缓存供全局字典查询接口使用
 */
@Service
public class DictService {

    @Autowired
    private SysDictTypeMapper dictTypeMapper;

    @Autowired
    private SysDictDataMapper dictDataMapper;

    /** 字典数据本地缓存：dictType -> 启用状态的字典数据列表（按 sort 排序） */
    private final Map<String, List<SysDictData>> dictCache = new ConcurrentHashMap<>();

    // ========== 字典类型 ==========

    /**
     * 分页查询字典类型
     */
    public Page<SysDictType> getDictTypePage(DictTypeQueryDTO query) {
        LambdaQueryWrapper<SysDictType> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(query.getName()), SysDictType::getName, query.getName())
                .like(StringUtils.hasText(query.getType()), SysDictType::getType, query.getType())
                .eq(query.getStatus() != null, SysDictType::getStatus, query.getStatus());
        wrapper.orderByDesc(SysDictType::getId);
        return dictTypeMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
    }

    /**
     * 全部启用的字典类型（不分页，用于字典数据表单里选择所属类型）
     */
    public List<SysDictType> getAllEnabledDictTypes() {
        LambdaQueryWrapper<SysDictType> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDictType::getStatus, 1).orderByAsc(SysDictType::getId);
        return dictTypeMapper.selectList(wrapper);
    }

    /**
     * 新增字典类型
     */
    public void addDictType(DictTypeSaveDTO dto) {
        if (!StringUtils.hasText(dto.getName())) {
            throw new RuntimeException("字典名称不能为空");
        }
        if (!StringUtils.hasText(dto.getType())) {
            throw new RuntimeException("字典类型编码不能为空");
        }
        checkTypeUnique(dto.getType(), null);
        SysDictType dictType = new SysDictType();
        dictType.setName(dto.getName());
        dictType.setType(dto.getType());
        dictType.setStatus(dto.getStatus() == null ? 1 : dto.getStatus());
        dictType.setRemark(dto.getRemark());
        dictType.setCreateTime(LocalDateTime.now());
        dictType.setUpdateTime(LocalDateTime.now());
        dictTypeMapper.insert(dictType);
    }

    /**
     * 编辑字典类型（类型编码变化时级联更新字典数据，并清理新旧编码缓存）
     */
    public void updateDictType(DictTypeSaveDTO dto) {
        if (dto.getId() == null) {
            throw new RuntimeException("字典类型ID不能为空");
        }
        SysDictType exist = dictTypeMapper.selectById(dto.getId());
        if (exist == null) {
            throw new RuntimeException("字典类型不存在");
        }
        if (!StringUtils.hasText(dto.getName())) {
            throw new RuntimeException("字典名称不能为空");
        }
        if (!StringUtils.hasText(dto.getType())) {
            throw new RuntimeException("字典类型编码不能为空");
        }
        checkTypeUnique(dto.getType(), dto.getId());

        String oldType = exist.getType();
        String newType = dto.getType();
        exist.setName(dto.getName());
        exist.setType(newType);
        if (dto.getStatus() != null) {
            exist.setStatus(dto.getStatus());
        }
        exist.setRemark(dto.getRemark());
        exist.setUpdateTime(LocalDateTime.now());
        dictTypeMapper.updateById(exist);

        if (!oldType.equals(newType)) {
            LambdaUpdateWrapper<SysDictData> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(SysDictData::getDictType, oldType).set(SysDictData::getDictType, newType);
            dictDataMapper.update(null, updateWrapper);
            evictCache(oldType);
        }
        evictCache(newType);
    }

    /**
     * 删除字典类型（存在关联字典数据时禁止删除）
     */
    public void deleteDictType(Long id) {
        SysDictType exist = dictTypeMapper.selectById(id);
        if (exist == null) {
            throw new RuntimeException("字典类型不存在");
        }
        LambdaQueryWrapper<SysDictData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDictData::getDictType, exist.getType());
        if (dictDataMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("该字典类型下存在字典数据，请先删除字典数据");
        }
        dictTypeMapper.deleteById(id);
        evictCache(exist.getType());
    }

    /**
     * 切换字典类型状态
     */
    public void changeDictTypeStatus(Long id, Integer status) {
        SysDictType exist = dictTypeMapper.selectById(id);
        if (exist == null) {
            throw new RuntimeException("字典类型不存在");
        }
        exist.setStatus(status);
        exist.setUpdateTime(LocalDateTime.now());
        dictTypeMapper.updateById(exist);
        evictCache(exist.getType());
    }

    private void checkTypeUnique(String type, Long excludeId) {
        LambdaQueryWrapper<SysDictType> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDictType::getType, type).ne(excludeId != null, SysDictType::getId, excludeId);
        if (dictTypeMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("字典类型编码已存在");
        }
    }

    // ========== 字典数据 ==========

    /**
     * 分页查询字典数据（填充所属字典类型名称）
     */
    public Page<SysDictData> getDictDataPage(DictDataQueryDTO query) {
        LambdaQueryWrapper<SysDictData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StringUtils.hasText(query.getDictType()), SysDictData::getDictType, query.getDictType())
                .like(StringUtils.hasText(query.getLabel()), SysDictData::getLabel, query.getLabel())
                .eq(query.getStatus() != null, SysDictData::getStatus, query.getStatus());
        wrapper.orderByAsc(SysDictData::getSort).orderByAsc(SysDictData::getId);
        Page<SysDictData> page = dictDataMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        fillDictTypeName(page.getRecords());
        return page;
    }

    /**
     * 新增字典数据
     */
    public void addDictData(DictDataSaveDTO dto) {
        validateDictData(dto, null);
        SysDictData data = new SysDictData();
        copyDictData(dto, data);
        data.setCreateTime(LocalDateTime.now());
        data.setUpdateTime(LocalDateTime.now());
        if (Integer.valueOf(1).equals(data.getIsDefault())) {
            clearOtherDefault(data.getDictType(), null);
        }
        dictDataMapper.insert(data);
        evictCache(data.getDictType());
    }

    /**
     * 编辑字典数据
     */
    public void updateDictData(DictDataSaveDTO dto) {
        if (dto.getId() == null) {
            throw new RuntimeException("字典数据ID不能为空");
        }
        SysDictData exist = dictDataMapper.selectById(dto.getId());
        if (exist == null) {
            throw new RuntimeException("字典数据不存在");
        }
        validateDictData(dto, dto.getId());
        String oldDictType = exist.getDictType();
        copyDictData(dto, exist);
        exist.setUpdateTime(LocalDateTime.now());
        if (Integer.valueOf(1).equals(exist.getIsDefault())) {
            clearOtherDefault(exist.getDictType(), exist.getId());
        }
        dictDataMapper.updateById(exist);
        evictCache(exist.getDictType());
        if (!oldDictType.equals(exist.getDictType())) {
            evictCache(oldDictType);
        }
    }

    /**
     * 删除字典数据
     */
    public void deleteDictData(Long id) {
        SysDictData exist = dictDataMapper.selectById(id);
        if (exist == null) {
            throw new RuntimeException("字典数据不存在");
        }
        dictDataMapper.deleteById(id);
        evictCache(exist.getDictType());
    }

    /**
     * 切换字典数据状态
     */
    public void changeDictDataStatus(Long id, Integer status) {
        SysDictData exist = dictDataMapper.selectById(id);
        if (exist == null) {
            throw new RuntimeException("字典数据不存在");
        }
        exist.setStatus(status);
        exist.setUpdateTime(LocalDateTime.now());
        dictDataMapper.updateById(exist);
        evictCache(exist.getDictType());
    }

    private void validateDictData(DictDataSaveDTO dto, Long excludeId) {
        if (!StringUtils.hasText(dto.getDictType())) {
            throw new RuntimeException("所属字典类型不能为空");
        }
        if (!StringUtils.hasText(dto.getLabel())) {
            throw new RuntimeException("字典标签不能为空");
        }
        if (!StringUtils.hasText(dto.getValue())) {
            throw new RuntimeException("字典键值不能为空");
        }
        LambdaQueryWrapper<SysDictType> typeWrapper = new LambdaQueryWrapper<>();
        typeWrapper.eq(SysDictType::getType, dto.getDictType());
        if (dictTypeMapper.selectCount(typeWrapper) == 0) {
            throw new RuntimeException("所属字典类型不存在");
        }
        // 同一字典类型下键值唯一
        LambdaQueryWrapper<SysDictData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDictData::getDictType, dto.getDictType())
                .eq(SysDictData::getValue, dto.getValue())
                .ne(excludeId != null, SysDictData::getId, excludeId);
        if (dictDataMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("同一字典类型下键值已存在");
        }
    }

    private void copyDictData(DictDataSaveDTO dto, SysDictData data) {
        data.setDictType(dto.getDictType());
        data.setLabel(dto.getLabel());
        data.setValue(dto.getValue());
        data.setSort(dto.getSort() == null ? 1 : dto.getSort());
        data.setStatus(dto.getStatus() == null ? 1 : dto.getStatus());
        data.setListClass(dto.getListClass());
        data.setIsDefault(dto.getIsDefault() == null ? 0 : dto.getIsDefault());
        data.setRemark(dto.getRemark());
    }

    /**
     * 同一字典类型下只允许一条默认项，设置新的默认项前先清除其它默认标记
     */
    private void clearOtherDefault(String dictType, Long excludeId) {
        LambdaUpdateWrapper<SysDictData> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(SysDictData::getDictType, dictType)
                .eq(SysDictData::getIsDefault, 1)
                .ne(excludeId != null, SysDictData::getId, excludeId)
                .set(SysDictData::getIsDefault, 0);
        dictDataMapper.update(null, wrapper);
    }

    private void fillDictTypeName(List<SysDictData> list) {
        if (list == null || list.isEmpty()) {
            return;
        }
        Map<String, String> typeNameMap = new HashMap<>();
        for (SysDictType type : dictTypeMapper.selectList(null)) {
            typeNameMap.put(type.getType(), type.getName());
        }
        list.forEach(item -> item.setDictTypeName(typeNameMap.get(item.getDictType())));
    }

    // ========== 对外字典查询（供前端 useDict 调用，带缓存） ==========

    /**
     * 按字典类型编码查询启用状态的字典数据（按 sort 排序）。
     * 若字典类型本身被禁用或不存在，返回空列表。
     */
    public List<SysDictData> getEnabledDictDataByType(String dictType) {
        if (!StringUtils.hasText(dictType)) {
            return List.of();
        }
        return dictCache.computeIfAbsent(dictType, this::loadEnabledDictData);
    }

    private List<SysDictData> loadEnabledDictData(String dictType) {
        LambdaQueryWrapper<SysDictType> typeWrapper = new LambdaQueryWrapper<>();
        typeWrapper.eq(SysDictType::getType, dictType).eq(SysDictType::getStatus, 1);
        if (dictTypeMapper.selectCount(typeWrapper) == 0) {
            return List.of();
        }
        LambdaQueryWrapper<SysDictData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDictData::getDictType, dictType).eq(SysDictData::getStatus, 1);
        wrapper.orderByAsc(SysDictData::getSort).orderByAsc(SysDictData::getId);
        return dictDataMapper.selectList(wrapper);
    }

    private void evictCache(String dictType) {
        if (StringUtils.hasText(dictType)) {
            dictCache.remove(dictType);
        }
    }

    /**
     * 清空全部字典缓存（管理页面"刷新缓存"按钮用）
     */
    public void refreshAllCache() {
        dictCache.clear();
    }

    // ========== 导出用 ==========

    public List<SysDictType> getAllDictTypes() {
        LambdaQueryWrapper<SysDictType> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(SysDictType::getId);
        return dictTypeMapper.selectList(wrapper);
    }

    public List<SysDictData> getAllDictData() {
        LambdaQueryWrapper<SysDictData> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(SysDictData::getDictType).orderByAsc(SysDictData::getSort).orderByAsc(SysDictData::getId);
        List<SysDictData> list = dictDataMapper.selectList(wrapper);
        fillDictTypeName(list);
        return list;
    }
}
