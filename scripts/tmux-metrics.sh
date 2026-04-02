#!/opt/homebrew/bin/bash

set -euo pipefail

bar_for_percent() {
    local percent=$1
    local filled=$((percent / 25))
    local empty=$((4 - filled))
    local bar=""
    local i

    for ((i = 0; i < filled; i++)); do
        bar+="■"
    done
    for ((i = 0; i < empty; i++)); do
        bar+="□"
    done

    printf '%s' "$bar"
}

cpu_percent() {
    top -l 1 -n 0 | awk -F'[:,% ]+' '/CPU usage/ { printf "%.0f\n", $3 + $5 }'
}

ram_percent() {
    vm_stat | awk '
        /page size of/ { gsub("\\.", "", $8); page_size=$8 }
        /Pages active/ { gsub("\\.", "", $3); active=$3 }
        /Pages wired down/ { gsub("\\.", "", $4); wired=$4 }
        /Pages occupied by compressor/ { gsub("\\.", "", $5); compressed=$5 }
        /Pages inactive/ { gsub("\\.", "", $3); inactive=$3 }
        /Pages speculative/ { gsub("\\.", "", $3); speculative=$3 }
        /Pages free/ { gsub("\\.", "", $3); free=$3 }
        END {
            used = active + wired + compressed
            total = active + wired + compressed + inactive + speculative + free
            if (total <= 0) {
                print 0
            } else {
                printf "%.0f\n", (used / total) * 100
            }
        }
    '
}

cpu=$(cpu_percent)
ram=$(ram_percent)
cpu_bar=$(bar_for_percent "$cpu")
ram_bar=$(bar_for_percent "$ram")

printf '#[fg=#fbf1c7,bg=#282828,bold]🧠 #[fg=#fe8019,bg=#282828,bold]%s %s%% #[fg=#fbf1c7,bg=#282828,bold]💾 #[fg=#fe8019,bg=#282828,bold]%s %s%% ' \
    "$cpu_bar" "$cpu" \
    "$ram_bar" "$ram"
