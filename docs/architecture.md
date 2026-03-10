# Architecture

This repository is the orchestration layer above three existing memory repositories:

- `claude-recall`
- `codex-recall`
- `gemini-recall`

It keeps the system light by separating responsibilities:

- Memory repositories remain the source of truth for platform memory behavior.
- This repository owns onboarding, install state, reconfigure flow, doctor checks, and component bundling.
- IM bridge, MCP, and skills stay modular and can be configured now or deferred.

Core layers:

1. Shared orchestration layer
2. Platform adapter layer
3. Optional component layer

Component support is intentionally tiered:

- Tier 1: official adapters for the three memory repositories and the official IM bridge product
- Tier 2: intentionally empty for now
- Tier 3: catalog-only external MCPs and skills

This keeps the repository maintainable while still giving users a curated expansion path.
