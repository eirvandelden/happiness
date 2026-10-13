# Plan: Update dependencies to their latest versions

From `intent.md` (2026-10-06). Status: accepted.

## Context

The app runs on old releases of its gems, yarn packages, Ruby (4.0.2) and Bundler (4.0.9). Eleven Dependabot PRs are open and pile up. This change moves every dependency to the newest version that resolves, keeps the behaviour the same for web users and the Android app, and lets Dependabot close its own PRs after the merge.

State measured on 2026-10-06, in this worktree:

- `bundle outdated` lists 32 gems: `appkit`, `bigdecimal`, `bootsnap`, `brakeman`, `exception_notification-campfire-once`, `fugit`, `herb` (0.10.3 → 0.11.0), `image_processing`, `io-console`, `jwt`, `lefthook`, `marcel` (stays 1.x), `msgpack`, `mvpa-css`, `net-imap`, `net-protocol` (0.3.0 → 0.4.0), `net-smtp`, `net-ssh`, `okcomputer`, `parallel`, `rdoc`, `regexp_parser`, `rubocop-eirvandelden`, `rubocop-minitest`, `rubocop-performance`, `rubocop-rails`, `rubyzip`, `selenium-webdriver`, `solid_cable`, `thruster`, `unicode-display_width`, `unicode-emoji`.
- `yarn outdated` lists `eslint` 10.8.1 → 10.12.0 and `stylelint` 17.14.1 → 17.16.0. `yarn.lock` has `js-yaml` 4.3.1 (via stylelint → cosmiconfig) and `brace-expansion` 5.0.9 (via eslint → minimatch).
- Personal gem `main` heads: `appkit` fd86991, `mvpa.css` 412cc74, `rubocop-eirvandelden` 1e2e033, `exception_notification-campfire-once` 2452ef9.
- Ruby 4.0.7 is installed through rv. It has Bundler 4.0.9, 4.0.20 and 4.0.21 installed, not 4.0.22.
- `bin/rubocop` and `bundle exec herb lint` pass today (herb exit 0, with 2 existing hints in `app/views/layouts/application.html.erb`). `node_modules` is not installed in this worktree yet.

## Design decisions

- **Update in groups, one commit per group.** Each group is one logical change and gets its own test run, so a failure points at one group. Order: Ruby, Bundler, each personal gem, the linter gems, herb, brakeman, the remaining gems, the yarn packages.
- **Linter and deprecation fixes go in their own commits**, after the bump that caused them (intent's flagged concern). No linter disable comments. No new entries in `.rubocop_todo.yml`; that file is a disable list too.
- **Final gem sweep is a plain `bundle update`.** The dependencies skill forbids it without explicit instruction; the intent gives that instruction ("update all dependencies"), and Etienne confirmed it for this sweep on 2026-10-06. By that step the targeted groups are done, so the sweep moves only the remaining gems. `marcel` stays on 1.x because Active Storage requires `marcel ~> 1.0`.
- **`Gemfile` and `package.json` do not change.** Every target version already fits the current constraints (`image_processing ~> 2.0` allows 2.2.0; `^10.8.1` allows 10.12.0; `^17.14.1` allows 17.16.0). The dependencies skill says not to tighten constraints without a reason.
- **`yarn upgrade` (no arguments) for the JavaScript side.** It re-resolves every package, transitive ones included, to the newest version within the `package.json` ranges and rewrites `yarn.lock`. `--latest` is not used, since it rewrites `package.json`.
- **Two characterization tests come first** (Etienne confirmed both on 2026-10-06). They pin behaviour the intent says must not change, and they pass before the update. They are proven able to fail by a temporary mutation, then they guard every later step:
  - The whole `configurations/android_v1` response body, `settings` included. The existing tests check `rules` but not `settings`.
  - A system test: a user signs in, logs a mood with a note, and sees that note in their history. No test covers the log-then-history path through a browser today.
- **Bundler 4.0.22 gets installed as a gem into Ruby 4.0.7** by `bundle update --bundler=4.0.22`. The intent puts the Bundler bump in scope, so this counts as approved. Ruby itself is not installed or switched by hand: rv picks up `.ruby-version`.
- **Baseline before changing anything.** Test, system test and boot output on today's versions go to `tmp/update-dependencies/baseline-*.log` (`tmp/` is gitignored). The "no new deprecation warnings" check diffs against that baseline.
- **Bundler's git cache for `exception_notification-campfire-once` under Ruby 4.0.2 tracks a stale branch** (`ai/execute-pasted-plan`), and `bundle outdated` reported a wrong head (ba8d2ec). Ruby 4.0.7 has its own cache. The personal-gem check therefore uses `git ls-remote`, never `bundle outdated`.

## Integration points

- `appkit` engine: sign-in, sessions, session transfer, push subscriptions, theming. Its 18 new commits change no runtime behaviour: two method reorders, one extracted local variable, rubocop config, tests, and the removal of a development dependency (`rubocop-rails-omakase`) from its gemspec. No new migrations.
- `mvpa-css`: 26 new commits, none in its stylesheets (lint, docs, CI, cspell removal).
- `rubocop-eirvandelden`: 3 new commits, all in the RSpec layer (`config/rspec.yml`). This app inherits `default.yml`, `rails.yml` and `capybara.yml` only.
- `exception_notification-campfire-once`: 2 new commits; its gemspec now requires Ruby >= 3.4.
- Android app: reads `configurations/android_v1` (`app/views/navigation_rules/show.json.jbuilder`). Public contract; its JSON must stay byte-for-byte equal in content.
- Production image: `Dockerfile` pulls `ruby:4.0.7-slim` and installs Bundler 4.0.22 from `BUNDLED WITH`.
- CI: `.github/workflows/ci.yml` calls `eirvandelden/appkit/.github/workflows/rails-ci.yml@main`, which reads `.ruby-version`. No workflow change.
- Dependabot: after the merge it compares its 11 PRs with `main` and closes them.

## Files that change

- `.ruby-version` — `ruby-4.0.2` → `ruby-4.0.7`.
- `Dockerfile` — line 3 only: `ARG RUBY_VERSION=4.0.2` → `4.0.7` (approved in the intent, rule 13).
- `Gemfile.lock` — all gem versions, the four git revisions, `BUNDLED WITH 4.0.22`, checksums.
- `yarn.lock` — all JavaScript package versions.
- `test/integration/android_navigation_rules_test.rb` — one new test for the whole response body.
- `test/system/mood_logging_test.rb` — new system test for sign in → log mood → history.
- Unknown until run: app, view or test files that the new rubocop-rails, rubocop-minitest, rubocop-performance, herb, brakeman, eslint or stylelint versions flag, or that raise new deprecation warnings. Each fix gets its own commit naming the tool and version.

Must not change: `Gemfile`, `package.json`, `.rubocop_todo.yml`, `.github/**`, `config/deploy.yml`, `config/environments/production.rb`, `lefthook.yml`, any other `Dockerfile` line.

## Order of work

Run every command from `/Users/etienne.vandelden/Developer/happiness/.worktrees/update-dependencies`. Commit messages end with the session's attribution line.

1. Set up the worktree: `yarn install --frozen-lockfile`, `bundle install`, `bin/rails db:prepare`.
2. Walking skeleton — run the acceptance checks and watch them fail: `bundle outdated` (lists 32 gems), `yarn outdated` (lists eslint and stylelint), `grep -A1 '^BUNDLED WITH' Gemfile.lock` (4.0.9), `cat .ruby-version` (4.0.2).
3. Record the baseline on today's versions, after `mkdir -p tmp/update-dependencies`:
   - `bin/rails test:all 2> tmp/update-dependencies/baseline-test.log` (system tests included; must be green).
   - `bin/rails runner 'puts :booted' 2> tmp/update-dependencies/baseline-boot.log`.
   - `yarn test`, `bin/rubocop`, `yarn eslint .`, `yarn stylelint "app/assets/stylesheets/**/*.css"`, `bundle exec herb lint`, `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`, `bin/bundler-audit check --update`. Any failure here is pre-existing: stop and report it (playbook rule 25), do not fold it into this change.
4. Add `AndroidNavigationRulesTest` test "the whole response is the contract the Android app parses": `assert_equal({ "settings" => {}, "rules" => [ { "patterns" => [ ".*" ], "properties" => { "context" => "default", "uri" => "hotwire://fragment/web", "pull_to_refresh_enabled" => true } } ] }, navigation_rules)`. Run it: green. Change one expected value, run, watch it fail, restore. Commit: `Pin the whole Android navigation rules response`.
5. Add `test/system/mood_logging_test.rb`, `MoodLoggingTest` test "user logs a mood and sees it in their history": `system_sign_in_as(users(:user))`, visit `new_state_of_mind_path`, set the range input, check `#emotion_happy`, fill the note with a unique string, submit, then `assert_current_path state_of_minds_path` and `assert_text` the note. Run it: green. Assert a different note, watch it fail, restore. Commit: `Cover logging a mood and seeing it in the history`.
6. Ruby: set `.ruby-version` to `ruby-4.0.7` and `Dockerfile` line 3 to `ARG RUBY_VERSION=4.0.7`. Confirm `ruby -v` prints 4.0.7; if rv does not switch, stop and report (playbook rule 8). `bundle install` (native extensions rebuild; `Gemfile.lock` must stay unchanged). `bin/rails test:all`. Commit: `Update Ruby to 4.0.7`.
7. Bundler: `bundle update --bundler=4.0.22`. `bundle -v` prints 4.0.22; the lock diff is `BUNDLED WITH` only. `bin/rails test`. Commit: `Update Bundler to 4.0.22`.
8. `bundle update appkit --conservative`. The lock revision equals `git ls-remote https://github.com/eirvandelden/appkit.git refs/heads/main`. `bin/rails test:all` (sign-in, session and preference tests matter most). Commit: `Update appkit to <sha>`.
9. Same for `mvpa-css` (`eirvandelden/mvpa.css`). Commit.
10. Same for `exception_notification-campfire-once`; `test/integration/exception_notification_test.rb` first, then `bin/rails test`. Commit.
11. Linters: `bundle update rubocop-eirvandelden rubocop-minitest rubocop-performance rubocop-rails` (also moves `parallel`, `regexp_parser`, `unicode-*`). `bin/rubocop`. Commit the bump. Fix any new offense in a separate commit per cop family. If a fix would change behaviour, or the cop conflicts with the playbook, stop and ask.
12. `bundle update herb` (0.10.3 → 0.11.0, a 0.x minor that can turn on new rules; no `.herb.yml` pins the rule set). `bundle exec herb lint`. Commit; fixes in a separate commit.
13. `bundle update brakeman` (8.0.6 → 8.1.0). `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`. Commit; fixes in a separate commit.
14. Sweep: `bundle update`. Read `git diff Gemfile.lock`: only version bumps, no gem added or removed (if one is, stop and ask, rule 11), `marcel` still 1.x, no major bump. `bin/rails test:all`. Commit: `Update the remaining gems`.
15. JavaScript: `yarn upgrade`. Expected diff: `yarn.lock` only. If `package.json` changed, restore it with `git checkout package.json`, run `yarn install`, then `yarn install --frozen-lockfile` must pass. `yarn outdated` lists nothing. `yarn eslint .`, `yarn stylelint "app/assets/stylesheets/**/*.css"`, `yarn test`. Commit: `Update the yarn packages`. Lint fixes in separate commits.
16. Deprecations: rerun step 3's test and boot commands into `tmp/update-dependencies/after-*.log`. Compare `grep -iE 'deprecat|warning:'` between baseline and after, ignoring path and Ruby-version differences. Fix each new warning from this app's code in its own commit. A new warning raised inside a gem, with no app-side fix, gets reported to Etienne instead.
17. Production image: `docker build -t happiness:update-dependencies .` succeeds. Do not push the image. Do not run kamal.
18. Manual smoke: `bin/rails db:seed`, start `bin/dev`, and with the `run` skill sign in as `user@localhost`, log a mood, open the history, and see it there. `curl -s localhost:3000/configurations/android_v1` matches the body pinned in step 4.
19. Final checks, right before the push: every line of `## Proof` passes. Re-run the personal-gem `git ls-remote` check; if a `main` moved, repeat that gem's step. Re-read the full diff against `main` (rule 21). Then run the `review` skill (rule 16).

## Risks

- **New linter rules flag code** (rubocop-rails 2.36 → 2.38, herb 0.10 → 0.11, eslint, stylelint). The fixes grow the diff. The intent chose to fix them here, in separate commits. Rejected: holding a linter back, a `.herb.yml` version lock, or new `.rubocop_todo.yml` entries.
- **`net-protocol` 0.3 → 0.4** is a 0.x minor under `net-imap`/`net-smtp`/`net-ssh`. Mail delivery could break; `test/mailers/user_mailer_test.rb` and the full suite guard it.
- **`appkit` changes sign-in and sessions.** Its diff is refactor-only, and the system tests plus `test/integration/{auth,sessions}_test.rb` cover it.
- **Native extensions** (`sqlite3`, `bootsnap`, `msgpack`, `bigdecimal`, `io-console`) rebuild for Ruby 4.0.7. A build failure stops step 6; report it, do not install system libraries.
- **`ruby:4.0.7-slim` and Bundler 4.0.22 must exist upstream.** The Docker build in step 17 proves both.
- **Conflict with `js-yaml-dependabot-15`.** Both changes touch `yarn.lock`. Whichever merges second rebases and regenerates `yarn.lock` with `yarn upgrade`.
- **A personal gem's `main` moves before the merge.** Step 19 re-checks it; Dependabot would otherwise open a new PR.
- **`yarn stylelint` with no arguments lints nothing** (stylelint reads empty stdin and exits 0). Every check here passes the glob `"app/assets/stylesheets/**/*.css"`.
- **`bin/bundler-audit --update` alone skips `config/bundler-audit.yml`**: the wrapper adds `--config` only for `check` or no arguments. Use `bin/bundler-audit check --update`.
- Rejected: one commit per gem (about 32 commits, the noise this change removes); a single commit for everything (a failure would not point at a cause).

## Proof

- `bundle outdated` lists no gem, except `marcel` → `bundle outdated`: one row, `marcel`.
- `yarn outdated` lists no package → `yarn outdated`: no table.
- `yarn.lock` resolves `js-yaml` ≥ 4.3.2 and `brace-expansion` ≥ 5.0.12 → `yarn why js-yaml`, `yarn why brace-expansion`.
- Each open Dependabot PR proposes a version this branch has, or an older one → `grep` in `Gemfile.lock`/`yarn.lock` for the semver ones: #104 image_processing ≥ 2.1.0, #112 js-yaml ≥ 4.3.2, #114 bootsnap ≥ 1.26.0, #116 selenium-webdriver ≥ 4.49.0, #118 herb ≥ 0.10.4, #119 lefthook ≥ 2.1.14, #122 brace-expansion ≥ 5.0.12. For the git ones, `gh api repos/eirvandelden/<repo>/compare/<pr-sha>...<locked-sha> --jq .status` prints `ahead` or `identical`: #105 exception_notification-campfire-once 2452ef9, #108 appkit fa8eead, #113 rubocop-eirvandelden 1e2e033, #121 mvpa.css 53caa59.
- `.ruby-version` and `Dockerfile` name Ruby 4.0.7; lock bundled with 4.0.22 → `cat .ruby-version`, `grep RUBY_VERSION= Dockerfile`, `grep -A1 '^BUNDLED WITH' Gemfile.lock`.
- Personal gems resolve to the newest `main` commit → for each of the four, the `revision:` in `Gemfile.lock` equals `git ls-remote https://github.com/eirvandelden/<repo>.git refs/heads/main`.
- Full suite passes, system tests included, and `yarn test` passes → `bin/rails test:all`, `yarn test`.
- Linters pass with no disable comments added → `bin/rubocop`, `yarn eslint .`, `yarn stylelint "app/assets/stylesheets/**/*.css"`, `bundle exec herb lint`; `git diff main -- . ':!docs' | grep -E '^\+.*(rubocop:disable|eslint-disable|stylelint-disable|herb:disable)'` prints nothing; `git diff main -- .rubocop_todo.yml` is empty.
- Brakeman and bundler-audit report no warnings → `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`, `bin/bundler-audit check --update`.
- No new deprecation warnings at boot or in tests → step 16's baseline/after diff is empty.
- Production image builds → `docker build -t happiness:update-dependencies .` exits 0.
- In `bin/dev`, a user signs in, logs a mood, and sees it in their history → `test/system/mood_logging_test.rb` `MoodLoggingTest#test_user_logs_a_mood_and_sees_it_in_their_history`, plus step 18's manual run.
- The Android app gets the same navigation rules as before → `test/integration/android_navigation_rules_test.rb` `AndroidNavigationRulesTest#test_the_whole_response_is_the_contract_the_Android_app_parses`, green before step 6 and after step 15.

Per changed file, the unit tests expected:

- `test/integration/android_navigation_rules_test.rb`: `the whole response is the contract the Android app parses`.
- `test/system/mood_logging_test.rb`: `user logs a mood and sees it in their history`.
- Files changed by linter or deprecation fixes: no new tests; the existing tests for that file stay green. A fix that changes behaviour is out of bounds (stop and ask).

Test setup: fixture `users(:user)` (password `password`) and `SessionTestHelper#system_sign_in_as`. System tests run headless Chrome (`ApplicationSystemTestCase`). No faked boundaries.

## Out of scope

- `marcel` 2.x.
- The npm advisory check in CI and lefthook (`js-yaml-dependabot-15`).
- `.github/workflows/`, `.github/dependabot.yml`, `config/deploy.yml`, and any `Dockerfile` line except `RUBY_VERSION`.
- Closing the Dependabot PRs by hand. A deploy.
- Importmap pins: `config/importmap.rb` pins only gem-shipped files, which the gem updates cover.
- The two existing herb hints in `app/views/layouts/application.html.erb`.
- Follow-ups to propose on their own branches (rule 21): `dependabot.yml` has no `npm` ecosystem (the dependencies skill asks for all ecosystems); `AGENTS.md` says `yarn stylelint` lints, but bare it lints nothing; `AGENTS.md` says `bin/dev` runs `Procfile.dev`, but it runs `bin/rails server` only.

---
Domain skills applied: dependencies. Not applicable: rails-upgrade (no Rails change), ruby-upgrade (Ruby patch release only).
