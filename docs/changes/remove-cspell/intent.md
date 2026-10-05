# Intent: Remove the cspell spell checker

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

cspell stops commits on correctly spelled technical words and has found no real typo.

## Proposed outcome

A commit is never stopped by a spell check.

## Affected users and systems

Anyone committing to the repo, and the lefthook pre-commit job and cspell config.

## Constraints

Nothing else in the repo changes.

## Open questions

None.
