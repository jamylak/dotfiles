#!/bin/sh

set -eu

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
TMPDIR=$(mktemp -d /tmp/coco-worktree-test.XXXXXX)
cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT INT TERM

assert_eq() {
    expected=$1
    actual=$2
    message=$3
    if [ "$expected" != "$actual" ]; then
        printf 'FAIL: %s\nexpected: %s\nactual:   %s\n' "$message" "$expected" "$actual" >&2
        exit 1
    fi
}

run_in_fish() {
    fish -c ". \"$ROOT_DIR/fish/config.fish\"; $1"
}

create_repo() {
    repo_name=$1
    default_branch=$2
    repo_dir="$TMPDIR/$repo_name"

    git -C "$TMPDIR" init -b "$default_branch" "$repo_name" >/dev/null
    git -C "$repo_dir" config user.email test@example.com
    git -C "$repo_dir" config user.name test
    touch "$repo_dir/README.md"
    git -C "$repo_dir" add README.md
    git -C "$repo_dir" commit -m init >/dev/null

    printf '%s\n' "$repo_dir"
}

print_case() {
    icon=$1
    title=$2
    start_dir=$3
    requested_branch=$4
    expected_dir=$5
    expected_branch=$6

    printf '\n%s %s\n' "$icon" "$title"
    printf '   start:            %s\n' "$start_dir"
    printf '   coco arg:         %s\n' "$requested_branch"
    printf '   expected folder:  %s\n' "$expected_dir"
    printf '   expected branch:  %s\n' "$expected_branch"
}

assert_worktree() {
    title=$1
    start_dir=$2
    requested_branch=$3
    expected_dir=$4
    expected_branch=$5

    print_case "🧪" "$title" "$start_dir" "$requested_branch" "$expected_dir" "$expected_branch"
    run_in_fish "cd \"$start_dir\"; worktree_add \"$requested_branch\""

    if [ ! -d "$expected_dir" ]; then
        printf 'FAIL: %s\nexpected directory missing: %s\n' "$title" "$expected_dir" >&2
        exit 1
    fi

    actual_dir=$(basename "$expected_dir")
    actual_branch=$(git -C "$expected_dir" rev-parse --abbrev-ref HEAD)

    assert_eq "$(basename "$expected_dir")" "$actual_dir" "$title: worktree folder should match"
    assert_eq "$expected_branch" "$actual_branch" "$title: branch name should match"
    printf '   result:           PASS\n'
}

MAIN_REPO=$(create_repo repo-main main)
MASTER_REPO=$(create_repo repo-master master)

# Scenario: coco off main should preserve the requested branch name.
assert_worktree \
    "coco off main" \
    "$MAIN_REPO" \
    "feature1" \
    "$TMPDIR/repo-main-feature1" \
    "feature1"

# Scenario: coco off master should also preserve the requested branch name.
assert_worktree \
    "coco off master" \
    "$MASTER_REPO" \
    "feature1" \
    "$TMPDIR/repo-master-feature1" \
    "feature1"

# Scenario: coco off repo-branch/ should prefix the new branch with the current worktree branch.
assert_worktree \
    "coco off repo-branch/" \
    "$TMPDIR/repo-main-feature1" \
    "feature2" \
    "$TMPDIR/repo-main-feature1-feature2" \
    "feature1-feature2"

# Scenario: coco off repo-branch-subbranch/ should keep chaining branch segments.
assert_worktree \
    "coco off repo-branch-subbranch/" \
    "$TMPDIR/repo-main-feature1-feature2" \
    "feature3" \
    "$TMPDIR/repo-main-feature1-feature2-feature3" \
    "feature1-feature2-feature3"

printf '\n✅ worktree_add tests passed\n'
