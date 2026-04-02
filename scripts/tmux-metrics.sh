#!/opt/homebrew/bin/bash

set -euo pipefail

clamp_percent() {
    local percent=$1

    if ((percent < 0)); then
        printf '0'
    elif ((percent > 100)); then
        printf '100'
    else
        printf '%s' "$percent"
    fi
}

interpolate_channel() {
    local start=$1
    local end=$2
    local progress=$3

    printf '%d' $((start + ((end - start) * progress / 100)))
}

color_for_percent() {
    local percent
    percent=$(clamp_percent "$1")

    local start_r start_g start_b
    local end_r end_g end_b
    local progress

    if ((percent <= 50)); then
        start_r=0xb8
        start_g=0xbb
        start_b=0x26
        end_r=0xfa
        end_g=0xbd
        end_b=0x2f
        progress=$((percent * 2))
    else
        start_r=0xfa
        start_g=0xbd
        start_b=0x2f
        end_r=0xfb
        end_g=0x49
        end_b=0x34
        progress=$(((percent - 50) * 2))
    fi

    printf '#%02x%02x%02x' \
        "$(interpolate_channel "$start_r" "$end_r" "$progress")" \
        "$(interpolate_channel "$start_g" "$end_g" "$progress")" \
        "$(interpolate_channel "$start_b" "$end_b" "$progress")"
}

bar_for_percent() {
    local percent
    percent=$(clamp_percent "$1")
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

cpu=$(clamp_percent "$(cpu_percent)")
ram=$(clamp_percent "$(ram_percent)")
cpu_bar=$(bar_for_percent "$cpu")
ram_bar=$(bar_for_percent "$ram")
cpu_color=$(color_for_percent "$cpu")
ram_color=$(color_for_percent "$ram")

printf '#[fg=#fbf1c7,bg=#282828,bold]🧠 #[fg=%s,bg=#282828,bold]%s %s%% #[fg=#fbf1c7,bg=#282828,bold]💾 #[fg=%s,bg=#282828,bold]%s %s%% ' \
    "$cpu_color" \
    "$cpu_bar" "$cpu" \
    "$ram_color" \
    "$ram_bar" "$ram"
