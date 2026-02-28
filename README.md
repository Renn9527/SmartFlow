# SmartFlow

SmartFlow is a Windows per-process proxy controller with a tray UI (`smartflow-ui`) and local core service (`smartflow-core`).

## Current Data Plane

- Runtime traffic enforcement backend: **ProxiFyre** (SOCKS5, TCP+UDP per-process)
- SmartFlow core generates/updates `app-config.json` automatically and controls ProxiFyre lifecycle.
- Runtime hardening policies are applied through Windows Firewall rules:
  - DNS direct block (`TCP/UDP 53`)
  - IPv6 direct block (`::/0`)
  - DoH provider IP block (`TCP 443`, known DoH endpoints)

## Key Features

- Proxy profiles (default: Clash Verge `127.0.0.1:7897`)
- Rule management (app name/path/PID matching)
- Quick Bar launch and bind
- Engine mode switch (`win_divert`, `wfp`, `api_hook`) with shared backend lifecycle
- Real-time process view, rule hit stats, and logs
- Tray resident UI

## Build Prerequisites (Win10)

- Rust toolchain (MSVC)
- Visual Studio Build Tools 2022 + C++ toolset
- Node.js + npm (frontend asset helper)

## Build

```powershell
.\scripts\build-release.ps1
```

Output:

- `release\SmartFlow\smartflow-core.exe`
- `release\SmartFlow\smartflow-ui.exe`
- `release\SmartFlow\proxifyre\*` (bundled runtime)

## Run

```powershell
.\release\SmartFlow\smartflow-core.exe --bind 127.0.0.1:46666
.\release\SmartFlow\smartflow-ui.exe
```

Notes:

- Run as **Administrator** for full enforcement/firewall rule operations.
- Runtime hardening firewall rules are applied only when at least one SOCKS5 endpoint is reachable.
- New default config starts with `runtime.enabled = false` for safer first launch.
- `smartflow-core` searches ProxiFyre in this order:
  1. `SMARTFLOW_PROXIFYRE_DIR`
  2. `<core_dir>\proxifyre`
  3. `<core_dir>`
  4. `<cwd>\third_party\proxifyre\pkg`
  5. `C:\tools\ProxiFyre`

## Core API

Base URL: `http://127.0.0.1:46666`

- `GET /health`
- `GET/PUT /config`
- `GET /processes`
- `GET/POST /rules`
- `PUT/DELETE /rules/{id}`
- `GET/POST /quickbar`
- `PUT/DELETE /quickbar/{id}`
- `POST /quickbar/{id}/launch`
- `GET/POST /proxies`
- `PUT/DELETE /proxies/{id}`
- `POST /engine/mode`
- `POST /runtime`
- `GET /stats`
- `GET /logs`

---

## 中文版

SmartFlow 是一个 Windows 按进程代理控制器，包含托盘界面（`smartflow-ui`）和本地核心服务（`smartflow-core`）。

### 当前数据平面

- 运行时流量接管后端：**ProxiFyre**（SOCKS5，支持 TCP+UDP 按进程代理）
- SmartFlow Core 会自动生成/更新 `app-config.json`，并管理 ProxiFyre 生命周期
- 运行时加固策略通过 Windows 防火墙规则生效：
  - 阻断直连 DNS（`TCP/UDP 53`）
  - 阻断直连 IPv6（`::/0`）
  - 阻断常见 DoH 提供商 IP（`TCP 443`）

### 主要功能

- 代理配置管理（默认：Clash Verge `127.0.0.1:7897`）
- 规则管理（支持进程名/路径/PID 匹配）
- Quick Bar 一键启动并绑定代理
- 引擎模式切换（`win_divert`、`wfp`、`api_hook`），共享后端生命周期
- 实时进程视图、规则命中统计、日志查看
- 托盘常驻 UI

### 构建依赖（Win10）

- Rust 工具链（MSVC）
- Visual Studio Build Tools 2022 + C++ toolset
- Node.js + npm（前端资源辅助）

### 构建

```powershell
.\scripts\build-release.ps1
```

输出目录：

- `release\SmartFlow\smartflow-core.exe`
- `release\SmartFlow\smartflow-ui.exe`
- `release\SmartFlow\proxifyre\*`（已打包运行时）

### 运行

```powershell
.\release\SmartFlow\smartflow-core.exe --bind 127.0.0.1:46666
.\release\SmartFlow\smartflow-ui.exe
```

说明：

- 建议使用 **管理员权限** 运行，以获得完整接管/防火墙规则能力。
- 仅当至少一个 SOCKS5 端点可达时，运行时加固防火墙规则才会应用。
- 新默认配置中 `runtime.enabled = false`，用于首次启动安全兜底。
- `smartflow-core` 会按以下顺序查找 ProxiFyre：
  1. `SMARTFLOW_PROXIFYRE_DIR`
  2. `<core_dir>\proxifyre`
  3. `<core_dir>`
  4. `<cwd>\third_party\proxifyre\pkg`
  5. `C:\tools\ProxiFyre`

### Core API

基础地址：`http://127.0.0.1:46666`

- `GET /health`
- `GET/PUT /config`
- `GET /processes`
- `GET/POST /rules`
- `PUT/DELETE /rules/{id}`
- `GET/POST /quickbar`
- `PUT/DELETE /quickbar/{id}`
- `POST /quickbar/{id}/launch`
- `GET/POST /proxies`
- `PUT/DELETE /proxies/{id}`
- `POST /engine/mode`
- `POST /runtime`
- `GET /stats`
- `GET /logs`
