#!/usr/bin/env fish

set -l root (path resolve (dirname (status filename))/..)
set -l scratch (mktemp -d /tmp/rex-coco-test.XXXXXX)
set -gx REX_TEST_DIR "$scratch"

function cleanup --on-event fish_exit
    rm -rf -- "$REX_TEST_DIR"
end

function check -a message
    if test "$argv[2]" != "$argv[3]"
        printf 'FAIL: %s\nexpected: %s\nactual: %s\n' "$message" "$argv[2]" "$argv[3]" >&2
        exit 1
    end
end

# Isolate startup from local overrides and never contact the real Rex server.
set -lx HOME "$scratch"
source "$root/fish/config.fish"
mkdir -p "$scratch/bin"
printf '%s\n' '#!/usr/bin/env fish' \
    'string join " " -- (string escape -- $argv) >> "$REX_TEST_DIR/calls"' \
    'if contains -- new $argv' \
    '    test "$REX_TEST_FAIL" = create; and exit 1' \
    '    echo \'{"session_id":"session:test"}\'' \
    'else if test "$argv[1]" = block' \
    '    test "$REX_TEST_FAIL" = inspect; and exit 9' \
    '    echo \'{"block":{"window_id":"window:original"}}\'' \
    'else if contains -- inspect $argv' \
    '    cat "$REX_TEST_DIR/view.json"' \
    'else if contains -- do $argv' \
    '    test "$REX_TEST_FAIL" = select; and exit 1' \
    'end' 'exit 0' > "$scratch/bin/rex"
chmod +x "$scratch/bin/rex"
set -gx PATH "$scratch/bin" $PATH
printf '%s\n' '{"label":"project","windows":[{"layers":[{"blocks":[{"creator_name":"com.superlogical.terminal","block_id":"block:owner"},{"creator_name":"com.superlogical.terminal","block_id":"block:other"}]}]}]}' > "$scratch/view.json"
set -gx REX_SESSION session:original
set -gx REX_BLOCK block:owner
set -gx AI_CLI codex --sandbox workspace-write

git init -q -b main "$scratch/project"
git -C "$scratch/project" -c user.name=test -c user.email=test@example.com commit -qm init --allow-empty
cd "$scratch/project"
printf '' > "$scratch/calls"
coco feature >/dev/null; or exit 1
check 'worktree branch' feature (git -C "$scratch/project-feature" branch --show-current)
check 'original shell stays in its project' "$scratch/project" "$PWD"
emit fish_prompt
set -l calls (cat "$scratch/calls")
check 'coco inspects, creates, selects, and closes without renaming' 4 (count $calls)
check 'coco captures the originating tab' 'block inspect -s session:original block:owner --json' "$calls[1]"
check 'Rex starts Codex in the named worktree' \
    "new project-feature -c $scratch/project-feature --keep-open --json -- codex --sandbox workspace-write" "$calls[2]"
check 'Rex displays the created session before closing' 'do session.select session_id=session:test' "$calls[3]"
check 'Rex closes only the originating tab' 'window close -s session:original window:original' "$calls[4]"

# A failed app switch keeps the created session and worktree, and reports failure.
cd "$scratch/project"
set -gx REX_TEST_FAIL select
printf '' > "$scratch/calls"
coco other >/dev/null 2>/dev/null
check 'failed app switch is reported' 1 $status
check 'failed switch keeps the originating tab' 3 (count (cat "$scratch/calls"))
check 'worktree survives app switch failure' other (git -C "$scratch/project-other" branch --show-current)
check 'failed switch leaves the original directory intact' "$scratch/project" "$PWD"
set -e REX_TEST_FAIL

# A failed session creation must not attempt to switch to an invalid session.
cd "$scratch/project"
set -gx REX_TEST_FAIL create
printf '' > "$scratch/calls"
coco failed >/dev/null 2>/dev/null
check 'failed creation is reported' 1 $status
check 'failed creation neither switches nor closes' 2 (count (cat "$scratch/calls"))
check 'worktree survives creation failure' failed (git -C "$scratch/project-failed" branch --show-current)
set -e REX_TEST_FAIL

# Failed worktree creation must not launch a session or leave naming suspended.
printf '' > "$scratch/calls"
coco feature >/dev/null 2>/dev/null
set -l worktree_status $status
test $worktree_status -ne 0
check 'existing worktree fails' 0 $status
check 'failed worktree creation only inspects the originating pane' 1 (count (cat "$scratch/calls"))
set -q __rex_project_session_suspended
check 'failed worktree creation restores automatic naming' 1 $status

set -gx REX_TEST_FAIL inspect
printf '' > "$scratch/calls"
coco inspect-fails >/dev/null 2>/dev/null
check 'inspection failure propagates' 9 $status
check 'failed inspection never creates or closes a session' 1 (count (cat "$scratch/calls"))
test ! -d "$scratch/project-inspect-fails"; or exit 1
set -e REX_TEST_FAIL

# Only the primary terminal may rename a session, using the Git root even in src/.
printf '%s\n' '{"label":"old","windows":[{"layers":[{"blocks":[{"creator_name":"com.superlogical.terminal","block_id":"block:owner"},{"creator_name":"com.superlogical.terminal","block_id":"block:other"}]}]}]}' > "$scratch/view.json"
mkdir "$scratch/project-other/src"
set -gx REX_BLOCK block:other
printf '' > "$scratch/calls"
cd "$scratch/project-other/src"
check 'secondary pane only inspects' 1 (count (cat "$scratch/calls"))
set -gx REX_BLOCK block:owner
cd ..
set calls (cat "$scratch/calls")
check 'directory change immediately names the session without another prompt' \
    '--autostart=false --timeout 1s session rename session:original project-other' "$calls[-1]"
printf '' > "$scratch/calls"
cd src
set calls (cat "$scratch/calls")
check 'primary pane names from worktree root even inside src' \
    '--autostart=false --timeout 1s session rename session:original project-other' "$calls[-1]"
set -l call_count (count $calls)
emit fish_prompt
check 'prompt after directory change does not repeat the rename' "$call_count" (count (cat "$scratch/calls"))

# Outside Rex, coco retains the tmux path.
set -e REX_SESSION
function tmux_attach -a name dir
    printf '%s\n' "$dir" > "$REX_TEST_DIR/tmux-dir"
end
cd "$scratch/project"
coco terminal >/dev/null; or exit 1
check 'tmux fallback gets new worktree' "$scratch/project-terminal" (cat "$scratch/tmux-dir")
printf '✅ Rex coco and naming tests passed\n'
