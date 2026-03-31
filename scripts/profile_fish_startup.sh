#!/bin/sh
set -eu

mode="${1:-current}"
runs="${2:-5}"

case "$mode" in
  current|empty) ;;
  *)
    echo "Usage: $0 [current|empty] [runs]" >&2
    exit 1
    ;;
esac

case "$runs" in
  ''|*[!0-9]*)
    echo "runs must be a positive integer" >&2
    exit 1
    ;;
esac

fish_bin="${FISH_BIN:-$(command -v fish || true)}"
if [ -z "$fish_bin" ]; then
  echo "fish not found on PATH" >&2
  exit 1
fi

tmp_root="$(mktemp -d /tmp/fish-profile.XXXXXX)"
profile_file="$tmp_root/profile.tsv"

cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT INT TERM

xdg_config_home=""
if [ "$mode" = "empty" ]; then
  xdg_config_home="$tmp_root/xdg"
  mkdir -p \
    "$xdg_config_home/fish/conf.d" \
    "$xdg_config_home/fish/functions" \
    "$xdg_config_home/fish/completions"
  : > "$xdg_config_home/fish/config.fish"
fi

run_fish() {
  if [ -n "$xdg_config_home" ]; then
    XDG_CONFIG_HOME="$xdg_config_home" "$fish_bin" -ic exit >/dev/null 2>&1
  else
    "$fish_bin" -ic exit >/dev/null 2>&1
  fi
}

profile_fish() {
  if [ -n "$xdg_config_home" ]; then
    XDG_CONFIG_HOME="$xdg_config_home" "$fish_bin" --profile-startup "$profile_file" -ic exit >/dev/null 2>&1
  else
    "$fish_bin" --profile-startup "$profile_file" -ic exit >/dev/null 2>&1
  fi
}

time_fish() {
  if [ -n "$xdg_config_home" ]; then
    XDG_CONFIG_HOME="$xdg_config_home" /usr/bin/time -p "$fish_bin" -ic exit >/dev/null
  else
    /usr/bin/time -p "$fish_bin" -ic exit >/dev/null
  fi
}

# Warm up once so first-run setup/migration noise does not pollute the numbers.
run_fish

echo "Fish startup benchmark"
echo "fish: $("$fish_bin" --version)"
echo "mode: $mode"
if [ -n "$xdg_config_home" ]; then
  echo "XDG_CONFIG_HOME: $xdg_config_home"
fi
echo "warmup: 1 discarded run"
echo

echo "Wall-clock timings"
i=1
while [ "$i" -le "$runs" ]; do
  echo "run $i"
  time_fish 2>&1
  i=$((i + 1))
done

profile_fish

echo
echo "profile-startup sorted by total time descending"
printf 'Time\tSum\tCommand\n'
tail -n +2 "$profile_file" | LC_ALL=C sort -t "$(printf '\t')" -k2,2nr
