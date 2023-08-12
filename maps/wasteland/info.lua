local Public = {}

local changelog =
    [[[font=heading-1]Aug 2023 updates[/font]
 - Outlanders now have their own fractions, allowing them to ally with towns without joining (drop a fish on them)
 - Outlanders can build mini-bases again, with turrets and walls. Note: They lose ownership on disconnect!
 - Offline shields now only work before league 4
 - Shields now protect against all biters, so bases with offline shield are 100% safe
 - Fix more offline base attack exploits
 - Outlanders can build turrets/mines again to fight towns
 - Added a button to build as neutral (bots will ignore+other players can access)
 - League shield now also protects towns offline towns
 - Power poles can no longer be used to block enemy buildings - now only turrets block buildings]]

local info =
    [[[font=heading-1]Welcome to the wasteland[/font]
Build a town that can survive against biters and other players!


]] .. changelog

local info_adv =
    changelog ..
    [[


[font=heading-1]Goal of the game[/font]
- Build or join a town and survive as long as you can
- Raid other towns. Defend your town. Reach 100 score on the leaderboard.

[font=heading-1]Town members, alliances and cease fire[/font]
- Join town: Drop a coin on that outlander (with the Z key). To accept an invite, they also need to drop a coin on you.
- Cease fire: Drop a fish on one of them or their town center (works for outlanders too). If they agree they need to drop a fish on you too.
    - Cease fire only means your weapons (turrets, bots, ..) won't fire on each other automatically. You still can't access the other's bases.
    - If you damage the other party, the ceasefire stops
- Town alliance: Drop a coin on a town member. If they agree they need to drop a coin on you too.
    - They can now access all of your stuff and radar is shared
    - To cancel an alliance, drop coal on them or their member
- Leave a town: Drop coal on the market. Note that their turrets will target you immediately.

[font=heading-1]Leagues and PvP Shields[/font]
- A system to give a chance to players who join later and to protect while offline
- PvP shields prevent players from entering, building and damaging
- League shield protects your town from players of a higher league and cover the outer blue tile square of your town
    - League score limits: 15 score or tank=L2, 35 score=L3, 60 score=L4
- Offline PvP shields deploy automatically once all players of a town leave the game
    - The size is same as your initial town wall, marked by the inner blue tile square
    - This only gets deployed if there are no enemies in your town's range - it is only safe to log out if your town market shows "No enemies"
    - This shield is available before League 4
- Your town has a AFK PvP shield that you can use to safely take a quick break - deploy it from the market
- Biters can't penetrate your shield

[font=heading-1]Advanced tips and tricks[/font]
- To join our discord, open wasteland-discord.fun in your web browser
- It's best to found new towns far from existing towns, as biters advance based on the tech of nearby towns
- Need more ores? Hand mine a few big rocks to find ore patches under them!
- Need more oil? Kill biter worms - some of them will leave you an oil patch
- The town market is the heart of your town. If it is destroyed, you lose everything.
    Protect it well and increase its health by purchasing upgrades.
- It's possible to automate trading with the town center! How cool is that?!! Try it out.
    Tip: use filter inserters to get coins out of the market or to buy items
- Fishes procreate near towns. The more fishes, the quicker they multiply. Automated fish farm, anyone?
    Accidentally overfished? No problem, you can drop them back in
- Use /rename-town NEWNAME (chat command) to rename your town
- If you get stuck or trapped, use the /suicide chat command to respawn
- It is not possible to build near other towns turrets, town centers or PvP shields
    except logistics entities (inserters, belts, boxes, rails) that can be used to steal items from other bases and can be built anywhere except near turrets
- Research modifier: Towns with more members (online+recently offline) have more expensive research. Less advanced towns have cheaper research
- Damage modifier: Members of towns with more online members cause reduced damage against other towns and players
- Biter waves with boss units (the ones with health bar) will attack advanced towns while their players are online
- Played this for the 100th time? Try /skip-tutorial]]

function Public.toggle_button(player)
    if player.gui.top['towny_map_intro_button'] then
        return
    end
    local b = player.gui.top.add({type = 'sprite-button', caption = {'wasteland.gui_info'}, name = 'towny_map_intro_button'})
    b.style.font_color = {r = 0.5, g = 0.3, b = 0.99}
    b.style.font = 'heading-1'
    b.style.minimal_height = 38
    b.style.minimal_width = 80
    b.style.top_padding = 1
    b.style.left_padding = 1
    b.style.right_padding = 1
    b.style.bottom_padding = 1

    local last_winner_name = "[[WINNER_NAME]]"
    local b = player.gui.top.add({type = 'sprite-button', caption = {'wasteland.gui_last_round_winner', last_winner_name},
                                  name = 'towny_map_last_winner'})
    b.style.font_color = {r = 1, g = 0.7, b = 0.1}
    b.style.minimal_height = 38
    b.style.minimal_width = 320
    b.style.top_padding = 1
    b.style.left_padding = 1
    b.style.right_padding = 1
    b.style.bottom_padding = 1
end

function Public.show(player, info_type)
    if player.gui.center['towny_map_intro_frame'] then
        player.gui.center['towny_map_intro_frame'].destroy()
    end
    local frame = player.gui.center.add {type = 'frame', name = 'towny_map_intro_frame'}
    frame = frame.add {type = 'frame', direction = 'vertical'}

    local cap = info
    if info_type == 'adv' then
        cap = info_adv
    end
    local l2 = frame.add {type = 'label', caption = cap}
    l2.style.single_line = false
    l2.style.font = 'heading-2'
    l2.style.font_color = {r = 0.8, g = 0.7, b = 0.99}
end

function Public.close(event)
    if not event.element then
        return
    end
    if not event.element.valid then
        return
    end
    local parent = event.element.parent
    for _ = 1, 4, 1 do
        if not parent then
            return
        end
        if parent.name == 'towny_map_intro_frame' then
            parent.destroy()
            return
        end
        parent = parent.parent
    end
end

function Public.toggle(event)
    if not event.element then
        return
    end
    if not event.element.valid then
        return
    end
    if event.element.name == 'towny_map_intro_button' then
        local player = game.players[event.player_index]
        if player.gui.center['towny_map_intro_frame'] then
            player.gui.center['towny_map_intro_frame'].destroy()
        else
            Public.show(player, 'adv')
        end
    end
end

local function on_gui_click(event)
    Public.close(event)
    Public.toggle(event)
end

local Event = require 'utils.event'
Event.add(defines.events.on_gui_click, on_gui_click)

return Public
