package com.example.geekeradmin.dto;

import lombok.Data;

/**
 * 关系分页查询参数
 */
@Data
public class RelationQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 20;
    /** 关系类型 */
    private String relationType;
    /** 按成员过滤：返回与该成员相关的所有关系（任一端匹配） */
    private Long memberId;
    /** 按家族过滤：返回与该家族相关的所有关系（任一端匹配） */
    private Long familyId;
    /** 按小说过滤 */
    private Long novelId;
    /** 关系状态 */
    private String status;
}
