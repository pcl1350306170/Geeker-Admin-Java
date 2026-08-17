package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.UserQueryDTO;
import com.example.geekeradmin.dto.UserSaveDTO;
import com.example.geekeradmin.entity.MenuMeta;
import com.example.geekeradmin.entity.SysMenu;
import com.example.geekeradmin.entity.SysUser;
import com.example.geekeradmin.mapper.SysMenuMapper;
import com.example.geekeradmin.mapper.SysUserMapper;
import com.example.geekeradmin.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    /**
     * 重置密码的默认明文密码（前端登录会先做 MD5，所以这里存的是 MD5 值）
     */
    private static final String DEFAULT_PASSWORD_MD5 = "e10adc3949ba59abbe56e057f20f883e"; // MD5("123456")

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysMenuMapper menuMapper;

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
                .eq(query.getStatus() != null, SysUser::getStatus, query.getStatus())
                .orderByDesc(SysUser::getId);
        Page<SysUser> page = userMapper.selectPage(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        Page<UserVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(this::toVO).collect(Collectors.toList()));
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
        return userMapper.selectList(null).stream().map(this::toVO).collect(Collectors.toList());
    }

    private UserVO toVO(SysUser user) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setAvatar(user.getAvatar());
        vo.setStatus(user.getStatus());
        vo.setCreateTime(user.getCreateTime());
        return vo;
    }

    private String getCurrentUsername() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return principal == null ? "" : principal.toString();
    }

    public List<SysMenu> getMenuList() {
        List<SysMenu> allMenus = menuMapper.selectAllEnabled();
        allMenus.forEach(menu -> {
            MenuMeta meta = new MenuMeta();
            meta.setIcon(menu.getIcon());
            meta.setTitle(menu.getTitle());
            meta.setIsLink(menu.getIsLink());
            meta.setHide(menu.getIsHide() == 1);
            meta.setFull(menu.getIsFull() == 1);
            meta.setAffix(menu.getIsAffix() == 1);
            meta.setKeepAlive(menu.getIsKeepAlive() == 1);
            meta.setActiveMenu(menu.getActiveMenu());
            menu.setMeta(meta);
        });
        return buildTree(allMenus, 0L);
    }

    private List<SysMenu> buildTree(List<SysMenu> menus, Long parentId) {
        return menus.stream()
                .filter(menu -> menu.getParentId().equals(parentId))
                .peek(menu -> menu.setChildren(buildTree(menus, menu.getId())))
                .collect(Collectors.toList());
    }
}
