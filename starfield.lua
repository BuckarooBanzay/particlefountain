
local DEFAULT_INTERVAL = 2


local function emit_particles(pos)

	local texture = "default_mese_crystal.png"

	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)

	minetest.add_particlespawner({
		amount = 250,
		time = DEFAULT_INTERVAL,
		minpos = pos,
		maxpos = pos,
		minvel = dir,
		maxvel = vector.add(dir, {x=3, y=3, z=3}),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1,
		maxexptime = 4,
		minsize = 1,
		maxsize = 1.7,
		collisiondetection = false,
		collision_removal = false,
		object_collision = false,
		vertical = false,
		texture = texture,
		glow = 9
	})
end

minetest.register_node("particlefountain:starfield", {
	description = "Starfield",
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
		minetest.get_node_timer(pos):start(DEFAULT_INTERVAL)
  end,

	on_timer = function(pos)
		emit_particles(pos)
		return true
	end
})
