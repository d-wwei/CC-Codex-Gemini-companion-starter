# Onboarding Flow

1. Detect whether the workspace already has install state or platform config.
2. Ask the user to choose:
   - fresh install
   - continue with existing info
   - partial setup
3. Show the open source disclaimer and require consent.
4. Prepare the memory layer and point the user to platform-specific next steps.
5. Confirm the initial memory interview.
6. Write a structured last-session checkpoint that can answer resume-style prompts quickly.
7. Create an `active-task.md` file as the highest-priority recovery anchor for live multi-step work.
8. Create a reusable resume checkpoint template under `.assistant/runtime/`.
9. Create an `interrupted-tasks.md` file for paused-task ordering, timestamps, and priority.
10. Embed a quick recall protocol into the default workflow rules so "continue / resume" prompts answer with task, progress, and next step first.
11. Enforce a two-stage recovery pattern: short recall first, interrupted-task list second.
12. Optimize first recovery for speed by checking the active task before broader scans.
13. Enforce language-aware recovery so the first reply follows the user's default language unless explicitly changed.
14. Enforce a strict three-section recovery format: A main task, B other interrupted tasks, C recovery options.
15. Insert divider lines between sections for faster scanning.
16. Within section A, require line 1 `task:`, line 2 `progress:`, line 3 `next step:`.
17. Within section B, require priority-sorted interrupted tasks, each with `task:`, `priority:`, `progress:`, `next step:`.
18. Offer numbered resume options so the user can continue the active task or switch directly to another paused task.
19. Localize recovery options to match the reply language.
20. Offer official IM bridge setup now or later.
21. If chosen, install the host-specific IM bridge skill and collect provider credentials one field at a time.
22. Offer MCP catalog review now or later.
23. Offer skills catalog review now or later.
24. Mark MCP and skills as self-managed when the user wants to defer native installation details.
25. Ask for one API key or token at a time when needed.
26. Print a summary and pending items.
