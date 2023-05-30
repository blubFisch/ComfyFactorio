local Public = {}

local ScenarioTable = require 'maps.wasteland.table'
local Event = require 'utils.event'

local button_id = "towny_research_balance"

function Public.add_balance_ui(player)
    if player.gui.top[button_id] then
        player.gui.top[button_id].destroy()
    end
    local button = player.gui.top.add {
        type = 'sprite-button',
        caption = 'Research cost',
        name = button_id
    }
    button.visible = false
    button.style.font = 'default'
    button.tooltip = "Cost of your town's research. Lower values mean cheaper (=faster). Depends on the number of recently active town members"
    button.style.font_color = {r = 255, g = 255, b = 255}
    button.style.minimal_height = 38
    button.style.minimal_width = 150
    button.style.top_padding = 2
    button.style.left_padding = 4
    button.style.right_padding = 4
    button.style.bottom_padding = 2
end

function Public.player_changes_town_status(player, in_town)
    player.gui.top[button_id].visible = in_town
end

function Public.format_town_modifier(modifier)
    return string.format('%.0f%%', 100 * 1 / modifier)
end

-- Relative speed modifier, 1=no change
local function calculate_modifier_for_town(town_center)
    local active_player_age_threshold = 4 * 60 * 60 * 60

    local this = ScenarioTable.get_table()
    local max_res = 0
    for _, town_center in pairs(this.town_centers) do
        max_res = math.max(town_center.evolution.worms, max_res)
    end
    local research_modifier = math.min(math.max(max_res, 0.01) / math.max(town_center.evolution.worms, 0.01), 10)

    local active_player_count = 0
    for _, player in pairs(town_center.market.force.players) do
        if game.tick - player.last_online < active_player_age_threshold then
            active_player_count = active_player_count + 1
        end
    end
    local player_modifier = math.max(active_player_count, 1) ^ -0.5

    return player_modifier * research_modifier
end

local function update_modifiers()
    local this = ScenarioTable.get_table()
    for _, town_center in pairs(this.town_centers) do
        if not town_center.research_balance then
            town_center.research_balance = {}
        end
        town_center.research_balance.current_modifier = calculate_modifier_for_town(town_center)

        -- Update UIs of all town players
        for _, player in pairs(town_center.market.force.connected_players) do
            player.gui.top[button_id].caption = "Research cost: " .. Public.format_town_modifier(town_center.research_balance.current_modifier)
        end
    end
end

-- Override research progress as it progresses based on modifier
local function update_research_progress()
    local this = ScenarioTable.get_table()

    for _, town_center in pairs(this.town_centers) do
        local force = town_center.market.force
        if force.current_research then
            if town_center.research_balance.last_research
                    and town_center.research_balance.last_research == force.current_research
            then
                local diff = force.research_progress - town_center.research_balance.last_progress
                force.research_progress = math.min(force.research_progress + diff * (town_center.research_balance.current_modifier - 1), 1)
            end
            town_center.research_balance.last_progress = force.research_progress
            town_center.research_balance.last_research = force.current_research
        end
    end
end

Event.add(defines.events.on_tick, update_research_progress)
Event.on_nth_tick(60, update_modifiers)

return Public
