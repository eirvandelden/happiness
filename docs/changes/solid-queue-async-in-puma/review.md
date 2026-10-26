# Review: Run Solid Queue in async mode inside Puma

## Round 1 — 2026-10-26T15:01:46Z — 0c59128

No `REVIEW.md` or `REVIEW.local.md` exists, so this round uses the default passes: Bugs, Security, Compliance, Design. The diff is `config/puma.rb`, `config/database.yml` and the change folder. Nothing is uncommitted.

Checks run on 0c59128: `bin/rails test` (87 runs, 0 failures), `bin/rubocop`, `npm test`, `npx eslint .`, `npm run stylelint` and `bundle exec herb lint` all exit 0.

- [ ] Nit: Async mode loses the fork-mode liveness link, and `plan.md`'s Risks do not say so. In fork mode the plugin's `monitor_solid_queue` stops Puma when the supervisor process dies, so the container restarts. In async mode nothing watches the supervise thread: if it raises (for example, a SQLite busy timeout in `release_claimed_jobs_by` while it replaces a dead worker thread), `create_thread` reports the error through `Rails.error` and the thread ends. Puma keeps serving, `/up` stays 200, and dead worker, dispatcher or scheduler threads are no longer replaced, so reminders stop without a restart. Add this to Risks so the tradeoff is recorded next to "Isolation is lost", or dismiss it with a reason. — `docs/changes/solid-queue-async-in-puma/plan.md:147` → dismissed: Etienne keeps the accepted plan as it is and will fix this if the dead-thread case becomes a real problem (2026-10-26).

### Bugs

- `plugin :solid_queue` loads the plugin file during DSL evaluation, so `solid_queue_mode` exists on the next line. The `if` block keeps development and test free of a `NoMethodError` (green suite, recorded development boot).
- In async, non-standalone mode the supervisor registers no signal handlers (`Signals` runs only `if: :standalone?`), so Puma keeps its own TERM and INT handling. Shutdown goes through `after_stopped` → `AsyncSupervisor#stop`.
- The queue pool count matches solid_queue 1.7.0: supervisor heartbeat and maintenance `TimerTask`s, dispatcher maintenance `TimerTask`, worker pool of 3, one `ScheduledTask` per recurring task (3). The sum is 19, and the comment says so.
- The jobs (`ReminderJob`, `Appkit::SessionExpiryJob`, `Appkit::PushNotificationJob`, `SendWelcomeEmailJob`) use neither `Rails.cache` nor Action Cable, so the cache and cable pools of 5 do not gain job threads.

### Security

Nothing found. No secrets, no `config/deploy.yml` or `config/environments/production.rb` change, no dependency change.

### Compliance

| Acceptance criterion | Evidence |
|---|---|
| One Ruby process, no `solid-queue-*` process | `verification.md` → Processes (`ps`, and `SolidQueue::Process` kinds all on the Puma pid) |
| An enqueued job runs to completion | `verification.md` → Enqueued job runs |
| Scheduler loads recurring tasks, enqueues `ReminderJob`, `Appkit::SessionExpiryJob` loaded | `verification.md` → Recurring tasks |
| `/up` returns 200 | `verification.md` → /up |
| Queue pool covers Solid Queue threads plus Puma threads | `config/database.yml` count comment; `verification.md` → Pools |
| Full test suite and every linter green | Not recorded in `verification.md`; this round ran all six and each exits 0 |

- No tests are expected: both changed files are configuration (playbook rule 3), and `plan.md`'s Proof names checks, not tests. No existing test was weakened, skipped or deleted.
- `verification.md` states openly that step 1 ran after the `config/puma.rb` edit, so the fork-mode "Detected Solid Queue has gone away" line was not reproduced. The recorded cause (no `solid_queue_*` tables in the development database) explains the fork-mode exit too, so the intent's "find the cause" item holds.
- Markdown prose follows rule 26 (one line per paragraph).

### Design

- No public Ruby method added, so `### Signatures` has nothing to cover. No call chains, no queries in loops.
- No glossary exists, so no `Avoid:` terms apply.
