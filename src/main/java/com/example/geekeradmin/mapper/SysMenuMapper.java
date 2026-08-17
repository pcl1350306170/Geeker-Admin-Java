package com.example.geekeradmin.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.geekeradmin.entity.SysMenu;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SysMenuMapper extends BaseMapper<SysMenu> {

    @Select("SELECT * FROM sys_menu WHERE status = 1 ORDER BY sort ASC")
    List<SysMenu> selectAllEnabled();
}
