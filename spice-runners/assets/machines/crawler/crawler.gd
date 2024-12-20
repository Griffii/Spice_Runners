extends Area2D

# Spice Collection Properties
@export var max_storage: int = 150  # Maximum spice the crawler can carry
@export var mining_rate: float = 10.0  # Units of spice collected per second
@export var mining_tile_range: float = 30.0  # Radius within which the crawler moves randomly while mining

# Current state and storage
var current_spice: int = 0  # Amount of spice collected
var is_mining: bool = false
var mining_timer: float = 0.0  # Tracks total time spent mining
var mining_tick: float = 0.0 # Tracks time between spice collections

# Node References
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var spice_map: TileMapLayer = get_parent().get_node("TileMapLayer")
var carrier: Area2D = null  # Reference to the carrier, if in transport
@onready var collision: CollisionShape2D = $CollisionShape2D


# Function to get the current spice amount
func get_spice() -> int:
	return current_spice
# Function to reduce spice after transfer
func reduce_spice(amount: int) -> void:
	current_spice = max(current_spice - amount, 0)
	print("Remaining spice in crawler: ", current_spice)


# Called when the crawler is placed on the ground
func start_mining():
	if spice_map.has_spice_at_position(global_position):
		var spice_amount = spice_map.has_spice_at_position(global_position)
		print("Spice detected! Amount: ", spice_amount, ". Starting mining.")
		is_mining = true
		anim_player.play("mining")
	else:
		print("No spice detected. Idle.")
		is_mining = false
		anim_player.play("idle")

func _process(delta: float) -> void:
	if is_mining:
		process_mining(delta)

# Mining state logic
func process_mining(delta: float) -> void:
	# Collect spice over time
	mining_timer += delta
	mining_tick += delta
	
	if mining_tick >= 1.0:  # Collect spice every second
		current_spice = min(current_spice + mining_rate, max_storage)
		print("Mining... Current Spice: ", current_spice, "/", max_storage)
		# Deplete available spice
		spice_map.reduce_spice_at_tile(global_position, mining_rate)
		# Reset timer
		mining_tick = 0.0
	# Stop mining if storage is full or spice is depleted
		if current_spice >= max_storage or !spice_map.has_spice_at_position(global_position):
			stop_mining()
	
	# Randomly move the crawler within the mining_tile_range
	move_randomly_on_tile(delta)


# Random movement within the mining range
func move_randomly_on_tile(delta: float) -> void:
	var random_offset = Vector2(
		randf_range(-mining_tile_range, mining_tile_range),
		randf_range(-mining_tile_range, mining_tile_range)
	)
	position = position.move_toward(global_position + random_offset, 10 * delta)

# Stop mining
func stop_mining() -> void:
	print("Storage full or no more spice to mine. Stopping mining.")
	is_mining = false
	anim_player.play("idle")


# Attach the crawler to the carrier for transport
func attach_to_carrier(carrier_node: Area2D) -> void:
	print("Crawler attached to carrier")
	carrier = carrier_node
	position = Vector2(0, 0)  # Align crawler to carrier's origin
	carrier.add_child(self)  # Make the crawler a child of the carrier
	collision.disabled = true

# Detach the crawler from the carrier
func detach_from_carrier() -> void:
	print("Crawler detached from carrier")
	collision.disabled = false
	if carrier:
		var global_pos = carrier.global_position + position  # Preserve world position
		carrier.remove_child(self)
		get_parent().add_child(self)
		global_position = global_pos
		carrier = null


# Utility function to check if the crawler is idle
func is_idle() -> bool:
	return !is_mining
