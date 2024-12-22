extends Node2D

# Reference to the currently loaded level
var current_level: Node = null 
var tile_data: TileMapLayer = null

###############################################################################
###          Load and unload levels
###############################################################################

# Function to load a level scene
func load_level(level_path: String) -> void:
	# Unload the current level, if any
	if current_level:
		current_level.queue_free()
		current_level = null
		tile_data = null
	
	# Load the new level scene
	var level_scene = load(level_path)
	if level_scene:
		current_level = level_scene.instantiate()
		add_child(current_level)  # Add the level as a child of Level_Manager
		print("Loaded level: ", level_path)
		tile_data = current_level.get_node("TileMapLayer")
	else:
		print("Failed to load level: ", level_path)

# Function to unload the current level
func unload_level() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null
		tile_data = null
		print("Level unloaded.")


###############################################################################
###          Get data from loaded level
###############################################################################

# Function to get level data - TileMapLayer data
func get_level_tile_data() -> TileMapLayer:
	return tile_data

# Check if a tile contains spice
func has_spice_at_position(world_position: Vector2) -> bool:
	var tile_coords = tile_data.local_to_map(world_position)  # Convert world position to tile coordinates
	return tile_data.spice_tiles.has(tile_coords)

# Get the amount of spice on a tile
func get_spice_amount_at_position(world_position: Vector2) -> int:
	var tile_coords = tile_data.local_to_map(world_position)
	if tile_data.spice_tiles.has(tile_coords):
		return tile_data.spice_tiles[tile_coords]
	return 0  # No spice on this tile

# Check adjacent tiles for spice
func check_nearby_spice(world_position: Vector2, search_radius: int) -> Array:
	var tile_coords = tile_data.local_to_map(world_position)  # Convert world position to tile coordinates
	var spice_tiles = []  # Array to hold the coordinates of tiles with spice
	
	# Iterate through tiles in the square around the given tile
	for x in range(-search_radius, search_radius + 1):
		for y in range(-search_radius, search_radius + 1):
			var check_coords = tile_coords + Vector2i(x, y)
			
			# Optional: Check if the tile is within a circular radius
			if check_coords.distance_to(tile_coords) <= search_radius:
				# Check if the tile contains spice
				if tile_data.spice_tiles.has(check_coords):
					spice_tiles.append(check_coords)
	
	return spice_tiles

# Give a global position for a give grid position
func grid_to_coord(grid_position: Vector2i) -> Vector2:
	return tile_data.map_to_local(grid_position)

###############################################################################
###          Change data from loaded level
###############################################################################

# Reduce the spice on a tile
func reduce_spice_at_tile(world_position: Vector2, amount: int) -> void:
	var tile_coords = tile_data.local_to_map(world_position)
	if tile_data.spice_tiles.has(tile_coords):
		tile_data.spice_tiles[tile_coords] = max(tile_data.spice_tiles[tile_coords] - amount, 0)
		
		# If the spice is depleted, remove the tile from the dictionary
		if tile_data.spice_tiles[tile_coords] <= 0:
			tile_data.spice_tiles.erase(tile_coords)
			print("Spice depleted at tile: ", tile_coords)
