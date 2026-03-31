# Douyin Live TV for Apple TV

> 在 Apple TV 大屏上监控抖音直播间数据

![Platform: tvOS](https://img.shields.io/badge/Platform-tvOS-blue.svg)
![Language: Swift](https://img.shields.io/badge/Language-Swift-orange.svg)
![Xcode: 16+](https://img.shields.io/badge/Xcode-16-blue.svg)
![Status: v1.0](https://img.shields.io/badge/Status-v1.0-brightgreen.svg)

一个为 Apple TV 打造的原生应用，让你在客厅大屏上轻松监控抖音直播间数据。

## 📖 项目简介

**Douyin Live TV** 是个人自用项目，主要用于：

- 📺 **大屏观看体验** - 在电视上一目了然地查看直播数据
- 📊 **核心数据展示** - 实时显示观看人数、点赞数、礼物总值
- ▶️ **视频预览** - 直接在 app 内播放直播视频
- ⭐ **收藏直播间** - 一键快速访问常用直播间
- 🔄 **自动刷新** - 每 30 分钟自动更新数据

本项目专为个人使用设计，代码简洁，功能聚焦，不发布到 App Store，侧载安装即可使用。

## 📱 功能截图

*(待补充截图)*

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 抖音账号登录 | 安全存储令牌，自动刷新 |
| 收藏直播间 | SwiftData 本地持久化存储 |
| 悬浮数据叠加 | 数据显示在视频上方，不遮挡画面 |
| 全屏/悬浮切换 | 可切换纯视频模式 |
| 画中画支持 | PiP 后台播放 |
| 手动下拉刷新 | 随时获取最新数据 |
| 自动后台刷新 | 系统原生 BackgroundTasks 框架 |
| Top Shelf 扩展 | Apple TV 主屏幕快速访问收藏 |
| 大屏幕优化 | 大字体适配远距离观看 |

## 🏗️ 系统架构

- **语言:** Swift 6.0
- **平台:** tvOS 17.0+
- **UI 框架:** SwiftUI
- **数据持久化:** SwiftData
- **视频播放:** AVPlayer
- **架构:** 清晰分层（UI → Domain → API）
- **依赖注入:** 手动 DependencyContainer

详细架构分析请参考 [.planning/codebase/ARCHITECTURE.md](.planning/codebase/ARCHITECTURE.md)

## 📋 环境要求

- Xcode 16.0+
- Swift 6.0+
- tvOS 17.0+
- Apple TV 4K 或更新机型
- Apple 开发者账号（用于侧载部署）

## 🚀 部署安装

完整的部署指南请查看 [DEPLOYMENT.md](./DEPLOYMENT.md)

快速步骤：

```bash
# 1. 克隆代码
git clone https://github.com/你的用户名/douyin.git
cd douyin

# 2. 打开项目
open DouyinLiveTV.xcodeproj

# 3. 配置代码签名
# 在 Xcode → Signing & Capabilities 中选择你的开发团队

# 4. 构建并部署到 Apple TV
# 选择你的 Apple TV 设备，点击运行
```

> ℹ️ 本项目是**个人侧载项目**，仅供自用，不会发布到 App Store。

## 📖 使用说明

完整使用说明请查看 [USAGE.md](./USAGE.md)

快速上手：

1. **登录** - 使用抖音扫描二维码登录
2. **添加直播间** - 输入房间 ID 或粘贴分享链接
3. **监控数据** - 在主界面查看实时数据和视频
4. **收藏管理** - 收藏常用直播间，下次快速打开

## 🗺️ 开发路线图

- ✅ v1.0 初始版本 - 基础功能完整可用
- 🔄 计划中：待定（欢迎提 Issue）

## ⚠️ 免责声明

本项目仅供学习和个人研究使用。请遵守抖音平台的相关规定。使用本软件产生的任何后果由使用者自行承担。

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

## 👤 作者

个人自用项目，欢迎 Fork 改进。

---

## 相关文档

- [部署指南](./DEPLOYMENT.md) - 详细的构建部署步骤
- [使用指南](./USAGE.md) - 完整功能使用说明
- [项目规划](.planning/PROJECT.md) - 需求和设计决策
