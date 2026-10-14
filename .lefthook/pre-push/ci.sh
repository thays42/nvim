#!/usr/bin/env bash
# Pre-push gate: runs make ci against the tip commit of each ref being pushed.
# Intermediate commits in a pushed range are not checked individually.
#
# This is a lefthook script rather than a command because lefthook skips
# pre-push commands when its push-file list, derived from the current branch
# rather than the refs being pushed, is empty. Scripts always run, and receive
# git's "<local ref> <local sha> <remote ref> <remote sha>" lines on stdin.
#
# A tip that is the current checkout, with no staged, unstaged or untracked
# changes, is checked in place: the common case, with warm build caches. Any
# other tip is checked in a temporary worktree so the result reflects what is
# pushed rather than what is on disk. Worktree builds are cold: sharing build
# directories (such as Cargo's target/) with the checkout lets timestamp-based
# rebuild checks reuse the wrong commit's artifacts.
#
# Limit: gitignored files (.env, caches, virtualenvs) are not considered
# changes, so a tip that only passes because of a local ignored file can still
# pass in place.
set -euo pipefail

zero=0000000000000000000000000000000000000000
head="$(git rev-parse HEAD)"
status=0
dir=""
checked=" "

cleanup() {
  if [ -n "$dir" ]; then
    git worktree remove --force "$dir" 2>/dev/null || true
    rm -rf "$dir"
    git worktree prune
    dir=""
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

clean_checkout() {
  [ -z "$(git status --porcelain)" ]
}

while read -r _ sha _ _; do
  [ -n "${sha:-}" ] || continue
  [ "$sha" = "$zero" ] && continue # branch deletion
  case "$checked" in *" $sha "*) continue ;; esac
  checked+="$sha "

  ok=1
  if [ "$sha" = "$head" ] && clean_checkout; then
    echo "pre-push: make ci at ${sha:0:12} (current checkout)"
    make ci </dev/null || ok=0
  else
    dir="$(mktemp -d)"
    git worktree add --quiet --detach "$dir" "$sha"
    echo "pre-push: make ci at ${sha:0:12} (temporary worktree)"
    # stdin is git's ref list; make must not consume it.
    (cd "$dir" && make ci </dev/null) || ok=0
    cleanup
  fi
  if [ "$ok" -eq 0 ]; then
    echo "pre-push: ${sha:0:12} fails make ci" >&2
    status=1
  fi
done

exit "$status"
