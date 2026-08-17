package com.example.geekeradmin.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.geekeradmin.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {
    @Select("SELECT id, username, password, nickname, avatar, status FROM sys_user WHERE username = #{username}")
    SysUser selectByUsername(@Param("username") String username);
}
