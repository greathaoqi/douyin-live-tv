# Douyin Live TV 部署指南

## 项目概述

Douyin Live TV 是一个为 Apple TV (tvOS) 开发的原生应用，用于在大屏电视上显示抖音直播间的基本统计数据，并提供直播视频预览。支持收藏常用直播间，支持手动刷新或每30分钟自动刷新。

这是一个个人自用项目，仅用于个人方便地在电视大屏上监控抖音直播间数据。

## 项目特点

- 原生 tvOS 应用，适配 Apple TV 遥控器操作
- 显示核心数据：观看人数、点赞数、礼物总值
- 直播视频预览播放，统计数据悬浮叠加显示
- 支持收藏直播间，快速访问
- 自动刷新（每30分钟）和手动刷新
- 通过 Apple TV Top Shelf 快速访问收藏直播间
- 使用 SwiftData 本地持久化存储收藏数据
- 支持画中画 (PiP) 播放

## 环境要求

- Xcode 16.0 或更高版本
- Swift 6.0
- tvOS 17.0 或更高版本
- Apple TV 4K 或更新型号（用于部署测试）
- macOS 14.0 或更高版本（开发机要求）

## 前置依赖

1. **Apple 开发者账号** - 虽然不需要发布到 App Store，但部署到真机需要开发者账号（或免费账号也可）
2. **Git** - 用于克隆代码
3. **抖音账号** - 需要有一个可用的抖音账号用于登录获取数据

## 构建步骤

### 1. 克隆代码

```bash
git clone <repository-url>
cd douyin
```

### 2. 打开项目

在 Finder 中打开 `DouyinLiveTV.xcodeproj`，或者用命令行打开：

```bash
open DouyinLiveTV.xcodeproj
```

### 3. 配置代码签名

1. 在 Xcode 左侧项目导航器中点击项目根节点
2. 选择 "DouyinLiveTV" target
3. 点击 "Signing & Capabilities" 标签
4. 在 "Team" 下拉菜单中选择你的开发团队
5. 修改 Bundle Identifier 为一个唯一的标识符（因为 Apple 要求唯一性）

> 如果你使用免费的 Apple 开发者账号，证书配置会自动完成，可能需要等待几分钟。

### 4. 检查项目配置

确保：
- 部署目标设置为 tvOS 17.0 或更高
- 应用图标已正确配置（项目中已包含）
- Top Shelf 扩展已正确配置（项目中已包含）

### 5. 构建应用

在 Xcode 中按 `Cmd+B` 构建项目，或选择菜单 `Product → Build`。

等待构建完成，若无错误则构建成功。

## 部署到 Apple TV

### 1. 连接 Apple TV

确保你的开发电脑和 Apple TV **连接到同一个 Wi-Fi 网络**。

通过 Xcode 连接到你的 Apple TV：
1. 在 Xcode 左上角，点击当前方案旁边的设备选择下拉框
2. 选择 "Add Additional Simulators and Devices..."
3. 在弹出窗口中，找到你的 Apple TV 并配对
4. 配对完成后，选择你的 Apple TV 作为部署目标

或者，如果你使用 USB-C 连接，可以直接通过线缆连接 Apple TV 到开发机。

### 2. 运行部署

点击 Xcode 中的 "Play" 按钮（或按 `Cmd+R`），Xcode 会将应用部署到你的 Apple TV。

首次部署可能需要几分钟，请耐心等待。部署完成后，应用会自动在 Apple TV 上打开。

### 3. 验证安装

部署成功后，在 Apple TV 主屏幕上应该能看到 "Douyin Live TV" 应用图标。点击打开应用，如果能正常启动则部署成功。

## 侧载说明

本项目是**个人侧载项目**：

- 仅供个人使用，不会发布到 App Store
- 不需要遵守 App Store 审核规则
- 每次用 Xcode 部署后，证书有效期大约为 7 天
- 过期后需要重新部署一次即可继续使用
- 如果你有付费开发者账号，可以使用自签名证书实现更长有效期

## 故障排查

### 构建失败

- 检查 Xcode 版本是否满足要求（16.0+）
- 检查 Swift 版本设置
- 尝试清理构建文件夹：`Product → Clean Build Folder` (Cmd+Shift+K)

### 无法连接到 Apple TV

- 检查两者是否在同一 Wi-Fi 网络
- 重启 Apple TV 和 Xcode 后重新配对
- 尝试使用 USB-C 有线连接

### 部署失败，提示证书错误

- 检查开发者账号是否有效
- 重新选择 Team，让 Xcode 重新生成证书
- 在 Xcode → Settings → Accounts 中检查账号状态

## 后续更新

当代码更新后，只需拉取最新代码，重新构建部署即可：

```bash
git pull
```

然后在 Xcode 中重新构建并部署到 Apple TV。
