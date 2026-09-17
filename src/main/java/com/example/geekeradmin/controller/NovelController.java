package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.NovelQueryDTO;
import com.example.geekeradmin.dto.NovelSaveDTO;
import com.example.geekeradmin.service.NovelService;
import com.example.geekeradmin.vo.NovelListVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 小说管理
 */
@RestController
@RequestMapping("/geeker/novel/novels")
public class NovelController {

    @Autowired
    private NovelService novelService;

    /**
     * 分页查询小说（含家族数）
     */
    @GetMapping
    public Result<Map<String, Object>> list(NovelQueryDTO query) {
        IPage<NovelListVO> page = novelService.getNovelPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 全量小说下拉列表
     */
    @GetMapping("/all")
    public Result<List<NovelListVO>> all() {
        return Result.success(novelService.getAllNovels());
    }

    /**
     * 新增小说
     */
    @PostMapping
    public Result<Map<String, Object>> add(@RequestBody NovelSaveDTO dto) {
        Long id = novelService.addNovel(dto);
        return Result.success(Map.of("id", id));
    }

    /**
     * 编辑小说
     */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody NovelSaveDTO dto) {
        novelService.updateNovel(id, dto);
        return Result.success(null);
    }

    /**
     * 删除小说（名下仍有家族时拒绝）
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        novelService.deleteNovel(id);
        return Result.success(null);
    }
}
