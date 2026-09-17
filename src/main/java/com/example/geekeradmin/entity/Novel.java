package com.example.geekeradmin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 小说表
 */
@Data
@TableName("novel")
public class Novel {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 小说名称 */
    private String name;
    /** 别名 */
    private String alias;
    /** 作者 */
    private String author;
    /** 简介 */
    private String introduction;
    /** 状态：ACTIVE-连载/完结 DISABLED-停用 */
    private String status;
    /** 排序 */
    private Integer sort;
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
    private Integer deleted;
}
