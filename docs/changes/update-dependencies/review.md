# Review: update-dependencies

## Round 1 — 2026-11-07 07:42 UTC — ed94c7b

Compliance, acceptance criteria against proof:

- `bundle outdated` lists only the accepted rows → fails: it also lists `appkit` (see the first Important finding). `marcel`, `net-ssh` 8.x and `prism` 2.x are accepted departures.
- `npm outdated` lists nothing → `package-lock.json` pins eslint 10.14.0 and stylelint 17.16.0, but `npm outdated` in this worktree lists both (see the second Important finding).
- `npm audit` lists only the accepted advisory → holds: only `minimatch` GHSA-g3hv-75wg-m249 (departure 2026-11-06).
- Each open Dependabot PR is covered → holds for all 13 open PRs (#112–#148), including `appkit` 4c82e2e, `mvpa-css` 890d132 and `rubocop-eirvandelden` 32d259f (compare status `ahead`).
- Ruby and Bundler → `.ruby-version` and Dockerfile name 4.0.9; `BUNDLED WITH 4.0.24`.
- Personal gems at newest `main` → `exception_notification-campfire-once`, `mvpa-css` and `rubocop-eirvandelden` match; `appkit` does not.
- Navigation rules unchanged → `AndroidNavigationRulesTest#test_the_whole_response_is_the_contract_the_Android_app_parses`.
- Sign in, log a mood, see it in the history → `MoodHistoryTest#test_user_logs_a_mood_and_sees_it_in_their_history`.
- mvpa-css views → `Admin::DashboardTest#test_the_recent_logins_table_stacks_on_narrow_screens`, `Admin::UsersTest#test_the_users_table_stacks_on_narrow_screens`, `#test_the_user_form_puts_its_buttons_in_an_action_row`, `#test_each_deletable_user_has_a_delete_dialog`, `StateOfMindsTest#test_the_mood_form_puts_its_submit_in_an_action_row`, `#test_index_shows_entry_after_submission`, `PreferencesTest#test_the_preferences_form_puts_its_submit_in_an_action_row`, `AdminUsersTest#test_admin_deletes_a_user_through_the_confirmation_dialog`, `#test_cancelling_the_dialog_keeps_the_user`. All present.
- PWA media types → `PwaTest` both tests extended. Present.
- Invariants: `Gemfile`, `package.json`, `.rubocop_todo.yml`, `.github/`, `lefthook.yml`, `config/deploy.yml` and `production.rb` are unchanged. The lock adds only `rbs-inline` and `rubocop-rbs_inline` and removes only `rexml`. No disable comment is added. No existing test line is removed or weakened.
- Tests, Docker build and smoke run: not re-run on request; taken from the caller's report.

Findings:

- [ ] Important: `appkit` is not at its newest `main`. The lock has de56db4; `main` is d106f6b (PR #24 "navigation-hubs", merged 2026-11-06 21:13 UTC, 21 minutes after commit 901bc1e "Update appkit to de56db4"). `bundle outdated` lists `appkit`, which fails the acceptance criterion "The personal gems resolve to the newest commit on their `main` branch" and plan step 27. d106f6b replaces `appkit/shared/_nav` and adds `Appkit::Menu` plus locale keys. This app does not render `_nav`, but the bump still needs its own check run, or a recorded decision to stop at de56db4. — `Gemfile.lock:3` → fixed (Update appkit to d106f6b)
- [ ] Important: the worktree's `node_modules` does not match the lock. `node_modules/eslint` is 10.8.1 and `node_modules/stylelint` is 17.14.1 (`node_modules/.package-lock.json` written 2026-11-07 08:37 local time), while `package-lock.json` pins 10.14.0 and 17.16.0. `npm outdated` lists both. Any `npx eslint .` or `npm run stylelint` run in this worktree since then used the old linters. The lint proof for eslint 10.14.0 and stylelint 17.16.0 is not in evidence at the tip; run `npm ci` and both linters again. — `package-lock.json:832` → dismissed: environment only; npm ci reinstalled the locked versions and eslint and stylelint pass, no commit needed
- [ ] Nit: the signatures contradict each other. `User#time_zone` is signed `() -> ActiveSupport::TimeZone?`, but `current_reminder_window` calls `time_zone.now` with no nil guard. A type checker rejects that call. Either the return is not nilable here, or the caller needs a guard. — `app/models/user.rb:33` → fixed (Sign User#time_zone as never nil)
- [ ] Nit: the YARD tags and the new `#:` signatures name different types. `svg_mood_chart` and `svg_emotion_chart` say `@param entries [Array<StateOfMind>]` and `@return [String]`; the signature says `Enumerable[StateOfMind]` and `ActiveSupport::SafeBuffer`. The validators say `@param value [String]`; the signature says `untyped`. Two type sources that disagree mislead the reader. — `app/helpers/charts_helper.rb:17` → fixed (Match the YARD types to the inline signatures)
- [ ] Nit: `plan.md` `### Signatures` still says "Not affected: no Ruby class or public method is added or changed", while the diff adds `#:` signatures to 24 public methods. The 2026-10-29 departure records the decision, but the Design section was not updated to list the signatures. — `docs/changes/update-dependencies/plan.md:31` → fixed (docs: name the newest versions instead of commit hashes for update-dependencies)
- [ ] Nit: `plan.md` `## Proof` was not updated for the second sweep. It still expects "exactly those two rows" from `bundle outdated` (now three accepted: `marcel`, `net-ssh`, `prism`), "only `braces`" from `npm audit` (now `minimatch`), and Ruby 4.0.7 and Bundler 4.0.23. The departures under Design decisions supersede them, but the Proof lines as written fail. — `docs/changes/update-dependencies/plan.md:165` → fixed (docs: name the newest versions instead of commit hashes for update-dependencies)
- [ ] Nit: `AdminUsersTest` puts `def user_row` at the same indentation as `private`. The other tests in the diff indent methods under `private` (`AndroidNavigationRulesTest`), so the style is inconsistent. — `test/system/admin_users_test.rb:27` → fixed (Indent the admin users test helper under private)

Design pass: no Law of Demeter violation in the diff. No N+1 query: the admin users page renders one `<dialog>` per row from the same query, as `### Complexity` states. No `GLOSSARY.md` exists, so no avoided term applies. Security pass: the dialog's Delete is a `button_to` with the CSRF token; `<form method="dialog">` sends no request. Nothing found.

## Round 2 — 2026-11-07 08:03 UTC — 8aa1c11

New since round 1: commit 8aa1c11 "Update appkit to d106f6b" (`Gemfile.lock` only). No uncommitted change except this file.

Status of round 1, re-checked at 8aa1c11 (the `→` slots stay for `code-review` to close):

- Important, `appkit` not at newest `main`: resolved by "Update appkit to d106f6b". `git ls-remote` gives `main` = d106f6b, and `bundle outdated` no longer lists `appkit`. The bump adds `Appkit::Menu`, `_account_menu`, rewrites `_nav` and renames keys under `appkit.navigation`. This app renders only `_pwa_meta`, `_skip_link` and `_flashes`, and its `nav.home` key is its own (`config/locales/en.yml:102`). Nothing in the app depends on the changed parts.
- Important, `node_modules` out of step with the lock: resolved in the environment, with no commit. `node_modules` now has eslint 10.14.0 and stylelint 17.16.0, and `npm outdated` lists nothing.
- The five round 1 nits: unchanged at 8aa1c11.

Compliance, re-run at 8aa1c11:

- `bundle outdated` → only `marcel`, `net-ssh` 8.x and `prism` 2.x, all accepted departures. Holds.
- `npm outdated` → empty. Holds.
- `npm audit` → only `minimatch` GHSA-g3hv-75wg-m249 and its three dependents in the eslint chain (departure 2026-11-06). Holds.
- Personal gems at newest `main` → all four hold now.
- Full suite → `bin/rails test`: 100 runs, 371 assertions, 0 failures, 0 errors, 0 skips (system tests included). `npm test`: 0 failures.
- Linters → `bin/rubocop` (96 files, no offenses), `npx eslint .`, `npm run stylelint`, `bundle exec herb lint`: all exit 0.
- Brakeman → no warnings. `bin/bundler-audit` → no vulnerabilities.
- Docker build and the `bin/dev` smoke run: not re-run in this round.

Findings:

- [ ] Nit: the second-sweep departure still names `appkit` de56db4 as the target, and no departure records the move to d106f6b. Step 12 ("Revision equals its `git ls-remote` main") covers the commit, but the plan text now disagrees with the lock. — `docs/changes/update-dependencies/plan.md:74` → fixed (docs: name the newest versions instead of commit hashes for update-dependencies)

Design pass: the new commit changes only `Gemfile.lock`. No new public method, no Law of Demeter violation, no query. No `GLOSSARY.md` exists. Security pass: appkit d106f6b adds a model and two partials this app does not render. Nothing found.

## Round 3 — 2026-11-07 10:22 UTC — 6c713f8

New since round 2: commit 6c713f8 "docs: name the newest versions instead of commit hashes for update-dependencies" (`intent.md` and `plan.md` only). No uncommitted change except this file. No code changed, so the round 2 test, lint, Brakeman and bundler-audit results still apply to the code.

Status of earlier findings:

- Round 1 nits on `plan.md` `### Signatures` and `## Proof`, and the round 2 nit on the appkit departure: closed by 6c713f8. The text now names the newest versions.
- Round 1 nits on `User#time_zone`, the `charts_helper.rb` YARD tags and the `AdminUsersTest` indentation: unchanged at 6c713f8, still open.

Compliance, re-run at 6c713f8:

- `bundle outdated` → fails: it lists `appkit` and `rubocop-eirvandelden` next to the accepted `marcel`, `net-ssh` 8.x and `prism` 2.x rows (see the two Important findings).
- `npm outdated` → empty. Holds.
- `npm audit` → only `minimatch` GHSA-g3hv-75wg-m249, 4 moderate (departure 2026-11-06). Holds.
- Personal gems at newest `main` → fails for two of four. `git ls-remote` gives `appkit` 839ca4a (lock d106f6b) and `rubocop-eirvandelden` f5cca63 (lock d91402e). `mvpa.css` 06778c8 and `exception_notification-campfire-once` 2452ef9 match.
- Ruby 4.0.9 and the newest Bundler → unchanged since round 2. Holds.

Findings:

- [ ] Important: `rubocop-eirvandelden` is not at its newest `main`. The lock has d91402e; `main` is f5cca63 (PR #14 "module-self-colon-form", merged 2026-11-07 10:07 UTC). The merge adds three cops (`InvalidTypesAllowingColon`, `KeywordSeparatorAllowingColon`, `ModuleSelfColonForm`), changes `config/default.yml` and the gemspec. That can change `bin/rubocop` results on the new `#:` signatures and the lock's dependency set. Fails the acceptance criterion "The personal gems resolve to the newest commit on their `main` branch" and plan step 27. — `Gemfile.lock:29` → fixed (Update rubocop-eirvandelden to f5cca63)
- [ ] Important: `appkit` is not at its newest `main`. The lock has d106f6b; `main` is 839ca4a (PR #28 "ci-lint-on-ubuntu-latest", merged 2026-11-07 09:56 UTC). The eight commits touch only `.github/workflows/ci.yml`, `.github/workflows/rails-ci.yml` and `CHANGELOG.md`, so no runtime code changes. This app's CI already runs `rails-ci.yml@main`. The bump still needs its own commit to meet the same criterion. — `Gemfile.lock:3` → fixed (Update appkit to 839ca4a)
- [ ] Nit: 6c713f8 moved the intent's Ruby and Bundler criteria to the second sweep, but two criteria beside them still state the first sweep. "`bundle outdated` lists no gem, except `marcel`" omits `net-ssh` and `prism`; "`npm audit` lists only `braces`" now reads `minimatch`. The plan departures supersede them, but the intent as written fails. — `docs/changes/update-dependencies/intent.md:68` → fixed (docs: match the update-dependencies criteria to the second sweep)
- [ ] Nit: the `net-ssh` departure says "7.3.8 is the newest 7.x release", but the lock has 7.3.9 (commit 110abdb). Step 20 still says "to 7.3.6". The second-sweep departure covers the move, but the `net-ssh` line now disagrees with the lock. — `docs/changes/update-dependencies/plan.md:70` → fixed (docs: match the update-dependencies criteria to the second sweep)

Design pass: 6c713f8 changes only Markdown. No public method, no Law of Demeter violation, no query. No `GLOSSARY.md` exists. Security pass: neither personal gem bump is in the lock yet; the `appkit` range is CI-only. Nothing found.

Not reviewed in this round: uncommitted edits to `app/helpers/charts_helper.rb`, `app/models/user.rb`, `app/validators/email_validator.rb` and `app/validators/url_validator.rb` appeared in the working tree after this round started. The next round covers them.

## Round 4 — 2026-11-07 10:26 UTC — 6c2b63a

New since round 3: a736609 "Sign User#time_zone as never nil", 38ba9bd "Match the YARD types to the inline signatures", af2d4bf "Indent the admin users test helper under private", a8d4148 "Update rubocop-eirvandelden to f5cca63", b54875a "Update appkit to 839ca4a" and 6c2b63a "docs: match the update-dependencies criteria to the second sweep". These include the uncommitted edits round 3 left unreviewed. No uncommitted change except this file.

Status of earlier findings: every finding from rounds 1 to 3 is closed in its slot. Re-checked at 6c2b63a:

- `User#time_zone` is signed `() -> ActiveSupport::TimeZone`. The comment's claim holds: `timezone` has `presence: true` and `inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }` (`app/models/user.rb:18`), so `current_reminder_window` needs no nil guard.
- `charts_helper.rb` YARD tags now say `Enumerable<StateOfMind>` and `ActiveSupport::SafeBuffer`; both validators say `ActiveModel::Validations` and `Object`. They match the `#:` lines.
- `AdminUsersTest#user_row` is indented under `private`, as in `AndroidNavigationRulesTest`.
- `intent.md` criteria name `net-ssh` 8.x, `prism` 2.x and `minimatch`; `plan.md` departures and step 20 name the newest 7.x for `net-ssh`.

Compliance, re-run at 6c2b63a:

- `bundle outdated` lists only the accepted rows → holds: `marcel` 2.1.0, `net-ssh` 8.1.1, `prism` 2.1.0.
- `npm outdated` lists nothing → holds (empty, exit 0).
- `npm audit` lists only `minimatch` → holds: GHSA-g3hv-75wg-m249 through `@eslint/config-array`, `eslint` and `@eslint/js`, 4 moderate. The only fix is `npm audit fix --force` to `eslint` 9.39.5, a downgrade.
- Each open Dependabot PR is covered → holds: the same 13 open PRs (#112–#148) as round 1, no new one.
- Ruby and Bundler → `.ruby-version` and Dockerfile name 4.0.9; `BUNDLED WITH 4.0.24`. Holds.
- Personal gems at newest `main` → holds for all four: `appkit` 839ca4a, `rubocop-eirvandelden` f5cca63, `mvpa.css` 06778c8 and `exception_notification-campfire-once` 2452ef9 equal their `git ls-remote` `main`.
- Navigation rules, mood logging and history, mvpa-css views, PWA media types → the tests listed in round 1 are present and pass.
- Invariants: no existing test is removed, skipped or weakened; no linter disable comment; `Gemfile`, `package.json`, `.github/` and `.rubocop_todo.yml` are unchanged.
- Full suite → `bin/rails test:all`: 100 runs, 371 assertions, 0 failures, 0 errors, 0 skips. `npm test`: 0 failures.
- Linters → `bin/rubocop` (96 files, no offenses, on `rubocop-eirvandelden` f5cca63 with its three new cops), `npx eslint .`, `npm run stylelint`, `bundle exec herb lint`: all exit 0.
- Brakeman → no warnings. `bin/bundler-audit` → no vulnerabilities.
- Docker build and the `bin/dev` smoke run: not re-run in this round.

Bugs pass: the new commits change comments, signatures, one test's indentation, two git revisions in `Gemfile.lock` and Markdown. No behaviour changes. Nothing found.

Design pass: every public method in the diff has a `#:` signature, and `### Signatures` covers them as one group ("every public method and `attr_*` outside tests"). No Law of Demeter violation, no N+1 query. No `GLOSSARY.md` exists. Nothing found.

Security pass: `appkit` d106f6b → 839ca4a touches only CI workflows and `CHANGELOG.md`. `rubocop-eirvandelden` is a development-only linter. Nothing found.

No findings in this round.
