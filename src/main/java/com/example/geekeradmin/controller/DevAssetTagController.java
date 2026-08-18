package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.service.DevAssetTagService;
import com.example.geekeradmin.vo.DevAssetTagVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 开发资产库-标签字典管理
 */
@RestController
@RequestMapping("/geeker/dev/tags")
public class DevAssetTagController {

    @Autowired
    private DevAssetTagService tagService;

    /**
     * 全部标签（含使用数量）
     */
    @GetMapping
    public Result<List<DevAssetTagVO>> list() {
        return Result.success(tagService.listAll());
    }

    /**
     * 新增标签
     */
    @PostMapping
    public Result<Map<String, Object>> add(@RequestBody Map<String, Object> body) {
        String name = body.get("name") == null ? null : body.get("name").toString();
        Integer sort = body.get("sort") == null ? null : Integer.valueOf(body.get("sort").toString());
        Long id = tagService.addTag(name, sort);
        return Result.success(Map.of("id", id));
    }

    /**
     * 修改标签（改名会同步更新资产中的标签）
     */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String name = body.get("name") == null ? null : body.get("name").toString();
        Integer sort = body.get("sort") == null ? null : Integer.valueOf(body.get("sort").toString());
        tagService.updateTag(id, name, sort);
        return Result.success(null);
    }

    /**
     * 删除标签（有资产使用时禁止删除）
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        tagService.deleteTag(id);
        return Result.success(null);
    }
}
