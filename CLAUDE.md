# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

GTNH（GregTech: New Horizons）整合包中血魔法"陨星仪式"（流星农场）的全自动控制脚本，运行在游戏内 OpenComputers（OC）电脑上。单文件项目：`zx.lua`，依赖 OC 标准库（component / sides / event / os / computer）。

无构建、测试、依赖管理工具链。脚本需拷入游戏内 OC 电脑运行；在本机只能做语法检查（如已安装 Lua：`luac -p zx.lua`）。注意 OC 使用 Lua 5.2+ 语法（`goto` 可用），`os.execute("cls")` 是 OC 清屏而非 Windows 命令。

## 工作流（必须遵守）

固定流程：**修改代码 → commit 并推送到 Gitee → 向用户反馈结果**。每次修改完成后必须立即提交并推送，不要把改动留在本地。

- 远程：`origin` = `git@gitee.com:mika-miko/starry-fall-automation.git`（SSH，master 分支）
- 本机全局 git 代理（localhost:7897）可能未运行：SSH 推送不受影响，不要改回 HTTPS 地址
- 游戏内下载地址（README 中提供）：`https://gitee.com/mika-miko/starry-fall-automation/raw/master/zx.lua`

## 游戏内硬件布局（脚本自识别约定）

启动时扫描组件，按约定识别，缺任一即 `os.exit(0)` 退出：

- **红石卡（redstone）**：触发仪式、控制清理机、接收完成信号。整个脚本只支持**一张**红石卡和一个转运器（组件扫描循环直接覆盖变量，多张会取到最后一个）。
- **转运器（transposer）**：扫描 0-5 六个面，按 `getInventoryName` 内部名识别四个容器：
  - `tile.fullDrawers1` → 放祭品的抽屉，**固定读 2 号槽**
  - `tile.enderchest` → 末影箱，**固定写 1 号槽**（仪式从这里取祭品）
  - `tile.chest` → 垃圾箱（接收非白名单物品）
  - `tile.extrautils:chestMini` → 放血魔法宝珠的迷你箱（读 `orb.networkEssence` 获取灵魂网络 LP 存量）
- **GT 采矿场**：组件类型 `gt_machine` 且 `getName()` 含 `multimachine.oredrill`，通过 `setWorkAllowed(bool)` 批量启停。

## 核心数据结构 itemData

祭品白名单，键为 `"物品名:damage"` 字符串（`get_type` 用 `item.name .. ":" .. item.damage` 拼接查询）。每项两个属性：

- `type`：陨石类型，决定落地后的处理方式
  - `1` 无矿石陨石 → 只用清理机（ore_miner）回收陨石本体
  - `2` 混合陨石 → 先采矿场（ore_drill）采矿石，再清理机扫尾
  - `3` 纯矿石陨石 → 只用采矿场
- `lp`：召唤该陨石消耗的 LP 量

新增祭品 = 在 `itemData` 加一行（含中文注释），并确认其 type 与处理机器匹配。

## 三种运行模式

启动时交互选择（非法输入默认模式 3）：

1. 奥术钻探机模式：接受白名单内所有祭品
2. 填充机模式：额外排除 type 1（`mode == 2 and type == 1` 送垃圾箱）
3. 纯矿石模式：只接受 type 3，不接清理机、也不询问其方向

模式 1/2 的区别仅在提示文案（奥术钻探机 vs 填充机），控制逻辑相同。过滤条件集中在 main 循环中单个 `if` 判断。

## 主循环（`goto select` 状态机）

1. 读抽屉 2 号槽，无祭品则待机（10 秒轮询）
2. 白名单 + 模式过滤，不合格物品**整堆**转运进垃圾箱
3. 等迷你箱出现宝珠，轮询 LP 直到 `当前LP + 100 >= 祭品lp`
4. 移 1 个祭品到末影箱 1 号槽 → 红石拉 `side_ritual` 保持 11 秒等陨石落地
5. 按 type 分派 ore_drill / ore_miner，回到第 1 步

启动时（initialize）会先交互询问各方向（n/s/e/w/u/d，支持默认值），然后做一次开场清理，再进入主循环——**脚本不是无头启动的，需要人工回答方向问题**。

## 关键机制与约定

- **完成信号**：机器完成后在约定方向输出信号强度 15。`wait_for_signal(side, 15, 300, 原因)` **先检查当前电平**（防止等待开始前信号已到位、或红石事件被 `os.sleep` 吞掉导致死等），再以 ≤5 秒分段监听 `redstone_changed`，每段打印等待原因与进度，总超时 300 秒。
- **超时重试**：`ore_drill` 超时后 `setWorkAllowed(false)`→`(true)` 真正重启机器；`ore_miner` 超时后断电再上电重启。初始化清理与主循环共用 `ore_miner()`。
- **容差设计**：LP 允许差 100 以内即开跑（LP 在转运期间仍在增长）。
- **等待可视化**：所有等待点（无祭品/宝珠/LP/红石信号）都周期性打印原因与已等待时间，避免"静默卡死看起来像死机"。LP 等待用 `\r` 回行首**原地覆盖刷新**（新信息短于旧信息时补空格擦残留），等待结束后补换行，其余输出不受影响。
