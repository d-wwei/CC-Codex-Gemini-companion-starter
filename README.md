# CC-Codex-Gemini Companion Starter

Single-repository bootstrap framework for Claude Code, Codex, and Gemini.

[中文说明](./README.zh-CN.md)

This repository does not replace the three existing memory repositories. It orchestrates them and adds:

- state-aware installation
- open source consent gating
- Tier 1 official IM bridge setup
- Tier 3 MCP catalog guidance
- Tier 3 skills catalog guidance
- doctor, reconfigure, and reset entry points

## Support Tiers

- Tier 1: `claude-recall`, `codex-recall`, `gemini-recall`, `Claude-Codex-Gemini-to-IM`
- Tier 2: currently empty
- Tier 3: all external MCPs and skills are catalog-only

See `docs/tiers.md` for the exact boundary.

## Repository Role

This is the integration layer.

- `claude-recall`, `codex-recall`, and `gemini-recall` remain the memory source of truth
- this repository manages onboarding and optional component setup

## What It Gives You

- A single install entry for Claude Code, Codex, and Gemini
- A real memory interview that writes the workspace `.assistant/` scaffold
- A Tier 1 adapter for `Claude-Codex-Gemini-to-IM`
- A curated Tier 3 catalog for external MCPs and skills
- State-aware `install`, `reconfigure`, `doctor`, and `reset` flows

## User Flow

1. Run the installer for the target platform.
2. If prior setup is detected, choose `fresh`, `continue`, or `partial`.
3. Accept the open source disclaimer.
4. Complete the memory interview.
5. Configure the official IM bridge now or skip it for later.
6. Review MCP and skills catalogs and mark them as self-managed if desired.
7. Re-enter later through `reconfigure` or `im ...` commands.

## Quick Start

```bash
cd CC-Codex-Gemini-companion-starter
chmod +x bin/cccg-companion scripts/install/setup.sh scripts/reconfigure/setup.sh scripts/doctor/check.sh scripts/reset/reset.sh scripts/im/setup.sh scripts/im/control.sh scripts/memory/interview.sh
bin/cccg-companion install --workspace /path/to/target-workspace --platform codex
```

## Commands

```bash
bin/cccg-companion install --workspace /path/to/workspace --platform claude
bin/cccg-companion reconfigure --workspace /path/to/workspace
bin/cccg-companion doctor --workspace /path/to/workspace --platform codex
bin/cccg-companion reset --workspace /path/to/workspace
bin/cccg-companion im start --workspace /path/to/workspace
bin/cccg-companion im status --workspace /path/to/workspace
bin/cccg-companion im logs --workspace /path/to/workspace 100
```

## IM Bridge Commands

```bash
bin/cccg-companion im start --workspace /path/to/workspace
bin/cccg-companion im stop --workspace /path/to/workspace
bin/cccg-companion im status --workspace /path/to/workspace
bin/cccg-companion im logs --workspace /path/to/workspace 100
bin/cccg-companion im doctor --workspace /path/to/workspace
```

## What Gets Written

The unified bootstrap state lives at:

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

## Repository Layout

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

## Documents

- `docs/architecture.md`
- `docs/tiers.md`
- `docs/im/official-bridge.md`
- `docs/onboarding-flow.md`
- `docs/disclaimer.md`
- `catalogs/recommended-mcp-skills.md`

## License

MIT
