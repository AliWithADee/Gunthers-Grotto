extends Node

# Cave Generation
const CAVE_SIZE = 50 # number of tiles
const CAVE_TILE_SIZE = 32 # number of pixels

# Items
enum ItemIDs { GEM, REVOLVER_AMMO, DYNAMITE_STICK }
const ITEMS = {
	ItemIDs.GEM: {
		single = "Gem",
		plural = "Gems",
		texture = null
	},
	ItemIDs.REVOLVER_AMMO: {
		single = "Bullet",
		plural = "Bullets",
		texture = null
	},
	ItemIDs.DYNAMITE_STICK: {
		single = "Dynamite Stick",
		plural = "Dynamite Sticks",
		texture = null
	}
}
# Frequencies for each quantity of gems you can recieve from mining gemstones
const GEM_FREQUENCIES = { 1: 50, 2: 35, 3: 15 }
# A pool of gem quantities generated from GEM_FREQUENCIES
var gem_quantity_pool: PoolIntArray
