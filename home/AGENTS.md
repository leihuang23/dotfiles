# global agent instructions

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.

# Shared skills

Single source of truth for agent skills:

- Source: `~/.agents/skills`
- All agent harnesses should symlink their `skills` directory to that source.
- To install a skill from a GitHub subfolder:
  `install-skill https://github.com/<owner>/<repo>/tree/<ref>/<path-to-skill>`
  (copies into `~/.agents/skills/<skill-id>/`; use `--force` to overwrite).
- Or copy/clone manually into `~/.agents/skills/<skill-id>/` (must include `SKILL.md`).

# RTK (Rust Token Killer)

Always prefix shell commands with `rtk` so command output is compressed before it hits the LLM context (typically 60-90% fewer tokens on git/test/build/lint).

```bash
rtk git status
rtk git diff
rtk cargo test
rtk npm test
rtk pytest -q
rtk ls .
rtk grep "pattern" .
rtk gh pr list
```

Meta: `rtk gain` (savings stats), `rtk proxy <cmd>` (raw unfiltered), `rtk --version`.

Full reference: `~/.codex/RTK.md` (same content as managed `home/RTK.md`).
