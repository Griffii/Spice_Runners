extends Node2D

# Base Properties - User Controlled
@export var level: int = 0
@export var num_of_carriers: int = 2
@export var num_of_crawlers: int = 2
@export var fuel: float = 0.0

var base_max_spice_storage: int
var base_current_spice_storage: int = 0 # Start with no spice at the beginning of the day


# Reference to the base components
@export var thopter_pad_scene: PackedScene
@export var crawler_pad_scene: PackedScene
@export var carrier_pad_scene: PackedScene
@export var spice_silo_scene: PackedScene


# Base Data
var base_perimeter: CollisionShape2D
var base_tiles: Array
# Array for silo nodes
@onready var silo_array: Array = []

# called once at beginning of the game
func _ready() -> void:
	add_silo() # Adds 1 silo to the array


# Function to load the base scene
func load_base() -> void:
	set_perimeter_size()
	assign_base_tiles(GameManager.level_manager.tile_data)
	spawn_thopter_pad()
	spawn_carrier_pads()
	spawn_crawler_pads()
	spawn_spice_silos()
	
	set_max_storage()


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
		var tile_coords = Vector2i(-2,(-2 + i))  # Increment the y-coordinate for each carrier pad
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
		var tile_coords = Vector2i(1,(-2 + i))  # Increment the y-coordinate for each carrier pad
		var spawn_position = GameManager.level_manager.tile_data.map_to_local(tile_coords)  # Convert to global position
		
		#Offset the coords to line up with the perimeter and thopter
		spawn_position.y = spawn_position.y - 16
		
		# Set the position of the carrier_pad instance
		crawler_pad_instance.position = spawn_position
		
		# Add the instance to the Base Manager
		add_child(crawler_pad_instance)
		
		print("Crawler pad spawned at tile:", tile_coords, "Global position:", spawn_position)

func spawn_spice_silos():
	# Check the silo array and spawn silos accordingly
	if silo_array.size() == 0:
		print("No silos available. That doesn't seem right...")
	else:
		for i in silo_array:
			var new_silo_instance = i
			
			# Add the instance to the Base Manager
			add_child(new_silo_instance)


# Add a silo to the array
func add_silo():
	# Check if the PackedScene is set
	if not spice_silo_scene:
		print("Spice silo scene is not set!")
		return
	
	# Instantiate the spice silo scene
	var silo = spice_silo_scene.instantiate()
	
	# Add it to the array
	silo_array.append(silo)
	
	# Calculate the position based on the size of the array
	var index = silo_array.size() - 1  # Current index (0-based)
	var tile_x = (index % 5) - 2  # Calculate x-coord (-2 to 2, based on 5 tiles per row)
	var tile_y = (index / 5) + 1  # Calculate y-coord (1-based, increments every 5 silos)
	
	# Assign the position 
	silo.position = Vector2(tile_x, tile_y) * 32  # 32px grid size

# Check the silo array and set the bases max storage capacity by adding silo storage capacities
func set_max_storage():
	var storage: int = 0
	for i in silo_array:
		storage += i.max_storage
	
	base_max_spice_storage = storage

# Add spice to the base storage:
# Select a silo and send the spice to that silos "recieve_spice(int)" function
func add_spice(amount: int):
	# Take the amount and pass it through the spice silo array filling them up as it goes
	var spice_to_deposit = amount
	for i in silo_array:
		if spice_to_deposit == 0:
			return
		spice_to_deposit = i.receive_spice(spice_to_deposit)
	
	if spice_to_deposit != 0:
		print(spice_to_deposit, " spice was unable to be stored.")
