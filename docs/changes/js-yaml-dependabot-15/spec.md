# Spec: Clear npm security advisories and report new ones

From `intent.md` (2026-10-20). Status: accepted.

## Flagged concerns

- The earlier accepted spec (commit 09bcdf6, 2026-10-01) assumed Yarn. #132 replaced Yarn with npm, so this spec replaces it.
- `braces` 3.0.3 has a high advisory (GHSA-vfj7-8cjw-p6xm) with no fixed version. A check that blocks on high would fail on every push that changes `package-lock.json`, and in CI on every run. Etienne chose to block only on critical. The tradeoff: a new high advisory with a fix also does not block. It shows in the printed report and in Dependabot.
- Playbook rule 13 requires approval to edit `.github/workflows/ci.yml`. Accepting this spec is that approval for the one new job described below.
- Playbook rule 11: no dependency is added. `npm audit` comes with npm 11.12.1.

## Requirements

1. `package-lock.json` resolves these packages to at least the fixed version:
   - `js-yaml` 4.3.2
   - `source-map-js` 1.2.2
   - `brace-expansion` 5.0.12
   - `postcss-selector-parser` 7.1.6
   - `colord` 2.9.4
   - `fast-uri` 3.1.8
2. Only the lockfile entries that requirement 1 needs change. No `npm update` of all packages, no `npm audit fix --force`. `package.json` changes only if a parent's range blocks a fixed version, and then through an `overrides` entry.
3. `npm run stylelint` and `npx eslint .` still lint the repository after the update.
4. The lefthook pre-push hook runs `npm audit --audit-level=critical` when `package.json` or `package-lock.json` is in the push. A non-zero exit blocks the push.
5. CI runs `npm audit --audit-level=critical` in a new job in `.github/workflows/ci.yml`. A non-zero exit fails the workflow.
6. In both places the full audit report prints, also when it does not block.

## Design decisions

- Call `npm audit --audit-level=critical` directly from the hook and from CI. No wrapper script: npm sets a non-zero exit only at or above the given level, and prints the full report either way (verified: exit 0 today with 8 high and 3 moderate).
- The pre-push hook follows the existing `bundle-audit` command: `glob` on the two npm files, a `security` tag, and a `fail_text` with the `--no-verify` hint.
- The CI job follows the existing `i18n` job and the shared appkit workflow: `ubuntu-latest`, `actions/checkout@v7.0.1`, `actions/setup-node@v7` with Node 24, then the audit. `npm audit` reads only `package-lock.json`, so the job does not need `npm ci`.
- Fix the versions with a targeted `npm update <package>` per package, or an `overrides` entry when the parent range blocks the fix. The plan decides per package.

## Integration points

- `package-lock.json` (and `package.json` only for `overrides`).
- `lefthook.yml`, `pre-push` section.
- `.github/workflows/ci.yml`.
- stylelint and ESLint, which must still run.
- Dependabot alerts #24, #27, #30, #31, which close once this merges.
- PR #120 (Rails 8.1.4), which rebases on this change after it merges.

## Acceptance criteria

- `package-lock.json` lists `js-yaml` at 4.3.2 or later.
- `package-lock.json` lists `source-map-js` at 1.2.2 or later.
- `package-lock.json` lists `brace-expansion` at 5.0.12 or later wherever the 5.x line is used, and no version inside any of its three advisory ranges.
- `package-lock.json` lists `postcss-selector-parser` at 7.1.6 or later.
- `package-lock.json` lists `colord` at 2.9.4 or later and `fast-uri` at 3.1.8 or later.
- `npm audit` on the updated tree reports no advisory except the `braces` one.
- `npm run stylelint` and `npx eslint .` pass on the updated tree.
- A push that changes `package-lock.json` while only high advisories exist goes through, and the push output shows the audit report.
- A push that changes `package-lock.json` while a critical advisory exists is blocked by the pre-push hook.
- A push that changes neither `package.json` nor `package-lock.json` does not run the audit.
- The new CI job passes on this branch and prints the audit report.

---
Domain skills applied: dependencies.
