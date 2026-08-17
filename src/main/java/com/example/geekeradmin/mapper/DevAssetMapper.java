package com.example.geekeradmin.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.geekeradmin.entity.DevAsset;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DevAssetMapper extends BaseMapper<DevAsset> {

    /**
     * 多关键词模糊搜索（title/tags/description/content/language），
     * 按匹配权重排序：标题 > 标签 > 简介 > 正文
     */
    IPage<DevAsset> searchAssetPage(IPage<DevAsset> page,
                                    @Param("keywords") List<String> keywords,
                                    @Param("type") String type,
                                    @Param("tag") String tag,
                                    @Param("isFavorite") Integer isFavorite);

    /**
     * 最近使用的资产（按使用记录时间倒序，去重）
     */
    List<DevAsset> selectRecentUsed(@Param("limit") int limit);
}
