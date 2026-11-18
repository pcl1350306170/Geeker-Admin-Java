package com.example.geekeradmin.dto;

import lombok.Data;

import java.util.List;

/**
 * 成员批量导入入参
 */
@Data
public class MemberImportDTO {
    /** 导入目标家族ID（必填） */
    private Long familyId;
    /** 待导入成员列表，可按成员自身 familyId 覆盖目标家族（须与目标家族同小说） */
    private List<MemberImportItemDTO> members;
}
