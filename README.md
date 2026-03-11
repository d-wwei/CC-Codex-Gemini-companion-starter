# CC-Codex-Gemini Companion Starter

Turn Claude Code / Codex / Gemini from capable CLI agents into better long-term personal assistants.

[中文说明](./README.zh-CN.md)

## Why This Repository Exists

What many people actually like about OpenClaw is not a single feature. It is the feeling of a long-term assistant:

- reachable from IM
- able to remember context
- able to use tools and move work forward

But if you want to place that kind of system into a real workflow, safety, stability, boundaries, and control quickly matter more than novelty.

This repository is not about cloning OpenClaw.  
It is about migrating the most valuable parts of that experience onto more mature hosts:

- Claude Code
- Codex
- Gemini

In practice, Claude Code and Codex are usually the main path.

## The Three-Part Upgrade

This is not a single prompt and not just a memory patch.

It is a three-part upgrade:

1. Memory
2. IM bridge
3. Tooling layer

### 1. Memory

Claude Code / Codex / Gemini are strong by default, but still tend to behave like single-session agents.

This starter adds a more durable collaboration layer with:

- global memory
- project memory
- temporary daily context
- runtime state and resume checkpoints

The design is inspired by OpenClaw-style durable memory, but rebuilt for Claude Code / Codex / Gemini workflows instead of copied directly.

### 2. IM Bridge

A real assistant should be easy to reach.

This repository integrates IM bridge setup so the host can be reached from real communication surfaces, especially Feishu / Lark style workflows.

The goal is not just “message delivery works”, but a smoother day-to-day assistant experience:

- easier entry point
- better session continuity
- fewer rough edges around attachments, voice, and background runtime
- isolation across multiple hosts on one machine

Core integration:

- [`Claude-Codex-Gemini-to-IM`](https://github.com/d-wwei/Claude-Codex-Gemini-to-IM)

With thanks to the upstream open source bridge work:

- [`op7418/Claude-to-IM-skill`](https://github.com/op7418/Claude-to-IM-skill)

Important runtime rule:

- `claude-to-im`, `codex-to-im`, and `gemini-to-im` must be treated as isolated runtimes
- each host keeps its own `~/.<host>-to-im/` home, config, logs, and credentials
- do not copy or reuse another host's `config.env` as the starting point

### 3. Tooling Layer

One major OpenClaw advantage is that it feels like it ships with an assistant-shaped tool layer out of the box.

Claude Code / Codex are different: they are powerful hosts, but closer to a blank canvas at the assistant-tooling layer.

So this repository does not just add “more MCPs”. It helps restore a practical default tool layer for long-term assistant work:

- browser and web handling
- search and discovery
- memory and reasoning support
- common infrastructure integrations such as GitHub and Feishu
- optional domain-specific tools

More importantly, those tools stay inside a host where the process is easier to inspect and control:

- what was read
- what was changed
- which tools were called
- which steps were executed

The goal is not only “can act”, but “can act with better control”.

## Why Claude Code / Codex

The point is not that OpenClaw cannot be modified.

The point is that Claude Code / Codex are already stronger long-term hosts for many real workflows:

- more mature and stable as daily-use hosts
- already strong at reading repos, editing files, running commands, and handling context
- still actively evolving
- richer subscription / provider options
- stronger surrounding ecosystem for skills, MCPs, and integrations

This repository tries to move the valuable experience layer onto a host you may actually want to trust long-term.

## Repository Role

This is an integration-layer repository, not a new memory core.

It orchestrates:

- unified install entry
- state-aware setup
- open source disclaimer confirmation
- memory onboarding
- IM bridge setup/control entry points
- MCP / skills catalog guidance
- `install / reconfigure / doctor / reset`

Core repositories in the current stack:

- `claude-recall`
- `codex-recall`
- `gemini-recall`
- `Claude-Codex-Gemini-to-IM`

## Current Status

This repository is currently best understood as an early public release.

What is already in place:

- state-aware install / continue / partial flows
- a real memory interview that writes the workspace `.assistant/` scaffold
- Tier 1 IM bridge integration with host-aware setup flow
- Tier 3 catalog guidance for MCPs and skills
- automated smoke tests
- a semi-integration test for the IM bridge install chain

What still benefits from more real-world feedback:

- first-run behavior across more Claude / Codex / Gemini environments
- provider-specific IM bridge setup in more real machines
- onboarding clarity and overall setup feel
- more edge cases around third-party dependencies and permissions

If you want a fully battle-tested release, wait.
If you are comfortable with an evolving but usable starter, this is ready for early adoption.

## Known Limitations

- Claude Code and Codex are currently the main path; Gemini still needs more real-world validation.
- IM bridge support is integrated, but different providers and machine setups may still expose rough edges.
- MCPs and skills are intentionally Tier 3 catalog entries for now; this repository does not fully lifecycle-manage them.
- Real third-party dependency installs can still vary by machine, network, and local CLI state.
- This repository improves continuity and setup structure, but it does not replace the native host runtime.

## Quick Start

```bash
cd CC-Codex-Gemini-companion-starter
chmod +x bin/cccg-companion scripts/install/setup.sh scripts/reconfigure/setup.sh scripts/doctor/check.sh scripts/reset/reset.sh scripts/im/setup.sh scripts/im/control.sh scripts/memory/interview.sh
bin/cccg-companion install --workspace /path/to/target-workspace --platform claude
```

Example commands:

```bash
bin/cccg-companion install --workspace /path/to/workspace --platform claude
bin/cccg-companion reconfigure --workspace /path/to/workspace
bin/cccg-companion doctor --workspace /path/to/workspace --platform codex
bin/cccg-companion reset --workspace /path/to/workspace
bin/cccg-companion im start --workspace /path/to/workspace
bin/cccg-companion im status --workspace /path/to/workspace
bin/cccg-companion im logs --workspace /path/to/workspace 100
```

## Test Commands

```bash
bash scripts/test/run-smoke-tests.sh
bash scripts/test/test-im-install-chain.sh
bash scripts/test/run-all-tests.sh
```

## User Flow

1. Run install for the target host.
2. Choose `fresh`, `continue`, or `partial` if prior state exists.
3. Read and accept the open source disclaimer.
4. Complete the memory interview.
5. Configure IM bridge now or later.
6. Review MCP / skills catalogs.
7. Re-enter later through `reconfigure`, `doctor`, or `im ...`.

## State Location

Unified bootstrap state is written under:

```text
.assistant/unified-bootstrap/
```

Key files:

- `state.env`
- `platform-next-steps.md`
- `memory-source/`
- `im-bridge-plan.md`
- `mcp-plan.md`
- `skills-plan.md`

## Documents

- `docs/tiers.md`
- `docs/architecture.md`
- `docs/im/official-bridge.md`
- `docs/onboarding-flow.md`
- `docs/disclaimer.md`
- `catalogs/recommended-mcp-skills.md`

## Install Only One Part

If you only want one part of the stack, you can install the standalone repositories directly instead of starting with the full integration repository.

### Memory Layer

- [claude-recall](https://github.com/d-wwei/claude-recall)
- [codex-recall](https://github.com/d-wwei/codex-recall)
- [gemini-recall](https://github.com/d-wwei/gemini-recall)

### IM Bridge

- [Claude-Codex-Gemini-to-IM](https://github.com/d-wwei/Claude-Codex-Gemini-to-IM)
- Upstream original bridge: [op7418/Claude-to-IM-skill](https://github.com/op7418/Claude-to-IM-skill)

### Starter Tool Pack

- [agent-powerpack](https://github.com/d-wwei/agent-powerpack)

## Open Source Note

This stack is not invented from scratch. It is assembled and adapted from open source projects, official capabilities, and community tooling.

- The IM bridge layer extends existing open source bridge work
- The memory layer is inspired by OpenClaw-style long-term collaboration ideas, rebuilt for Claude Code / Codex / Gemini workflows
- Some MCP, skill, and plugin capabilities come from community and official ecosystems

Much of this project was also shaped through fast AI-era vibe coding: rapid iteration, quick testing, and quick restructuring.

The project was built in a relatively short time. It has been self-tested in real usage, but it does not cover every environment, permission model, or workflow edge case.

Issues and feedback are welcome.  
And if something breaks, Claude Code / Codex can probably help you fix it too.

## License

MIT
