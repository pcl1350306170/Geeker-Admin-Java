package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.UserQueryDTO;
import com.example.geekeradmin.dto.UserSaveDTO;
import com.example.geekeradmin.entity.SysDepartment;
import com.example.geekeradmin.entity.SysUser;
import com.example.geekeradmin.mapper.SysDepartmentMapper;
import com.example.geekeradmin.mapper.SysUserMapper;
import com.example.geekeradmin.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class UserService {

    /**
     * 重置密码的默认明文密码（前端登录会先做 MD5，所以这里存的是 MD5 值）
     */
    private static final String DEFAULT_PASSWORD_MD5 = "e10adc3949ba59abbe56e057f20f883e"; // MD5("123456")

    /** 数据范围：全部数据 */
    public static final int SCOPE_ALL = 1;
    /** 数据范围：本部门 */
    public static final int SCOPE_DEPT = 2;
    /** 数据范围：本部门及以下 */
    public static final int SCOPE_DEPT_AND_CHILD = 3;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysDepartmentMapper departmentMapper;

    @Autowired
    private DepartmentService departmentService;

    public SysUser findByUsername(String username) {
        return userMapper.selectByUsername(username);
    }

    /**
     * 分页查询用户列表
     */
    public Page<UserVO> getUserPage(UserQueryDTO query) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(query.getUsername()), SysUser::getUsername, query.getUsername())
                .like(StringUtils.hasText(query.getNickname()), SysUser::getNickname, query.getNickname())
                .eq(query.getStatus() != null, SysUser::getStatus, query.getStatus());
        // 数据权限 + 部门搜索（含子孙部门）组合过滤
        applyDataScopeAndDeptFilter(wrapper, query);
        wrapper.orderByDesc(SysUser::getId);
        Page<SysUser> page = userMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        Map<Long, String> deptNameMap = buildDeptNameMap();
        Page<UserVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(user -> toVO(user, deptNameMap)).collect(Collectors.toList()));
        return voPage;
    }

    /**
     * 新增用户
     */
    public void addUser(UserSaveDTO dto) {
        if (findByUsername(dto.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }
        if (!StringUtils.hasText(dto.getPassword())) {
            throw new RuntimeException("密码不能为空");
        }
        SysUser user = new SysUser();
        user.setUsername(dto.getUsername());
        user.setPassword(BCrypt.hashpw(dto.getPassword(), BCrypt.gensalt()));
        user.setNickname(dto.getNickname());
        user.setAvatar(dto.getAvatar());
        user.setStatus(dto.getStatus() == null ? 1 : dto.getStatus());
        user.setDeptId(dto.getDeptId());
        user.setDataScope(dto.getDataScope() == null ? SCOPE_ALL : dto.getDataScope());
        userMapper.insert(user);
    }

    /**
     * 编辑用户
     */
    public void updateUser(UserSaveDTO dto) {
        SysUser exist = userMapper.selectById(dto.getId());
        if (exist == null) {
            throw new RuntimeException("用户不存在");
        }
        // 修改用户名时校验唯一性
        if (StringUtils.hasText(dto.getUsername()) && !dto.getUsername().equals(exist.getUsername())) {
            if (findByUsername(dto.getUsername()) != null) {
                throw new RuntimeException("用户名已存在");
            }
            exist.setUsername(dto.getUsername());
        }
        if (dto.getNickname() != null) {
            exist.setNickname(dto.getNickname());
        }
        if (dto.getAvatar() != null) {
            exist.setAvatar(dto.getAvatar());
        }
        if (dto.getStatus() != null) {
            exist.setStatus(dto.getStatus());
        }
        if (dto.getDeptId() != null) {
            exist.setDeptId(dto.getDeptId());
        }
        if (dto.getDataScope() != null) {
            exist.setDataScope(dto.getDataScope());
        }
        // 密码非空时才更新（前端传入的是 MD5 值）
        if (StringUtils.hasText(dto.getPassword())) {
            exist.setPassword(BCrypt.hashpw(dto.getPassword(), BCrypt.gensalt()));
        }
        userMapper.updateById(exist);
    }

    /**
     * 删除用户
     */
    public void deleteUser(Long id) {
        SysUser user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (user.getUsername().equals(getCurrentUsername())) {
            throw new RuntimeException("不能删除当前登录用户");
        }
        userMapper.deleteById(id);
    }

    /**
     * 切换用户状态
     */
    public void changeStatus(Long id, Integer status) {
        SysUser user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (user.getUsername().equals(getCurrentUsername()) && status == 0) {
            throw new RuntimeException("不能禁用当前登录用户");
        }
        user.setStatus(status);
        userMapper.updateById(user);
    }

    /**
     * 重置密码为默认密码 123456
     */
    public void resetPassword(Long id) {
        SysUser user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        user.setPassword(BCrypt.hashpw(DEFAULT_PASSWORD_MD5, BCrypt.gensalt()));
        userMapper.updateById(user);
    }

    /**
     * 查询所有用户（导出用）
     */
    public List<UserVO> getAllUsers() {
        // 导出同样受数据权限约束
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        applyDataScopeAndDeptFilter(wrapper, new UserQueryDTO());
        Map<Long, String> deptNameMap = buildDeptNameMap();
        return userMapper.selectList(wrapper).stream().map(user -> toVO(user, deptNameMap)).collect(Collectors.toList());
    }

    /**
     * 构建部门ID -> 部门名称 的映射（用于列表/导出填充 deptName）
     */
    private Map<Long, String> buildDeptNameMap() {
        Map<Long, String> map = new HashMap<>();
        for (SysDepartment dept : departmentMapper.selectList(null)) {
            map.put(dept.getId(), dept.getName());
        }
        return map;
    }

    private UserVO toVO(SysUser user, Map<Long, String> deptNameMap) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setAvatar(user.getAvatar());
        vo.setStatus(user.getStatus());
        vo.setDeptId(user.getDeptId());
        vo.setDeptName(user.getDeptId() == null ? null : deptNameMap.get(user.getDeptId()));
        vo.setDataScope(user.getDataScope());
        vo.setCreateTime(user.getCreateTime());
        return vo;
    }

    /**
     * 数据权限过滤：根据当前登录用户的角色与 dataScope 限定可见用户范围，
     * 并与搜索栏的部门过滤（含子孙）取交集。
     * admin 或 dataScope=全部 时不限制。
     */
    private void applyDataScopeAndDeptFilter(LambdaQueryWrapper<SysUser> wrapper, UserQueryDTO query) {
        SysUser current = getCurrentUser();
        // 搜索栏指定的部门（含子孙）；null 表示未按部门搜索
        Set<Long> requested = query.getDeptId() == null
                ? null
                : departmentService.getSelfAndDescendantIds(query.getDeptId());

        boolean isAdmin = current == null || RoleService.ROLE_ADMIN.equals(current.getRole());
        int scope = (current == null || current.getDataScope() == null) ? SCOPE_ALL : current.getDataScope();

        // 数据权限允许的部门集合：null 表示不限制；selfOnly 表示只能看自己
        Set<Long> visible = null;
        boolean selfOnly = false;
        if (!isAdmin && (scope == SCOPE_DEPT || scope == SCOPE_DEPT_AND_CHILD)) {
            if (current.getDeptId() == null) {
                selfOnly = true;
            } else if (scope == SCOPE_DEPT) {
                visible = new HashSet<>();
                visible.add(current.getDeptId());
            } else {
                visible = departmentService.getSelfAndDescendantIds(current.getDeptId());
            }
        }

        // 与搜索栏部门过滤取交集
        if (requested != null) {
            if (selfOnly) {
                boolean hit = current.getDeptId() != null && requested.contains(current.getDeptId());
                if (!hit) {
                    wrapper.eq(SysUser::getId, -1L); // 无匹配数据
                    return;
                }
            } else if (visible == null) {
                visible = requested;
            } else {
                visible.retainAll(requested);
            }
        }

        if (selfOnly) {
            wrapper.eq(SysUser::getId, current.getId());
            return;
        }
        if (visible != null) {
            if (visible.isEmpty()) {
                wrapper.eq(SysUser::getId, -1L); // 交集为空，无可见数据
            } else {
                wrapper.in(SysUser::getDeptId, visible);
            }
        }
    }

    /**
     * 获取当前登录用户（取不到时返回 null）
     */
    private SysUser getCurrentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        if (principal == null || !StringUtils.hasText(principal.toString())) {
            return null;
        }
        return userMapper.selectByUsername(principal.toString());
    }

    private String getCurrentUsername() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return principal == null ? "" : principal.toString();
    }
}
