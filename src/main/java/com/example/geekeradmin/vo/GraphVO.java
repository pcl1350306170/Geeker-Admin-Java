package com.example.geekeradmin.vo;

import lombok.Data;

import java.util.List;

/**
 * 关系图谱 VO（节点 + 边）
 */
@Data
public class GraphVO {
    private List<Node> nodes;
    private List<Edge> edges;

    @Data
    public static class Node {
        /** 节点ID（同 type 域内唯一，前端拼接展示用） */
        private String id;
        /** 显示名 */
        private String name;
        /** 分类：FAMILY-家族 MEMBER-成员 */
        private String category;
        /** 成员所属家族ID（家族节点为空） */
        private Long familyId;
        /** 家族类型 / 成员角色定位（字典值，用于节点着色） */
        private String type;
        /** 是否家主（仅成员节点） */
        private Integer isHead;
        /** 附加信息（家族：成员数；成员：头衔） */
        private String sub;
    }

    @Data
    public static class Edge {
        /** 发起端节点ID */
        private String source;
        /** 接收端节点ID */
        private String target;
        /** 关系类型（字典值） */
        private String relationType;
        /** 补充描述 */
        private String description;
    }
}
