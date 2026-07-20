# add user local bin to PATH (for claude CLI, etc.)
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

#My own preferred aliases
alias py3="python3"

# Starship prompt
eval "$(starship init bash)"
