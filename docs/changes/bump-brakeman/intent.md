# Intent: Bump Brakeman to the latest release

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore. Delivery: autonomous

## Problem

CI job `scan_ruby` fails. `bin/brakeman` runs with `--ensure-latest` and exits 5 because Brakeman 8.0.6 is not the latest version, 8.1.0.

## Proposed outcome

`scan_ruby` passes on a branch with no other change.

## Affected users and systems

Etienne; the happiness CI `scan_ruby` job; `Gemfile.lock`.

## Constraints

- Run only `bundle update brakeman`, never a full `bundle update` (rule 11).
- No gem is added or removed. `Gemfile` stays unchanged.
- Own branch and pull request, separate from the `update-dependencies` change (rule 21). That change rebases on this one (rule 25).

## In scope

- Update the locked `brakeman` version to the latest release.

## Out of scope

- Other gems, other repos, any Brakeman warning fixes, the `update-dependencies` change.

## Acceptance criteria

- `bin/brakeman --no-pager` exits 0 locally.
- `scan_ruby` is green on the pull request.

## Open questions

None.
