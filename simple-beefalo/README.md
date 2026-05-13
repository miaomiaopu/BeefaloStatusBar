# Simple Beefalo Status Bar

> 本 MOD 由 AI 辅助制作（Claude Code）

骑乘皮弗娄牛时显示状态栏，展示健康、驯化度、顺从度、骑乘计时器、鞍具使用次数、饥饿值。

状态栏位于屏幕右侧、时间钟和季节钟的左侧，与 [Combined Status](https://steamcommunity.com/sharedfiles/filedetails/?id=376333686) 兼容。

## 制作基准

- **制作时间**：2026-05-13
- **基于**：
  - [Beefalo Status Bar](https://steamcommunity.com/sharedfiles/filedetails/?id=2477889104) (by MNK) — 原始架构与 UI 组件
  - [骑牛状态栏](https://steamcommunity.com/sharedfiles/filedetails/?id=3715373342) (by MNK, 修改: 莲华可爱捏·ω·) — 喂食计时器重置修复

发布地址：[Steam 创意工坊](https://steamcommunity.com/sharedfiles/filedetails/?id=3725322029)

## 功能

骑乘皮弗娄牛时自动显示以下信息：

| 徽章 | 内容 |
|------|------|
| 饥饿 | 牛的饱食度（可设置阈值，低于阈值时隐藏） |
| 生命 | 牛的血量百分比 |
| 驯化 | 驯化进度 + 倾向（战牛/行牛/肥牛），颜色随倾向变化 |
| 顺从 | 驯服程度百分比 |
| 计时器 | 距牛发怒掀翻玩家的倒计时 + 鞍具使用次数 |

### 特色

- **右侧显示**：位于屏幕右上方面板，季节钟和时间钟左侧，不覆盖时钟
- **喂食计时器重置**：喂食牛肉后骑乘计时器自动重置
- **Combined Status 兼容**：与组合状态 MOD 同时使用无冲突
- **可配置**：支持位置偏移、徽章颜色、主题、比例等多项自定义
- **中文本地化**：全部配置项与提示为中文

## 安装

### Steam 创意工坊（推荐）

在 [Steam 创意工坊](https://steamcommunity.com/sharedfiles/filedetails/?id=3725322029) 中点击「订阅」，启动游戏后 MOD 将自动下载启用。

### 手动安装

1. 下载 `simple-beefalo` 文件夹
2. 放入 `Don't Starve Together/mods/` 目录
3. 在游戏的 MOD 管理界面启用「Simple Beefalo Status Bar」

> 注意：此 MOD 为服务端 MOD，所有客户端均需订阅。单人使用无需额外操作。

> 注意：此为服务端 MOD，需要 `all_clients_require_mod = true`（已默认设置）。

## 配置

可在游戏内「主机游戏 → 世界 → MOD」或「主菜单 → MOD → 服务器 MOD」中调整：

- **常规**：自动显示、切换按键(RAlt)、音效
- **徽章设置**：主题(默认/熔炉)、比例、饥饿阈值、背景亮度/透明度、间隙
- **徽章颜色**：各驯化倾向独立配色、顺从色、计时器色
- **位置偏移**：水平偏移(X, -500~500, 步长10)、垂直偏移(Y, -200~200, 步长5)

## 工作日志

### v2026.05.13.0

- 基于 Beefalo Status Bar (2477889104) 原始架构构建
- 从骑牛状态栏 (3715373342) 移植喂食计时器重置修复
- 剥离所有无关功能代码（MiniFan 系列约 490 行）
- UI 定位改为右侧 topright_root 面板（季节钟/时间钟左侧）
- 饥饿徽章移至最左侧，展开时不覆盖时钟区域
- 动画改为水平滑出（适配右侧位置）
- 简化定位配置（移除倍率和微调，改为直接数值偏移）
- 中文本地化（配置项、提示文本）
- 默认主题改为「Default」

## 许可

原始代码版权归属 MNK 及 莲华可爱捏·ω·。本修改版仅供个人使用。
