#add to PATH

fish_add_path ~/.local/bin
fish_add_path ~/bin
fish_add_path /opt/nvim-linux-x86_64/bin

if status is-interactive
    # 1. Tell fish to use Vi key bindings globally
    set -g fish_key_bindings fish_vi_key_bindings

    # 2. Define the user key bindings function
    function fish_user_key_bindings
        # These will override the defaults safely
        bind -M default k up-or-search
        bind -M default j down-or-search
    end
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

function fish_greeting
    echo "fish started" | set_color cyan
end

# vim key bindings in fish


function fish_user_key_bindings
    # Ermöglicht Ctrl+F im Insert- und Normal-Mode, um Vorschläge zu akzeptieren
    bind -M insert \cf forward-char
    bind -M default \cf forward-char
    
    # Falls du das klassische "Vorschlag komplett akzeptieren" willst:
    # bind -M insert \cf accept-autosuggestion
end

# zoxide
zoxide init fish | source

# Created by `pipx` on 2025-12-14 17:34:20
set -gx PATH $PATH ~/.local/bin


# vim as default editor
set -gx EDITOR nvim

# starship
starship init fish | source
