extends Node2D

# Base Properties - User Controlled
@export var level: int = 0
@export var num_of_carriers: int = 2
@export var num_of_crawlers: int = 2
@export var fuel: float = 0.0

var max_spice_storage: float
var current_spice_storage: float = 0.0 # Start with no spice at the beginning of the day


# Reference to the base components
@export var thopter_pad_scene: PackedScene
@export var crawler_pad_scene: PackedScene
@export var carrier_pad_scene: PackedScene
@export var spice_silo_01_scene: PackedScene
@export var spice_silo_02_scene: PackedScene
@export var spice_silo_03_scene: PackedScene

# Base Data
var base_perimeter: CollisionShape2D
var base_tiles: Array


# Function to load the base scene
func load_base() -> void:
	set_perimeter_size()
	assign_base_tiles(GameManager.level_manager.tile_data)
	spawn_thopter_pad()
	spawn_carrier_pads()
	spawn_crawler_pads()

# Function to unload the current base
func unload_base() -> void:
	pass



#################
## Logic to dynamically load parts of the bas in based on upgrades etc


func create_base_perimeter():
	# Check if the base_perimeter node exists
	if not has_node("BasePerimeter"):
		# Create the CollisionShape2D node
		base_perimeter = CollisionShape2D.new()
		base_perimeter.name = "BasePerimeter"
		
		# Create the RectangleShape2D and assign it to the CollisionShape2D
		var rect_shape = RectangleShape2D.new()
		base_perimeter.shape = rect_shape
		
		# Add the base_perimeter to the scene
		add_child(base_perimeter)
		
		# Optionally set its position or properties
		base_perimeter.position = Vector2(0, 0)  # Adjust as needed (Center of tile (0,0) is (16,16))
		
		print("Base perimeter node and shape created.")
	else:
		print("Base perimeter already exists:", base_perimeter)

func set_perimeter_size():
	# Ensure the base perimeter and its shape exist
	if not base_perimeter or not base_perimeter.shape:
		print("Base perimeter or shape is missing! Creating it.")
		create_base_perimeter()
	
	# Get the RectangleShape2D from the base perimeter
	if base_perimeter.shape is RectangleShape2D:
		var rect_shape = base_perimeter.shape as RectangleShape2D
		
		# Set the collision size based on the level
		if level == 1 or level == 0:  # Tutorial and Level 1 are 5x5 tiles
			rect_shape.extents = Vector2(80, 80)  # Half the width/height (160x160)
		elif level == 2:  # Level 2 is 7x7 tiles
			rect_shape.extents = Vector2(112, 112)  # Half the width/height (224x224)
		else:  # For Level 3 or higher, set the perimeter to 9x9 tiles
			rect_shape.extents = Vector2(144, 144)  # Half the width/height (288x288)
			
			print("Base perimeter size set to:", rect_shape.extents)
	else:
		print("Base perimeter does not have a valid RectangleShape2D!")

func assign_base_tiles(tilemap: TileMapLayer):
	 # Ensure the perimeter extents exist
	if not base_perimeter or not base_perimeter.shape:
		print("Base perimeter collision shape is missing!")
		return
	
	# Get bounds of the base perimeter
	var global_min = global_position - base_perimeter.shape.extents
	var global_max = global_position + base_perimeter.shape.extents
	
	# Convert bounds to tile coords
	var min_tile_coords = tilemap.local_to_map(global_min)
	var max_tile_coords = tilemap.local_to_map(global_max)
	
	 # Iterate through tiles within the bounds
	for x in range(min_tile_coords.x, max_tile_coords.x + 1):
		for y in range(min_tile_coords.y, max_tile_coords.y + 1):
			var tile_coords = Vector2i(x, y)
			 
			# Use tile_data.get_cell() to check if the tile exists
			if tilemap.map_tiles.has(tile_coords):
				# Add the tile coordinates to the array
				base_tiles.append(tile_coords)
				##print("Base tile added: ", tile_coords)

func spawn_thopter_pad():
	# Check if the PackedScene is set
	if not thopter_pad_scene:
		print("Thopter pad scene is not set!")
		return
	
	# Instantiate the thopter_pad scene
	var thopter_pad_instance = thopter_pad_scene.instantiate()
	
	# Thopter will always spawn at (0,0) - No need to check tile array
	var spawn_position = Vector2i(0,0)  # Convert to global position
	
	# Set the position of the thopter_pad instance
	thopter_pad_instance.position = spawn_position
	
	# Add the instance to the Base Manager
	add_child(thopter_pad_instance)

func spawn_carrier_pads():
	# Check if the PackedScene is set
	if not carrier_pad_scene:
		print("Carrier pad scene is not set!")
		return
	
	# Spawn the specified number of carrier pads
	for i in range(num_of_carriers):
		# Instantiate the carrier_pad scene
		var carrier_pad_instance = carrier_pad_scene.instantiate()
		
		# Calculate the spawn tile position
		var tile_coords = Vector2i(-2, i)  # Increment the y-coordinate for each carrier pad
		var spawn_position = GameManager.level_manager.tile_data.map_to_local(tile_coords)  # Convert to global position
		
		#Offset the coords to line up with the perimeter and thopter
		spawn_position.y = spawn_position.y - 16
		
		# Set the position of the carrier_pad instance
		carrier_pad_instance.position = spawn_position
		
		# Add the instance to the Base Manager
		add_child(carrier_pad_instance)
		
		print("Carrier pad spawned at tile:", tile_coords, "Global position:", spawn_position)

func spawn_crawler_pads():
	# Check if the PackedScene is set
	if not crawler_pad_scene:
		print("Crawler pad scene is not set!")
		return
	
	# Spawn the specified number of carrier pads
	for i in range(num_of_crawlers):
		# Instantiate the crawler_pad scene
		var crawler_pad_instance = crawler_pad_scene.instantiate()
		
		# Calculate the spawn tile position
		var tile_coords = Vector2i(1, i)  # Increment the y-coordinate for each carrier pad
		var spawn_position = GameManager.level_manager.tile_data.map_to_local(tile_coords)  # Convert to global position
		
		#Offset the coords to line up with the perimeter and thopter
		spawn_position.y = spawn_position.y - 16
		
		# Set the position of the carrier_pad instance
		crawler_pad_instance.position = spawn_position
		
		# Add the instance to the Base Manager
		add_child(crawler_pad_instance)
		
		print("Crawler pad spawned at tile:", tile_coords, "Global position:", spawn_position)

# Add spice to the base storage
func add_spice(amount: int) -> int:
	var remaining_capacity = max_spice_storage - current_spice_storage
	var added_spice = min(amount, remaining_capacity)
	current_spice_storage += added_spice
	print("Added ", added_spice, " spice to base. Current storage: ", current_spice_storage, "/", max_spice_storage)
	return added_spice
