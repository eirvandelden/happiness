# Intent: Run Solid Queue in async mode inside Puma

Author: Etienne van Delden. Status: accepted (2026-10-26). Type: chore. Delivery: step-by-step.

## Problem

Production uses 490 MB for this app on CT104 (3 cores, 12 GB, about 12 apps). The Solid Queue Puma plugin forks a supervisor, a dispatcher, a scheduler and a worker. Each fork is a separate Ruby process with its own private memory. The app has 2 to 5 users, so the forks add memory and no useful throughput.

## Proposed outcome

Production runs Solid Queue as threads inside the Puma process. One Ruby process serves web requests and runs jobs. The expected saving is about 160 MB. Fizzy measured the forked supervisor, dispatcher and scheduler at 46, 56 and 56 MB private memory.

## Affected users and systems

- The production host CT104 (the memory budget it shares with about 12 apps).
- Background jobs: `ReminderJob` (web push, every 15 minutes), `Appkit::SessionExpiryJob` (daily), and the hourly clean-up of finished jobs.
- Users receive mood reminders as before.

## Constraints

- Etienne chose async on purpose, knowing the Solid Queue README recommends fork mode ("only use async if you know what you're doing").
- The queue database pool is shared by the worker threads (3), the dispatcher, the scheduler, the supervisor heartbeat and the Puma threads that enqueue jobs. It must be large enough for all of them.
- In async mode Solid Queue ignores `processes` in `config/queue.yml`.
- Do not edit `config/deploy.yml` unless the pool fix truly needs an environment variable. If it does, ask Etienne first.
- No deploy and no `kamal` commands. Etienne deploys himself.
- No dependency changes.
- Never read or print secrets.

## In scope

- `config/puma.rb`: `solid_queue_mode :async` on the line after `plugin :solid_queue`.
- `config/database.yml`: queue database `max_connections` large enough for the threads above.
- Find the cause of "Detected Solid Queue has gone away" in development, then verify locally with `SOLID_QUEUE_IN_PUMA=true`.
- Record the verification evidence.

## Out of scope

- `config/deploy.yml` (unless the pool fix needs an environment variable, then ask first).
- Fork mode, Puma worker count, Puma thread count, and other memory tuning.
- Any change to jobs, `config/recurring.yml` or `config/queue.yml` content.
- Making development run Solid Queue permanently, unless the cause of the local failure shows that the change needs it.
- Deploying.

## Acceptance criteria

- Booted with `SOLID_QUEUE_IN_PUMA=true`, `ps` shows one Ruby process for Puma and no solid-queue-supervisor, -dispatcher, -scheduler or -worker process.
- An enqueued job runs to completion.
- The scheduler loads the recurring tasks from `config/recurring.yml` and enqueues `ReminderJob`, and `Appkit::SessionExpiryJob` is among the loaded tasks.
- `/up` returns 200.
- The queue database pool covers all Solid Queue threads plus the Puma threads that enqueue jobs.
- The full test suite and every linter are green.

## Flagged concerns

- Async mode trades isolation for memory. A crash or a long job in a worker thread now shares the Puma process. Etienne accepted this tradeoff for the memory saving.

## Decisions

- Use async mode inside Puma — to save about 160 MB per app on a memory-limited host.
- Do not edit `config/deploy.yml` unless needed — Etienne deploys himself and the pool can live in `database.yml`.

## Open questions

None.
