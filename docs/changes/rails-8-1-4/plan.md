# Plan

Loosen the Gemfile rails constraint only if it blocks 8.1.4.

Run `bundle update rails --conservative` (never plain `bundle update`).

Run the test suite, rubocop on touched files, bundler-audit, and brakeman.
