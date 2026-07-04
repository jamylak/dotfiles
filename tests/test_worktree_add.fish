#!/usr/bin/env fish

set ROOT_DIR (cd (dirname (status filename))/.. && pwd)
set TMPDIR (mktemp -d /tmp/coco-worktree-test.XXXXXX)

function cleanup --on-event fish_exit
    rm -rf "$TMPDIR"
end

function assert_eq -a expected actual message
    if test "$expected" != "$actual"
        printf 'FAIL: %s\nexpected: %s\nactual:   %s\n' "$message" "$expected" "$actual" >&2
        exit 1
    end
end

function run_in_fish -a command
    fish -c ". \"$ROOT_DIR/fish/config.fish\"; $command"
end

function create_repo -a repo_name default_branch
    set repo_dir "$TMPDIR/$repo_name"

    git -C "$TMPDIR" init -b "$default_branch" "$repo_name" >/dev/null
    git -C "$repo_dir" config user.email test@example.com
    git -C "$repo_dir" config user.name test
    touch "$repo_dir/README.md"
    git -C "$repo_dir" add README.md
    git -C "$repo_dir" commit -m init >/dev/null

    printf '%s\n' "$repo_dir"
end

function print_case -a icon title start_dir requested_branch expected_dir expected_branch
    printf '\n%s %s\n' "$icon" "$title"
    printf '   start:            %s\n' "$start_dir"
    printf '   coco arg:         %s\n' "$requested_branch"
    printf '   expected folder:  %s\n' "$expected_dir"
    printf '   expected branch:  %s\n' "$expected_branch"
end

function assert_worktree -a title start_dir requested_branch expected_dir expected_branch
    print_case "🧪" "$title" "$start_dir" "$requested_branch" "$expected_dir" "$expected_branch"
    run_in_fish "cd \"$start_dir\"; worktree_add \"$requested_branch\""

    if not test -d "$expected_dir"
        printf 'FAIL: %s\nexpected directory missing: %s\n' "$title" "$expected_dir" >&2
        exit 1
    end

    set actual_dir (basename "$expected_dir")
    set actual_branch (git -C "$expected_dir" rev-parse --abbrev-ref HEAD)

    assert_eq (basename "$expected_dir") "$actual_dir" "$title: worktree folder should match"
    assert_eq "$expected_branch" "$actual_branch" "$title: branch name should match"
    printf '   result:           PASS\n'
end

set MAIN_REPO (create_repo repo-main main)
set MASTER_REPO (create_repo repo-master master)

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
