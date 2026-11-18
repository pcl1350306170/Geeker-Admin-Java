````# 开发资产库公开接口使用说明

> 对应代码：`com.example.geekeradmin.controller.DevAssetPublicController`

## 1. 概述

本组接口为**免登录公开接口**，供外部独立单页（无需账号体系）快速访问开发资产库，提供 **搜索 / 标签字典 / 详情 / 新增 / 复制上报** 五项能力。

- 基础路径：`/geeker/public/assets`
- 鉴权：`SecurityConfig` 中 `/geeker/public/**` 已配置 `permitAll`，**无需携带 Token / Cookie**
- 跨域：服务端已开启 CORS（允许任意来源的 GET / POST / PUT / DELETE / OPTIONS），浏览器可直接 `fetch` 调用
- 本地调试地址：`http://localhost:8880`（生产环境以实际部署域名 / nginx 反代地址为准）

## 2. 统一响应格式

所有接口返回 JSON，结构如下：

```json
{
  "code": 200,
  "msg": "",
  "data": {}
}
```

- 成功：HTTP 200，`code = 200`，业务数据在 `data` 中
- 业务失败（如参数不合法、资产不存在）：HTTP 400，`code = 400`，`msg` 为可直接展示给用户的提示文案
- 系统异常：HTTP 500，`msg` 统一为「服务器内部错误，请稍后重试」，不暴露内部细节

错误响应示例：

```json
{ "code": 400, "msg": "资产不存在或已被删除", "data": null }
```

## 3. 接口清单

| # | 方法 | 路径 | 说明 |
|---|------|------|------|
| 1 | GET | `/geeker/public/assets` | 分页查询 / 搜索 |
| 2 | GET | `/geeker/public/assets/tags` | 标签字典 |
| 3 | GET | `/geeker/public/assets/{id}` | 资产详情（记录一次 VIEW） |
| 4 | POST | `/geeker/public/assets` | 新增资产 |
| 5 | POST | `/geeker/public/assets/{id}/copy` | 复制上报（使用次数 +1） |

### 3.1 分页查询 / 搜索

`GET /geeker/public/assets`

Query 参数（均可选）：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| pageNum | int | 1 | 页码 |
| pageSize | int | 20 | 每页条数 |
| keyword | string | - | 搜索关键词，**空格分隔多个关键词**，按权重排序 |
| type | string | - | 资产类型，见下方枚举 |
| tag | string | - | 标签名（精确筛选） |

> 注意：公开页不提供收藏筛选，即使传 `isFavorite` 也会被服务端强制忽略。

资产类型枚举（`type`）：

| 值 | 含义 |
|----|------|
| CODE | 代码 |
| SOLUTION | 解决方案 |
| TROUBLESHOOTING | 故障排查 |
| PROCEDURE | 操作步骤 |
| SNIPPET | 代码片段 |

响应 `data`：

```json
{
  "list": [
    {
      "id": 1,
      "title": "MySQL 8 连接配置",
      "type": "SOLUTION",
      "description": "解决 caching_sha2_password 认证失败",
      "language": "yaml",
      "tags": ["MySQL", "Spring Boot"],
      "isFavorite": 0,
      "usageCount": 12,
      "parentId": null,
      "updatedAt": "2026-11-10T15:30:00"
    }
  ],
  "total": 100,
  "pageNum": 1,
  "pageSize": 20
}
```

> 列表项**不含正文 `content`**（保证列表加载速度），正文需调详情接口获取。

示例：

```bash
curl "http://localhost:8880/geeker/public/assets?keyword=MySQL%20连接&type=SOLUTION&pageNum=1&pageSize=10"
```

### 3.2 标签字典

`GET /geeker/public/assets/tags`

无参数。返回全部标签（含使用数量），供公开页做标签筛选下拉：

```json
{
  "code": 200,
  "msg": "",
  "data": [
    { "id": 1, "name": "MySQL", "sort": 1, "usageCount": 8, "createdAt": "2026-10-01T10:00:00" }
  ]
}
```

### 3.3 资产详情

`GET /geeker/public/assets/{id}`

- 路径参数 `id`：资产 ID
- 返回含 Markdown 正文 `content` 的完整详情；若资产由其他资产复制而来，附带 `parentId` / `parentTitle`
- **每次调用会记录一次 VIEW 使用日志**（请勿用轮询方式反复调用）
- 资产不存在或已逻辑删除：HTTP 400，`msg = "资产不存在或已被删除"`

响应 `data` 字段：`id / title / type / description / content / language / tags / isFavorite / usageCount / parentId / parentTitle / createdBy / createdAt / updatedAt`。

示例：

```bash
curl "http://localhost:8880/geeker/public/assets/1"
```

### 3.4 新增资产

`POST /geeker/public/assets`

请求头：`Content-Type: application/json`

Body 字段：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | ✅ | 标题（不能为空，服务端会 trim） |
| type | string | ✅ | 资产类型，必须是上方枚举之一，否则报「资产类型不合法」 |
| description | string | ❌ | 简介 |
| content | string | ❌ | Markdown 正文 |
| language | string | ❌ | 代码语言（如 java / sql / yaml） |
| tags | string[] | ❌ | 标签数组；**新标签会自动注册到标签字典** |

请求示例：

```bash
curl -X POST "http://localhost:8880/geeker/public/assets" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "WSL nginx 反向代理配置",
    "type": "PROCEDURE",
    "description": "本地 WSL 部署 nginx 反代后端的步骤",
    "content": "## 步骤\n1. 安装 nginx\n2. 配置 proxy_pass ...",
    "language": "nginx",
    "tags": ["nginx", "WSL"]
  }'
```

成功响应（返回新资产 ID）：

```json
{ "code": 200, "msg": "", "data": { "id": 123 } }
```

> 免登录调用时 `createdBy` 记录为空字符串；新增资产默认未收藏、使用次数为 0。

### 3.5 复制上报

`POST /geeker/public/assets/{id}/copy`

无 Body。用户在前端点击「复制」成功后调用，服务端将该资产 `usage_count + 1` 并记录一条 COPY 使用日志。

```bash
curl -X POST "http://localhost:8880/geeker/public/assets/1/copy"
```

成功响应：

```json
{ "code": 200, "msg": "", "data": null }
```

资产不存在或已删除时同样返回 HTTP 400。

## 4. 典型调用流程（公开单页）

1. 页面加载：`GET /tags` 拉取标签字典 + `GET /geeker/public/assets` 拉取首屏列表
2. 用户搜索 / 筛选：带 `keyword / type / tag` 重新请求列表接口
3. 点击条目：`GET /{id}` 获取详情并渲染 Markdown
4. 用户复制内容成功后：`POST /{id}/copy` 上报
5. 用户投稿：`POST /geeker/public/assets` 新增，成功后可用返回的 `id` 跳转详情

## 5. 注意事项

- 公开接口**只提供上述五项能力**；编辑、删除、收藏、复制为新资产等操作属于登录后的管理接口，不在本组范围内
- 详情与复制上报都会产生使用统计，前端应避免无意义的重复调用
- 新增接口无鉴权与限流，若对公网开放，建议在 nginx 层补充限流 / 内容审核策略````
