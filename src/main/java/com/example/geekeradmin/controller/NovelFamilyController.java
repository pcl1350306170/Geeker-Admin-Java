package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.FamilyQueryDTO;
import com.example.geekeradmin.dto.FamilySaveDTO;
import com.example.geekeradmin.service.NovelFamilyService;
import com.example.geekeradmin.vo.FamilyDetailVO;
import com.example.geekeradmin.vo.FamilyListVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 小说家族管理
 */
@RestController
@RequestMapping("/geeker/novel/families")
public class NovelFamilyController {

    @Autowired
    private NovelFamilyService novelFamilyService;

    /**
     * 分页查询家族（含成员数 / 核心角色数）
     */
    @GetMapping
    public Result<Map<String, Object>> list(FamilyQueryDTO query) {
        IPage<FamilyListVO> page = novelFamilyService.getFamilyPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 家族详情
     */
    @GetMapping("/{id}")
    public Result<FamilyDetailVO> detail(@PathVariable Long id) {
        return Result.success(novelFamilyService.getFamilyDetail(id));
    }

    /**
     * 新增家族
     */
    @PostMapping
    public Result<Map<String, Object>> add(@RequestBody FamilySaveDTO dto) {
        Long id = novelFamilyService.addFamily(dto);
        return Result.success(Map.of("id", id));
    }

    /**
     * 编辑家族
     */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody FamilySaveDTO dto) {
        novelFamilyService.updateFamily(id, dto);
        return Result.success(null);
    }

    /**
     * 删除家族（有成员时禁止删除；级联逻辑删除家族间关系）
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        novelFamilyService.deleteFamily(id);
        return Result.success(null);
    }
}
