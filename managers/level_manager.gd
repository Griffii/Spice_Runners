extends Node2D

# Reference to the currently loaded level
var current_level: Node = null 
#var tile_data: TileMapLayer = null ## Moved script to current_level, this is not needed?

# Array of levels for the tutorial
var in_tutorial: bool = false
var current_level_index = 0
var tutorial_levels: Array = [
	"res://levels/tutorial/tutorial_level_01.tscn",
	"res://levels/tutorial/tutorial_level_02.tscn"
]

###############################################################################
###          Load and unload levels
###############################################################################

# Function to load a level scene
func load_level(level_path: String) -> void:
	# Unload the current level, if any
	if current_level:
		current_level.queue_free()
		current_level = null
		#tile_data = null
	
	# Load the new level scene
	var level_scene = load(level_path)
	if level_scene:
		current_level = level_scene.instantiate()
		GameManager.current_scene = current_level # Track current main scene in GameManager
		add_child(current_level)  # Add the level as a child of Level_Manager
		print("Loaded level: ", level_path)
		#tile_data = current_level.get_node("TileMapLayer")
	else:
		print("Failed to load level: ", level_path)

func load_tutorial():
	# Check there are tutorial levels remaining
	if (current_level_index) < tutorial_levels.size():
		# Get the level path from the array
		var next_level = tutorial_levels[current_level_index]
		# load the level
		load_level(next_level)
		# Increment the index
		current_level_index += 1
	else:
		# No more tutorial levels - Load to main menu
		in_tutorial = false
		GameManager.ui_manager.load_main_menu()

# Function to unload the current level
func unload_level() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null
		GameManager.current_scene.queue_free()
		GameManager.current_scene = null
		#tile_data = null
		print("Level unloaded.")


###############################################################################
###          Get data from loaded level
###############################################################################

# Function to get level data - TileMapLayer data
##func get_level_tile_data() -> TileMapLayer:
	##return tile_data


# Check if a tile contains spice
func has_spice_at_position(world_position: Vector2) -> bool:
	var tile_coords = current_level.tilemap.local_to_map(world_position)  # Convert world position to tile coordinates
	return current_level.spice_tiles.has(tile_coords)

# Get the amount of spice on a tile
func get_spice_amount_at_position(world_position: Vector2) -> int:
	var tile_coords = current_level.tilemap.local_to_map(world_position)
	if current_level.spice_tiles.has(tile_coords):
		return current_level.spice_tiles[tile_coords]
	return 0  # No spice on this tile

# Check adjacent tiles for spice
func check_nearby_spice(world_position: Vector2, search_radius: int) -> Array:
	var tile_coords = current_level.tilemap.local_to_map(world_position)  # Convert world position to tile coordinates
	var spice_tiles = []  # Array to hold the coordinates of tiles with spice
	
	# Iterate through tiles in the square around the given tile
	for x in range(-search_radius, search_radius + 1):
		for y in range(-search_radius, search_radius + 1):
			var check_coords = tile_coords + Vector2i(x, y)
			
			# Optional: Check if the tile is within a circular radius
			if check_coords.distance_to(tile_coords) <= search_radius:
				# Check if the tile contains spice
				if current_level.spice_tiles.has(check_coords):
					spice_tiles.append(check_coords)
	
	return spice_tiles

# Give a global position for a given grid position
func grid_to_coord(grid_position: Vector2i) -> Vector2:
	return current_level.tilemap.map_to_local(grid_position)
# Give a grid position for a given global position
func coord_to_grid(coord: Vector2) -> Vector2i:
	return current_level.tilemap.local_to_map(coord)

###############################################################################
###          Change data from loaded level
###############################################################################

# Reduce the spice on a tile
func reduce_spice_at_tile(world_position: Vector2, amount: int) -> void:
	var tile_coords = current_level.tilemap.local_to_map(world_position)
	if current_level.spice_tiles.has(tile_coords):
		current_level.spice_tiles[tile_coords] = max(current_level.spice_tiles[tile_coords] - amount, 0)
		
		# If the spice is depleted, remove the tile from the dictionary
		if current_level.spice_tiles[tile_coords] <= 0:
			current_level.spice_tiles.erase(tile_coords)
			print("Spice depleted at tile: ", tile_coords)
