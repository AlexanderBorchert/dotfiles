
#add to PATH

fish_add_path ~/.local/bin
fish_add_path ~/bin



if status is-interactive
    # Commands to run in interactive sessions can go here
end

# yazi
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
        cd "$cwd"
    end
    rm -f -- "$tmp"
end

# zoxide
zoxide init fish | source

# Created by `pipx` on 2025-12-14 17:34:20
set -gx PATH $PATH ~/.local/bin


# Load nvm automatically
# nvm use --lts > /dev/null
