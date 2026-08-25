<div align="center">

# 🤖 workbuddy-auto-signin

**自动领取 WorkBuddy 每日签到积分的小脚本**

零依赖 · 纯标准库 · 跨平台 · 幂等安全

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![No Dependencies](https://img.shields.io/badge/dependencies-0-green.svg)]()
[![Platform](https://img.shields.io/badge/platform-Win%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()
[![Stars](https://img.shields.io/github/stars/88lin/workbuddy-auto-signin.svg)](https://github.com/88lin/workbuddy-auto-signin)

</div>

> 一个自包含的 Python 脚本，每天自动帮你领取 **WorkBuddy**（腾讯 AI 编程助手）的每日签到积分。只读取你自己机器上的登录态，零内置密钥，可安全分享。

---

## 🚀 一键使用（推荐）

不用手动配置——直接把仓库链接发给有本地执行能力的 AI 助手（如 **WorkBuddy**），让它帮你跑起来并设置每日定时签到。把下面这段原样发过去即可：

```text
帮我把这个仓库的签到脚本跑起来，并设置每天 00:05 自动签到：
https://github.com/88lin/workbuddy-auto-signin
```

> [!TIP]
> 一键方式依赖 AI 能访问你本机（运行 Python、读取桌面端登录态）。WorkBuddy 自身就具备这个能力；纯云端 AI（如网页版 ChatGPT）无法直接执行，但可指导你手动操作（见下方 🛠️ 手动使用）。

---

## ✨ 特性

| | |
|:---:|---|
| 🧩 | **零依赖** — 纯 Python 标准库，不用 `pip install`，任意 Python 3 即可 |
| 📦 | **单文件** — 完全自包含 |
| 🔁 | **幂等安全** — 先查状态，未签才领；重复运行不会多领 |
| 🐱 | **成长中心** — 自动领 Buddy 旅行礼物、派 Buddy 出发、开盲盒、领任务奖励 |
| 🧠 | **智能汇报** — 一行 JSON，如 `成功领取 100 积分（连续 7 天，累计 700 积分）` |
| 🛡️ | **健壮** — 兼容"已签"两种返回形态、识别 401/403 登录态过期、识别非签到季 |
| 🌐 | **跨平台** — 自动探测 Windows / macOS / Linux 凭据文件 |
| 🔒 | **无密钥** — 仓库不含任何密钥，只读取运行者本机登录凭据 |

---

## ⚙️ 工作原理

登录后，WorkBuddy 桌面端写出明文 JSON 会话文件 `workbuddy-desktop.info`（含 `accessToken`）。脚本流程：

1. 📂 **定位**凭据文件（自动探测，或用 `WORKBUDDY_AUTH_FILE` 覆盖）
2. 🔍 **查询** `POST /v2/billing/meter/checkin-activity-status` — 今天是否已领？
3. 🎁 **领取** 若未领，`POST /v2/billing/meter/daily-checkin`
4. 📤 **输出** 一行 JSON，`report` 字段是人话汇报

> [!NOTE]
> 所有请求都打到官方客户端用的同一个 endpoint（`https://copilot.tencent.com`）。签到接口系从桌面端 `app.asar` 逆向得到，仅供个人自动化使用。

---

## 📋 前置条件

- ✅ 已安装并**登录过 WorkBuddy 桌面端**（登录后自动写出凭据文件）
- ✅ 本机有 **Python 3**（任意版本，无需任何第三方包）

---

## 🛠️ 手动使用

```bash
git clone https://github.com/88lin/workbuddy-auto-signin.git
cd workbuddy-auto-signin
python signin.py auto
```

```
python signin.py auto     # 每日自动化：签到 + 成长中心（领旅行礼物/派Buddy/开盲盒/领任务奖）
python signin.py growth   # 仅成长中心（不签到）
python signin.py status   # 仅查签到状态（调试）
python signin.py claim    # 仅领取签到（调试，幂等）
python signin.py all      # 查签到状态 + 领取（调试）
```

看到 `今日已签过` 或 `成功领取 N 积分` 就说明通了。

---

## ⏰ 每日定时

本脚本依赖**本机桌面端登录态**，云端 CI（如 GitHub Actions）跑不了，推荐在**本机**配置定时任务。

### 方式一：Windows 任务计划（推荐，纯本地无人值守）

仓库内置一键脚本，把 `python signin.py auto` 注册成 Windows 任务计划，每天定时自动跑：

- 安装（默认每天 **00:05**）：`install-schedule.bat`
- 自定义时间（24 小时制）：`install-schedule.bat 09:30`
- 卸载：`uninstall-schedule.bat`
- 手动跑一次（测试用，非交互）：`run-once.bat`

脚本会自动用 `schtasks` 注册名为 `WorkBuddyAutoSignin` 的任务，调用 `scheduled-run.bat`：
解析 Python 绝对路径（任务计划环境可能没 PATH）→ 运行 `signin.py auto` → 把结果写日志并可选推送。

> [!TIP]
> 脚本已自动解析 Python 路径并写进任务命令，避免计划任务找不到 Python。
> 如需把签到结果推送到飞书群机器人，设置环境变量后自动生效（无需改脚本）：
> `setx WORKBUDDY_FEISHU_WEBHOOK "https://open.feishu.cn/open-apis/bot/v2/hook/xxxx"`

### 方式二：WorkBuddy 定时自动化

1. 把 `signin.py` 放到固定位置，例如 `<工作区>/.workbuddy/automations/daily-signin/signin.py`
2. 新建 WorkBuddy 自动化：
   - **名称**：每日自动领 WorkBuddy 积分
   - **计划**：每天 00:05
   - **提示词**：
     ```text
     运行 python "<signin.py 绝对路径>" auto，
     把命令输出的 JSON 里 report 字段的内容，直接一句话汇报给我。
     若 report 含"领取失败"或"登录态已失效"，提醒我重新登录 WorkBuddy 桌面端。
     ```

---

## 🔧 配置

| 环境变量 | 作用 |
|---|---|
| `WORKBUDDY_AUTH_FILE` | 自动探测失败时，手动指定凭据文件路径 |

---

## 🧪 排错

| 现象 | 处理 |
|---|---|
| `NO_AUTH / 未找到登录凭据` | 先登录一次 WorkBuddy 桌面端；或设置 `WORKBUDDY_AUTH_FILE` |
| `NO_SESSION / HTTP 401\|403` | 登录态过期——重新登录桌面端，自动化自动恢复 |
| `INACTIVE / 签到活动未开启` | 非签到季，属正常，无需处理 |
| 调试原始返回 | `python signin.py status` 或 `python signin.py all` |

> [!IMPORTANT]
> 登录态失效时脚本会明确返回 `NO_SESSION` 并提醒重新登录桌面端；重新登录后自动化无需任何改动即自动恢复。

---

## 🔐 安全与隐私

- 脚本只读取**你自己本机**的 WorkBuddy 会话文件，不含、不内嵌、不传输任何第三方密钥
- 永远不会打印 `accessToken`，`Authorization` 头不会出现在日志里
- 可安全 fork、分享、在自己机器上运行——它只作用于**你自己的**登录态

---

## ⚠️ 免责声明

> [!WARNING]
> 本项目为**非官方**工具，与腾讯或 WorkBuddy 无任何隶属关系。签到接口系从桌面端 `app.asar` 逆向得到。使用风险自负；接口可能随时变动且不另行通知。请遵守相关服务条款。

---

## 📁 项目结构

```text
workbuddy-auto-signin/
├── signin.py                  # 签到主脚本（纯标准库，auto/growth/status/claim/all）
├── install-schedule.bat      # 一键注册"每日自动签到"Windows 任务计划
├── scheduled-run.bat         # 非交互运行器：供任务计划调用（解析 Python 路径→运行→落日志→可选推送）
├── uninstall-schedule.bat    # 删除"每日自动签到"任务计划
├── run-once.bat              # 手动跑一次（测试用，非交互）
├── scripts/
│   └── notify.ps1            # 把签到结果推送到飞书群机器人（WORKBUDDY_FEISHU_WEBHOOK）
├── README.md
├── LICENSE
└── CHANGELOG.md
```

> 任务计划任务名固定为 `WorkBuddyAutoSignin`；`.bat` 均为 ASCII + CRLF（无 BOM），中文提示统一走 PowerShell，避免 GBK 代码页误解析。

## 📄 协议

[MIT](LICENSE) © 2026 88lin
