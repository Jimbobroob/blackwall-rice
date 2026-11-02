-- Rice: Hyprland entry point (Hyprland 0.57+ reads Lua only).
-- Colours come from generated/palette.lua and layout facts from generated/settings.lua,
-- both built from ~/Source/rices/blackwall-rice/theme/palette.json and ~/Source/rices/blackwall-rice/settings.json by tools/generate.py.

local dir = os.getenv("HOME") .. "/.config/hypr"

local rice = {
    dir      = dir,
    palette  = dofile(dir .. "/generated/palette.lua"),
    settings = dofile(dir .. "/generated/settings.lua"),
}

-- "rgb(FF0033)" for a palette role, optionally with alpha ("cc").
function rice.rgb(role, alpha)
    local hex = rice.palette[role]
    return alpha and ("rgba(" .. hex .. alpha .. ")") or ("rgb(" .. hex .. ")")
end

-- The live monitor for a role ("main" / "side"), matched by description so it
-- survives the KVM renaming ports. nil while that screen is unplugged.
function rice.monitor(role)
    return hl.get_monitor("desc:" .. rice.settings.monitors[role].desc)
end

-- Global so scripts/widgets can call helpers, e.g. hyprctl eval 'rice.toggle_app("discord")'
_G.rice = rice

for _, name in ipairs({ "env", "monitors", "look", "input", "special", "rules", "binds", "gamemode", "autostart" }) do
    dofile(dir .. "/modules/" .. name .. ".lua")(rice)
end
