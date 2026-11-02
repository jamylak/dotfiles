#!/usr/bin/env fish

set -l root (path resolve (dirname (status filename))/..)
set -gx REX_PROJECT_TEST_DIR (mktemp -d /tmp/rex-project-test.XXXXXX)
set -gx REX_PROJECT_TEST_DIR (path resolve -- "$REX_PROJECT_TEST_DIR")
function cleanup --on-event fish_exit
    rm -rf -- "$REX_PROJECT_TEST_DIR"
end
function check -a message expected actual
    if test "$expected" != "$actual"
        printf 'FAIL: %s\nexpected: %s\nactual: %s\n' "$message" "$expected" "$actual" >&2
        exit 1
    end
end

# Isolate project creation from startup hooks, personal trust files, and real Rex.
source (sed -n '/^function make_new_project /,/^end$/p' "$root/fish/config.fish" | psub)
source (sed -n '/^function __rex_make_new_project /,/^end$/p' "$root/fish/config.fish" | psub)
source (sed -n '/^function tmux_dir_session_name /,/^end$/p' "$root/fish/config.fish" | psub)
function codex_trust_project -a dir
    echo "$dir" > "$REX_PROJECT_TEST_DIR/trusted"
end
function __rex_cli
    echo "$REX_PROJECT_TEST_DIR/rex"
end
function tmux_attach -a name dir
    echo "$dir" > "$REX_PROJECT_TEST_DIR/tmux"
end
printf '%s\n' '#!/usr/bin/env fish' \
    'string join "|" -- $argv >> "$REX_PROJECT_TEST_DIR/calls"' \
    'if test "$argv[1]" = new' \
    '    test "$REX_PROJECT_FAIL" = create; and exit 7' \
    '    echo \'{"session_id":"session:new"}\'' \
    'else if test "$argv[1]" = block' \
    '    test "$REX_PROJECT_FAIL" = inspect; and exit 9' \
    '    echo \'{"block":{"window_id":"window:original"}}\'' \
    'else if test "$argv[1]" = do' \
    '    test "$REX_PROJECT_FAIL" = select; and exit 8' \
    'end' 'exit 0' > "$REX_PROJECT_TEST_DIR/rex"
chmod +x "$REX_PROJECT_TEST_DIR/rex"
set -gx REX_SESSION session:original
set -gx REX_BLOCK block:original
set -gx AI_CLI codex --sandbox workspace-write
set -l original_dir "$PWD"
set -l project "$REX_PROJECT_TEST_DIR/project with spaces"
make_new_project "$project" >/dev/null 2>/dev/null; or exit 1
test -d "$project/.git"; or exit 1
check 'project is trusted' "$project" (cat "$REX_PROJECT_TEST_DIR/trusted")
check 'original Rex shell stays in place' "$original_dir" "$PWD"
set -l calls (cat "$REX_PROJECT_TEST_DIR/calls")
check 'inspect, create, switch, and close exactly once' 4 (count $calls)
check 'originating pane is inspected before creation' 'block|inspect|-s|session:original|block:original|--json' "$calls[1]"
check 'AI_CLI arguments and project path are preserved' \
    "new|project with spaces|-c|$project|--keep-open|--json|--|codex|--sandbox|workspace-write" "$calls[2]"
check 'new session is displayed before closing the old tab' 'do|session.select|session_id=session:new' "$calls[3]"
check 'only the originating tab is closed' 'window|close|-s|session:original|window:original' "$calls[4]"
test ! -e "$REX_PROJECT_TEST_DIR/tmux"; or exit 1

printf '' > "$REX_PROJECT_TEST_DIR/calls"
make_new_project "$project" >/dev/null 2>/dev/null
test $status -ne 0; or exit 1
check 'existing project only inspects the original pane' 1 (count (cat "$REX_PROJECT_TEST_DIR/calls"))

printf '' > "$REX_PROJECT_TEST_DIR/calls"
set -gx REX_PROJECT_FAIL create
make_new_project "$REX_PROJECT_TEST_DIR/create-fails" >/dev/null 2>/dev/null
check 'creation failure propagates' 7 $status
check 'failed creation never switches or closes' 2 (count (cat "$REX_PROJECT_TEST_DIR/calls"))
printf '' > "$REX_PROJECT_TEST_DIR/calls"
set -gx REX_PROJECT_FAIL select
make_new_project "$REX_PROJECT_TEST_DIR/select-fails" >/dev/null 2>/dev/null
check 'selection failure propagates' 8 $status
check 'failed selection never closes the original tab' 3 (count (cat "$REX_PROJECT_TEST_DIR/calls"))
check 'failures keep the original shell directory' "$original_dir" "$PWD"
set -gx REX_PROJECT_FAIL inspect
make_new_project "$REX_PROJECT_TEST_DIR/inspect-fails" >/dev/null 2>/dev/null
check 'inspection failure propagates' 9 $status
test ! -d "$REX_PROJECT_TEST_DIR/inspect-fails"; or exit 1
set -e REX_PROJECT_FAIL REX_SESSION

make_new_project "$REX_PROJECT_TEST_DIR/tmux-project" >/dev/null 2>/dev/null; or exit 1
check 'outside Rex, shell enters project' "$REX_PROJECT_TEST_DIR/tmux-project" "$PWD"
check 'outside Rex, tmux launches project' "$PWD" (cat "$REX_PROJECT_TEST_DIR/tmux")
cd "$original_dir"
echo 'PASS: Rex project creation, trust, AI launch, switch before tab close, failures, and tmux fallback'
