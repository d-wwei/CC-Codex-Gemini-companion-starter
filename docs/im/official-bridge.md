# Official IM Bridge

Tier 1 IM bridge product:

- Repository: [d-wwei/Claude-Codex-Gemini-to-IM](https://github.com/d-wwei/Claude-Codex-Gemini-to-IM)

What this repository now owns:

- clone or update bridge source into the workspace bootstrap cache
- install the host-specific skill for Claude, Codex, or Gemini
- create and update the bridge `config.env`
- collect provider credentials one field at a time
- track configured provider and runtime home in install state
- run the bridge doctor from the installed host skill

Supported providers in the official flow:

- Telegram
- Discord
- Feishu / Lark

Provider notes:

- Telegram: asks for bot token, chat ID, optional allowed user IDs
- Discord: asks for bot token, optional allowed user IDs, channel IDs, guild IDs
- Feishu / Lark: asks for app ID, app secret, domain, optional allowed user IDs
