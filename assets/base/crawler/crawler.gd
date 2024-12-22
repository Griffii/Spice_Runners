extends Area2D

# Spice Collection Properties
@export var max_storage: int = 500  # Maximum spice the crawler can carry
@export var mining_rate: float = 10.0  # Units of spice collected per second
@export var mining_tile_range: float = 30.0  # Radius within which the crawler moves randomly while mining
@export var search_radius: int = 3 # Distance the crawler will search for spice in tiles
@export var travel_speed: float = 20 # Speed of the crawler when traveling
@export var mining_speed: float = 10 # Speed of crawler when mining

# Mining Variables
var current_spice: int = 0  # Amount of spice collected
var mining_timer: float = 0.0  # Tracks total time spent mining
var mining_tick: float = 0.0 # Tracks time between spice collections

var target_position: Vector2
var arrival_distance: float = 1.0  # Distance at which the crawler "arrives"

# Node References
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var spice_map: TileMapLayer = GameManager.get_current_map()
var carrier: Area2D = null  # Reference to the carrier it will/is transport(ing)
@onready var collision: CollisionShape2D = $CollisionShape2D

# Other node references
@onready var platform: Area2D = get_parent() # Reference to the landing pad


# States
var state: String = "idle"  # States: "idle", "travelling", "mining", "dead"


# Start Mining
func start_mining():
	# Confirm presence of spice
	if GameManager.level_manager.has_spice_at_position(global_position):
		var spice_amount = GameManager.level_manager.get_spice_amount_at_position(global_position)
		print("Spice detected! Amount: ", spice_amount, ". Starting mining.")
		anim_player.play("mining")
		state = "mining"
	else:
		print("No spice detected. Searching for spice...")
		search_for_spice()

# Stop Mining
func stop_mining() -> void:
	anim_player.play("idle")
	if current_spice >= max_storage:
		print("Spice stores full. We could use a pick-up!")
		state = "idle"
	elif GameManager.level_manager.get_spice_amount_at_position(global_position) <= 0:
		print("Spice source depleted, searching for more spice...")
		search_for_spice()
	else:
		print("Mining stopped!")
		state = "idle"


func _process(delta: float) -> void:
	match state:
		"idle":
			anim_player.play("idle")
		"mining":
			process_mining(delta)
		"travelling":
			if target_position:
				move_to_target(delta, target_position)
				if has_arrived():
					start_mining()
			else:
				state = "idle"
		"dead":
			pass

# Mining state logic
func process_mining(delta: float) -> void:
	# Collect spice over time
	mining_timer += delta
	mining_tick += delta
	
	if mining_tick >= 1.0:  # Collect spice every second
		current_spice = min(current_spice + mining_rate, max_storage)
		print("Mining... Current Spice: ", current_spice, "/", max_storage)
		# Deplete available spice
		GameManager.level_manager.reduce_spice_at_tile(global_position, mining_rate)
		# Reset timer
		mining_tick = 0.0
		# Stop mining if storage is full or spice is depleted stop mining
		if current_spice >= max_storage or !GameManager.level_manager.has_spice_at_position(global_position):
			stop_mining()
	
	
	# Randomly move the crawler within the mining_tile_range
	move_randomly_on_tile(delta)

# Search for nearby spice
func search_for_spice():
	var nearby_spice_coords: Array = GameManager.level_manager.check_nearby_spice(global_position, search_radius)
	if nearby_spice_coords.size() > 0:
		print("Spice detected at grids: ", nearby_spice_coords)
		
		# Pick a random value from the array and set it is as the target position
		var new_tile = nearby_spice_coords[randi() % nearby_spice_coords.size()]
		var new_tile_position = GameManager.level_manager.grid_to_coord(new_tile)
		# Set target position as new tiles world position as returned by level manager
		target_position = new_tile_position
		
		print("Traveling to grid: ", new_tile, " at coords: ", target_position)
		state = "travelling"
	else:
		print("No spice detected, crawler idle. We'd like a pick-up!")
		state = "idle"

# Move to a new spice tile
func move_to_target(delta: float, target_position: Vector2):
	print("Moving from: ", global_position, " to: ", target_position)
	global_position = global_position.move_toward(target_position, travel_speed * delta)

# Check if arrived at target position
func has_arrived() -> bool:
	return global_position.distance_to(target_position) < arrival_distance

# Random movement within the mining range
func move_randomly_on_tile(delta: float) -> void:
	var random_offset = Vector2(
		randf_range(-mining_tile_range, mining_tile_range),
		randf_range(-mining_tile_range, mining_tile_range)
	)
	global_position = global_position.move_toward(global_position + random_offset, mining_speed * delta)



# Attach the crawler to the carrier for transport
func attach_to_carrier(carrier_node: Area2D) -> void:
	print("Crawler attached to carrier")
	carrier = carrier_node
	position = carrier.global_position  # Align crawler to carrier's global position
	carrier.add_child(self)  # Make the crawler a child of the carrier
	collision.disabled = true

# Detach the crawler from the carrier
func detach_from_carrier() -> void:
	print("Crawler detached from carrier")
	collision.disabled = false
	if carrier:
		var global_pos = carrier.global_position  # Preserve world position
		carrier.remove_child(self)
		get_parent().add_child(self)
		global_position = global_pos
		carrier = null

# Utility function to check if the crawler is idle
func is_idle() -> bool:
	if state == "idle":
		return true
	else:
		return false

# Function to call for pick-up
func call_for_pickup():
	print(self.name, " calling for pickup at: ", global_position)
	GameManager.activate_carrier_for_crawler(self)


# Function to get the current spice amount
func get_spice() -> int:
	return current_spice
# Function to reduce spice after transfer
func reduce_spice(amount: int) -> void:
	current_spice = max(current_spice - amount, 0)
	print("Remaining spice in crawler: ", current_spice)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if crawler is already home
		if position == Vector2.ZERO:
			print("Crawler already at base, no need for pick-up.")
		else:
			call_for_pickup()
