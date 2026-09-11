# Happiness

## What this is

A mood-tracking app. A signed-in user logs how they feel, several times a day, and later reviews that history. It ships as a web app (Hotwire) and pushes reminder notifications to a companion Android app, which also fetches its in-app navigation rules from this server so navigation can change without a new Android release.

## Domain

A `User` has a role (`user` or `admin`), a locale (`en`, `nl`, `it`), a timezone, and a theme (light/dark colors). Authentication, sessions, session transfer between devices, push subscriptions, and theming come from the `appkit` engine (`eirvandelden/appkit`), mounted at `/`; this app only overrides the session routes to restore its own flash messages.

A `StateOfMind` belongs to a `User` and is the mood entry itself: a `mood_score` from 1 to 5, an `entry_type` (`momentary` or `daily`), a `recorded_at` timestamp, a free-text `note`, and two fixed-vocabulary multi-select lists — `emotions` (happy, hopeful, grateful, excited, content, calm, angry, frustrated, sad, anxious, drained, disgusted, indifferent) and `contexts` (work, relationships, family, health, sleep, exercise, current_events, weather, other). Both lists are validated against `StateOfMind::EMOTIONS` / `StateOfMind::CONTEXTS`; nothing outside those lists is a valid entry.

`ReminderJob` runs on a schedule and nudges each user, in their own timezone, during three daily windows (09:30-12:30, 14:30-17:30, 19:30-22:30) — but only once per window per day, and only if they have not already recorded a mood or already been reminded in that window.

Admins (`/admin`) get a dashboard (user counts, recent logins) and full CRUD over users.

## Commands

- Setup: `bin/setup` (installs gems, prepares the SQLite database, clears logs/tmp)
- Run: `bin/dev` (Procfile.dev) or `bin/rails server`
- Test: `bin/rails test` (Minitest, includes system tests); JS unit tests: `yarn test`
- Lint: `bin/rubocop`; `yarn eslint .`; `yarn stylelint`; `bundle exec herb lint` for `.erb`/`.rhtml`

## Gotchas

- Auth, sessions, push subscriptions, and user theming live in the `appkit` gem, not this app — look there first before assuming a model or controller is missing.
- `emotions` and `contexts` are closed vocabularies (`StateOfMind::EMOTIONS` / `CONTEXTS`); adding a new one requires updating the model, not just the data.
- `configurations/android_v1` is a real, versioned API contract consumed by the Android app — treat its JSON shape as a public interface, not an internal view.
