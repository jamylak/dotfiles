#!/usr/bin/env fish

set SELF_PATH (realpath (status filename))
set TEST_DIR (dirname "$SELF_PATH")
set test_files (find "$TEST_DIR" -maxdepth 1 -type f -name '*.fish' | sort)
set failures 0

for test_file in $test_files
    if test (realpath "$test_file") = "$SELF_PATH"
        continue
    end

    printf '\n▶ running %s\n' (basename "$test_file")
    fish "$test_file"
    or set failures (math "$failures + 1")
end

if test $failures -ne 0
    printf '\nFAIL: %s test file(s) failed\n' "$failures" >&2
    exit 1
end

printf '\n✅ all tests passed\n'
