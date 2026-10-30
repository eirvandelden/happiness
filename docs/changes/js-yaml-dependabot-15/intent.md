# Intent: Clear npm security advisories and report new ones

Author: Etienne van Delden de la Haije. Status: accepted. Type: bugfix.

## Problem

The app's JavaScript development tools (stylelint, ESLint) depend, indirectly, on npm packages with known security advisories. `package-lock.json` resolves them to vulnerable versions:

- `js-yaml` 4.3.1, high (GHSA-2883-xcg3-v3hh, Dependabot #24; was #15 before the move from Yarn to npm in #132).
- `source-map-js` 1.2.1, high (GHSA-68fv-2mgg-jv7q, Dependabot #31).
- `brace-expansion` 5.0.9, high and moderate (GHSA-6j4f-fj2g-mc7p, GHSA-qhr7-859c-m2p7, GHSA-q2hr-2g5m-vwhr, Dependabot #27).
- `postcss-selector-parser` 7.1.5, moderate (GHSA-rj75-hqrm-r3gf, Dependabot #30).
- `colord` 2.9.3 and `fast-uri` 3.1.7, moderate (Dependabot dismissed these on its own as #23 and #28).

Nobody working on the app sees npm advisories before GitHub reports them. `bin/bundler-audit` checks only gems. Neither CI nor the git hooks check npm packages. The first alert was found by chance, while pushing PR #120 (Rails 8.1.4).

`braces` 3.0.3 also has a high advisory (GHSA-vfj7-8cjw-p6xm). No fixed version exists, so this change cannot clear it.

## Proposed outcome

- `package-lock.json` resolves each package above to a version outside its advisory's vulnerable range. Stylelint and ESLint still lint the repository.
- A known critical npm advisory fails CI and blocks a push through the lefthook pre-push hook.
- High, moderate and low advisories are printed but do not block, so `braces` does not block every push.

## Affected users and systems

- Developers of this app: local tooling and git hooks.
- CI: `.github/workflows/ci.yml`.
- Not the running app or its users: all affected packages are used only by development tools.
- PR #120 (Rails 8.1.4) rebases on this change once it merges.

## Constraints

- Must land on `main` before PR #120.
- Changing `.github/workflows/ci.yml` needs explicit approval (playbook rule 13).
- No new dependency (playbook rule 11). `npm audit` comes with npm.
- No `npm update` of all packages and no `npm audit fix --force`. Update only what the fixes need.

## Success

- `npm audit` reports none of the advisories listed under Problem, except `braces`.
- The new check prints the audit report and blocks only on a critical advisory, before push and in CI.

## Open questions

None.
