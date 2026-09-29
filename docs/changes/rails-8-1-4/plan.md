# Plan

Loosen the Gemfile rails constraint only if it blocks 8.1.4.

Run `bundle update rails --conservative` (never plain `bundle update`).

Run the test suite, rubocop on touched files, bundler-audit, and brakeman.

Update json to 3.x together with rubocop (1.89 requires `json ~> 2.3`) with `bundle update json rubocop --conservative`, then run the tests, rubocop and bundler-audit on json 3.x.
