
local DEFAULT_INTERVAL = 2

local update_formspec = function(meta)
	meta:set_string("infotext", "Particlefountain")

	meta:set_string("formspec", "size[8,7;]" ..
		"field[0.2,0.5;2,1;amount;Amount;${amount}]" ..
		"field[2.2,0.5;2,1;glow;Glow;${glow}]" ..
		"field[4.2,0.5;2,1;time;Time;${time}]" ..
		"field[6.2,0.5;2,1;spread;Spread;${spread}]" ..

		"list[context;main;0.1,1.5;1,1;]" ..
		"field[4.2,1.5;2,1;speedfactor;Speed-factor;${speedfactor}]" ..
		"button_exit[6.1,1.5;2,1;save;Save]" ..

		"list[current_player;main;0,3;8,4;]" ..
		"listring[]" ..
		"")
end

local function emit_particles(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("main", 1)
	local node_name = stack:get_name()
	if node_name == "ignore" or node_name == "" then
		return true
	end

	local def = minetest.registered_items[node_name]
	if not def then
		return true
	end

	local texture = "default_mese_crystal.png"

	if def.inventory_image and def.inventory_image ~= "" then
		texture = def.inventory_image

	elseif def.tiles then
		if type(def.tiles) == "string" then
			texture = def.tiles

		elseif type(def.tiles) == "table" and #def.tiles >= 1 and def.tiles[1] then
			texture = def.tiles[1]

		end
	end

	local spread = meta:get_int("spread")

	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)

	minetest.add_particlespawner({
		amount = meta:get_int("amount"),
		time = DEFAULT_INTERVAL,
		minpos = vector.add(pos, spread),
		maxpos = vector.add(pos, -spread),
		minvel = dir,
		maxvel = vector.multiply(dir, meta:get_int("speedfactor")),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1,
		maxexptime = meta:get_int("time"),
		minsize = 1,
		maxsize = 1.7,
		collisiondetection = false,
		collision_removal = false,
		object_collision = false,
		vertical = false,
		texture = texture,
		glow = meta:get_int("glow")
	})
end

minetest.register_node("particlefountain:particlefountain", {
	description = "Particlefountain",
	tiles = {
		"default_gold_block.png",
		"default_gold_block.png",
		"default_gold_block.png",
		"default_gold_block.png",
		"default_gold_block.png^default_mese_crystal.png",
		"default_gold_block.png"
	},

	groups = {cracky=3,oddly_breakable_by_hand=3},
	paramtype2 = "facedir",

	on_construct = function(pos)
    local meta = minetest.get_meta(pos)
		meta:set_int("amount", 4)
		meta:set_int("glow", 9)
		meta:set_int("time", 2)
		meta:set_int("spread", 1)
		meta:set_int("speedfactor", 2)

		local inv = meta:get_inventory()
		inv:set_size("main", 1)

    update_formspec(meta, pos)
		minetest.get_node_timer(pos):start(DEFAULT_INTERVAL)
  end,

  on_receive_fields = function(pos, _, fields, sender)
		if not sender or minetest.is_protected(pos, sender:get_player_name()) then
			-- not allowed
			return
		end

		local meta = minetest.get_meta(pos);

		if fields.save then
			meta:set_int("amount", tonumber(fields.amount) or 4)
			meta:set_int("glow", tonumber(fields.glow) or 9)
			meta:set_int("time", tonumber(fields.time) or 2)
			meta:set_int("spread", tonumber(fields.spread) or 1)
			meta:set_int("speedfactor", tonumber(fields.speedfactor) or 2)

			emit_particles(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(DEFAULT_INTERVAL)
		end

		update_formspec(meta)
  end,

	allow_metadata_inventory_put = function(pos, _, _, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, _, _, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,

	mesecons = {
		effector = {
			action_on = function (pos)
				emit_particles(pos)
				local timer = minetest.get_node_timer(pos)
				timer:start(DEFAULT_INTERVAL)
			end,
			action_off = function (pos)
				local timer = minetest.get_node_timer(pos)
				timer:stop()
			end
	  }
	},

	on_timer = function(pos)
		emit_particles(pos)
		return true
	end
})
