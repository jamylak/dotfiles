#!/usr/bin/env fish

set -l root (path resolve (dirname (status filename))/..)
set -l scratch (mktemp -d /tmp/rex-launch-test.XXXXXX)
set -gx REX_TEST_DIR "$scratch"

function cleanup --on-event fish_exit
    rm -rf -- "$REX_TEST_DIR"
end

function check -a message expected actual
    if test "$expected" != "$actual"
        printf 'FAIL: %s\nexpected: %s\nactual: %s\n' "$message" "$expected" "$actual" >&2
        exit 1
    end
end

set -lx HOME "$scratch"
source "$root/fish/config.fish"
mkdir -p "$scratch/bin" "$scratch/project with spaces"
printf '%s\n' '#!/usr/bin/env fish' \
    'string join " " -- (string escape -- $argv) >> "$REX_TEST_DIR/calls"' \
    'test "$REX_TEST_FAIL" = yes; and exit 7' \
    'if contains -- do $argv; and test "$REX_TEST_FAIL" = select; exit 8; end' \
    'echo \'{"window_id":"window:new","block_ids":["block:new","block:original"]}\'' > "$scratch/bin/rex"
chmod +x "$scratch/bin/rex"
set -gx PATH "$scratch/bin" $PATH
set -e REX_SESSION REX_BLOCK TMUX
cd "$scratch/project with spaces"
set -gx REX_SESSION session:original
set -gx REX_BLOCK block:original
# Rex can inherit a Kitty-compatible TERM; Rex must still take precedence.
set -gx TERM xterm-kitty
set -l cmd 'printf "%s\\n" "a b"; echo $PWD | cat'
set -l fish_cli (status fish-path)
check 'Rex receives an absolute executable path' / (string sub -l 1 -- "$fish_cli")

function expected_call
    string join ' ' -- (string escape -- $argv)
end

for layout in tab right below overlay
    printf '' > "$scratch/calls"
    switch "$layout"
        case tab
            launch_new_tab "$cmd" >/dev/null; or exit 1
        case right
            launch_vsplit "$cmd" >/dev/null; or exit 1
        case below
            launch_hsplit "$cmd" >/dev/null; or exit 1
        case overlay
            launch_overlay "$cmd" >/dev/null; or exit 1
    end
    set -l calls (cat "$scratch/calls")
    if test "$layout" = tab
        check 'tab command preserves cwd and shell syntax' \
            (expected_call run -s "$REX_SESSION" -c "$PWD" --shell=none --json -- "$fish_cli" -c "$cmd") "$calls[1]"
    else
        set -l direction "$layout"
        set -l extra
        if test "$layout" = overlay
            set direction below
            set extra --json
        end
        check "$layout uses explicit source pane and preserves command" \
            (expected_call split -s "$REX_SESSION" -b "$REX_BLOCK" --split="$direction" -c "$PWD" --shell=none $extra -- "$fish_cli" -c "$cmd") "$calls[1]"
    end
    if test "$layout" = tab
        check 'new tab is explicitly displayed in the app' \
            (expected_call do session.select "session_id=$REX_SESSION" window_id=window:new) "$calls[2]"
        check 'tab calls create and select' 2 (count $calls)
    else if test "$layout" = overlay
        check 'overlay zooms the newly created pane' \
            (expected_call zoom -s "$REX_SESSION" block:new --on) "$calls[2]"
        check 'overlay calls split and zoom' 2 (count $calls)
    else
        check 'one launch per request' 1 (count $calls)
    end
end

set -gx REX_TEST_FAIL yes
printf '' > "$scratch/calls"
launch_overlay "$cmd" >/dev/null 2>/dev/null
check 'creation failure propagates' 7 $status
check 'failed overlay does not zoom' 1 (count (cat "$scratch/calls"))
printf '' > "$scratch/calls"
launch_new_tab "$cmd" >/dev/null 2>/dev/null
check 'tab creation failure propagates' 7 $status
check 'failed tab creation does not select a tab' 1 (count (cat "$scratch/calls"))
set -gx REX_TEST_FAIL select
launch_new_tab "$cmd" >/dev/null 2>/dev/null
check 'tab selection failure propagates' 8 $status
set -e REX_TEST_FAIL REX_BLOCK
printf '' > "$scratch/calls"
launch_vsplit "$cmd" >/dev/null 2>/dev/null
check 'missing source pane fails' 1 $status
check 'missing source pane never splits the focused pane' 0 (count (cat "$scratch/calls"))

function tmux
    echo tmux >> "$REX_TEST_DIR/calls"
end
function kitty
    echo kitty >> "$REX_TEST_DIR/calls"
end
function skhd
    echo skhd >> "$REX_TEST_DIR/calls"
end

set -gx TMUX tmux:test
for launcher in launch_new_tab launch_overlay launch_vsplit launch_hsplit
    printf '' > "$scratch/calls"
    $launcher "$cmd"
    check "$launcher retains tmux precedence inside Rex" tmux (cat "$scratch/calls")
end
set -e TMUX REX_SESSION
for launcher in launch_new_tab launch_overlay launch_vsplit launch_hsplit
    printf '' > "$scratch/calls"
    $launcher "$cmd"
    check "$launcher retains Kitty fallback" kitty (cat "$scratch/calls")
    set -gx TERM xterm-256color
    printf '' > "$scratch/calls"
    $launcher "$cmd"
    check "$launcher retains Ghostty fallback" skhd (head -n 1 "$scratch/calls")
    set -gx TERM xterm-kitty
end
printf '✅ Rex launch tests passed\n'
