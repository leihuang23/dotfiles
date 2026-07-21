# RTK - Rust Token Killer

Token-optimized CLI proxy for shell commands (typically 60-90% savings on common dev ops).

## Rule

Always prefix shell commands with `rtk`.

```bash
rtk git status
rtk git diff
rtk git log -n 10
rtk ls .
rtk grep "pattern" .
rtk find "*.rs" .
rtk cargo test
rtk npm test
rtk pytest -q
rtk gh pr list
rtk docker ps
```

## Meta commands (call rtk directly)

```bash
rtk gain              # Token savings analytics
rtk gain --history    # Recent command savings
rtk discover          # Missed savings opportunities
rtk proxy <cmd>       # Raw command without filtering
rtk rewrite <cmd>     # Show how a command would be rewritten
```

## Notes

- Prefer `rtk` over dumping raw test/build/lint logs into context.
- Built-in agent tools (`read_file`, `grep`, `list_dir`) do not go through RTK; for huge shell listings/searches, use `rtk ls` / `rtk grep` / `rtk find`.
- If filtered output is insufficient after a failure, RTK may point at a full tee log, or use `rtk proxy <cmd>`.

## Verify

```bash
rtk --version
rtk gain
which rtk
```
