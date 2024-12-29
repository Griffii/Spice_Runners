extends Area2D

# Spice Collection Properties
@export var max_storage: float = 500.0  # Maximum spice the crawler can carry
@export var mining_rate: float = 10.0  # Units of spice collected per second
@export var mining_tile_range: float = 30.0  # Radius within which the crawler moves randomly while mining
@export var search_radius: int = 3 # Distance the crawler will search for spice in tiles
@export var travel_speed: float = 20 # Speed of the crawler when traveling
@export var mining_speed: float = 10 # Speed of crawler when mining

# Mining Variables
var current_spice: float = 0.0  # Amount of spice collected
var mining_timer: float = 0.0  # Tracks total time spent mining
var mining_tick: float = 0.0 # Tracks time between spice collections

var target_position: Vector2
var arrival_distance: float = 1.0  # Distance at which the crawler "arrives"

# Node References
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var spice_map: TileMapLayer = GameManager.get_current_map()
var carrier: Area2D = null  # Reference to the carrier it will/is transport(ing)
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var spice_meter: ColorRect = $SpiceMeter
#var spice_meter_position: Vector2 = (4,-5)
var spice_meter_max_y: int = 22

# Other node references
@onready var platform: Area2D = get_parent() # Reference to the landing pad
@export var crawler_ui_widget_scene: PackedScene


# States
var state: String = "idle"  # States: "idle", "travelling", "mining", "dead"
var crawler_id = 99
var crawler_name

func _ready() -> void:
	load_ui_widget()
	spice_meter.size.y = 0 # Zero out the meter


# Start Mining
func start_mining():
	# Confirm presence of spice
	if GameManager.level_manager.has_spice_at_position(global_position):
		var spice_amount = GameManager.level_manager.get_spice_amount_at_position(global_position)
		var message = "Spice detected! Amount: " + str(spice_amount) + ". Starting mining."
		GameManager.ui_manager.radio_message(crawler_name, message)
		anim_player.play("mining")
		state = "mining"
	else:
		#print("No spice detected. Searching for spice...")
		GameManager.ui_manager.radio_message(crawler_name, "No spice detected. Searching for spice...")
		search_for_spice()

# Stop Mining
func stop_mining() -> void:
	anim_player.play("idle")
	if current_spice >= max_storage:
		#print("Spice stores full. We could use a pick-up!")
		GameManager.ui_manager.radio_message(crawler_name, "Spice stores full. We could use a pick-up!")
		state = "idle"
	elif GameManager.level_manager.get_spice_amount_at_position(global_position) <= 0:
		#print("Spice source depleted, searching for more spice...")
		GameManager.ui_manager.radio_message(crawler_name, "Spice source depleted, searching for more spice...")
		search_for_spice()
	else:
		#print("Mining stopped!")
		GameManager.ui_manager.radio_message(crawler_name, "Mining stopped!")
		state = "idle"


func _process(delta: float) -> void:
	match state:
		"idle":
			idle()
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
		
	# Update the spice meter
	update_spice_meter()

# Mining state logic
func process_mining(delta: float) -> void:
	# Collect spice over time
	mining_timer += delta
	mining_tick += delta
	
	if mining_tick >= 1.0:  # Collect spice every second
		# Increase spice in crawler storage
		current_spice += mining_rate
		##print("Mining... Current Spice: ", current_spice, "/", max_storage)
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
		##print("Spice detected at grids: ", nearby_spice_coords)
		
		# Pick a random value from the array and set it is as the target position
		var new_tile = nearby_spice_coords[randi() % nearby_spice_coords.size()]
		var new_tile_position = GameManager.level_manager.grid_to_coord(new_tile)
		# Set target position as new tiles world position as returned by level manager
		target_position = new_tile_position
		
		##print("Traveling to grid: ", new_tile, " at coords: ", target_position)
		state = "travelling"
	else:
		#print("No spice detected, crawler idle. We'd like a pick-up!")
		GameManager.ui_manager.radio_message(crawler_name, "No spice detected, crawler idle. We'd like a pick-up!")
		state = "idle"

# Move to a new spice tile
func move_to_target(delta: float, target_position: Vector2):
	##print("Moving from: ", global_position, " to: ", target_position)
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
	carrier = carrier_node
	position = carrier.global_position  # Align crawler to carrier's global position
	carrier.add_child(self)  # Make the crawler a child of the carrier
	collision.disabled = true

# Detach the crawler from the carrier
func detach_from_carrier() -> void:
	collision.disabled = false
	if carrier:
		var global_pos = carrier.global_position  # Preserve world position
		carrier.remove_child(self)
		get_parent().add_child(self)
		global_position = global_pos
		carrier = null


# Check if idle
func is_idle() -> bool:
	if state == "idle":
		return true
	else:
		return false

# Sets idle animation 
func idle():
	anim_player.play("idle")
	# If idling on platform, unload current spice storage

# Function to call for pick-up
func call_for_pickup():
	var message = "Calling for pickup at: " + str(global_position)
	GameManager.ui_manager.radio_message(crawler_name, message)
	GameManager.activate_carrier_for_crawler(self)


# Function to get the current spice amount
func get_spice() -> float:
	return current_spice
# Function to reduce spice after transfer
func reduce_spice(amount: int) -> void:
	current_spice = max(current_spice - amount, 0)

func update_spice_meter():
	var percentage = (current_spice / max_storage)
	
	spice_meter.size.y = (spice_meter_max_y * percentage)
	
	##Debug 
	#print("Current Spice: ", current_spice, " | ", percentage)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if crawler is already home
		if position == Vector2.ZERO:
			#print("Crawler already at base, no need for pick-up.")
			GameManager.ui_manager.radio_message(crawler_name, "Crawler already at base, no need for pick-up.")
		else:
			call_for_pickup()


# Load the UI widget to track Crawler info
func load_ui_widget():
	var game_ui = GameManager.ui_manager.get_game_ui()
	
	# Ensure game_ui and its container are valid
	if game_ui:
		var crawler_info_container = game_ui.get_node("CrawlerInfoContainer") as VBoxContainer
		
		if crawler_info_container:
			# Instantiate the UI widget
			var ui_widget = crawler_ui_widget_scene.instantiate()
			# Connect the widget to the crawler
			ui_widget.set_crawler(self)
			# Add the widget as a child of the container
			crawler_info_container.add_child(ui_widget)
		else:
			print("CrawlerInfoContainer not found!")
	else:
		print("Game UI is not loaded! Retrying...")
		# Retry after a short delay
		await get_tree().create_timer(0.1).timeout
		load_ui_widget()
