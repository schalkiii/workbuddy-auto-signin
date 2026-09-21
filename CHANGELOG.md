# Changelog

本项目所有重要变更均记录于此。格式参考 [Keep a Changelog](https://keepachangelog.com/)。

## [Unreleased]

### Added
- 新增 Windows 任务计划一键调度能力（参考 `trae-daily-checkin` 的 `schtasks` 方案）：
  - `install-schedule.bat`：注册名为 `WorkBuddyAutoSignin` 的每日任务（默认 00:05，支持自定义时间）。
  - `scheduled-run.bat`：非交互运行器，供任务计划调用；自动解析 Python 绝对路径、运行 `signin.py auto`、落日志。
  - `uninstall-schedule.bat`：删除任务计划。
  - `run-once.bat`：手动跑一次（测试用）。
  - `scripts/notify.ps1`：把签到结果（JSON 的 `report` 字段）推送到飞书群机器人，通过 `WORKBUDDY_FEISHU_WEBHOOK` 环境变量配置。
- `README.md` 新增「Windows 任务计划」使用方式与项目结构说明。
- 新增本 `CHANGELOG.md`。

### Fixed
- 修复三个调度脚本的 Python 解析：Windows 上 `where python` 常先命中 Microsoft Store 的 `WindowsApps\python.exe` 占位 stub（机器未装 Store 版 Python 时运行时直接失败，退出码 9009，且无窗口下表现为「无输出、看似成功」），导致任务计划每日签到实际从未执行过。现在跳过 `WindowsApps` 路径，依次回退 `python3` 与 `%LOCALAPPDATA%\Programs\Python` 下的真实安装（`run-once.bat` / `scheduled-run.bat` / `install-schedule.bat` 三处统一修复）。
