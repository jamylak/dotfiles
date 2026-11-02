#!/usr/bin/env fish

set -l root (path resolve (dirname (status filename))/..)
set -gx REX_PICKER_TEST_DIR (mktemp -d /tmp/rex-picker-test.XXXXXX)
function cleanup --on-event fish_exit
    rm -rf -- "$REX_PICKER_TEST_DIR"
end

# Load only the picker; don't run personal startup hooks or contact Rex.
source (sed -n '/^function rex_session_fzf /,/^end$/p' "$root/fish/config.fish" | psub)
printf '%s\n' '#!/bin/sh' \
    'if [ "$1" = ls ]; then' \
    '  [ "$REX_PICKER_FAIL_LIST" = yes ] && exit 7' \
    '  printf \'%s\n\' \'{"sessions":[{"session_id":"session:one","label":"same name"},{"session_id":"session:two","label":"same name"}]}\'' \
    'else' \
    '  printf "%s\n" "$@" > "$REX_PICKER_TEST_DIR/selected"' \
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
if test (string join ' ' -- $selected) != 'do session.select session_id=session:two'
    echo 'FAIL: duplicate labels must select by session ID' >&2
    exit 1
end
rm "$REX_PICKER_TEST_DIR/selected"
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
echo 'PASS: Rex picker selection, cancellation, and listing failure'
