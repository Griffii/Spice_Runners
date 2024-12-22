extends TileMapLayer

var min_spice_amount: int = 50
var max_spice_amount: int = 300


# Dictionary for all map tiles
# Format: {Vector2i}
var map_tiles: Array = []
# Dictionary to store spice data for tiles
# Format: {Vector2i: spice_amount}
var spice_tiles: Dictionary = {}

# Initialize spice tiles when the scene is loaded
func _ready() -> void:
	initialize_tiles()

# Add tiles to spice dictionary and/or map array
func initialize_tiles() -> void:
	# Loop through all tiles in the TileMap, add spice tiles to the spice array
	for x in range(get_used_rect().position.x, get_used_rect().end.x):
		for y in range(get_used_rect().position.y, get_used_rect().end.y):
			var tile_coords = Vector2i(x, y)
			var tile_id = get_cell_source_id(tile_coords)
			
			# Add tile to map_tiles no matter what
			map_tiles.append(tile_coords)
			
			# Check if the tile is a spice tile (tile_id == 1)
			if tile_id == 1:
				# Assign a random spice amount to the tile
				spice_tiles[tile_coords] = (randi() % (max_spice_amount - min_spice_amount) + min_spice_amount)  # Initialize with a default spice amount


# Function to change tile type
func change_tile_type(tile_position: Vector2, tile_type: int):
	pass
