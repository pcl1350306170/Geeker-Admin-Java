package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.RelationQueryDTO;
import com.example.geekeradmin.dto.RelationSaveDTO;
import com.example.geekeradmin.service.NovelRelationService;
import com.example.geekeradmin.vo.GraphVO;
import com.example.geekeradmin.vo.RelationVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 小说关系管理（成员间 / 家族间）与关系图谱
 */
@RestController
@RequestMapping("/geeker/novel/relations")
public class NovelRelationController {

    @Autowired
    private NovelRelationService novelRelationService;

    /**
     * 分页查询关系（memberId=xx 查成员关系；familyId=xx 查家族间关系）
     */
    @GetMapping
    public Result<Map<String, Object>> list(RelationQueryDTO query) {
        IPage<RelationVO> page = novelRelationService.getRelationPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 新增关系（校验两端存在且不重复）
     */
    @PostMapping
    public Result<Map<String, Object>> add(@RequestBody RelationSaveDTO dto) {
        Long id = novelRelationService.addRelation(dto);
        return Result.success(Map.of("id", id));
    }

    /**
     * 删除关系（逻辑删除）
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        novelRelationService.deleteRelation(id);
        return Result.success(null);
    }

    /**
     * 家族总览图：全部家族节点 + 家族间关系边
     */
    @GetMapping("/family-graph")
    public Result<GraphVO> familyGraph() {
        return Result.success(novelRelationService.getFamilyGraph());
    }

    /**
     * 成员关系图：指定家族成员节点 + 成员间关系边
     */
    @GetMapping("/member-graph")
    public Result<GraphVO> memberGraph(@RequestParam Long familyId) {
        return Result.success(novelRelationService.getMemberGraph(familyId));
    }
}
