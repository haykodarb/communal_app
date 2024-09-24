#!zsh
tmux start-server
tmux new-session -A -s flutter "nvim ." \; split-window -v \; resize-pane -y 10 -t 1 \; split-window -h \; select-pane -t 0 \;
