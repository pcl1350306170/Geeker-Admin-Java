# Geeker-Admin-Java

[Geeker-Admin](https://github.com/HalseySpicy/Geeker-Admin)（Vue3 + TypeScript + Element-Plus）配套的 **Spring Boot 3** 后端服务。

> 一份"开箱即跑"的中后台脚手架：JWT 鉴权、动态菜单、按钮级权限、部门/字典/账号管理、系统日志、定时任务、开发资产库、小说家族图谱等业务模块一应俱全。

---

## 一、项目现状

### 技术栈

| 类别 | 选型 | 版本 |
|---|---|---|
| 语言 / 运行时 | Java | **21** |
| 框架 | Spring Boot | **3.5.10-SNAPSHOT** |
| 安全 | Spring Security + JWT (jjwt) | 0.11.5 |
| 持久层 | MyBatis-Plus（Spring Boot 3 专用 starter） | 3.5.5 |
| 数据库 | MySQL | 8.0+ |
| 简化编码 | Lombok | 跟随 parent |
| 构建 | Maven Wrapper（`mvnw` / `mvnw.cmd`） | — |

### 已实现模块

| 模块 | Controller | 主要能力 |
|---|---|---|
| 认证 | `ApiController` | 登录（`/geeker/login`）、登出、当前用户信息、动态菜单、按钮权限清单 |
| 账号管理 | `UserController` | 用户 CRUD、状态切换、重置密码、数据范围（全部 / 本部门 / 本部门及以下） |
| 部门管理 | `DepartmentController` | 树形部门 CRUD、启停 |
| 角色 | `RoleController` | 轻量角色方案（`admin` / `user`），菜单可见性由 `sys_menu.roles` 控制 |
| 菜单管理 | `MenuController` | 动态菜单 CRUD（前端路由完全由后端下发） |
| 字典管理 | `DictController` | `sys_dict_type` + `sys_dict_data`，前端 `useDict` 直接消费 |
| 文件上传 | `FileController` | 本地目录写入 + jsDelivr CDN 回显（图床走 `image-cdn` 仓库） |
| 开发资产库 | `DevAssetController` / `DevAssetTagController` / `DevAssetPublicController` | 代码/方案/踩坑/流程/片段五类资产，标签管理、收藏、复制计数、公开搜索页 |
| 小说家族 | `NovelController` / `NovelFamilyController` / `NovelFamilyMemberController` / `NovelRelationController` | 小说→家族→成员→关系四级建模，支持关系图谱可视化 |
| 系统日志 | `LogController` | `@Log` 注解 + AOP 切面自动采集操作/登录/异常三类日志，支持分页查询、详情、删除、按类型清空、CSV 导出 |
| 定时任务 | `JobController` | Spring `@Scheduled` 线程池动态调度，数据库驱动任务注册；支持增删改查、启停、立即执行、cron 预览、调度日志；`invokeTarget` 反射调用 + 包白名单 |

代码统计：**16 个 Controller / 13 个 Service / 16 个 Entity / 15 个 Mapper / 25 个 DTO / 14 个 VO**，共 **117** 个 Java 文件。

### 数据库表（16 张）

```
sys_user            sys_menu            sys_department      sys_log
sys_dict_type       sys_dict_data       sys_job             sys_job_log
dev_asset           dev_asset_tag       dev_asset_usage     dev_asset_relation
novel               novel_family        novel_family_member novel_relation
```

---

## 二、快速开始

### 1. 环境要求

- **JDK 21+**（`java -version` 验证）
- **MySQL 8.0+**（默认端口 `3307`，可按需改 `application.yml`）
- **Maven**（可选，仓库自带 `mvnw` 包装器）
- **Node.js 18+**（仅前端联调需要）

### 2. 一键初始化数据库 ⭐

**整个项目只需要执行一个 SQL 文件**：[`src/main/resources/geeker_admin_full.sql`](src/main/resources/geeker_admin_full.sql)

它包含：建库 → 建 16 张表 → 灌入全部种子数据（菜单、字典、部门、账号、演示用小说家族、示例定时任务）。**幂等**，可重复执行。

任选一种方式执行：

```bash
# 方式 A：命令行
mysql -h 127.0.0.1 -P 3307 -u root -p < src/main/resources/geeker_admin_full.sql

# 方式 B：MySQL Workbench / Navicat / DataGrip / IDEA Database
# 打开 geeker_admin_full.sql → Run
```

执行完毕后你会得到：

| 账号 | 密码 | 角色 | 说明 |
|---|---|---|---|
| `admin` | `123456` | 超级管理员 | 全部菜单 + 全部按钮权限 |
| `user` | `123456` | 普通用户 | 受限菜单，只读性质按钮 |
| `gz` | `123456` | 普通用户 | 测试账号 |

> 密码在库中以 **BCrypt** 加密存储；前端登录时会先对明文做一次 MD5，再交给后端 BCrypt 校验，详见 [`PasswordEncoderUtil`](src/main/java/com/example/geekeradmin/util/PasswordEncoderUtil.java)。

### 3. 修改配置

编辑 [`src/main/resources/application.yml`](src/main/resources/application.yml)：

```yaml
server:
  port: 8880                                    # 后端端口

spring:
  datasource:
    url: jdbc:mysql://localhost:3307/geeker_admin?...
    username: dev_user                          # ← 改成你的 MySQL 用户
    password: 123456                            # ← 改成你的 MySQL 密码

app:
  upload:
    path: D:\CODE\image-cdn\Upload              # ← 改成你本机的图床仓库路径
    cdn-prefix: https://cdn.jsdelivr.net/gh/pcl1350306170/image-cdn@refs/heads/main/Upload

jwt:
  secret: GeekerAdminSecretKeyForJWT2025Secure  # 生产环境务必替换
  expiration: 86400000                          # 24 小时
```

生产环境使用 [`application-prod.yml`](src/main/resources/application-prod.yml)（端口 `8881`，WSL 路径），启动时加 `--spring.profiles.active=prod`。

### 4. 启动后端

```bash
# 开发模式
./mvnw spring-boot:run

# 或打包后运行
./mvnw clean package -DskipTests
java -jar target/geekeradmin-0.0.1-SNAPSHOT.jar
```

看到 `Tomcat started on port 8880` 即成功。

### 5. 联调前端

```bash
cd <Geeker-Admin 前端目录>
pnpm install        # 或 npm install
pnpm dev            # 默认 http://localhost:5173
```

前端 `.env.development` 需指向本服务：

```env
VITE_API_URL = http://localhost:8880
```

浏览器打开 `http://localhost:5173`，用 `admin / 123456` 登录即可。

---

## 三、API 概览

统一前缀 `/geeker`，统一返回体：

```json
{ "code": 200, "msg": "", "data": { } }
```

### 公开接口（免登录）

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/geeker/login` | 登录，返回 JWT |
| GET/POST | `/geeker/public/assets/**` | 开发资产库公开搜索页（列表 / 详情 / 新增 / 复制上报 / 标签） |
| GET | `/geeker/file/img/**` | 图片回显 |
| GET | `/uploads/**` | 上传文件静态访问 |

### 鉴权接口（`Authorization: Bearer <token>`）

| 分组 | 路径前缀 | 主要端点 |
|---|---|---|
| 用户上下文 | `/geeker/user/info`、`/geeker/menu/list`、`/geeker/auth/buttons`、`/geeker/logout` | 当前用户信息 / 动态菜单 / 按钮权限 / 登出 |
| 账号管理 | `/geeker/user` | 分页、增删改、状态切换、重置密码 |
| 部门管理 | `/geeker/department` | 树查询、增删改、启停 |
| 菜单管理 | `/geeker/menu` | 增删改查 |
| 角色 | `/geeker/role` | 角色列表、菜单授权 |
| 字典 | `/geeker/dict/type`、`/geeker/dict/data` | 类型/数据双表 CRUD |
| 文件 | `/geeker/file/upload` | 图片/附件上传，返回 CDN URL |
| 开发资产库 | `/geeker/devAsset`、`/geeker/devAssetTag` | 资产 CRUD、收藏、标签管理 |
| 小说家族 | `/geeker/novel`、`/geeker/novelFamily`、`/geeker/novelFamilyMember`、`/geeker/novelRelation` | 四级建模、关系图谱 |
| 系统日志 | `/geeker/log` | 分页查询、详情、删除、按类型清空、CSV 导出 |
| 定时任务 | `/geeker/job` | 任务分页/增删改、启停、立即执行、cron 预览、调度日志查询与清空 |

未登录访问鉴权接口时统一返回：

```json
{ "code": 401, "msg": "登录已过期，请重新登录", "data": null }
```

---

## 四、项目结构

```
Geeker-Admin-Java/
├── pom.xml                             Maven 依赖（Spring Boot 3.5.10-SNAPSHOT + MyBatis-Plus 3.5.5 + jjwt 0.11.5）
├── mvnw / mvnw.cmd                     Maven 包装器
├── src/main/java/com/example/geekeradmin/
│   ├── GeekerAdminApplication.java     启动类
│   ├── common/                         Result / GlobalExceptionHandler / @Log 注解 / BusinessType 枚举
│   ├── config/                         SecurityConfig / MybatisPlusConfig / WebMvcConfig / AsyncConfig / SchedulingConfig（调度线程池）
│   ├── aspect/                         LogAspect（@Log 操作日志切面）
│   ├── filter/                         JwtAuthenticationFilter
│   ├── schedule/                       ScheduledTaskManager（动态调度核心）
│   ├── task/                           SampleTask（示例任务处理器）
│   ├── util/                           JwtUtil / PasswordEncoderUtil / IpUtil / JobInvokeUtil（反射调用+白名单）
│   ├── controller/                     16 个 REST 控制器
│   ├── service/                        13 个业务服务
│   ├── mapper/                         15 个 MyBatis-Plus Mapper
│   ├── entity/                         16 个数据库实体
│   ├── dto/                            25 个入参对象
│   └── vo/                             14 个出参对象
├── src/main/resources/
│   ├── application.yml                 开发配置（端口 8880）
│   ├── application-prod.yml            生产配置（端口 8881，WSL 路径）
│   ├── geeker_admin_full.sql           ⭐ 一体化初始化脚本（建库+建表+种子数据）
│   ├── sys_job_migration.sql           定时任务表增量迁移脚本（老库非破坏式升级）
│   └── mapper/DevAssetMapper.xml       复杂查询 XML
└── uploads/                            本地上传目录（运行时生成）
```

---

## 五、关键设计说明

### 1. 认证流程

1. 前端 `POST /geeker/login`，body 中密码是 **MD5(明文)**；
2. 后端用 `BCrypt.checkpw(md5Password, user.password)` 校验；
3. 通过后 `JwtUtil.generateToken(username)` 签发 24h JWT；
4. 后续请求头带 `Authorization: Bearer <token>`，`JwtAuthenticationFilter` 解析并写入 `SecurityContext`。

### 2. 权限模型（轻量方案）

- **角色**：`sys_user.role` 直接存 `admin` / `user` 字符串，无独立角色表；
- **菜单可见性**：`sys_menu.roles` 存逗号分隔的角色编码（如 `admin,user`），`MenuService` 按当前用户角色过滤后返回；
- **按钮权限**：`ApiController#getAuthButtons` 硬编码返回，`admin` 拥有全部，`user` 仅保留只读按钮；
- **数据权限**：`sys_user.data_scope` 三档（全部 / 本部门 / 本部门及以下），`UserService#applyDataScopeAndDeptFilter` 在分页/导出时拼接部门 IN 条件。

### 3. 文件上传 + jsDelivr CDN

- 后端把文件写入本机 `app.upload.path`（该目录是一个 git 仓库 `image-cdn`）；
- 手动 `git push` 后，jsDelivr 会自动同步；
- 接口返回 `app.upload.cdn-prefix + /文件名`，前端直接展示 CDN URL；
- 好处：**零成本图床**、全球加速、无需对象存储账号。

### 4. 开发资产库

- 5 种资产类型：`CODE` / `SOLUTION` / `TROUBLESHOOTING` / `PROCEDURE` / `SNIPPET`；
- 标签双写：`dev_asset.tags`（JSON 数组，用于搜索）+ `dev_asset_tag`（标签字典，用于筛选器）；
- 使用记录：`dev_asset_usage` 记录 `VIEW` / `COPY` 动作，`dev_asset.usage_count` 冗余计数便于排序；
- 公开页：`/geeker/public/assets` 系列接口免登录，可挂到独立域名做团队知识库。

### 5. 小说家族

- 四级建模：`novel`（小说）→ `novel_family`（家族）→ `novel_family_member`（成员）→ `novel_relation`（关系）；
- 关系表用 `source_type` + `source_id` + `target_type` + `target_id` 支持"成员↔成员"和"家族↔家族"两类边；
- 唯一键 `uk_relation` 防止重复建边；
- 内置《红楼梦》四大家族 + 《仙剑三同人》唐家两套演示数据（共 3 部小说 / 6 个家族 / 46 名成员 / 88 条关系）。

### 6. 系统日志（AOP 自动采集）

- **采集方式**：自定义 `@Log` 注解 + `LogAspect` 环绕切面（`@Around("@annotation(Log)")`），在业务 Controller 方法上标注即可自动记录，不侵入业务代码；
- **三类日志**：统一落 `sys_log` 表，用 `log_type` 区分——`1` 操作日志（增删改 / 导出）、`2` 登录日志（登录 / 登出）、`3` 异常日志（`GlobalExceptionHandler` 兜底写入）；
- **异步落库**：`LogService#saveLog` 标注 `@Async("logTaskExecutor")`，由 `AsyncConfig` 提供的独立线程池写库，不阻塞主请求；日志采集失败仅打印错误，绝不影响业务；
- **操作人 & IP**：优先从 `SecurityContext` 取当前用户（登录接口无认证时回退取入参 username），IP 经 `IpUtil` 解析 `X-Forwarded-For` 等代理头，适配 nginx 反代；
- **前端**：`/system/systemLog` 单页 ProTable，按 `log_type` 字典（`sys_log_type`）筛选，支持详情弹窗、删除、按类型清空、CSV 导出（带 BOM 防中文乱码）。

### 7. 定时任务（Spring 动态调度）

- **调度内核**：`SchedulingConfig` 开启 `@EnableScheduling` 并提供 `ThreadPoolTaskScheduler`（池大小 10）；`ScheduledTaskManager` 实现 `ApplicationRunner`，启动时加载 `sys_job` 中 `status=1` 的任务，用 `CronTrigger` 注册到线程池，并持有 `ScheduledFuture` 以便取消/重建；
- **调用目标**：`invokeTarget` 形如 `beanName.method(args)`，由 `JobInvokeUtil` 反射解析；**安全白名单**限定只能调用 `com.example.geekeradmin.task` 包下的 bean，杜绝任意反射；参数支持字符串/整数/小数/布尔；
- **并发控制**：`concurrent=1`（禁止）时用 `AtomicBoolean` 保证上一次未结束则跳过本次；
- **cron 校验/预览**：基于 Spring `CronExpression`（6 段式：秒 分 时 日 月 周），`/previewCron` 返回未来 N 次触发时间；
- **调度日志**：每次执行写入 `sys_job_log`（执行信息、状态、耗时、异常堆栈）；
- **示例任务默认暂停**（`status=0`），避免部署后意外执行，需在页面手动启用。

---

## 六、部署

### 打包

```bash
./mvnw clean package -DskipTests
# 产物：target/geekeradmin-0.0.1-SNAPSHOT.jar
```

### 生产运行

```bash
java -jar target/geekeradmin-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
```

`prod` profile 使用端口 `8881`、WSL 挂载路径 `/mnt/d/CODE/image-cdn/Upload`，按需修改 [`application-prod.yml`](src/main/resources/application-prod.yml)。

### 数据库迁移

- **全新部署 / 可接受清库**：直接跑 `geeker_admin_full.sql`（会 DROP 后重建全部 16 张表）。**注意备份业务数据**（`dev_asset` / `dev_asset_usage` / `sys_log` 不在种子范围内，会被清空）。
- **老库增量升级（不想清库）**：只跑 [`sys_job_migration.sql`](src/main/resources/sys_job_migration.sql) 即可非破坏式地补建 `sys_job` / `sys_job_log` 两张表并插入示例任务；脚本用 `CREATE TABLE IF NOT EXISTS` + `WHERE NOT EXISTS`，**可安全重复执行**。

---

## 七、开发进度（Git 里程碑）

按提交顺序（最新在上）：

- `feat(job)` 定时任务模块（Spring 动态调度 + 反射调用白名单 + cron 预览 + 调度日志）
- `feat(system)` 系统日志模块（`@Log` 注解 + AOP 切面，操作/登录/异常三类日志）
- `feat(graph)` 成员关系图添加辈分布局和人物详情面板
- `feat(system)` 字典管理 + 小说家族功能
- `feat(devAssets)` 订单预览功能
- `feat(account)` 账号管理完善 + 部门管理模块
- `feat(asset)` 开发资产库公开接口新增资产创建
- `feat(devAssets)` 资产详情页面改为弹窗模式
- `refactor(publicAssets)` 公共资产库重构为搜索中心化设计
- `feat(dev-asset)` 标签管理 + 公共访问接口
- `feat(dev-asset)` 个人开发资产库 V1.0
- `feat(auth)` 基于角色的菜单权限控制
- `feat(file)` jsDelivr CDN 文件上传集成
- `feat(accountManage)` 用户管理 + 文件上传
- `feat(auth)` 用户认证与授权
- `初始化`

---

## 八、常见问题

**Q1：执行 `geeker_admin_full.sql` 报 `Access denied`？**  
A：`dev_user` 是开发账号，权限受限。用 `root` 或具备 `CREATE DATABASE` 权限的账号执行。

**Q2：登录后前端菜单空白？**  
A：检查 `sys_menu` 是否有数据（应有 85 条），以及当前用户 `role` 字段值是否匹配菜单的 `roles`。

**Q3：上传文件返回 404？**  
A：`app.upload.path` 目录必须存在且可写；如需 CDN 回显，还要把该目录 push 到 GitHub 上的 `image-cdn` 仓库。

**Q4：JWT 报 `Unable to determine key`？**  
A：`jwt.secret` 长度不足 32 字节。生产环境请替换为足够长的随机串。

**Q5：想加新模块从哪下手？**  
A：参考 `NovelController` → `NovelService` → `NovelMapper` → `Novel` 实体这条链路，配合 MyBatis-Plus 代码生成器可以 10 分钟起一个 CRUD。

---

## 九、License

本项目基于 MIT License 开源，前端框架版权归 [Geeker-Admin](https://github.com/HalseySpicy/Geeker-Admin) 原作者所有。
