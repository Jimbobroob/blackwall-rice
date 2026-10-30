# fish: Blackwall rice. Colours come from ~/rice/generated/colors.fish (built from the palette).

fish_add_path -g ~/.local/bin ~/.cargo/bin

if status is-interactive
    # No greeting: open straight to the prompt.
    function fish_greeting
    end

    set -l rice (path dirname (path resolve (status filename)))/..
    source $rice/generated/colors.fish

    command -q starship; and starship init fish | source
end
