#!/bin/bash
# Rearrange current window's panes into a 4-column x 2-row grid

# Get pane IDs in current window
panes=($(tmux list-panes -F '#{pane_id}'))
count=${#panes[@]}

if [ "$count" -ne 8 ]; then
  tmux display-message "Need exactly 8 panes for 4x2 layout (have $count)"
  exit 1
fi

# Get window dimensions
W=$(tmux display -p '#{window_width}')
H=$(tmux display -p '#{window_height}')

cols=4

# Column widths (4 columns, accounting for 3 separator lines)
usable_width=$(( W - (cols - 1) ))
base_col_width=$(( usable_width / cols ))
last_col_width=$(( usable_width - (base_col_width * (cols - 1)) ))

# Row heights (2 rows, accounting for 1 separator line)
R1=$(( (H - 1) / 2 ))
R2=$(( H - 1 - R1 ))

# Y offset for second row
Y2=$(( R1 + 1 ))

# Strip the % prefix from pane IDs to get raw numbers
ids=()
for p in "${panes[@]}"; do
  ids+=("${p#%}")
done

# Build layout string (without checksum)
layout="${W}x${H},0,0{"
x=0
for ((i=0; i<cols; i++)); do
  col_width=$base_col_width
  if [ "$i" -eq $((cols - 1)) ]; then
    col_width=$last_col_width
  fi

  top_idx=$(( i * 2 ))
  bottom_idx=$(( top_idx + 1 ))

  layout+="${col_width}x${H},${x},0[${col_width}x${R1},${x},0,${ids[$top_idx]},${col_width}x${R2},${x},${Y2},${ids[$bottom_idx]}]"

  if [ "$i" -lt $((cols - 1)) ]; then
    layout+=","
  fi

  x=$(( x + col_width + 1 ))
done
layout+="}"

# Compute tmux layout checksum
csum=0
for (( i=0; i<${#layout}; i++ )); do
  c=$(printf '%d' "'${layout:$i:1}")
  csum=$(( ((csum >> 1) | ((csum & 1) << 15)) + c ))
  csum=$(( csum & 0xFFFF ))
done

tmux select-layout "$(printf '%04x' $csum),${layout}"
