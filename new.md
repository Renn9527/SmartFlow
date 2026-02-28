# SmartFlow  
## 轻量化托盘级进程代理控制器设计文档（完整版本）

---

## 1. 项目定位

SmartFlow 是一款 Windows 平台的：

> 轻量级、托盘常驻、进程级强制代理控制工具

核心目标：

- 精准控制指定 EXE 的网络流量走指定代理
- 强制所有流量（TCP / UDP / DNS）被接管
- 解决 Clash TUN 无法完全代理某些程序的问题
- 支持动态进程绑定
- 提供一键启动 + 自动绑定能力
- 默认极简、后台运行、资源占用低

---

## 2. 产品设计原则

### 2.1 轻量优先

- 空闲 CPU ≈ 0%
- 内存占用 < 30MB
- 启动时间 < 1s
- 无复杂动画
- 默认不启用实时流量面板

### 2.2 极简交互

- 主操作全部在托盘完成
- 单窗口轻量面板
- 默认无多余图表
- 高级功能可隐藏

### 2.3 强制能力优先

- 不依赖系统代理
- 可拦截绕过代理行为
- 支持子进程继承规则
- 支持 DNS 强制

---

## 3. 核心功能模块

---

### 3.1 进程级代理绑定

功能：

- 手动添加 EXE 路径
- 从当前运行进程选择
- 拖拽 EXE 添加
- 支持通配符匹配
- 子进程自动继承
- 支持基于进程名 / PID / Hash 匹配

---

### 3.2 强制流量重定向引擎

支持三种模式：

#### 模式 A：WinDivert 拦截（MVP 推荐）

- 基于 PID 过滤
- 拦截 TCP / UDP
- 重定向到本地 SOCKS5

优点：
- 不依赖系统代理
- 可精准进程控制

---

#### 模式 B：WFP 驱动模式

- Windows Filtering Platform
- 内核级拦截
- 性能更稳定

---

#### 模式 C：API Hook 模式

- Hook connect / WSASocket / WinHTTP
- 用于特殊程序兼容

---

### 3.3 动态进程检测

- 监听进程创建事件
- 自动提示加入代理
- 支持自动规则学习（可选）

---

### 3.4 多代理支持

每个程序可绑定：

- SOCKS5
- HTTP Proxy
- Clash 本地端口
- 直连
- 指定网卡
- 指定 VPN

支持不同程序走不同代理。

---

### 3.5 防绕过增强

- 禁止 RAW socket
- 强制 DNS 走代理
- 阻止 IPv6 绕过
- 禁止直连行为
- 防止 DoH 绕过

---

### 3.6 DNS 控制模块

- 强制 DNS 代理
- 自定义 DoH
- 按进程 DNS 规则
- 域名拦截

---

### 3.7 日志与调试

- 进程连接统计
- 连接目标 IP / 端口
- 代理使用情况
- 上传下载统计
- 可导出 JSON

默认关闭，打开面板后才启用。

---

## 4. 托盘常驻设计

### 4.1 托盘右键菜单结构

Quick Bar
    - 动态列表
    - 编辑 Quick Bar...

进程代理规则
    - 添加 EXE...
    - 从运行中选择...
    - 最近添加
    - 打开规则目录

模式开关
    - 启用 / 暂停 SmartFlow
    - 日志等级
    - DNS 强制 开 / 关
    - IPv6 开 / 关

打开面板
设置
退出

---

### 4.2 面板设计

#### Tab A：规则

- EXE
- 当前状态
- 绑定代理
- 命中连接数
- 启用 / 禁用

#### Tab B：Quick Bar

- 名称
- EXE
- 参数
- 代理
- 启动模式
- 拖拽排序
- 编辑 / 删除

#### Tab C：日志（可选）

- 简洁流式日志
- 可导出

关闭窗口仅隐藏到托盘，不退出程序。

---

## 5. 一键启动栏（Quick Bar）

### 5.1 功能定义

支持：

- 启动程序
- 自动绑定代理
- 绑定子进程
- 启动参数配置
- 管理员权限启动

### 5.2 每个条目字段

- name
- exePath
- args
- workDir
- proxyProfile
- startMode
    - start_only
    - bind_only
    - start_and_bind
- runAsAdmin
- autoBindChildren

---

### 5.3 启动流程

点击条目：

1. 检查是否运行
2. 未运行则启动
3. 应用代理规则
4. 弹出简短提示

---

## 6. 轻量化工程策略

### 6.1 默认静默运行

- 不启用实时流量刷新
- 不持续写入日志
- 仅规则命中时处理

### 6.2 UI 与核心分离

- smartflow-core.exe
- smartflow-ui.exe

UI 关闭后线程休眠。

---

## 7. 配置结构

采用 JSON5 支持注释。

示例：

{
  logLevel: "Info",
  proxies: [
    {
      name: "clash-socks",
      type: "socks5",
      endpoint: "127.0.0.1:7897"
    }
  ],
  rules: [
    {
      match: { appNames: ["Antigravity", "language_server_windows_x64"] },
      proxy: "clash-socks",
      protocols: ["TCP", "UDP"],
      autoBindChildren: true
    }
  ],
  quickBar: [
    {
      name: "Antigravity (Proxy)",
      exePath: "C:\\Tools\\Antigravity\\antigravity.exe",
      proxy: "clash-socks",
      startMode: "start_and_bind"
    }
  ]
}

---

## 8. 可扩展创意功能

- 自动代理失败切换
- AI 网络诊断
- 流量拓扑可视化
- 游戏低延迟模式
- 反检测模式
- 快捷键触发 Quick Bar
- 临时规则 TTL

---

## 9. 技术栈建议

核心：

- Rust + WinDivert（推荐）
或
- C++ + WFP

UI：

- Tauri
或
- WPF

驱动：

- WinDivert
- WFP
- Detours（可选）

---

## 10. MVP 实现路径

阶段 1：

- 托盘程序
- Quick Bar
- 规则保存
- WinDivert PID 拦截
- SOCKS5 重定向

阶段 2：

- 子进程继承
- DNS 强制
- IPv6 防绕过

阶段 3：

- UI 优化
- 日志系统
- 多代理管理

---

## 11. 核心价值总结

SmartFlow 解决的问题是：

Windows 平台缺乏真正的 per-process 强制代理控制能力。

它不是替代 Clash，
而是补全 Clash TUN 无法覆盖的场景。

目标是：

- 轻量
- 精准
- 可控
- 常驻托盘
- 一键启动
- 不打扰用户

---