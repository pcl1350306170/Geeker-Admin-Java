package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 字典类型（如"系统状态""用户性别"），一个类型下挂多条字典数据
 */
@Data
@TableName("sys_dict_type")
public class SysDictType {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 字典名称 */
    private String name;
    /** 字典类型编码（唯一，如 sys_status） */
    private String type;
    /** 状态：1-启用 / 0-禁用 */
    private Integer status;
    /** 备注 */
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
