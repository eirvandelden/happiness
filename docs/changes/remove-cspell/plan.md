# Plan: Remove the cspell spell checker

Status: accepted.

## Files that change

Delete the `spelling` pre-commit job and the commented-out cspell `commit-msg` block (with the TODO line that belongs only to it) from `lefthook.yml`, and delete `cspell.json`.

## Proof

- `git grep -n -i -E '(^|[^a-z])cspell' -- ':!docs/changes'` prints nothing.
- The repo's own lint and tests stay as green as on main.
