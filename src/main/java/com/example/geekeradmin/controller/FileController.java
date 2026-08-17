package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * 文件上传（对应前端 @/api/modules/upload.ts）
 * 文件保存到 image-cdn 仓库目录，手动 push 后通过 jsDelivr CDN 访问
 * 返回 data.fileUrl，前端 UploadImg / UploadImgs 组件直接使用
 */
@RestController
@RequestMapping("/geeker/file")
public class FileController {

    /** 图片允许的扩展名 */
    private static final Set<String> IMAGE_EXTENSIONS = Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp");

    /** 视频允许的扩展名 */
    private static final Set<String> VIDEO_EXTENSIONS = Set.of(".mp4", ".avi", ".mov", ".webm");

    @Value("${app.upload.path}")
    private String uploadPath;

    @Value("${app.upload.cdn-prefix}")
    private String cdnPrefix;

    /**
     * 图片上传
     */
    @PostMapping("/upload/img")
    public Result<Map<String, String>> uploadImg(@RequestParam("file") MultipartFile file) {
        String fileName = saveFile(file, IMAGE_EXTENSIONS);
        return Result.success(Map.of("fileUrl", cdnPrefix + "/" + fileName));
    }

    /**
     * 视频上传
     */
    @PostMapping("/upload/video")
    public Result<Map<String, String>> uploadVideo(@RequestParam("file") MultipartFile file) {
        String fileName = saveFile(file, VIDEO_EXTENSIONS);
        return Result.success(Map.of("fileUrl", cdnPrefix + "/" + fileName));
    }

    /**
     * 保存文件到 image-cdn 仓库目录（平铺存放，与 CDN 路径一一对应），返回文件名
     */
    private String saveFile(MultipartFile file, Set<String> allowedExtensions) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("上传文件不能为空");
        }
        String originalName = file.getOriginalFilename();
        String extension = "";
        if (StringUtils.hasText(originalName) && originalName.contains(".")) {
            extension = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();
        }
        if (!allowedExtensions.contains(extension)) {
            throw new RuntimeException("不支持的文件类型：" + extension);
        }
        try {
            Path dir = Paths.get(uploadPath).toAbsolutePath().normalize();
            Files.createDirectories(dir);
            String fileName = UUID.randomUUID().toString().replace("-", "") + extension;
            file.transferTo(dir.resolve(fileName).toFile());
            return fileName;
        } catch (IOException e) {
            throw new RuntimeException("文件保存失败：" + e.getMessage());
        }
    }
}
