package com.example.geekeradmin.controller;

import com.example.geekeradmin.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
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

    /** 粘贴/截图上传时文件可能无文件名，按 contentType 兼容推导扩展名 */
    private static final Map<String, String> MIME_EXTENSION_MAP = Map.of(
            "image/jpeg", ".jpg",
            "image/png", ".png",
            "image/gif", ".gif",
            "image/webp", ".webp",
            "video/mp4", ".mp4",
            "video/quicktime", ".mov",
            "video/webm", ".webm"
    );

    /** 本地直出图片时的 Content-Type 映射 */
    private static final Map<String, String> IMAGE_CONTENT_TYPES = Map.of(
            ".jpg", "image/jpeg",
            ".jpeg", "image/jpeg",
            ".png", "image/png",
            ".gif", "image/gif",
            ".webp", "image/webp"
    );

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
     * 本地图片直出（保底回退）：图片尚未 push 到 CDN 仓库时，
     * 前端图片加载失败会自动回退到该地址；push 后 CDN 地址生效，此接口仅作为保底
     */
    @GetMapping("/img/**")
    public ResponseEntity<Resource> serveImage(jakarta.servlet.http.HttpServletRequest request) {
        String fileName = request.getRequestURI().substring(request.getRequestURI().lastIndexOf('/') + 1);
        String extension = fileName.contains(".") ? fileName.substring(fileName.lastIndexOf(".")).toLowerCase() : "";
        if (!IMAGE_EXTENSIONS.contains(extension)) {
            return ResponseEntity.notFound().build();
        }
        try {
            Path dir = Paths.get(uploadPath).toAbsolutePath().normalize();
            Path file = dir.resolve(fileName).normalize();
            // 防止路径穿越，仅允许访问上传目录内的文件
            if (!file.startsWith(dir) || !Files.exists(file)) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(IMAGE_CONTENT_TYPES.getOrDefault(extension, "image/jpeg")))
                    .body(new FileSystemResource(file));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
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
        } else if (StringUtils.hasText(file.getContentType())) {
            // 剪贴板粘贴/截图上传的文件往往没有文件名，按 MIME 类型推导扩展名
            extension = MIME_EXTENSION_MAP.getOrDefault(file.getContentType().toLowerCase(), "");
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
