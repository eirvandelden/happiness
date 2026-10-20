# Intent: Update dependencies to their latest versions

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

The app runs on old releases of its gems, its npm packages, Ruby and Bundler. It misses the bug fixes and security fixes in the newer releases.

Dependabot proposes each update as a separate PR. Ten PRs are open (#112, #113, #114, #116, #122, #124, #128, #129, #130, #131), and they pile up faster than they get merged.

On 2026-10-20, the state is:

- 33 gems are behind. All are minor or patch updates, except `marcel` 2.x, which Rails holds back.
- The personal gems from GitHub are behind their `main` branch: `appkit`, `mvpa-css`, `rubocop-eirvandelden` and `exception_notification-campfire-once`.
- `eslint` (10.8.1 → 10.13.0) and `stylelint` (17.14.1 → 17.16.0) are behind.
- `npm audit` reports 11 advisories in dev packages: 8 high and 3 moderate. Four of them are open Dependabot alerts: `js-yaml` (#24), `brace-expansion` (#27), `postcss-selector-parser` (#30) and `source-map-js` (#31).
- Ruby is 4.0.2; 4.0.7 is the newest. Bundler is 4.0.9; 4.0.23 is the newest.

## Proposed outcome

- Every gem, npm package, Ruby and Bundler is at the newest version that resolves.
- `npm audit` reports only `braces`, which has no fixed release.
- The app behaves as before for users and for the Android app.
- After the merge, Dependabot sees that the versions are current and closes its open PRs and alerts itself.

## Affected users and systems

- Users of the web app: sign-in, sessions and theming come from `appkit`, which changes.
- The Android app: it gets reminder pushes and fetches its navigation rules from `configurations/android_v1`.
- The production container: the Dockerfile's Ruby version changes.
- Developers: the linters (`rubocop-*`, `herb`, `eslint`, `stylelint`) change and can flag code that passes today.
- CI: it reads `.ruby-version`, so it picks up the new Ruby without a workflow change.

## Constraints

- Never skip a major version. `marcel` stays on 1.x, because Rails 8.1 Active Storage requires `marcel ~> 1.0`.
- Etienne explicitly asked to update all dependencies (rule 11). Do not add or remove a dependency without asking first.
- Etienne approved one Dockerfile edit: `ARG RUBY_VERSION` 4.0.2 → 4.0.7 (rule 13). No other deployment config or workflow file changes.
- Ruby 4.0.7 is already installed through rv. Install no system tooling.
- Personal gems stay unpinned and come from their GitHub `main` branch.
- `package.json` keeps its current ranges. No npm `overrides`.
- No deploy.

## In scope

- All gem.coop gems, direct and transitive.
- The personal git gems: `appkit`, `mvpa-css`, `rubocop-eirvandelden` and `exception_notification-campfire-once`.
- All npm packages, direct and transitive, in `package-lock.json`.
- Every `npm audit` advisory that a version inside the current `package.json` ranges fixes.
- Ruby 4.0.2 → 4.0.7 in `.ruby-version` and the Dockerfile.
- Bundler 4.0.9 → 4.0.23 in `Gemfile.lock`.
- Fixes for code that the new linter versions flag.
- Fixes for warnings from the new Brakeman and bundler-audit versions.
- Fixes for deprecation warnings that the new versions introduce.

## Out of scope

- `marcel` 2.x: it needs a Rails release that allows it.
- `braces` (GHSA-vfj7-8cjw-p6xm): no fixed release exists. Stylelint 18.0.0 drops it; that major upgrade is a follow-up change.
- An npm `overrides` entry or a fork of `braces`.
- The npm advisory check in CI and lefthook: the `js-yaml-dependabot-15` change keeps that.
- Changes to `.github/workflows/` or other deployment config, except the approved Dockerfile line.
- Closing the Dependabot PRs or alerts by hand.
- A deploy.

## Acceptance criteria

- `bundle outdated` lists no gem, except `marcel`.
- `npm outdated` lists no package.
- `npm audit` lists only `braces`.
- Each open Dependabot PR proposes a version that this branch already has, or an older one.
- `.ruby-version` and the Dockerfile name Ruby 4.0.7, and `Gemfile.lock` says it was bundled with Bundler 4.0.23.
- The personal gems resolve to the newest commit on their `main` branch.
- The full test suite passes, system tests included, and `npm test` passes.
- `bin/rubocop`, `npx eslint .`, `npm run stylelint` and `bundle exec herb lint` pass, with no linter disable comments added.
- Brakeman and bundler-audit report no warnings.
- The app boots and the tests run without new deprecation warnings.
- The production Docker image builds locally.
- In `bin/dev`, a user signs in, logs a mood, and sees that mood in their history.
- The Android app gets the same navigation rules from `configurations/android_v1` as before the update.

## Flagged concerns

- New linter versions can flag code that passes today. Fixing that code grows the change; holding a linter back leaves it behind. Chosen side: fix it in this change, in separate commits.
- The accepted intent in `js-yaml-dependabot-15` also bumps `js-yaml`. Chosen side: this change bumps `js-yaml` with all other packages. The other change keeps only the npm advisory check.
- `braces` has no fixed release. An override to a fork clears the advisory but runs unreviewed third-party code in the linter. Chosen side: accept the advisory and wait for stylelint 18.
- The draft change `bump-brakeman` fixes the failing CI job `scan_ruby` by bumping Brakeman alone. Chosen side: that change lands first (rule 25), and this branch rebases on it.

## Open questions

None.
