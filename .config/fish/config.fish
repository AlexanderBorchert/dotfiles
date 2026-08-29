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

function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    set -l cho (mktemp -t "yazi-cho.XXXXXX")

    # Startet Yazi
    yazi $argv --cwd-file="$tmp" --chooser-file="$cho"

    # Fall 1: Eine Datei wurde mit Enter ausgewählt
    if test -f "$cho"; and test -s "$cho"
        set -l opened_file (cat -- "$cho" | head -n 1)
        # Ermittle den Ordner, in dem die Datei liegt
        set -l file_dir (dirname -- "$opened_file")
        
        # 1. Wechsle sofort in den Ordner der Datei
        if test -n "$file_dir"; and test "$file_dir" != "$PWD"
            cd "$file_dir"
        end
        
        # 2. Lösche die temporären Dateien, da Yazi bereits zu ist
        rm -f -- "$tmp" "$cho"
        
        # 3. Starte nvim ganz normal (OHNE exec). 
        # Die Shell wartet im Hintergrund, bis du nvim schließt.
        nvim "$opened_file"

    # Fall 2: Yazi wurde normal mit "q" geschlossen
    else if test -f "$tmp"
        if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
            cd "$cwd"
        end
        rm -f -- "$tmp" "$cho"
    end
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
