# Verification: Run Solid Queue in async mode inside Puma

Run on 2026-10-26 in the worktree, local production environment (`RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1`, `SOLID_QUEUE_IN_PUMA=true`, port 3000).

## Development failure cause

`SOLID_QUEUE_IN_PUMA=true bin/rails server -p 3011` in development:

```
SolidQueue-1.7.0 Error registering Supervisor(async) ... error: "ActiveRecord::StatementInvalid Could not find table 'solid_queue_processes'"
Exiting
```

Development sets no `solid_queue.connects_to` and has no queue database. `SolidQueue::Record` uses the primary development database, which has no `solid_queue_*` tables, so the supervisor fails during boot.

Limit of this evidence: the boot ran after the `config/puma.rb` edit, so it ran in async mode. The plan asked for fork mode, where the plugin logs "Detected Solid Queue has gone away". I could not reproduce that line. Rails `-c` takes a rackup file, not a Puma config. Port 3001 was already used by another app, so I used 3011.

## Processes

`ps -o pid,ppid,command -ax | grep -E 'puma|solid-queue' | grep -v grep`:

```
21570 21553 puma 8.0.2 (tcp://0.0.0.0:3000) [solid-queue-async-in-puma]
```

One Puma process for this app. The `solid-queue-fork-supervisor` line (pid 46522) belongs to another app on port 3001.

`SolidQueue::Process.pluck(:kind, :pid)`:

```
[["Supervisor(async)", 21570], ["Dispatcher", 21570], ["Worker", 21570], ["Scheduler", 21570]]
```

## Enqueued job runs

`Appkit::SessionExpiryJob.perform_later`, then `SolidQueue::Job.where(class_name: "Appkit::SessionExpiryJob").last.finished_at`:

```
2026-10-26 14:42:43.367497000 UTC +00:00
```

## Recurring tasks

`SolidQueue::RecurringTask.pluck(:key, :class_name)`:

```
[["clear_solid_queue_finished_jobs", nil], ["mood_reminders", "ReminderJob"], ["appkit_session_expiry", "Appkit::SessionExpiryJob"]]
```

`SolidQueue::Job.where(class_name: "ReminderJob").pluck(:created_at, :finished_at)`, read at 14:46 UTC:

```
[[2026-10-26 14:45:00.093112000 UTC +00:00, 2026-10-26 14:45:00.298723000 UTC +00:00]]
```

The scheduler enqueued `ReminderJob` at the 14:45 quarter hour and a worker thread finished it.

## Shutdown

`kill -TERM` on the Puma pid stopped the process within 20 seconds, and no `solid-queue` process remained. Exit code 143 is the signal.

## Development without `SOLID_QUEUE_IN_PUMA`

`bin/rails server -p 3011` booted, `/up` returned 200 and the log has no `NoMethodError`.

## /up

`curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/up` printed `200`.

## Pools

```
{"queue" => 20, "primary" => 10}
```

The server log has no "needs at least" warning.
