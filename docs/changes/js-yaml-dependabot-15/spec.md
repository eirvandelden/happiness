# Spec: Clear js-yaml advisory and report npm advisories

From `intent.md` (2026-10-01). Status: accepted.

## Flagged concerns

- The intent names only `js-yaml`, but `yarn audit` also reports two high advisories on `brace-expansion` (GHSA-qhr7-859c-m2p7, GHSA-6j4f-fj2g-mc7p) through `eslint > minimatch`. A blocking gate would fail on them at once. Etienne decided to fix them in this change, so the gate lands green.
- Playbook rule 13 requires approval to edit `.github/workflows/ci.yml`. Etienne chose a new job there; accepting this spec is that approval.
- Playbook rule 11: the check adds no dependency. It uses `yarn audit`, which ships with the installed Yarn 1.22.22.

## Requirements

1. `yarn.lock` resolves `js-yaml` to 4.3.2 or later.
2. `yarn.lock` resolves `brace-expansion` to a version that clears both advisories (5.0.11 or later where the 5.x line is used).
3. Only the lockfile entries needed for 1 and 2 change. No `yarn upgrade` of all packages. `package.json` ranges change only if a targeted update cannot work without it.
4. Stylelint and ESLint still lint the repository after the update.
5. A script, `bin/npm-audit`, runs `yarn audit --level high` and exits non-zero when the audit finds a high or critical advisory.
6. The script exits zero and still prints the report when only low or moderate advisories exist.
7. The lefthook pre-push hook runs the script when `yarn.lock` or `package.json` is in the push, and a failure blocks the push.
8. CI runs the script as a new job in `.github/workflows/ci.yml`, and a failure fails the workflow.

## Design decisions

- `yarn audit --level high` still sets the moderate bit in its exit code (observed exit 12 with 4 moderate and 5 high). The script therefore masks the exit code to the high (8) and critical (16) bits instead of passing it through.
- The script lives in `bin/` beside `bin/bundler-audit`, so hook and CI call one command.
- The pre-push hook uses the same glob style as the existing `bundle-audit` command, with `fail_text` in the same format and the `--no-verify` hint.
- The CI job mirrors the existing `i18n` job: `ubuntu-latest`, `actions/checkout` at the pinned version already in the file, then Node and `yarn install --frozen-lockfile`, then `bin/npm-audit`.
- Fix versions with `yarn upgrade <package>` scoped to one package, or a `resolutions` entry only if the parent range blocks the patched version. The plan decides which.

## Integration points

- `yarn.lock` (and possibly `package.json`).
- `bin/npm-audit` (new).
- `lefthook.yml`, `pre-push` section.
- `.github/workflows/ci.yml`.
- `stylelint`, `eslint`: must still run.
- PR #120 (Rails 8.1.4) rebases on this change after it merges.

## Acceptance criteria

- `yarn.lock` lists `js-yaml` at 4.3.2 or later.
- `yarn.lock` lists no `brace-expansion` version inside either vulnerable range.
- `yarn stylelint` and `yarn eslint .` still pass on the repository after the update.
- `bin/npm-audit` on the updated tree exits zero.
- `bin/npm-audit` exits non-zero when the audit reports a high advisory, shown with a lockfile that pins `js-yaml` 4.3.1.
- `bin/npm-audit` exits non-zero when the audit reports a critical advisory.
- `bin/npm-audit` exits zero and prints the report when the audit reports only moderate advisories.
- Pushing a branch that changes `yarn.lock` with a high advisory present is blocked by the pre-push hook.
- A pull request whose `yarn.lock` has a high advisory fails the new CI job.

---
Domain skills applied: dependencies.
