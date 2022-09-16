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
