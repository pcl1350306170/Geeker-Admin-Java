package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.MemberQueryDTO;
import com.example.geekeradmin.dto.MemberSaveDTO;
import com.example.geekeradmin.service.NovelFamilyMemberService;
import com.example.geekeradmin.vo.MemberDetailVO;
import com.example.geekeradmin.vo.MemberListVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 小说家族成员管理
 */
@RestController
@RequestMapping("/geeker/novel/members")
public class NovelFamilyMemberController {

    @Autowired
    private NovelFamilyMemberService novelFamilyMemberService;

    /**
     * 分页查询成员（支持按家族 / 关键词 / 角色定位筛选）
     */
    @GetMapping
    public Result<Map<String, Object>> list(MemberQueryDTO query) {
        IPage<MemberListVO> page = novelFamilyMemberService.getMemberPage(query);
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return Result.success(data);
    }

    /**
     * 成员详情（含家族名、性格标签、人物小传）
     */
    @GetMapping("/{id}")
    public Result<MemberDetailVO> detail(@PathVariable Long id) {
        return Result.success(novelFamilyMemberService.getMemberDetail(id));
    }

    /**
     * 新增成员
     */
    @PostMapping
    public Result<Map<String, Object>> add(@RequestBody MemberSaveDTO dto) {
        Long id = novelFamilyMemberService.addMember(dto);
        return Result.success(Map.of("id", id));
    }

    /**
     * 编辑成员
     */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody MemberSaveDTO dto) {
        novelFamilyMemberService.updateMember(id, dto);
        return Result.success(null);
    }

    /**
     * 删除成员（级联逻辑删除其相关关系）
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        novelFamilyMemberService.deleteMember(id);
        return Result.success(null);
    }
}
