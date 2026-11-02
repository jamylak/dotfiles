#!/usr/bin/env fish

set -l root (path resolve (dirname (status filename))/..)
set -gx REX_CLOSE_TEST_DIR (mktemp -d /tmp/rex-close-test.XXXXXX)
function cleanup --on-event fish_exit
    rm -rf -- "$REX_CLOSE_TEST_DIR"
end
function check -a message expected actual
    if test "$expected" != "$actual"
        printf 'FAIL: %s\nexpected: %s\nactual: %s\n' "$message" "$expected" "$actual" >&2
        exit 1
    end
end
source (sed -n '/^function __rex_close_origin_tab /,/^end$/p' "$root/fish/config.fish" | psub)
printf '%s\n' '#!/usr/bin/env fish' \
    'string join "|" -- $argv >> "$REX_CLOSE_TEST_DIR/calls"' \
    'if test "$argv[1]" = session' \
    '    test "$REX_CLOSE_FAIL" = inspect; and exit 7' \
    '    cat "$REX_CLOSE_TEST_DIR/view.json"' \
    'else' \
    '    test "$REX_CLOSE_FAIL" = close; and exit 8' \
    'end' 'exit 0' > "$REX_CLOSE_TEST_DIR/rex"
chmod +x "$REX_CLOSE_TEST_DIR/rex"

printf '%s\n' '{"windows":[{"window_id":"window:origin"}]}' > "$REX_CLOSE_TEST_DIR/view.json"
__rex_close_origin_tab "$REX_CLOSE_TEST_DIR/rex" session:origin window:origin; or exit 1
set -l calls (cat "$REX_CLOSE_TEST_DIR/calls")
check 'inspect before closing the last tab' 'session|inspect|session:origin|--json' "$calls[1]"
check 'close the session instead of leaving it empty' 'kill|session:origin' "$calls[2]"
check 'no cleanup is needed after terminating the originating shell' 2 (count $calls)

printf '' > "$REX_CLOSE_TEST_DIR/calls"
printf '%s\n' '{"windows":[{"window_id":"window:origin"},{"window_id":"window:other"}]}' > "$REX_CLOSE_TEST_DIR/view.json"
__rex_close_origin_tab "$REX_CLOSE_TEST_DIR/rex" session:origin window:origin; or exit 1
set calls (cat "$REX_CLOSE_TEST_DIR/calls")
check 'other tabs keep their session' 'window|close|-s|session:origin|window:origin' "$calls[2]"

# A stale origin ID must never cause a different, sole tab to be killed.
printf '' > "$REX_CLOSE_TEST_DIR/calls"
printf '%s\n' '{"windows":[{"window_id":"window:other"}]}' > "$REX_CLOSE_TEST_DIR/view.json"
__rex_close_origin_tab "$REX_CLOSE_TEST_DIR/rex" session:origin window:origin; or exit 1
set calls (cat "$REX_CLOSE_TEST_DIR/calls")
check 'a different sole tab is preserved' 'window|close|-s|session:origin|window:origin' "$calls[2]"

printf '' > "$REX_CLOSE_TEST_DIR/calls"
set -gx REX_CLOSE_FAIL inspect
__rex_close_origin_tab "$REX_CLOSE_TEST_DIR/rex" session:origin window:origin
check 'inspection failure propagates' 7 $status
check 'failed inspection never closes anything' 1 (count (cat "$REX_CLOSE_TEST_DIR/calls"))

set -gx REX_CLOSE_FAIL close
__rex_close_origin_tab "$REX_CLOSE_TEST_DIR/rex" session:origin window:origin
check 'tab close failure propagates' 8 $status
printf '%s\n' '{"windows":[{"window_id":"window:origin"}]}' > "$REX_CLOSE_TEST_DIR/view.json"
__rex_close_origin_tab "$REX_CLOSE_TEST_DIR/rex" session:origin window:origin
check 'session close failure propagates' 8 $status
echo 'PASS: last-tab session cleanup, other-tab preservation, stale IDs, and failures'
