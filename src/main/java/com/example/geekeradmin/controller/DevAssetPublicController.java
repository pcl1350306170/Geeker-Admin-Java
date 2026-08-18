package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.DevAssetQueryDTO;
import com.example.geekeradmin.service.DevAssetService;
import com.example.geekeradmin.service.DevAssetTagService;
import com.example.geekeradmin.vo.DevAssetDetailVO;
import com.example.geekeradmin.vo.DevAssetListVO;
import com.example.geekeradmin.vo.DevAssetTagVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 开发资产库公开接口（免登录，只读查询）
 * 供外部快速访问的独立单页使用，仅提供搜索 / 详情 / 复制上报能力
 */
@RestController
@RequestMapping("/geeker/public/assets")
public class DevAssetPublicController {

    @Autowired
    private DevAssetService devAssetService;

    @Autowired
    private DevAssetTagService devAssetTagService;

    /**
     * 分页查询 / 搜索（关键词、类型、标签）
     */
    @GetMapping
    public Result<Map<String, Object>> list(DevAssetQueryDTO query) {
        // 公开页不提供收藏筛选
        query.setIsFavorite(null);
        IPage<DevAssetListVO> page = devAssetService.getAssetPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 标签字典（供公开页标签筛选）
     */
    @GetMapping("/tags")
    public Result<List<DevAssetTagVO>> tags() {
        return Result.success(devAssetTagService.listAll());
    }

    /**
     * 资产详情（记录 VIEW）
     */
    @GetMapping("/{id}")
    public Result<DevAssetDetailVO> detail(@PathVariable Long id) {
        return Result.success(devAssetService.getDetail(id));
    }

    /**
     * 复制上报（usage_count + 1，记录 COPY）
     */
    @PostMapping("/{id}/copy")
    public Result<?> copy(@PathVariable Long id) {
        devAssetService.recordCopy(id);
        return Result.success(null);
    }
}
