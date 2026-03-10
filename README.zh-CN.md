# CC-Codex-Gemini Companion Starter

把 Claude Code / Codex / Gemini 从“会干活的 CLI Agent”改造成“更适合长期协作的个人助理”。

[English README](./README.md)

## 为什么会有这个仓库

最近很多人喜欢 OpenClaw，不是因为它又多了一个功能点，而是因为它第一次把“长期助理感”做得很具体。

但如果你真的想把它长期放进自己的工作流，安全性、稳定性、边界和控制感很容易变成更大的顾虑。

这套仓库要解决的不是“复刻 OpenClaw”，而是把它最值得保留的体验迁到更成熟、更稳定、也更接近日常工作流的宿主上。

这里优先支持的宿主是：

- Claude Code
- Codex
- Gemini

其中，Claude Code / Codex 通常是更顺的主线。

## 这套方案保留了什么

如果只看体验层，我真正想保留的是三件事：

- 随时可达：可以在 IM 里随时叫它，不必每次都从终端冷启动
- 长期延续：它能记住你、记住项目、记住上次做到哪
- 真能干活：它不只是陪聊，而是会调用工具把事情往前推

## 这套仓库做了什么

这不是单个 prompt，也不是单纯补一层记忆。

它本质上是一套“三件套”改造：

1. 记忆改造
2. IM 桥接
3. 工具能力补齐

### 1. 记忆改造

Claude Code / Codex / Gemini 这类宿主本身都很强，但默认仍然更像“单回合高手”。

窗口一关，很多上下文就丢了。  
项目一多，长期协作感也很难自然长出来。

所以这套 starter 会给它们补上一个更清楚的长期记忆结构：

- 全局记忆：你的身份、风格、长期偏好、协作方式
- 项目记忆：当前项目的背景、约束、决策和上下文
- 临时记忆：当天的碎片信息、未确认信息、短期事项
- 运行时状态：当前活跃任务、最近会话、下一步该接哪里

这套思路参考了 OpenClaw 风格的长期记忆设计，但按 Claude Code / Codex / Gemini 的工作流做了重构，不是简单照搬。

### 2. IM 桥接

长期助理的一个关键体感，是“你能随时叫到它”。

所以这套仓库支持把宿主接入 IM，尤其围绕飞书 / Lark 这类真实办公入口做过较多适配。

它解决的不是“技术上能不能收到消息”，而是让体验更接近一个真的助理：

- 消息入口更自然
- 会话切换和持续协作更顺
- 附件、语音、后台常驻这类真实使用问题更少
- 同一台机器上多个宿主可隔离运行

当前官方桥接集成基于：

- [`Claude-Codex-Gemini-to-IM`](https://github.com/d-wwei/Claude-Codex-Gemini-to-IM)

同时也感谢上游开源项目：

- [`op7418/Claude-to-IM-skill`](https://github.com/op7418/Claude-to-IM-skill)

### 3. 工具能力补齐

OpenClaw 一个很大的优势，是装上就自带一整套围绕“助理”组织起来的工具层。

Claude Code / Codex 这类宿主则更像强大的白板底座：  
本身 agent 能力很强，但助理化工具层默认没有替你装好。

所以这里补的，不是“随便多装几个 MCP”，而是一套更适合长期协作的默认工具组合：

- 浏览器 / 网页处理
- 搜索与资料发现
- 记忆与推理增强
- GitHub / 飞书等常用基础设施连接
- 可选的垂直领域工具

更重要的是，这些工具能力会被放回一个更可控的宿主里。

相比某些“黑箱感”更强的系统，Claude Code / Codex 这种宿主通常会让你更清楚地看到：

- 读了什么
- 改了什么
- 调用了什么工具
- 执行了什么步骤

所以这里追求的不是“像 OpenClaw 一样会动手”，而是“既能动手，又让我对过程更有控制感”。

## 为什么优先选 Claude Code / Codex

我最后没有继续围着 OpenClaw 本体改，而是选 Claude Code / Codex 作为迁移宿主，核心原因很简单：

- 它们作为宿主更成熟、更稳定，放进真实工作流时心智负担更小
- agent 能力已经足够强，读仓库、改文件、跑命令、接上下文本来就很接近日常使用场景
- 官方还在持续更新，能力边界一直在往外扩
- 官方订阅和主流 provider 选择都比较丰富
- skill、MCP、插件生态更成熟，很多真正有价值的能力都可以迁移、补齐或重建

这套仓库的目标，不是把未来押在一个你原本就有顾虑的底座上，而是把真正有价值的体验层迁到更稳的宿主上。

## 仓库定位

这是一个整合层仓库，不是新的 memory core。

底层能力来源分层如下：

- Tier 1：维护和编排的核心能力
- Tier 2：当前留空
- Tier 3：外部 MCP 和 skills，仅做 catalog 推荐

当前整合的核心仓库包括：

- `claude-recall`
- `codex-recall`
- `gemini-recall`
- `Claude-Codex-Gemini-to-IM`

本仓库负责：

- 统一安装入口
- 状态感知安装
- 开源免责声明确认
- memory onboarding
- IM bridge 规划与控制入口
- MCP / skill catalog 引导
- `install / reconfigure / doctor / reset`

## 快速开始

```bash
cd CC-Codex-Gemini-companion-starter
chmod +x bin/cccg-companion scripts/install/setup.sh scripts/reconfigure/setup.sh scripts/doctor/check.sh scripts/reset/reset.sh scripts/im/setup.sh scripts/im/control.sh scripts/memory/interview.sh
bin/cccg-companion install --workspace /path/to/target-workspace --platform claude
```

支持平台：

- `claude`
- `codex`
- `gemini`

示例：

```bash
bin/cccg-companion install --workspace /path/to/workspace --platform claude
bin/cccg-companion reconfigure --workspace /path/to/workspace
bin/cccg-companion doctor --workspace /path/to/workspace --platform codex
bin/cccg-companion reset --workspace /path/to/workspace
bin/cccg-companion im start --workspace /path/to/workspace
bin/cccg-companion im status --workspace /path/to/workspace
bin/cccg-companion im logs --workspace /path/to/workspace 100
```

## 用户路径

1. 运行安装命令并选择目标宿主。
2. 如果检测到已有状态，选择 `fresh`、`continue` 或 `partial`。
3. 阅读并确认开源说明。
4. 完成记忆访谈并生成 `.assistant/` 核心文件。
5. 选择是否现在配置 IM bridge。
6. 查看 MCP / skills 推荐目录，按需继续配置。
7. 后续通过 `reconfigure`、`doctor` 或 `im ...` 命令继续调整。

## 写入位置

统一安装状态写入：

```text
.assistant/unified-bootstrap/
```

关键文件包括：

- `state.env`
- `platform-next-steps.md`
- `memory-source/`
- `im-bridge-plan.md`
- `mcp-plan.md`
- `skills-plan.md`

## 关键文档

- `docs/tiers.md`
- `docs/architecture.md`
- `docs/im/official-bridge.md`
- `docs/onboarding-flow.md`
- `docs/disclaimer.md`
- `catalogs/recommended-mcp-skills.md`

## 只安装其中一部分

如果你只对其中一部分感兴趣，也可以直接使用单独仓库安装，而不必从这个整合仓库全量开始。

### 记忆系统改造

- [claude-recall](https://github.com/d-wwei/claude-recall)
- [codex-recall](https://github.com/d-wwei/codex-recall)
- [gemini-recall](https://github.com/d-wwei/gemini-recall)

### IM 桥接

- [Claude-Codex-Gemini-to-IM](https://github.com/d-wwei/Claude-Codex-Gemini-to-IM)
- 上游原始仓库：[op7418/Claude-to-IM-skill](https://github.com/op7418/Claude-to-IM-skill)

### 初始化工具包安装

- [agent-powerpack](https://github.com/d-wwei/agent-powerpack)

## 开源说明

这套方案不是凭空造出来的，而是基于现有开源项目、官方能力和社区生态做组合、适配与重构。

其中：

- IM bridge 底层能力基于开源项目继续适配和扩展
- 记忆系统参考了 OpenClaw 提出的长期协作思路，并按 Claude Code / Codex / Gemini 的工作流做了重构
- 部分 MCP、skill、插件能力来自社区和官方开源生态

这套方案的大量实现，也受益于 AI 时代的 vibe coding 工作方式，很多想法都是在快速试错、快速验证、快速迭代中长出来的。感谢这个时代。

由于整个项目历时还比较短，虽然已经经过实际使用和自测验证，但很难覆盖所有环境、权限配置和具体工作流场景。

如果你在使用中遇到问题，欢迎提 issue、提反馈，也欢迎直接继续改。  
如果真出了小问题，也可以先让 Claude Code / Codex 帮你一起修修。

这套仓库想表达的不是“重新发明一个 OpenClaw”，而是：  
把它最值得保留的部分迁移、强化，并落到一个更适合长期使用的宿主上。

## License

MIT
