local Public = {}

local GameSettings = require 'game_settings'

local button_id = "wl_game_mode"

function Public.add_mode_button(player)
    if player.gui.top[button_id] then
        player.gui.top[button_id].destroy()
    end
    local button = player.gui.top.add {
        type = 'sprite-button',
        caption = 'Game Mode: ' .. GameSettings.mode_name,
        name = button_id
    }
    button.tooltip = "Changes game duration, research cost and research score"
    button.style.font_color = {r = 1, g = 1, b = 1}
    button.style.minimal_height = 38
    button.style.minimal_width = 150
    button.style.top_padding = 2
    button.style.left_padding = 4
    button.style.right_padding = 4
    button.style.bottom_padding = 2
end

return Public
