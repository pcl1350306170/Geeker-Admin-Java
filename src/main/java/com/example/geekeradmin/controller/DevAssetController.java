package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.DevAssetQueryDTO;
import com.example.geekeradmin.dto.DevAssetSaveDTO;
import com.example.geekeradmin.service.DevAssetService;
import com.example.geekeradmin.vo.DevAssetDetailVO;
import com.example.geekeradmin.vo.DevAssetHomeVO;
import com.example.geekeradmin.vo.DevAssetListVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 开发资产库（Dev Assets）
 */
@RestController
@RequestMapping("/geeker/dev/assets")
public class DevAssetController {

    @Autowired
    private DevAssetService devAssetService;

    /**
     * 首页聚合数据（最近使用 / 收藏 / 常用 / 最近更新）
     */
    @GetMapping("/home")
    public Result<DevAssetHomeVO> home() {
        return Result.success(devAssetService.getHomeData());
    }

    /**
     * 分页查询 / 搜索
     */
    @GetMapping
    public Result<Map<String, Object>> list(DevAssetQueryDTO query) {
        IPage<DevAssetListVO> page = devAssetService.getAssetPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 资产详情（记录 VIEW）
     */
    @GetMapping("/{id}")
    public Result<DevAssetDetailVO> detail(@PathVariable Long id) {
        return Result.success(devAssetService.getDetail(id));
    }

    /**
     * 新增资产
     */
    @PostMapping
    public Result<Map<String, Object>> add(@RequestBody DevAssetSaveDTO dto) {
        Long id = devAssetService.addAsset(dto);
        return Result.success(Map.of("id", id));
    }

    /**
     * 编辑资产
     */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody DevAssetSaveDTO dto) {
        devAssetService.updateAsset(id, dto);
        return Result.success(null);
    }

    /**
     * 删除资产（逻辑删除）
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        devAssetService.deleteAsset(id);
        return Result.success(null);
    }

    /**
     * 收藏 / 取消收藏
     */
    @PutMapping("/{id}/favorite")
    public Result<Map<String, Object>> favorite(@PathVariable Long id) {
        Integer isFavorite = devAssetService.toggleFavorite(id);
        return Result.success(Map.of("isFavorite", isFavorite));
    }

    /**
     * 复制上报（usage_count + 1，记录 COPY）
     */
    @PostMapping("/{id}/copy")
    public Result<?> copy(@PathVariable Long id) {
        devAssetService.recordCopy(id);
        return Result.success(null);
    }

    /**
     * 基于旧资产创建新资产
     */
    @PostMapping("/{id}/duplicate")
    public Result<Map<String, Object>> duplicate(@PathVariable Long id) {
        Long newId = devAssetService.duplicateAsset(id);
        return Result.success(Map.of("id", newId));
    }
}
