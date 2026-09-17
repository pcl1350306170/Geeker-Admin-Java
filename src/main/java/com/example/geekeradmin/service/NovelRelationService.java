package com.example.geekeradmin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.dto.RelationQueryDTO;
import com.example.geekeradmin.dto.RelationSaveDTO;
import com.example.geekeradmin.entity.NovelFamily;
import com.example.geekeradmin.entity.NovelFamilyMember;
import com.example.geekeradmin.entity.NovelRelation;
import com.example.geekeradmin.mapper.NovelFamilyMapper;
import com.example.geekeradmin.mapper.NovelFamilyMemberMapper;
import com.example.geekeradmin.mapper.NovelRelationMapper;
import com.example.geekeradmin.vo.GraphVO;
import com.example.geekeradmin.vo.RelationVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 小说关系（成员间 / 家族间）
 */
@Service
public class NovelRelationService {

    public static final String TYPE_MEMBER = "MEMBER";
    public static final String TYPE_FAMILY = "FAMILY";
    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_BROKEN = "BROKEN";

    private static final Set<String> ENTITY_TYPES = Set.of(TYPE_MEMBER, TYPE_FAMILY);
    private static final Set<String> STATUSES = Set.of(STATUS_ACTIVE, STATUS_BROKEN);

    @Autowired
    private NovelRelationMapper relationMapper;

    @Autowired
    private NovelFamilyMapper familyMapper;

    @Autowired
    private NovelFamilyMemberMapper memberMapper;

    /**
     * 分页查询关系，支持按成员 / 家族过滤（任一端匹配），并组装两端显示名
     */
    public IPage<RelationVO> getRelationPage(RelationQueryDTO query) {
        LambdaQueryWrapper<NovelRelation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NovelRelation::getDeleted, 0);
        if (StringUtils.hasText(query.getRelationType())) {
            wrapper.eq(NovelRelation::getRelationType, query.getRelationType());
        }
        if (StringUtils.hasText(query.getStatus())) {
            wrapper.eq(NovelRelation::getStatus, query.getStatus());
        }
        if (query.getMemberId() != null) {
            wrapper.eq(NovelRelation::getSourceType, TYPE_MEMBER)
                    .and(w -> w.eq(NovelRelation::getSourceId, query.getMemberId())
                            .or().eq(NovelRelation::getTargetId, query.getMemberId()));
        } else if (query.getFamilyId() != null) {
            wrapper.eq(NovelRelation::getSourceType, TYPE_FAMILY)
                    .and(w -> w.eq(NovelRelation::getSourceId, query.getFamilyId())
                            .or().eq(NovelRelation::getTargetId, query.getFamilyId()));
        }
        if (query.getNovelId() != null) {
            wrapper.eq(NovelRelation::getNovelId, query.getNovelId());
        }
        wrapper.orderByDesc(NovelRelation::getCreatedAt);

        IPage<NovelRelation> page = relationMapper.selectPage(
                new Page<>(query.getPageNum(), query.getPageSize()), wrapper);

        IPage<RelationVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(toRelationVOs(page.getRecords()));
        return voPage;
    }

    /**
     * 新增关系：校验类型一致、两端存在、不重复（含反向）
     */
    public Long addRelation(RelationSaveDTO dto) {
        validateSaveDTO(dto);
        NovelRelation relation = new NovelRelation();
        relation.setSourceType(dto.getSourceType());
        relation.setSourceId(dto.getSourceId());
        relation.setTargetType(dto.getTargetType());
        relation.setTargetId(dto.getTargetId());
        relation.setNovelId(resolveNovelId(dto));
        relation.setRelationType(dto.getRelationType());
        relation.setDescription(dto.getDescription());
        relation.setStatus(StringUtils.hasText(dto.getStatus()) ? dto.getStatus() : STATUS_ACTIVE);
        relation.setDeleted(0);
        relation.setCreatedBy(getCurrentUsername());
        relation.setCreatedAt(LocalDateTime.now());
        relation.setUpdatedBy(relation.getCreatedBy());
        relation.setUpdatedAt(relation.getCreatedAt());
        relationMapper.insert(relation);
        return relation.getId();
    }

    /**
     * 删除关系（逻辑删除）
     */
    public void deleteRelation(Long id) {
        getExistRelation(id);
        LambdaUpdateWrapper<NovelRelation> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(NovelRelation::getId, id)
                .set(NovelRelation::getDeleted, 1)
                .set(NovelRelation::getUpdatedBy, getCurrentUsername())
                .set(NovelRelation::getUpdatedAt, LocalDateTime.now());
        relationMapper.update(null, wrapper);
    }

    /**
     * 家族总览图：指定小说的全部家族节点 + 家族间关系边（novelId 为空时返回全部）
     */
    public GraphVO getFamilyGraph(Long novelId) {
        LambdaQueryWrapper<NovelFamily> familyWrapper = new LambdaQueryWrapper<>();
        familyWrapper.eq(NovelFamily::getDeleted, 0);
        if (novelId != null) {
            familyWrapper.eq(NovelFamily::getNovelId, novelId);
        }
        familyWrapper.orderByAsc(NovelFamily::getSort).orderByDesc(NovelFamily::getUpdatedAt);
        List<NovelFamily> families = familyMapper.selectList(familyWrapper);

        LambdaQueryWrapper<NovelRelation> relationWrapper = new LambdaQueryWrapper<>();
        relationWrapper.eq(NovelRelation::getDeleted, 0)
                .eq(NovelRelation::getSourceType, TYPE_FAMILY);
        if (novelId != null) {
            relationWrapper.eq(NovelRelation::getNovelId, novelId);
        }
        List<NovelRelation> relations = relationMapper.selectList(relationWrapper);

        GraphVO vo = new GraphVO();
        vo.setNodes(new ArrayList<>());
        vo.setEdges(new ArrayList<>());

        Map<Long, Long> memberCountMap = families.stream()
                .collect(Collectors.toMap(NovelFamily::getId, f -> 0L));
        if (!families.isEmpty()) {
            memberMapper.selectList(new LambdaQueryWrapper<NovelFamilyMember>()
                            .select(NovelFamilyMember::getFamilyId)
                            .eq(NovelFamilyMember::getDeleted, 0)
                            .in(NovelFamilyMember::getFamilyId, memberCountMap.keySet()))
                    .forEach(m -> memberCountMap.merge(m.getFamilyId(), 1L, Long::sum));
        }

        for (NovelFamily f : families) {
            GraphVO.Node node = new GraphVO.Node();
            node.setId("F" + f.getId());
            node.setName(f.getName());
            node.setCategory(TYPE_FAMILY);
            node.setType(f.getType());
            node.setSub("成员 " + memberCountMap.getOrDefault(f.getId(), 0L));
            vo.getNodes().add(node);
        }
        for (NovelRelation r : relations) {
            vo.getEdges().add(toGraphEdge(r));
        }
        return vo;
    }

    /**
     * 成员关系图：指定家族的全部成员节点 + 成员间关系边
     */
    public GraphVO getMemberGraph(Long familyId) {
        NovelFamily family = familyMapper.selectById(familyId);
        if (family == null || (family.getDeleted() != null && family.getDeleted() == 1)) {
            throw new RuntimeException("家族不存在或已被删除");
        }
        List<NovelFamilyMember> members = memberMapper.selectList(new LambdaQueryWrapper<NovelFamilyMember>()
                .eq(NovelFamilyMember::getDeleted, 0)
                .eq(NovelFamilyMember::getFamilyId, familyId)
                .orderByAsc(NovelFamilyMember::getSort));

        List<NovelRelation> relations = relationMapper.selectList(new LambdaQueryWrapper<NovelRelation>()
                .eq(NovelRelation::getDeleted, 0)
                .eq(NovelRelation::getSourceType, TYPE_MEMBER));

        Set<Long> memberIds = members.stream().map(NovelFamilyMember::getId).collect(Collectors.toSet());
        // 仅保留两端都在本家族内的关系（家族内成员之间的关系）
        List<NovelRelation> innerRelations = relations.stream()
                .filter(r -> memberIds.contains(r.getSourceId()) && memberIds.contains(r.getTargetId()))
                .toList();

        GraphVO vo = new GraphVO();
        vo.setNodes(new ArrayList<>());
        vo.setEdges(new ArrayList<>());
        for (NovelFamilyMember m : members) {
            GraphVO.Node node = new GraphVO.Node();
            node.setId("M" + m.getId());
            node.setName(m.getName());
            node.setCategory(TYPE_MEMBER);
            node.setFamilyId(m.getFamilyId());
            node.setType(m.getRoleType());
            node.setIsHead(m.getIsHead());
            node.setSub(m.getTitle());
            node.setGeneration(m.getGeneration());
            vo.getNodes().add(node);
        }
        for (NovelRelation r : innerRelations) {
            vo.getEdges().add(toGraphEdge(r));
        }
        return vo;
    }

    // ==================== 私有方法 ====================

    private void validateSaveDTO(RelationSaveDTO dto) {
        if (!ENTITY_TYPES.contains(dto.getSourceType()) || !ENTITY_TYPES.contains(dto.getTargetType())) {
            throw new RuntimeException("关系端类型不合法：仅支持 MEMBER（成员）或 FAMILY（家族）");
        }
        if (!dto.getSourceType().equals(dto.getTargetType())) {
            throw new RuntimeException("关系两端类型必须一致：成员与成员，或家族与家族");
        }
        if (dto.getSourceId() == null || dto.getTargetId() == null) {
            throw new RuntimeException("关系两端ID不能为空");
        }
        if (dto.getSourceId().equals(dto.getTargetId())) {
            throw new RuntimeException("关系两端不能是同一对象");
        }
        if (!StringUtils.hasText(dto.getRelationType())) {
            throw new RuntimeException("关系类型不能为空");
        }
        if (StringUtils.hasText(dto.getStatus()) && !STATUSES.contains(dto.getStatus())) {
            throw new RuntimeException("关系状态不合法：仅支持 ACTIVE（存续）或 BROKEN（破裂）");
        }
        if (TYPE_MEMBER.equals(dto.getSourceType())) {
            NovelFamilyMember source = memberMapper.selectById(dto.getSourceId());
            NovelFamilyMember target = memberMapper.selectById(dto.getTargetId());
            if (source == null || (source.getDeleted() != null && source.getDeleted() == 1)
                    || target == null || (target.getDeleted() != null && target.getDeleted() == 1)) {
                throw new RuntimeException("关系两端成员不存在或已被删除");
            }
            if (!java.util.Objects.equals(source.getNovelId(), target.getNovelId())) {
                throw new RuntimeException("关系两端成员必须属于同一部小说");
            }
        } else {
            NovelFamily source = familyMapper.selectById(dto.getSourceId());
            NovelFamily target = familyMapper.selectById(dto.getTargetId());
            if (source == null || (source.getDeleted() != null && source.getDeleted() == 1)
                    || target == null || (target.getDeleted() != null && target.getDeleted() == 1)) {
                throw new RuntimeException("关系两端家族不存在或已被删除");
            }
            if (!java.util.Objects.equals(source.getNovelId(), target.getNovelId())) {
                throw new RuntimeException("关系两端家族必须属于同一部小说");
            }
        }
        // 重复校验：同方向与反方向均视为重复
        LambdaQueryWrapper<NovelRelation> fwd = new LambdaQueryWrapper<>();
        fwd.eq(NovelRelation::getDeleted, 0)
                .eq(NovelRelation::getSourceType, dto.getSourceType())
                .eq(NovelRelation::getSourceId, dto.getSourceId())
                .eq(NovelRelation::getTargetId, dto.getTargetId())
                .eq(NovelRelation::getRelationType, dto.getRelationType());
        LambdaQueryWrapper<NovelRelation> rev = new LambdaQueryWrapper<>();
        rev.eq(NovelRelation::getDeleted, 0)
                .eq(NovelRelation::getSourceType, dto.getSourceType())
                .eq(NovelRelation::getSourceId, dto.getTargetId())
                .eq(NovelRelation::getTargetId, dto.getSourceId())
                .eq(NovelRelation::getRelationType, dto.getRelationType());
        if (relationMapper.selectCount(fwd) > 0 || relationMapper.selectCount(rev) > 0) {
            throw new RuntimeException("该关系已存在，请勿重复添加");
        }
    }

    private NovelRelation getExistRelation(Long id) {
        NovelRelation relation = relationMapper.selectById(id);
        if (relation == null || (relation.getDeleted() != null && relation.getDeleted() == 1)) {
            throw new RuntimeException("关系不存在或已被删除");
        }
        return relation;
    }

    /**
     * 关系所属小说：以发起端实体为准（前端可传 novelId，但以服务端口径为准）
     */
    private Long resolveNovelId(RelationSaveDTO dto) {
        if (TYPE_MEMBER.equals(dto.getSourceType())) {
            NovelFamilyMember source = memberMapper.selectById(dto.getSourceId());
            return source == null ? null : source.getNovelId();
        }
        NovelFamily source = familyMapper.selectById(dto.getSourceId());
        return source == null ? null : source.getNovelId();
    }

    /**
     * 组装关系 VO 列表（批量查询两端名称，避免 N+1）
     */
    private List<RelationVO> toRelationVOs(List<NovelRelation> relations) {
        List<RelationVO> vos = new ArrayList<>(relations.size());
        if (relations.isEmpty()) {
            return vos;
        }
        // 成员端
        Set<Long> memberIds = relations.stream()
                .filter(r -> TYPE_MEMBER.equals(r.getSourceType()))
                .flatMap(r -> java.util.stream.Stream.of(r.getSourceId(), r.getTargetId()))
                .collect(Collectors.toSet());
        Map<Long, NovelFamilyMember> memberMap = memberIds.isEmpty() ? Map.of()
                : memberMapper.selectBatchIds(memberIds).stream()
                        .collect(Collectors.toMap(NovelFamilyMember::getId, m -> m, (a, b) -> a));
        // 家族端
        Set<Long> familyIds = relations.stream()
                .filter(r -> TYPE_FAMILY.equals(r.getSourceType()))
                .flatMap(r -> java.util.stream.Stream.of(r.getSourceId(), r.getTargetId()))
                .collect(Collectors.toSet());
        Map<Long, NovelFamily> familyMap = familyIds.isEmpty() ? Map.of()
                : familyMapper.selectBatchIds(familyIds).stream()
                        .collect(Collectors.toMap(NovelFamily::getId, f -> f, (a, b) -> a));

        for (NovelRelation r : relations) {
            RelationVO vo = new RelationVO();
            vo.setId(r.getId());
            vo.setNovelId(r.getNovelId());
            vo.setSourceType(r.getSourceType());
            vo.setSourceId(r.getSourceId());
            vo.setTargetType(r.getTargetType());
            vo.setTargetId(r.getTargetId());
            vo.setRelationType(r.getRelationType());
            vo.setDescription(r.getDescription());
            vo.setStatus(r.getStatus());
            vo.setCreatedBy(r.getCreatedBy());
            vo.setCreatedAt(r.getCreatedAt());
            if (TYPE_MEMBER.equals(r.getSourceType())) {
                NovelFamilyMember source = memberMap.get(r.getSourceId());
                NovelFamilyMember target = memberMap.get(r.getTargetId());
                vo.setSourceName(source == null ? "(已删除)" : source.getName());
                vo.setSourceSub(source == null ? null : getFamilyName(source.getFamilyId()));
                vo.setTargetName(target == null ? "(已删除)" : target.getName());
                vo.setTargetSub(target == null ? null : getFamilyName(target.getFamilyId()));
            } else {
                NovelFamily source = familyMap.get(r.getSourceId());
                NovelFamily target = familyMap.get(r.getTargetId());
                vo.setSourceName(source == null ? "(已删除)" : source.getName());
                vo.setSourceSub(source == null ? null : source.getStatus());
                vo.setTargetName(target == null ? "(已删除)" : target.getName());
                vo.setTargetSub(target == null ? null : target.getStatus());
            }
            vos.add(vo);
        }
        return vos;
    }

    private String getFamilyName(Long familyId) {
        NovelFamily family = familyMapper.selectById(familyId);
        return family == null ? null : family.getName();
    }

    private GraphVO.Edge toGraphEdge(NovelRelation r) {
        GraphVO.Edge edge = new GraphVO.Edge();
        String prefix = TYPE_MEMBER.equals(r.getSourceType()) ? "M" : "F";
        edge.setSource(prefix + r.getSourceId());
        edge.setTarget(prefix + r.getTargetId());
        edge.setRelationType(r.getRelationType());
        edge.setDescription(r.getDescription());
        return edge;
    }

    private String getCurrentUsername() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        return principal == null ? "" : principal.toString();
    }
}
