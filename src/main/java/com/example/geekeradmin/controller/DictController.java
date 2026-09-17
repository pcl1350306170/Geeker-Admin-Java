package com.example.geekeradmin.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.geekeradmin.common.Result;
import com.example.geekeradmin.dto.DictDataQueryDTO;
import com.example.geekeradmin.dto.DictDataSaveDTO;
import com.example.geekeradmin.dto.DictTypeQueryDTO;
import com.example.geekeradmin.dto.DictTypeSaveDTO;
import com.example.geekeradmin.entity.SysDictData;
import com.example.geekeradmin.entity.SysDictType;
import com.example.geekeradmin.service.DictService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 字典管理（字典类型 + 字典数据）
 */
@RestController
@RequestMapping("/geeker/dict")
public class DictController {

    @Autowired
    private DictService dictService;

    // ========== 字典类型 ==========

    /**
     * 分页查询字典类型
     */
    @GetMapping("/type/list")
    public Result<Map<String, Object>> typeList(DictTypeQueryDTO query) {
        Page<SysDictType> page = dictService.getDictTypePage(query);
        return Result.success(buildPageData(page));
    }

    /**
     * 全部启用的字典类型（不分页，供字典数据表单选择所属类型）
     */
    @GetMapping("/type/all")
    public Result<List<SysDictType>> typeAll() {
        return Result.success(dictService.getAllEnabledDictTypes());
    }

    /**
     * 新增字典类型
     */
    @PostMapping("/type")
    public Result<?> addType(@RequestBody DictTypeSaveDTO dto) {
        dictService.addDictType(dto);
        return Result.success(null);
    }

    /**
     * 编辑字典类型
     */
    @PutMapping("/type")
    public Result<?> updateType(@RequestBody DictTypeSaveDTO dto) {
        dictService.updateDictType(dto);
        return Result.success(null);
    }

    /**
     * 删除字典类型
     */
    @DeleteMapping("/type/{id}")
    public Result<?> deleteType(@PathVariable Long id) {
        dictService.deleteDictType(id);
        return Result.success(null);
    }

    /**
     * 切换字典类型状态
     */
    @PutMapping("/type/status")
    public Result<?> changeTypeStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());
        dictService.changeDictTypeStatus(id, status);
        return Result.success(null);
    }

    /**
     * 导出字典类型列表（CSV 格式，前端 http.download 为 POST 请求）
     */
    @PostMapping("/type/export")
    public void exportType(HttpServletResponse response) throws Exception {
        List<SysDictType> types = dictService.getAllDictTypes();
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("UTF-8");
        String fileName = URLEncoder.encode("字典类型列表", StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment;filename=" + fileName + ".csv");
        response.getOutputStream().write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        PrintWriter writer = response.getWriter();
        writer.println("ID,字典名称,字典类型编码,状态,备注,创建时间,更新时间");
        for (SysDictType type : types) {
            writer.println(String.join(",",
                    String.valueOf(type.getId()),
                    escape(type.getName()),
                    escape(type.getType()),
                    type.getStatus() != null && type.getStatus() == 1 ? "启用" : "禁用",
                    escape(type.getRemark()),
                    type.getCreateTime() == null ? "" : type.getCreateTime().toString(),
                    type.getUpdateTime() == null ? "" : type.getUpdateTime().toString()));
        }
        writer.flush();
    }

    // ========== 字典数据 ==========

    /**
     * 分页查询字典数据
     */
    @GetMapping("/data/list")
    public Result<Map<String, Object>> dataList(DictDataQueryDTO query) {
        Page<SysDictData> page = dictService.getDictDataPage(query);
        return Result.success(buildPageData(page));
    }

    /**
     * 按字典类型编码查询启用的字典数据（不分页，供全局 useDict 调用）
     */
    @GetMapping("/data/type/{dictType}")
    public Result<List<SysDictData>> dataByType(@PathVariable String dictType) {
        return Result.success(dictService.getEnabledDictDataByType(dictType));
    }

    /**
     * 新增字典数据
     */
    @PostMapping("/data")
    public Result<?> addData(@RequestBody DictDataSaveDTO dto) {
        dictService.addDictData(dto);
        return Result.success(null);
    }

    /**
     * 编辑字典数据
     */
    @PutMapping("/data")
    public Result<?> updateData(@RequestBody DictDataSaveDTO dto) {
        dictService.updateDictData(dto);
        return Result.success(null);
    }

    /**
     * 删除字典数据
     */
    @DeleteMapping("/data/{id}")
    public Result<?> deleteData(@PathVariable Long id) {
        dictService.deleteDictData(id);
        return Result.success(null);
    }

    /**
     * 切换字典数据状态
     */
    @PutMapping("/data/status")
    public Result<?> changeDataStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());
        dictService.changeDictDataStatus(id, status);
        return Result.success(null);
    }

    /**
     * 导出字典数据列表（CSV 格式，前端 http.download 为 POST 请求）
     */
    @PostMapping("/data/export")
    public void exportData(HttpServletResponse response) throws Exception {
        List<SysDictData> dataList = dictService.getAllDictData();
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("UTF-8");
        String fileName = URLEncoder.encode("字典数据列表", StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment;filename=" + fileName + ".csv");
        response.getOutputStream().write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        PrintWriter writer = response.getWriter();
        writer.println("ID,所属字典类型编码,所属字典类型名称,字典标签,字典键值,排序,状态,样式类型,是否默认,备注,创建时间,更新时间");
        for (SysDictData data : dataList) {
            writer.println(String.join(",",
                    String.valueOf(data.getId()),
                    escape(data.getDictType()),
                    escape(data.getDictTypeName()),
                    escape(data.getLabel()),
                    escape(data.getValue()),
                    String.valueOf(data.getSort()),
                    data.getStatus() != null && data.getStatus() == 1 ? "启用" : "禁用",
                    escape(data.getListClass()),
                    data.getIsDefault() != null && data.getIsDefault() == 1 ? "是" : "否",
                    escape(data.getRemark()),
                    data.getCreateTime() == null ? "" : data.getCreateTime().toString(),
                    data.getUpdateTime() == null ? "" : data.getUpdateTime().toString()));
        }
        writer.flush();
    }

    // ========== 缓存 ==========

    /**
     * 手动刷新全部字典缓存
     */
    @PostMapping("/cache/refresh")
    public Result<?> refreshCache() {
        dictService.refreshAllCache();
        return Result.success(null);
    }

    private Map<String, Object> buildPageData(Page<?> page) {
        Map<String, Object> data = new HashMap<>();
        data.put("list", page.getRecords());
        data.put("total", page.getTotal());
        data.put("pageNum", page.getCurrent());
        data.put("pageSize", page.getSize());
        return data;
    }

    private String escape(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(",") || value.contains("\"")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
