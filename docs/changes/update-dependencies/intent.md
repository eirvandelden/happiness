# Intent: Update dependencies to their latest versions

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

The app runs on old releases of its gems, its yarn packages, Ruby and Bundler. It misses the bug fixes and security fixes in the newer releases.

Dependabot proposes each update as a separate PR. Eleven PRs are open (#104, #105, #108, #112, #113, #114, #116, #118, #119, #121, #122), and they pile up faster than they get merged.

On 2026-10-06, the state is:

- 32 gems are behind. All are minor or patch updates.
- The personal gems from GitHub are behind their `main` branch: `appkit` by 18 commits, `mvpa-css` by 26, and `rubocop-eirvandelden` by 3.
- `eslint` (10.8.1 → 10.12.0), `stylelint` (17.14.1 → 17.16.0) and transitive packages such as `brace-expansion` and `js-yaml` are behind.
- Ruby is 4.0.2; 4.0.7 is the newest. Bundler is 4.0.9; 4.0.22 is the newest.

## Proposed outcome

- Every gem, yarn package, Ruby and Bundler is at the newest version that resolves.
- The app behaves as before for users and for the Android app.
- After the merge, Dependabot sees that the versions are current and closes those 11 PRs itself.

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
- No deploy.

## In scope

- All gem.coop gems, direct and transitive.
- The personal git gems: `appkit`, `mvpa-css`, `rubocop-eirvandelden` and `exception_notification-campfire-once`.
- All yarn packages, direct and transitive, including `js-yaml`.
- Ruby 4.0.2 → 4.0.7 in `.ruby-version` and the Dockerfile.
- Bundler 4.0.9 → 4.0.22 in `Gemfile.lock`.
- Fixes for code that the new linter versions flag.
- Fixes for warnings from the new Brakeman and bundler-audit versions.
- Fixes for deprecation warnings that the new versions introduce.

## Out of scope

- `marcel` 2.x: it needs a Rails release that allows it.
- The npm advisory check in CI and lefthook: the `js-yaml-dependabot-15` change keeps that.
- Changes to `.github/workflows/` or other deployment config, except the approved Dockerfile line.
- Closing the Dependabot PRs by hand.
- A deploy.

## Acceptance criteria

- `bundle outdated` lists no gem, except `marcel`.
- `yarn outdated` lists no package.
- `yarn.lock` resolves `js-yaml` to 4.3.2 or later and `brace-expansion` to 5.0.12 or later.
- Each of the 11 open Dependabot PRs proposes a version that this branch already has, or an older one.
- `.ruby-version` and the Dockerfile name Ruby 4.0.7, and `Gemfile.lock` says it was bundled with Bundler 4.0.22.
- The personal gems resolve to the newest commit on their `main` branch.
- The full test suite passes, system tests included, and `yarn test` passes.
- `bin/rubocop`, `yarn eslint .`, `yarn stylelint` and `bundle exec herb lint` pass, with no linter disable comments added.
- Brakeman and bundler-audit report no warnings.
- The app boots and the tests run without new deprecation warnings.
- The production Docker image builds locally.
- In `bin/dev`, a user signs in, logs a mood, and sees that mood in their history.
- The Android app gets the same navigation rules from `configurations/android_v1` as before the update.

## Flagged concerns

- New linter versions can flag code that passes today. Fixing that code grows the change; holding a linter back leaves it behind. Chosen side: fix it in this change, in separate commits.
- The accepted intent in `js-yaml-dependabot-15` also bumps `js-yaml`. Chosen side: this change bumps `js-yaml` with all other packages. The other change keeps only the npm advisory check.

## Open questions

None.
