package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.Result;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * 文件上传（对应前端 @/api/modules/upload.ts）
 * 返回 data.fileUrl，前端 UploadImg / UploadImgs 组件直接使用
 */
@RestController
@RequestMapping("/geeker/file")
public class FileController {

    /** 图片允许的扩展名 */
    private static final Set<String> IMAGE_EXTENSIONS = Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp");

    /** 视频允许的扩展名 */
    private static final Set<String> VIDEO_EXTENSIONS = Set.of(".mp4", ".avi", ".mov", ".webm");

    @Value("${app.upload.path:./uploads}")
    private String uploadPath;

    /**
     * 图片上传
     */
    @PostMapping("/upload/img")
    public Result<Map<String, String>> uploadImg(@RequestParam("file") MultipartFile file, HttpServletRequest request) {
        String url = saveFile(file, "img", IMAGE_EXTENSIONS);
        return Result.success(Map.of("fileUrl", buildFileUrl(request, url)));
    }

    /**
     * 视频上传
     */
    @PostMapping("/upload/video")
    public Result<Map<String, String>> uploadVideo(@RequestParam("file") MultipartFile file, HttpServletRequest request) {
        String url = saveFile(file, "video", VIDEO_EXTENSIONS);
        return Result.success(Map.of("fileUrl", buildFileUrl(request, url)));
    }

    /**
     * 保存文件到本地目录，返回相对访问路径（如 /img/xxx.png）
     */
    private String saveFile(MultipartFile file, String type, Set<String> allowedExtensions) {
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
            Path dir = Paths.get(uploadPath, type).toAbsolutePath().normalize();
            Files.createDirectories(dir);
            String fileName = UUID.randomUUID().toString().replace("-", "") + extension;
            file.transferTo(dir.resolve(fileName).toFile());
            return "/" + type + "/" + fileName;
        } catch (IOException e) {
            throw new RuntimeException("文件保存失败：" + e.getMessage());
        }
    }

    /**
     * 拼接完整访问地址（含当前服务的 scheme://host:port），保证前端任意端口下都能访问
     */
    private String buildFileUrl(HttpServletRequest request, String relativePath) {
        String baseUrl = ServletUriComponentsBuilder.fromRequestUri(request)
                .replacePath(request.getContextPath())
                .build().toUriString();
        return baseUrl + "/uploads" + relativePath;
    }
}
