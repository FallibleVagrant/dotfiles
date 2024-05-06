mkdir -p ./.config/
# Note to self: be careful with recursive directory copies.
# Adding a slash at the end will copy the dir *into* the dest, not replace dest.
cp -ruv ~/.config/nvim/ ./.config

cp -uv ~/.tmux.conf ./.tmux.conf
