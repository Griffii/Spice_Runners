extends TileMapLayer

# Dictionary to store spice data for tiles
# Format: {Vector2i: spice_amount}
var spice_tiles: Dictionary = {}


# Initialize spice tiles when the scene is loaded
func _ready() -> void:
	initialize_spice_tiles()

# Initialize spice data for tiles
func initialize_spice_tiles() -> void:
	# Loop through all tiles in the TileMap
	for x in range(get_used_rect().position.x, get_used_rect().end.x):
		for y in range(get_used_rect().position.y, get_used_rect().end.y):
			var tile_coords = Vector2i(x, y)
			var tile_id = get_cell_source_id(tile_coords)
			
			# Check if the tile is a spice tile (tile_id == 1)
			if tile_id == 1:
				spice_tiles[tile_coords] = 100  # Initialize with a default spice amount

# Check if a tile contains spice
func has_spice_at_position(world_position: Vector2) -> bool:
	var tile_coords = local_to_map(world_position)  # Convert world position to tile coordinates
	return spice_tiles.has(tile_coords)

# Get the amount of spice on a tile
func get_spice_amount_at_tile(world_position: Vector2) -> int:
	var tile_coords = local_to_map(world_position)
	if spice_tiles.has(tile_coords):
		return spice_tiles[tile_coords]
	return 0  # No spice on this tile

# Reduce the spice on a tile
func reduce_spice_at_tile(world_position: Vector2, amount: int) -> void:
	var tile_coords = local_to_map(world_position)
	if spice_tiles.has(tile_coords):
		spice_tiles[tile_coords] = max(spice_tiles[tile_coords] - amount, 0)
		
		# If the spice is depleted, remove the tile from the dictionary
		if spice_tiles[tile_coords] <= 0:
			spice_tiles.erase(tile_coords)
			print("Spice depleted at tile: ", tile_coords)
