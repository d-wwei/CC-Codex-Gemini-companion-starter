# Component Tiers

This repository uses a strict tier model to control maintenance scope.

## Tier 1: Official Adapters

These components are officially orchestrated by this repository.

- `claude-recall`
- `codex-recall`
- `gemini-recall`
- `Claude-Codex-Gemini-to-IM`

Tier 1 means:

- install flow is owned here
- state is tracked here
- `doctor` and `reconfigure` should understand the component

## Tier 2: Semi-Adapted

Currently empty by design.

Tier 2 is reserved for future cases where a component deserves guided setup but not full lifecycle support.

## Tier 3: Catalog Only

All external MCPs and skills default to Tier 3 unless explicitly promoted.

Tier 3 means:

- this repository recommends the component
- this repository may provide links, key guidance, and notes
- this repository does not promise full install automation or lifecycle maintenance

Current examples include:

- Feishu official MCP
- GitHub MCP
- Vercel agent-browser
- Sequential Thinking
- OpenMemory (Mem0)
- Tavily MCP
- Exa MCP
- Firecrawl MCP
- Jina Reader
- Anthropic financial-services-plugins
