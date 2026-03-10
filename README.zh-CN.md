# CC-Codex-Gemini Companion Starter

这是一个面向 Claude Code、Codex、Gemini 的单仓库统一引导框架。

[English README](./README.md)

它不替代现有的三个记忆仓库，而是在其上增加：

- 状态感知安装
- 开源免责声明确认
- Tier 1 官方 IM bridge 接入
- Tier 3 MCP catalog 引导
- Tier 3 skills catalog 引导
- doctor / reconfigure / reset 入口

## 支持分层

- Tier 1：`claude-recall`、`codex-recall`、`gemini-recall`、`Claude-Codex-Gemini-to-IM`
- Tier 2：当前留空
- Tier 3：全部外部 MCP 和 skill，仅做 catalog 推荐

具体边界见 `docs/tiers.md`。

## 定位

这个仓库是整合层，不是新的 memory core。

- `claude-recall`、`codex-recall`、`gemini-recall` 继续作为记忆能力源仓库
- 本仓库负责统一 onboarding 和可选模块编排

## 它实际提供什么

- 一个面向 Claude Code / Codex / Gemini 的统一安装入口
- 一个真正会写入 `.assistant/` 的记忆访谈流程
- 一个针对 `Claude-Codex-Gemini-to-IM` 的 Tier 1 官方适配器
- 一个针对外部 MCP 和 skills 的 Tier 3 推荐目录
- 一套状态感知的 `install / reconfigure / doctor / reset` 流程

## 用户体验路径

1. 针对目标平台运行安装命令。
2. 如果检测到已有安装信息，选择 `fresh`、`continue` 或 `partial`。
3. 同意开源免责声明。
4. 完成记忆访谈并生成 `.assistant/` 核心文件。
5. 选择是否现在配置官方 IM bridge。
6. 查看 MCP / skills catalog，并按需标记为 self-managed。
7. 之后可随时通过 `reconfigure` 或 `im ...` 命令继续配置。

## 快速开始

```bash
cd CC-Codex-Gemini-companion-starter
chmod +x bin/cccg-companion scripts/install/setup.sh scripts/reconfigure/setup.sh scripts/doctor/check.sh scripts/reset/reset.sh scripts/im/setup.sh scripts/im/control.sh scripts/memory/interview.sh
bin/cccg-companion install --workspace /path/to/target-workspace --platform codex
```

## 命令

```bash
bin/cccg-companion install --workspace /path/to/workspace --platform claude
bin/cccg-companion reconfigure --workspace /path/to/workspace
bin/cccg-companion doctor --workspace /path/to/workspace --platform codex
bin/cccg-companion reset --workspace /path/to/workspace
bin/cccg-companion im start --workspace /path/to/workspace
bin/cccg-companion im status --workspace /path/to/workspace
bin/cccg-companion im logs --workspace /path/to/workspace 100
```

## IM Bridge 命令

```bash
bin/cccg-companion im start --workspace /path/to/workspace
bin/cccg-companion im stop --workspace /path/to/workspace
bin/cccg-companion im status --workspace /path/to/workspace
bin/cccg-companion im logs --workspace /path/to/workspace 100
bin/cccg-companion im doctor --workspace /path/to/workspace
```

## 写入位置

统一安装状态写入：

```text
.assistant/unified-bootstrap/
```

核心文件包括：

- `state.env`
- `platform-next-steps.md`
- `memory-source/`
- `im-bridge-plan.md`
- `mcp-plan.md`
- `skills-plan.md`

## 仓库结构

```text
bin/
scripts/
  install/
  reconfigure/
  doctor/
  reset/
  im/
  memory/
docs/
catalogs/
manifests/
profiles/
```

## 关键文档

- `docs/tiers.md`
- `docs/architecture.md`
- `docs/im/official-bridge.md`
- `docs/onboarding-flow.md`
- `docs/disclaimer.md`
- `catalogs/recommended-mcp-skills.md`

## License

MIT
