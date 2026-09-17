package com.example.geekeradmin.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 小说列表 VO
 */
@Data
public class NovelListVO {
    private Long id;
    private String name;
    private String alias;
    private String author;
    private String introduction;
    private String status;
    private Integer sort;
    /** 家族数 */
    private Long familyCount;
    private LocalDateTime updatedAt;
}
