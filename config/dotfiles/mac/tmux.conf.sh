# Terminal with true color support
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm*:Tc:smcup@:rmcup@"
set -ag terminal-overrides ",*256col*:Tc"

# Performance
set -sg escape-time 0
set -g history-limit 50000

# Mouse support
set -g mouse on

# Auto-enter copy-mode when scrolling up.
bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"

# Scroll bindings in copy-mode.
bind-key -T copy-mode-vi WheelUpPane send-keys -X scroll-up
bind-key -T copy-mode-vi WheelDownPane send-keys -X scroll-down
bind-key -T copy-mode WheelUpPane send-keys -X scroll-up
bind-key -T copy-mode WheelDownPane send-keys -X scroll-down

# Clipboard integration on macOS.
if-shell 'command -v pbcopy >/dev/null 2>&1' 'bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"'
if-shell 'command -v pbcopy >/dev/null 2>&1' 'bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"'
