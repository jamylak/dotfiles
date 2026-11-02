#!/usr/bin/env fish

set -l root (path resolve (dirname (status filename))/..)
set -gx REX_PICKER_TEST_DIR (mktemp -d /tmp/rex-picker-test.XXXXXX)
function cleanup --on-event fish_exit
    rm -rf -- "$REX_PICKER_TEST_DIR"
end

# Load only the picker; don't run personal startup hooks or contact Rex.
source (sed -n '/^function rex_session_fzf /,/^end$/p' "$root/fish/config.fish" | psub)
set -gx REX_SESSION session:one
set -gx REX_BLOCK block:origin
printf '%s\n' '#!/bin/sh' \
    'if [ "$1" = ls ]; then' \
    '  [ "$REX_PICKER_FAIL_LIST" = yes ] && exit 7' \
    '  printf \'%s\n\' \'{"sessions":[{"session_id":"session:one","label":"same name"},{"session_id":"session:two","label":"same name"}]}\'' \
    'elif [ "$1" = block ]; then' \
    '  printf \'%s\n\' \'{"block":{"window_id":"window:origin"}}\'' \
    'else' \
    '  [ "$1" = do ] && [ "$REX_PICKER_FAIL_SWITCH" = yes ] && exit 8' \
    '  printf "%s " "$@" >> "$REX_PICKER_TEST_DIR/selected"' \
    '  printf "\n" >> "$REX_PICKER_TEST_DIR/selected"' \
    'fi' > "$REX_PICKER_TEST_DIR/rex"
chmod +x "$REX_PICKER_TEST_DIR/rex"

function __rex_cli
    echo "$REX_PICKER_TEST_DIR/rex"
end
function fzf
    cat > "$REX_PICKER_TEST_DIR/rows"
    test "$REX_PICKER_CANCEL" = yes; and return 130
    tail -n 1 "$REX_PICKER_TEST_DIR/rows"
end

rex_session_fzf; or exit 1
set -l selected (cat "$REX_PICKER_TEST_DIR/selected")
if test (count $selected) -ne 2; or test "$selected[1]" != 'do session.select session_id=session:two '; or test "$selected[2]" != 'window close -s session:one window:origin '
    echo 'FAIL: switch by ID first, then close only the original tab' >&2
    exit 1
end
rm "$REX_PICKER_TEST_DIR/selected"
set -gx REX_SESSION session:two
rex_session_fzf
if test -e "$REX_PICKER_TEST_DIR/selected"
    echo 'FAIL: selecting the current session must keep its tab' >&2
    exit 1
end
set -gx REX_SESSION session:one
set -gx REX_PICKER_FAIL_SWITCH yes
rex_session_fzf
if test $status -ne 8; or test -e "$REX_PICKER_TEST_DIR/selected"
    echo 'FAIL: a failed switch must not close the original tab' >&2
    exit 1
end
set -e REX_PICKER_FAIL_SWITCH
set -gx REX_PICKER_CANCEL yes
rex_session_fzf
if test -e "$REX_PICKER_TEST_DIR/selected"
    echo 'FAIL: cancellation switched sessions' >&2
    exit 1
end
set -gx REX_PICKER_FAIL_LIST yes
rex_session_fzf
if test $status -ne 7
    echo 'FAIL: listing failure must propagate' >&2
    exit 1
end
echo 'PASS: switch before close, same-session selection, failed switch, cancellation, and listing failure'
