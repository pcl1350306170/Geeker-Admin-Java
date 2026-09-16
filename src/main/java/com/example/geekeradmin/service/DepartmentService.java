package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.geekeradmin.dto.DepartmentQueryDTO;
import com.example.geekeradmin.dto.DepartmentSaveDTO;
import com.example.geekeradmin.entity.SysDepartment;
import com.example.geekeradmin.mapper.SysDepartmentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 部门管理（树形 CRUD）
 */
@Service
public class DepartmentService {

    @Autowired
    private SysDepartmentMapper departmentMapper;

    /**
     * 查询部门树（不分页）。
     * 当带有 name/status 过滤条件时，保留命中节点及其所有祖先，保证树结构完整。
     */
    public List<SysDepartment> getDepartmentTree(DepartmentQueryDTO query) {
        LambdaQueryWrapper<SysDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(SysDepartment::getSort).orderByAsc(SysDepartment::getId);
        List<SysDepartment> all = departmentMapper.selectList(wrapper);

        boolean filtered = StringUtils.hasText(query.getName()) || query.getStatus() != null;
        if (filtered) {
            all = retainWithAncestors(all, query);
        }
        return buildTree(all, 0L);
    }

    /**
     * 查询所有部门的扁平列表（导出用）
     */
    public List<SysDepartment> getAllFlat() {
        LambdaQueryWrapper<SysDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(SysDepartment::getSort).orderByAsc(SysDepartment::getId);
        return departmentMapper.selectList(wrapper);
    }

    /**
     * 获取指定部门自身及其所有子孙部门的ID集合（数据权限/级联过滤用）。
     * deptId 为 null 时返回空集合。
     */
    public Set<Long> getSelfAndDescendantIds(Long deptId) {
        Set<Long> result = new HashSet<>();
        if (deptId == null) {
            return result;
        }
        List<SysDepartment> all = departmentMapper.selectList(null);
        Deque<Long> stack = new ArrayDeque<>();
        stack.push(deptId);
        while (!stack.isEmpty()) {
            Long current = stack.pop();
            if (!result.add(current)) {
                continue;
            }
            for (SysDepartment dept : all) {
                if (current.equals(dept.getParentId())) {
                    stack.push(dept.getId());
                }
            }
        }
        return result;
    }

    /**
     * 新增部门
     */
    public void addDepartment(DepartmentSaveDTO dto) {
        if (!StringUtils.hasText(dto.getName())) {
            throw new RuntimeException("部门名称不能为空");
        }
        SysDepartment dept = new SysDepartment();
        dept.setParentId(dto.getParentId() == null ? 0L : dto.getParentId());
        dept.setName(dto.getName());
        dept.setCode(dto.getCode());
        dept.setLeader(dto.getLeader());
        dept.setPhone(dto.getPhone());
        dept.setEmail(dto.getEmail());
        dept.setSort(dto.getSort() == null ? 1 : dto.getSort());
        dept.setStatus(dto.getStatus() == null ? 1 : dto.getStatus());
        dept.setCreateTime(LocalDateTime.now());
        // 校验上级部门是否存在
        if (dept.getParentId() != 0L && departmentMapper.selectById(dept.getParentId()) == null) {
            throw new RuntimeException("上级部门不存在");
        }
        // 校验部门编码唯一
        checkCodeUnique(dto.getCode(), null);
        departmentMapper.insert(dept);
    }

    /**
     * 编辑部门
     */
    public void updateDepartment(DepartmentSaveDTO dto) {
        if (dto.getId() == null) {
            throw new RuntimeException("部门ID不能为空");
        }
        SysDepartment exist = departmentMapper.selectById(dto.getId());
        if (exist == null) {
            throw new RuntimeException("部门不存在");
        }
        if (!StringUtils.hasText(dto.getName())) {
            throw new RuntimeException("部门名称不能为空");
        }
        Long newParentId = dto.getParentId() == null ? exist.getParentId() : dto.getParentId();
        if (newParentId.equals(dto.getId())) {
            throw new RuntimeException("上级部门不能选择自己");
        }
        // 上级部门不能是自己的子孙部门，否则会造成循环
        if (newParentId != 0L && isDescendant(newParentId, dto.getId())) {
            throw new RuntimeException("上级部门不能选择自己的下级部门");
        }
        if (newParentId != 0L && departmentMapper.selectById(newParentId) == null) {
            throw new RuntimeException("上级部门不存在");
        }
        checkCodeUnique(dto.getCode(), dto.getId());

        exist.setParentId(newParentId);
        exist.setName(dto.getName());
        exist.setCode(dto.getCode());
        exist.setLeader(dto.getLeader());
        exist.setPhone(dto.getPhone());
        exist.setEmail(dto.getEmail());
        if (dto.getSort() != null) {
            exist.setSort(dto.getSort());
        }
        if (dto.getStatus() != null) {
            exist.setStatus(dto.getStatus());
        }
        departmentMapper.updateById(exist);
    }

    /**
     * 删除部门（存在子部门时禁止删除）
     */
    public void deleteDepartment(Long id) {
        SysDepartment dept = departmentMapper.selectById(id);
        if (dept == null) {
            throw new RuntimeException("部门不存在");
        }
        LambdaQueryWrapper<SysDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDepartment::getParentId, id);
        if (departmentMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("该部门存在下级部门，请先删除下级部门");
        }
        departmentMapper.deleteById(id);
    }

    /**
     * 切换部门状态
     */
    public void changeStatus(Long id, Integer status) {
        SysDepartment dept = departmentMapper.selectById(id);
        if (dept == null) {
            throw new RuntimeException("部门不存在");
        }
        dept.setStatus(status);
        departmentMapper.updateById(dept);
    }

    /**
     * 校验部门编码唯一（excludeId 为需要排除的自身ID，新增时传 null）
     */
    private void checkCodeUnique(String code, Long excludeId) {
        if (!StringUtils.hasText(code)) {
            return;
        }
        LambdaQueryWrapper<SysDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDepartment::getCode, code).ne(excludeId != null, SysDepartment::getId, excludeId);
        if (departmentMapper.selectCount(wrapper) > 0) {
            throw new RuntimeException("部门编码已存在");
        }
    }

    /**
     * 判断 candidateId 是否为 parentId 的子孙节点
     */
    private boolean isDescendant(Long candidateId, Long parentId) {
        Set<Long> visited = new HashSet<>();
        Long cursor = candidateId;
        while (cursor != null && cursor != 0L && visited.add(cursor)) {
            SysDepartment node = departmentMapper.selectById(cursor);
            if (node == null) {
                return false;
            }
            if (parentId.equals(node.getParentId())) {
                return true;
            }
            cursor = node.getParentId();
        }
        return false;
    }

    /**
     * 保留命中过滤条件的节点及其所有祖先
     */
    private List<SysDepartment> retainWithAncestors(List<SysDepartment> all, DepartmentQueryDTO query) {
        Set<Long> keepIds = new HashSet<>();
        for (SysDepartment dept : all) {
            boolean nameMatch = !StringUtils.hasText(query.getName())
                    || (dept.getName() != null && dept.getName().contains(query.getName()));
            boolean statusMatch = query.getStatus() == null || query.getStatus().equals(dept.getStatus());
            if (nameMatch && statusMatch) {
                // 命中节点，向上补齐所有祖先
                Long cursor = dept.getId();
                while (cursor != null && cursor != 0L && keepIds.add(cursor)) {
                    SysDepartment node = findById(all, cursor);
                    cursor = node == null ? null : node.getParentId();
                }
            }
        }
        return all.stream().filter(dept -> keepIds.contains(dept.getId())).toList();
    }

    private SysDepartment findById(List<SysDepartment> all, Long id) {
        return all.stream().filter(item -> item.getId().equals(id)).findFirst().orElse(null);
    }

    private List<SysDepartment> buildTree(List<SysDepartment> departments, Long parentId) {
        return departments.stream()
                .filter(dept -> parentId.equals(dept.getParentId()))
                .peek(dept -> dept.setChildren(buildTree(departments, dept.getId())))
                .toList();
    }
}
