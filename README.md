# 方块世界 CubeCraft

一个 Minecraft 风格的方块体素游戏，使用 **Godot 4.4** 引擎（内置 Vulkan/OpenGL 渲染器）开发。

- 作者：hjm98-rgb
- 版本：0.1.0（主菜单与工程框架阶段）
- 引擎：Godot 4.4.1（Forward+ 渲染器，支持 Vulkan/Metal/OpenGL 多后端）
- 3D 模型：程序化生成的 .obj 模型（方块人 + 方块），导入引擎渲染

## 当前包含的功能

| 模块 | 说明 |
|------|------|
| 加载画面 | 启动进度条，标注作者与版本号 |
| 主菜单 | 开始游戏 / 设置 / 退出，右上角语言切换按钮 |
| 多语言 | 简体中文 / English / 日本語，切换即时生效并持久化 |
| 设置 | 语言、音量（真实作用于音频总线）、全屏、画质（MSAA + 渲染缩放）、分辨率，保存到 user://settings.cfg |
| 3D 渲染验证 | 方块人角色 + 方块地形/树木，轨道相机（拖拽旋转、滚轮缩放） |
| 云打包 | GitHub Actions 自动构建 Linux / Windows / macOS 桌面版与 iOS（.ipa，使用个人证书签名） |

> 说明：本版本为工程框架与主菜单阶段，**尚未包含游戏玩法内容**（生存、建造、联机等将在后续版本加入）。

## 本地运行（开发）

```bash
# 需要 Godot 4.4.x
godot --path game3d
```

## 云打包（GitHub Actions）

仓库 `.github/workflows/build.yml` 定义自动构建：

- `build-desktop`：Linux / Windows / macOS 桌面版，上传为 Actions Artifact
- `build-ios`：macOS runner 上使用 **Apple Distribution 证书** 签名生成 .ipa（证书、密码、描述文件均通过 Repository Secrets 注入，不进代码库）

### 需要的 Repository Secrets

| Secret | 内容 |
|--------|------|
| `IOS_P12_BASE64` | 证书 .p12 文件的 base64 |
| `IOS_CERT_PASSWORD` | 证书密码 |
| `IOS_MOBILEPROVISION_BASE64` | 描述文件 .mobileprovision 的 base64 |

iOS 产物签名信息：Team `Terry Peppers (2TAD594A66)`，Bundle ID `com.cert.account.t260901214911`。
