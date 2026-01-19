# PM -> Apply -> Push -> CI Pipeline (Termux)

## Concept
- PM writes task into pm_ai/inbox/*.md
- Optional patch: same name .patch or .diff
- pm_loop.sh:
  - checkout main -> create branch ai/<taskid>
  - apply patch (if any)
  - run bin/git_runner.sh (safe commit/push)
  - move task to pm_ai/done/

## Commands
Create task:
  sh bin/pm_new_task.sh "title" <<'EOF'
  ...instruction...
  EOF

Run loop once:
  sh bin/pm_loop.sh

Notes
- Instruction-only task will just push branch (no changes) => runner gate will do nothing.
- Use git_runner_verbose.sh when debugging.
