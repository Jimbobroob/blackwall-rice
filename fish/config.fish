# fish: Blackwall rice. Colours come from ~/Source/rices/blackwall-rice/generated/colors.fish (built from the palette).

fish_add_path -g ~/.local/bin ~/.cargo/bin

if status is-interactive
    # No greeting: open straight to the prompt.
    function fish_greeting
    end

    set -l rice (path dirname (path resolve (status filename)))/..
    source $rice/generated/colors.fish

    command -q starship; and starship init fish | source

    # ls with Nerd Font icons.
    if command -q eza
        alias ls 'eza --icons --group-directories-first'
        alias ll 'eza --icons --group-directories-first -l --git --time-style=relative'
        alias la 'eza --icons --group-directories-first -la --git --time-style=relative'
        alias lt 'eza --icons --tree --level=2'
    end

    # Smarter cd that learns your folders.
    command -q zoxide; and zoxide init fish --cmd cd | source
end
