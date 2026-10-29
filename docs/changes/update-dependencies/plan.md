# Plan: Update dependencies to their latest versions

From `intent.md` (2026-10-20). Status: accepted.

## Context

The app runs on old releases of its gems, npm packages, Ruby 4.0.2 and Bundler 4.0.9. Thirteen Dependabot PRs are open (#112, #114, #122, #130, #131, #133–#140), and four Dependabot alerts are open (#24 js-yaml, #27 brace-expansion, #30 postcss-selector-parser, #31 source-map-js). This change moves every dependency to the newest version that resolves. It keeps the behaviour the same for web users and the Android app. It moves the app's views to the new mvpa-css styles, which Etienne added on 2026-10-21. After the merge, Dependabot closes its own PRs and alerts.

State measured on 2026-10-21 in this worktree, with a full `bundle lock --update` and `npm update` simulated in a scratch copy:

- Gems that move: `appkit` ed6f302 → 9b5b30d, `mvpa-css` cdc8355 → 2be440b, `rubocop-eirvandelden` a168e3d → 6d41c35, `bootsnap` 1.25.0 → 1.26.0, `brakeman` 8.0.6 → 8.1.0, `date` 3.5.1 → 3.6.0, `fugit` 1.13.0 → 1.14.0, `herb` 0.11.0 → 0.11.1, `json` 3.0.2 → 3.1.0, `jwt` 3.2.0 → 3.3.0, `lefthook` 2.1.11 → 2.2.2, `msgpack` 1.8.4 → 1.8.5, `net-imap` 0.6.6 → 0.6.8, `net-protocol` 0.3.0 → 0.4.0, `net-smtp` 0.5.1 → 0.5.2, `net-ssh` 7.3.3 → 7.3.6, `okcomputer` 1.19.2 → 1.20.0, `parallel` 2.1.0 → 2.3.0, `prettyprint` 0.2.0 → 0.2.1, `regexp_parser` 2.12.0 → 2.13.1, `rubocop` 1.91.0 → 1.92.0, `rubocop-capybara` 3.0.0 → 3.1.0, `rubocop-minitest` 0.40.0 → 0.41.0, `rubocop-performance` 1.26.1 → 1.27.0, `rubocop-rails` 2.36.0 → 2.38.0, `rubyzip` 3.4.1 → 3.7.0, `selenium-webdriver` 4.47.0 → 4.51.0, `sqlite3` 2.9.6 → 2.10.1, `thruster` 0.1.26 → 0.1.27, `unicode-display_width` 3.2.0 → 3.3.0, `unicode-emoji` 4.2.0 → 4.3.0, `uri` 1.1.1 → 1.1.2.
- Gems that appear: `rbs-inline` 0.14.0 and `rubocop-rbs_inline` 2.0.0, new dependencies of `rubocop-eirvandelden` main. Its cops run only in files that start with `# rbs_inline: enabled`; no file here does. Gem that disappears: `rexml`, which `selenium-webdriver` 4.51 no longer needs.
- After the sweep, `bundle outdated` still lists `marcel` 2.1.0 (Active Storage needs `marcel ~> 1.0`) and `net-ssh` 8.0.0 (`kamal` 2.12 needs `net-ssh ~> 7.3`; `net-scp` and `net-sftp` need `< 8.0.0`).
- `exception_notification-campfire-once` main is 2452ef9, which the lock already has. Under Ruby 4.0.2, Bundler's git cache for it is checked out on a stale branch (`ai/execute-pasted-plan`) and resolves ba8d2ec. Under Ruby 4.0.7, the cache is on `main` and resolves 2452ef9.
- `npm update` keeps `package.json` unchanged and moves `eslint` 10.8.1 → 10.13.0, `stylelint` 17.14.1 → 17.16.0, `js-yaml` → 4.3.2, `brace-expansion` → 5.0.12, `postcss-selector-parser` → 7.1.7, `source-map-js` → 1.2.2, plus `colord` and `fast-uri`. `npm audit` then lists only `braces`.
- Ruby 4.0.7 is installed through rv, with Bundler 4.0.23 already installed.
- The Dependabot PRs for `appkit`, `mvpa-css` and `rubocop-eirvandelden` pass `test`, `system-test` and `lint` in CI. Only `scan_ruby` fails, on every PR and on `main`: `bin/brakeman` runs with `--ensure-latest`, and Brakeman 8.0.6 is not the latest. The separate change `bump-brakeman` fixes that. Its intent is still a draft in `.worktrees/bump-brakeman`.

## Design

### Domain terms

No new domain terms. The plan uses the intent's words: **personal gems** (`appkit`, `mvpa-css`, `rubocop-eirvandelden`, `exception_notification-campfire-once`) and **navigation rules** (the JSON at `configurations/android_v1`). There is no `GLOSSARY.md` yet, and this change adds no term to it.

### Diagrams

Not affected: no class, table, message or state changes. Lockfiles, one version pin and view markup change.

### Signatures

Not affected: no Ruby class or public method is added or changed. Only test methods are added.

Not checked: happiness has no Steep or rbs_rails setup.

### Complexity

Not affected: no new query and no new request path. The admin users page renders one `<dialog>` per user row, in the same single query.

### Invariants

- `Gemfile` and `package.json` stay byte-identical to `main`. Enforced by the commit check script (`git diff --quiet main -- Gemfile package.json`).
- The navigation rules body stays equal to `{"settings" => {}, "rules" => [...]}`. Enforced by `AndroidNavigationRulesTest`'s new whole-body test.
- Every commit is green on the full suite, system tests, `npm test`, every linter, Brakeman and bundler-audit. Enforced by `tmp/update-dependencies/check.sh` before each commit, and by `git rebase -x` over the whole branch at the end.
- No added line carries a linter disable comment, and `.rubocop_todo.yml` does not change. Enforced by the same script.
- A gem commit's `Gemfile.lock` diff moves only its named gem and the versions that gem forces. Enforced by reading each diff before committing; a forced extra version is named in the commit message.
- No gem appears or disappears except `rbs-inline`, `rubocop-rbs_inline` (added) and `rexml` (removed). Enforced by reading each lock diff; any other one stops the work (rule 11).
- After the last gem and npm commit, `bundle lock --update` and `npm update` produce no diff. Checked in the final step.

### Alternatives

- **Chosen: one gem or one npm package per commit**, about 40 commits, each one green. A failure after any commit points at one dependency.
- Rejected: three sweep commits (Ruby and Bundler, all gems, all npm packages). It is the smallest diff to review, but a regression cannot be bisected inside the 30-gem commit.
- Rejected: about 12 grouped commits (each personal gem, the linter family, the rest). A failure in a group still has many causes.

## Design decisions

- **Conflicts with `intent.md`, each decided by Etienne on 2026-10-21:**
  - `net-ssh` is a second accepted `bundle outdated` row, beside `marcel`. It goes to 7.3.6 and stays on 7.x until `kamal` allows 8. The intent's criterion said only `marcel`.
  - `rbs-inline` and `rubocop-rbs_inline` may be added and `rexml` may be removed (intent constraint: ask first). No other gem may appear or disappear.
  - The views adopt the new mvpa-css styles. The intent said the app behaves as before; the app now looks different on purpose. Adopted: stacking admin tables, action-row footers, Delete through a `<dialog>`, and `<time>` in the history list. The push "Enable reminders" button stays `type="button"` and turns plain. The pull-down menu and title-bar rules need `main > header nav`, which this app does not have, so they are left out.
- **Precondition: `bump-brakeman` lands first** (intent's flagged concern, rule 25). This branch then rebases on `main` with the `sync` skill. The baseline cannot be green before that, because `bin/brakeman --ensure-latest` fails.
- **Ruby before any `bundle update`.** Under Ruby 4.0.2 the stale git cache resolves the wrong `exception_notification-campfire-once` revision. The personal-gem check uses `git ls-remote`, never `bundle outdated`.
- **Per-gem commands.** A runtime gem: `bundle update <gem> --conservative`, so shared dependencies stay put. `rubocop`: `bundle update rubocop` without `--conservative`, so its own dependencies (`parallel`, `regexp_parser`, `unicode-*`) move in the same commit. A personal gem: `bundle update <gem>`. Install gems with `bi`, never `bundle install`.
- **Characterization tests come first, on the old versions.** Each one passes, is proven able to fail by a temporary mutation, and then guards every later commit. They cover the navigation rules body (`settings` is unchecked today), sign in → log mood → history (no system test today), and `/manifest` and `/service-worker` (appkit main makes them inherit the host `ApplicationController`, with its `allow_browser versions: :modern` and `before_action :set_locale`).
- **The mvpa-css view work follows the mvpa-css bump**, one commit per view group, each with its tests first. The Delete dialog opens with the HTML invoker attributes `commandfor` and `command="show-modal"`. There is no JavaScript, and `turbo_confirm` goes away on that button. appkit's `_confirm_dialog` partial does not fit: it is one shared, script-filled dialog with `type="button"` controls and a `<nav>`, not the mvpa pattern.
- **Linter and deprecation fixes go in their own commits**, after the bump that caused them, named after the tool and version. No disable comments. No new `.rubocop_todo.yml` entries.
- **`Gemfile`, `package.json` and `.github/` do not change.** Every target fits the current constraints. `npm update` is used without arguments (never `--save`, never `--latest`).
- **The full sweep is allowed.** Rule 11 forbids `bundle update` without explicit instruction. The intent gives that instruction ("update all dependencies"). The final `bundle lock --update` runs as a check only; it must change nothing.
- **`crass` goes first (departure, 2026-10-26).** The step 5 baseline failed `bin/bundler-audit` on `crass` 1.0.7 (GHSA-pq4g-8rxf-4g29, fixed in 1.0.8), an advisory published after the plan. `crass` is a patch bump inside the sweep, so it is the first commit; every later commit then has a green baseline.
- **Baseline before changing anything.** Test and boot output on today's versions go to `tmp/update-dependencies/baseline-*.log` (`tmp/` is gitignored). The "no new deprecation warnings" check diffs against it.
- **`npm run stylelint` takes the glob.** Bare `npm run stylelint` lints nothing. Every check runs `npm run stylelint -- "app/assets/stylesheets/**/*.css"`.

## Integration points

- `appkit` 9b5b30d: sign-in, sessions, session transfer, push subscriptions, theming. Runtime changes: `app_name` accepts a string or a callable (this app sets a callable); the manifest and the service worker inherit the host `ApplicationController` and send `Cache-Control: max-age=0, private, must-revalidate`; the service worker cache name changes per appkit commit; gemspec floors move to railties `~> 8.1`, turbo-rails `~> 2.0`, importmap-rails `~> 2.2`, web-push `~> 3.1`, rqrcode `~> 3.2`, okcomputer `~> 1.20`. It ships RBS in `sig/`. This app already includes `Appkit::Authentication` in `ApplicationController` (appkit upgrading step 4). The view this app overrides, `app/views/appkit/preferences/edit.html.erb`, changed upstream only in whitespace.
- `mvpa-css` 2be440b: button hierarchy (a `type="button"` control is plain; a submit and a `DELETE` form button stay filled and red), the `<footer>` action row in forms and dialogs, dialog styles, stacking tables (`data-stack`), `main` as an inline-size container, `max-inline-size: 100%` on tables. The flashes container already renders outside `<main>` (mvpa upgrading step 9).
- `rubocop-eirvandelden` 6d41c35: adds `rubocop-rbs_inline` in opt-in mode, `Layout/LeadingCommentSpace: AllowRBSInlineAnnotation`, and switches YARD cops off.
- Android app: reads `configurations/android_v1` (`app/views/navigation_rules/show.json.jbuilder`). A public contract; its parsed JSON must stay equal.
- Production image: `Dockerfile` pulls `ruby:4.0.7-slim`. Bundler 4.0.23 comes from `BUNDLED WITH`.
- CI: `.github/workflows/ci.yml` calls `eirvandelden/appkit/.github/workflows/rails-ci.yml@main`, which reads `.ruby-version`. No workflow change.
- Dependabot: after the merge it compares its open PRs and alerts with `main` and closes them.
- `bump-brakeman` and `js-yaml-dependabot-15`: both touch the same lockfiles. Whichever merges after this branch rebases and regenerates its lockfile.

## Files that change

- `test/integration/android_navigation_rules_test.rb` — one test for the whole response body.
- `test/system/mood_history_test.rb` — new: sign in → log mood → history.
- `test/integration/pwa_test.rb` — manifest and service worker answer 200 with their media types, without a redirect.
- `.ruby-version` — `ruby-4.0.2` → `ruby-4.0.7`.
- `Dockerfile` — line 3 only: `ARG RUBY_VERSION=4.0.2` → `4.0.7` (approved in the intent, rule 13).
- `Gemfile.lock` — every gem version, three git revisions, `RUBY VERSION`, `BUNDLED WITH 4.0.23`, checksums.
- `package-lock.json` — every npm package version.
- `app/views/admin/dashboard/index.html.erb`, `app/views/admin/users/index.html.erb` — stacking tables: `data-stack="medium"`, `role="table"`, `role="rowgroup"` on `thead` and `tbody`, `role="row"` on each `tr`, `role="columnheader"` on each `th`, `role="cell"` and `data-label` on each `td`, `aria-labelledby` pointing at the table's heading (give the heading an `id`), and `<time datetime>` around each date.
- `app/views/admin/users/index.html.erb` — the Delete `button_to` with `turbo_confirm` becomes a `type="button" class="button-danger"` "Delete…" trigger with `commandfor="delete-user-<id>" command="show-modal"`, and a `<dialog id="delete-user-<id>" aria-labelledby=...>` per deletable row: the confirm text, then a `<footer>` with `<form method="dialog"><button>Cancel</button></form>` and `button_to Delete, admin_user_path(user), method: :delete`.
- `app/views/admin/users/_form.html.erb` — the `<nav>` with submit and Cancel becomes a `<footer>` as the form's last child, in the order Cancel, Save.
- `app/views/state_of_minds/new.html.erb`, `app/views/appkit/preferences/edit.html.erb` — the submit moves into a `<footer>` as the form's last child.
- `app/views/state_of_minds/index.html.erb` — `recorded_at` in the history list is wrapped in `<time datetime="<iso8601>">`.
- `config/locales/en.yml`, `nl.yml`, `it.yml` — new keys for the dialog (the "Delete…" trigger, Cancel, Delete), only where an existing key does not fit. All three locales get each key.
- `test/integration/admin/dashboard_test.rb`, `test/integration/admin/users_test.rb`, `test/integration/state_of_minds_test.rb`, `test/integration/preferences_test.rb` — `assert_select` tests for the new markup.
- `test/system/admin_users_test.rb` — new: delete a user through the dialog, and cancel the dialog.
- Unknown until run: app, view or test files that a new linter version flags, or that raise a new deprecation warning. Each fix gets its own commit.

Must not change: `Gemfile`, `package.json`, `.rubocop_todo.yml`, `.github/**`, `config/deploy.yml`, `config/environments/production.rb`, `lefthook.yml`, any other `Dockerfile` line.

## Order of work

Run every command from `/Users/etienne.vandelden/Developer/happiness/.worktrees/update-dependencies`. Commit messages end with the session's attribution line.

1. Precondition: `bump-brakeman` is merged into `origin/main`. Check with `git fetch origin && git log --oneline origin/main | head` and its PR state. Not merged: stop and report; do not bump Brakeman here to get around it. Merged: rebase this branch on `origin/main` with the `sync` skill.
2. Set up: `npm ci`, `bi`, `bin/rails db:prepare`.
3. Write `tmp/update-dependencies/check.sh` (gitignored, never committed), `set -euo pipefail`: `bin/rails test:all`, `npm test`, `bin/rubocop`, `npx eslint .`, `npm run stylelint -- "app/assets/stylesheets/**/*.css"`, `bundle exec herb lint`, `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`, `bin/bundler-audit check --update`, `bin/check_i18n_normalized`, `git diff --quiet main -- Gemfile package.json .rubocop_todo.yml`, and `! git diff main -- . ':!docs' | grep -E '^\+.*(rubocop:disable|eslint-disable|stylelint-disable|herb:disable)'`.
4. Walking skeleton: run the acceptance checks and watch them fail. `bundle outdated` lists about 33 gems; `npm outdated` lists `eslint` and `stylelint`; `npm audit` lists 11 advisories; `cat .ruby-version` is 4.0.2; `grep -A1 '^BUNDLED WITH' Gemfile.lock` is 4.0.9.
5. Baseline on today's versions: `mkdir -p tmp/update-dependencies`, `bin/rails test:all 2> tmp/update-dependencies/baseline-test.log`, `bin/rails runner 'puts :booted' 2> tmp/update-dependencies/baseline-boot.log`, then `tmp/update-dependencies/check.sh`. Any failure here is pre-existing: stop and report it (rule 25).
6. `AndroidNavigationRulesTest` test "the whole response is the contract the Android app parses": `get "/configurations/android_v1.json"`, then `assert_equal({ "settings" => {}, "rules" => [ { "patterns" => [ ".*" ], "properties" => { "context" => "default", "uri" => "hotwire://fragment/web", "pull_to_refresh_enabled" => true } } ] }, navigation_rules)`. Green. Change one expected value, watch it fail, restore. Commit: `Pin the whole Android navigation rules response`.
7. `test/system/mood_history_test.rb`, `MoodHistoryTest` test "user logs a mood and sees it in their history": `system_sign_in_as(users(:user))`, `visit new_state_of_mind_path`, `check "emotion_happy"`, fill the note with a unique string, `click_button I18n.t("state_of_minds.new.submit")`, `assert_current_path state_of_minds_path`, `assert_text` the note. Green. Assert a different note, watch it fail, restore. Commit: `Cover logging a mood and seeing it in the history`.
8. `PwaTest`: the existing two tests also assert `assert_response :success` with no redirect and the media type. Read each media type from a run on the old versions; do not guess it. Green; mutate one media type, watch it fail, restore. Commit: `Pin the manifest and service worker media types`.
9. Ruby: `.ruby-version` → `ruby-4.0.7`, `Dockerfile` line 3 → `ARG RUBY_VERSION=4.0.7`. `ruby -v` prints 4.0.7; if rv does not switch, stop and report (rule 8). `bi` (native extensions rebuild). `check.sh`. Commit: `Update Ruby to 4.0.7`.
10. Bundler: `bundle update --bundler=4.0.23`. `bundle -v` prints 4.0.23; the lock diff is `BUNDLED WITH` (and `RUBY VERSION` if present). `check.sh`. Commit: `Update Bundler to 4.0.23`.
11. `exception_notification-campfire-once`: `bundle update exception_notification-campfire-once`. The lock revision must equal `git ls-remote https://github.com/eirvandelden/exception_notification-campfire-once.git refs/heads/main`. If the lock does not change, there is no commit; record it.
12. `appkit`: `bundle update appkit`. Revision equals its `git ls-remote` main. `check.sh` (the PWA, auth, sessions and preferences tests matter most). Commit: `Update appkit to <sha>`. A host fix, if needed, is its own commit.
13. `mvpa-css` (`eirvandelden/mvpa.css`): same as step 12. Commit: `Update mvpa-css to <sha>`.
14. Adopt the mvpa-css styles, one commit each, tests first (red, then green):
    1. Stacking admin tables: in `test/integration/admin/dashboard_test.rb` and `users_test.rb`, assert `table[data-stack=medium][role=table][aria-labelledby]`, `thead[role=rowgroup]`, `tr[role=row]`, `th[role=columnheader]`, `td[role=cell][data-label]`, and `td time[datetime]` for `last_login_at`. Then change both views. Commit: `Stack the admin tables on narrow screens`.
    2. Action-row footers: assert `form > footer:last-child input[type=submit]` on the admin new and edit user pages, the log-mood form and the preferences form, and that the admin form has no `form > nav`. Then change `_form.html.erb`, `state_of_minds/new.html.erb`, `appkit/preferences/edit.html.erb`. Commit: `Put the form buttons in an action row`.
    3. Delete through a dialog: integration tests assert one `dialog[id^=delete-user-]` per deletable user, a `button[commandfor][command=show-modal]` trigger, `dialog footer form[method=dialog] button`, a `DELETE` form inside the dialog, and no `[data-turbo-confirm]`. `test/system/admin_users_test.rb` `AdminUsersTest`: test "admin deletes a user through the confirmation dialog" (click "Delete…" in the user's row, click Delete in the dialog, see the success notice, the email is gone) and test "cancelling the dialog keeps the user". Then change the view and locales. Commit: `Confirm user deletion in a dialog`.
    4. `<time>` in the history: assert `li time[datetime]` in `test/integration/state_of_minds_test.rb` "index shows entry after submission". Then change the view. Commit: `Mark mood times in the history`.
    5. Check by hand in `bin/dev` (step 26's session): the history page with its charts (main is now a size container), the preferences page, both admin tables at narrow and wide widths. Fix broken layout only, in its own commit.
15. Linter gems, with `rubocop-eirvandelden` last. First `bundle update rubocop` (also moves `parallel`, `regexp_parser`, `unicode-display_width`, `unicode-emoji`). `bin/rubocop`. Commit the bump; fix any new offense in its own commit per cop family. A fix that changes behaviour or conflicts with the playbook: stop and ask.
16. Same, one commit each with `--conservative`: `rubocop-capybara`, `rubocop-minitest`, `rubocop-performance`, `rubocop-rails`.
17. `bundle update rubocop-eirvandelden`. Revision equals its `git ls-remote` main. The lock gains `rbs-inline` and `rubocop-rbs_inline` and nothing else new. Commit, then fixes.
18. `bundle update herb --conservative`. `bundle exec herb lint`. Commit, then fixes.
19. `brakeman`: if the rebase in step 1 already brought 8.1.0, skip. Otherwise `bundle update brakeman --conservative`, commit, then fixes.
20. One commit each, `bundle update <gem> --conservative`, `check.sh` before every commit: `sqlite3`, `json` (step 6's test must stay green), `net-protocol`, `net-imap`, `net-smtp` (`test/mailers` and `test/integration/exception_notification_test.rb` must stay green), `net-ssh` (to 7.3.6; also `bundle exec kamal version` runs), `selenium-webdriver` (removes `rexml`; the system tests must stay green), `rubyzip`, `bootsnap`, `date`, `fugit`, `jwt`, `lefthook`, `msgpack`, `okcomputer`, `thruster`, `uri`, `prettyprint`. Skip a gem that an earlier step already moved. Commit message: `Update <gem> to <version>`.
21. Gem sweep check: `bundle lock --update` must leave `Gemfile.lock` unchanged. If it changes, `git checkout Gemfile.lock`, give each moved gem its own step-20 commit, and repeat. `bundle outdated` lists only `marcel` and `net-ssh`.
22. npm: `npm update eslint`, `npx eslint .`, `check.sh`, commit (`package-lock.json` only). Fixes in their own commits. Then `npm update stylelint`, same.
23. One commit each for the remaining packages with an advisory, skipping any that step 22 moved: `npm update js-yaml`, `brace-expansion`, `postcss-selector-parser`, `source-map-js`, `colord`, `fast-uri`. Then `npm update` with no arguments must leave `package-lock.json` unchanged; if not, give each moved package its own commit. `git diff main -- package.json` is empty. `npm outdated` lists nothing. `npm audit` lists only `braces`.
24. Deprecations: rerun step 5's test and boot commands into `tmp/update-dependencies/after-*.log`. Compare `grep -iE 'deprecat|warning:'` between baseline and after, ignoring path and Ruby-version differences. Fix each new warning from this app's code in its own commit. A new warning from inside a gem, with no app-side fix, goes to Etienne instead.
25. Production image: `docker build -t happiness:update-dependencies .` exits 0. Do not push the image. Do not run kamal against a server.
26. Manual smoke with the `run` skill: `bin/rails db:seed`, start `bin/dev`, sign in, log a mood, open the history and see it there; do step 14.5's checks. `curl -s localhost:3000/configurations/android_v1` parses to the body pinned in step 6.
27. Final checks right before the push: fetch and rebase on `origin/main` (`sync` skill). Re-run the four `git ls-remote` checks; if a `main` moved, repeat that gem's step. `git rebase -x tmp/update-dependencies/check.sh origin/main` passes on every commit. Every `## Proof` line passes. Re-read the full diff against `main` (rule 21). Then run the `review` skill (rule 16).

## Risks

- **`bump-brakeman` does not land.** Then no baseline is green and this change waits. Rejected: bumping Brakeman here as a workaround; the intent puts that in its own change.
- **About 40 full-suite runs**, system tests included, plus one `git rebase -x` pass at the end. Slow, but the cost Etienne chose for bisectability.
- **New linter rules flag code** (rubocop 1.92, rubocop-rails 2.38, rubocop-minitest 0.41, rubocop-performance 1.27, rubocop-capybara 3.1, herb 0.11.1, eslint 10.13, stylelint 17.16). The fixes grow the diff, in their own commits. The three personal-gem Dependabot PRs passed lint in CI, so few offenses are expected.
- **appkit's manifest and service worker now run the host's `before_action`s.** `allow_browser versions: :modern` could block an old user agent on `/manifest`. Step 8's tests and the existing PWA tests guard it.
- **mvpa-css's `main` container** can make wide content (the SVG charts) overflow. Step 14.5 checks by hand.
- **Invoker commands (`commandfor`, `command`)** need a current browser. `allow_browser versions: :modern` already requires one, and headless Chrome supports them. If the system test shows Chrome does not, stop and ask before adding a Stimulus controller.
- **`net-protocol` 0.3 → 0.4** is a 0.x minor under `net-imap`, `net-smtp` and `net-ssh`. Mail delivery could break; the mailer and exception notification tests guard it.
- **Native extensions** (`sqlite3`, `bootsnap`, `msgpack`, `bigdecimal`, `io-console`, `json`) rebuild for Ruby 4.0.7. A build failure stops step 9; report it, install no system library.
- **A personal gem's `main` moves before the merge.** Step 27 re-checks it.
- **Conflicts with `js-yaml-dependabot-15`** in `package-lock.json`. Whichever merges second rebases and regenerates the lockfile.

## Proof

- `bundle outdated` lists no gem, except `marcel` (and `net-ssh`, decided 2026-10-21) → check: `bundle outdated` lists exactly those two rows.
- `npm outdated` lists no package → check: `npm outdated` prints nothing.
- `npm audit` lists only `braces` → check: `npm audit` names only `braces` and the packages that depend on it (`micromatch`, `fast-glob`, `globby`, `stylelint`).
- Each open Dependabot PR proposes a version this branch has, or an older one → check: for every PR in `gh pr list --author app/dependabot --state open`, the locked version is ≥ its target: #112 js-yaml 4.3.2, #114 bootsnap 1.26.0, #122 brace-expansion 5.0.12, #130 postcss-selector-parser 7.1.6, #131 source-map-js 1.2.2, #133 sqlite3 2.10.0, #134 selenium-webdriver 4.51.0, #136 brakeman 8.1.0, #137 lefthook 2.2.2, #140 thruster 0.1.27; for the git ones (#135 rubocop-eirvandelden 6d41c35, #138 appkit 9b5b30d, #139 mvpa-css 2be440b), `gh api repos/eirvandelden/<repo>/compare/<pr-sha>...<locked-sha> --jq .status` prints `ahead` or `identical`. Any PR opened after 2026-10-21 is included.
- `.ruby-version` and the Dockerfile name Ruby 4.0.7; the lock is bundled with Bundler 4.0.23 → check: `cat .ruby-version`, `grep RUBY_VERSION= Dockerfile`, `grep -A1 '^BUNDLED WITH' Gemfile.lock`.
- The personal gems resolve to the newest `main` commit → check: for each of the four, the `revision:` in `Gemfile.lock` equals `git ls-remote https://github.com/eirvandelden/<repo>.git refs/heads/main`.
- The full test suite passes, system tests included, and `npm test` passes → check: `bin/rails test:all`, `npm test`.
- The linters pass with no disable comments added → check: `bin/rubocop`, `npx eslint .`, `npm run stylelint -- "app/assets/stylesheets/**/*.css"`, `bundle exec herb lint`; the disable-comment grep in `check.sh` prints nothing; `git diff main -- .rubocop_todo.yml` is empty.
- Brakeman and bundler-audit report no warnings → check: `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`, `bin/bundler-audit check --update`.
- The app boots and the tests run without new deprecation warnings → check: step 24's baseline/after diff is empty.
- The production Docker image builds locally → check: `docker build -t happiness:update-dependencies .` exits 0.
- In `bin/dev`, a user signs in, logs a mood, and sees it in their history → `test/system/mood_history_test.rb` `MoodHistoryTest#test_user_logs_a_mood_and_sees_it_in_their_history`, plus step 26's manual run.
- The Android app gets the same navigation rules as before → `test/integration/android_navigation_rules_test.rb` `AndroidNavigationRulesTest#test_the_whole_response_is_the_contract_the_Android_app_parses`, green from step 6 to the end.
- Invariant: every commit is green, enforced by `check.sh` → check: `git rebase -x tmp/update-dependencies/check.sh origin/main` in step 27.
- Invariant: `Gemfile` and `package.json` unchanged, enforced by `check.sh` → check: `git diff main -- Gemfile package.json` is empty.
- Invariant: the sweep is complete → check: `bundle lock --update` and `npm update` leave both lockfiles unchanged (steps 21 and 23).
- mvpa-css views (decided 2026-10-21): admin tables stack → `test/integration/admin/dashboard_test.rb` `Admin::DashboardTest#test_the_recent_logins_table_stacks_on_narrow_screens`, `test/integration/admin/users_test.rb` `Admin::UsersTest#test_the_users_table_stacks_on_narrow_screens`.
- mvpa-css views: form buttons sit in an action row → `Admin::UsersTest#test_the_user_form_puts_its_buttons_in_an_action_row`, `StateOfMindsTest#test_the_mood_form_puts_its_submit_in_an_action_row`, `PreferencesTest#test_the_preferences_form_puts_its_submit_in_an_action_row`.
- mvpa-css views: deleting a user asks in a dialog → `Admin::UsersTest#test_each_deletable_user_has_a_delete_dialog`, `test/system/admin_users_test.rb` `AdminUsersTest#test_admin_deletes_a_user_through_the_confirmation_dialog`, `AdminUsersTest#test_cancelling_the_dialog_keeps_the_user`.
- mvpa-css views: history times are marked up → `StateOfMindsTest#test_index_shows_entry_after_submission` (extended with `li time[datetime]`).

Per changed file, the unit tests expected, named as behaviour:

- `test/integration/android_navigation_rules_test.rb`: `the whole response is the contract the Android app parses`.
- `test/system/mood_history_test.rb`: `user logs a mood and sees it in their history`.
- `test/integration/pwa_test.rb`: `manifest is available without authentication` and `service worker is available without authentication`, each extended with no redirect and its media type.
- `test/integration/admin/dashboard_test.rb`: `the recent logins table stacks on narrow screens`.
- `test/integration/admin/users_test.rb`: `the users table stacks on narrow screens`, `the user form puts its buttons in an action row`, `each deletable user has a delete dialog` (none for the signed-in admin).
- `test/integration/state_of_minds_test.rb`: `the mood form puts its submit in an action row`; `index shows entry after submission` extended.
- `test/integration/preferences_test.rb`: `the preferences form puts its submit in an action row`.
- `test/system/admin_users_test.rb`: `admin deletes a user through the confirmation dialog`, `cancelling the dialog keeps the user`.
- Files changed by linter or deprecation fixes: no new tests; their existing tests stay green. A fix that changes behaviour stops the work.

Test setup: fixtures `users(:user)` and `users(:admin)` (password `password`); `SessionTestHelper#sign_in_as` for integration tests and `#system_sign_in_as` for system tests. System tests run headless Chrome (`ApplicationSystemTestCase`). No faked boundaries.

## Out of scope

- `marcel` 2.x and `net-ssh` 8.x: both wait for an upstream release that allows them.
- `braces` (GHSA-vfj7-8cjw-p6xm) and stylelint 18: a follow-up change.
- npm `overrides`, a fork of `braces`, any `package.json` or `Gemfile` edit.
- The npm advisory check in CI and lefthook (`js-yaml-dependabot-15`).
- `.github/workflows/`, `.github/dependabot.yml`, `config/deploy.yml`, and any `Dockerfile` line except `RUBY_VERSION`. A deploy.
- Closing Dependabot PRs or alerts by hand.
- The mvpa-css pull-down menu and title-bar rules (this app has no `main > header nav`), and any restyling of the push "Enable reminders" button.
- Adopting appkit's RBS signatures or Steep in this app.
- Importmap pins: `config/importmap.rb` pins only gem-shipped files, which the gem updates cover.

---
Domain skills applied: dependencies, rails-ui (mvpa-css view adoption), rails-testing. Not applicable: rails-upgrade (no Rails change), ruby-upgrade (Ruby patch release only).
