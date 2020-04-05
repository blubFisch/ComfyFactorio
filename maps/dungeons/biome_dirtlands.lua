local Functions = require "maps.dungeons.functions"
local Get_noise = require "utils.get_noise"

local table_shuffle_table = table.shuffle_table
local table_insert = table.insert
local table_remove = table.remove
local math_random = math.random
local math_abs = math.abs

local decoratives = {"brown-asterisk", "brown-carpet-grass", "brown-fluff", "brown-fluff-dry", "brown-hairy-grass", "brown-asterisk", "brown-fluff", "brown-fluff-dry"}
local ores = {"iron-ore", "iron-ore", "iron-ore", "iron-ore", "copper-ore", "copper-ore", "copper-ore","coal", "coal","stone", "stone"}
local trees = {"dead-dry-hairy-tree", "dead-grey-trunk", "dead-tree-desert", "dry-hairy-tree", "dry-tree"}
local size_of_trees = #trees

local function draw_deco(surface, position, decorative_name, seed)
	if surface.get_tile(position).name == "water" then return end
	local noise = Get_noise("decoratives", position, seed)
	if math_abs(noise) > 0.35 then
		surface.create_decoratives{check_collision = false, decoratives = {{name = decorative_name, position = position, amount = math.floor(math.abs(noise * 3)) + 1}}}
	end
end

local function draw_room_decoratives(surface, room)
	local seed = game.surfaces[1].map_gen_settings.seed + math_random(1, 1000000)
	local decorative_name = decoratives[math_random(1, #decoratives)]
	for _, tile in pairs(room.path_tiles) do draw_deco(surface, tile.position, decorative_name, seed) end
	for _, tile in pairs(room.room_border_tiles) do draw_deco(surface, tile.position, decorative_name, seed) end
	for _, tile in pairs(room.room_tiles) do draw_deco(surface, tile.position, decorative_name, seed) end
end

local function dirtlands(surface, room)
	local path_tile = "dirt-" .. math_random(1, 3)
	for _, tile in pairs(room.path_tiles) do
		surface.set_tiles({{name = path_tile, position = tile.position}}, true)
	end
	
	if not room.room_border_tiles[1] then draw_room_decoratives(surface, room) return end
	
	table_shuffle_table(room.room_tiles)
	for key, tile in pairs(room.room_tiles) do
		surface.set_tiles({{name = "dirt-7", position = tile.position}}, true)
		if math_random(1, 64) == 1 then
			surface.create_entity({name = ores[math_random(1, #ores)], position = tile.position, amount = math_random(250, 500) + global.dungeons.depth * 10})
		else
			if math_random(1, 128) == 1 then
				surface.create_entity({name = trees[math_random(1, size_of_trees)], position = tile.position})
			end
		end
		if key % 128 == 0 and math_random(1, 2) == 1 then
			surface.create_entity({name = Functions.roll_spawner_name(), position = tile.position, force = "enemy"})
		end
		if math_random(1, 320) == 1 then
			surface.create_entity({name = Functions.roll_worm_name(), position = tile.position, force = "enemy"})
		end
		if math_random(1, 512) == 1 then
			surface.create_entity({name = "mineable-wreckage", position = tile.position})
		end
		if math_random(1, 256) == 1 then
			surface.create_entity({name = "rock-huge", position = tile.position})
		end
		if math_random(1, 256) == 1 then
			Functions.common_loot_crate(surface, tile.position)
		else
			if math_random(1, 512) == 1 then
				Functions.uncommon_loot_crate(surface, tile.position)
			end
		end
	end
	
	if room.center then
		if math_random(1, 16) == 1 then
			for x = -1, 1, 1 do
				for y = -1, 1, 1 do
					local p = {room.center.x + x, room.center.y + y}
					surface.set_tiles({{name = "water", position = p}})
					if math_random(1, 4) == 1 then
						surface.create_entity({name = "fish", position = p})
					end
				end
			end
		else
			if math_random(1, 24) == 1 then
				surface.create_entity({name = "crude-oil", position = room.center, amount = Functions.get_crude_oil_amount()})
			end
			if math_random(1, 2) == 1 then
				surface.create_entity({name = Functions.roll_spawner_name(), position = room.center})
			end
		end	
	end
	
	table_shuffle_table(room.room_border_tiles)
	for key, tile in pairs(room.room_border_tiles) do
		surface.set_tiles({{name = "dirt-4", position = tile.position}}, true)
		if key % 8 == 1 then
			surface.create_entity({name = "rock-big", position = tile.position})
		end
	end
	
	draw_room_decoratives(surface, room)
end

return dirtlands