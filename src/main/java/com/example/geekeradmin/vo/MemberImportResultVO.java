package com.example.geekeradmin.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 成员批量导入结果。
 * ok=false 表示校验未通过、未写入任何数据，errors 为逐条错误明细。
 */
@Data
public class MemberImportResultVO {
    /** 是否导入成功 */
    private boolean ok;
    /** 提交总数 */
    private int total;
    /** 实际写入数 */
    private int successCount;
    /** 新写入成员ID列表 */
    private List<Long> ids = new ArrayList<>();
    /** 逐条错误明细 */
    private List<ErrorItem> errors = new ArrayList<>();

    @Data
    public static class ErrorItem {
        /** 在 members 数组中的序号（从 1 开始） */
        private int index;
        private String name;
        private String message;

        public ErrorItem() {}

        public ErrorItem(int index, String name, String message) {
            this.index = index;
            this.name = name;
            this.message = message;
        }
    }
}
