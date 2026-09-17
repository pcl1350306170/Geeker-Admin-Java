package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 字典数据（隶属于某个字典类型，通过 dictType 编码关联 sys_dict_type.type）
 */
@Data
@TableName("sys_dict_data")
public class SysDictData {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 所属字典类型编码（关联 sys_dict_type.type） */
    private String dictType;
    /** 字典标签（展示用） */
    private String label;
    /** 字典键值（业务用） */
    private String value;
    /** 显示排序 */
    private Integer sort;
    /** 状态：1-启用 / 0-禁用 */
    private Integer status;
    /** el-tag 样式类型：primary/success/info/warning/danger，可为空 */
    private String listClass;
    /** 是否默认：1-是 / 0-否 */
    private Integer isDefault;
    /** 备注 */
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    /** 所属字典类型名称（非数据库字段，列表查询时填充） */
    @TableField(exist = false)
    private String dictTypeName;
}
