extends Area2D

# Carrier Properties
@export var speed: float = 50.0  # Movement speed
@export var arrival_distance: float = 1.0  # Distance at which the carrier "arrives"
@export var max_altitude: float = 15.0  # Maximum height
@export var payload_drop_delay: float = 1.0  # Delay before dropping payload
@export var payload_altitude: float = 12.0  # Altitude when dropping or grabbing payload
@export var landing_altitude: float = 0.0
@export var altitude_change_speed: float = 2.0  # Speed of altitude adjustment

# Carrier Properties
var carrier_id = 99
var altitude: float = 0.0  # Current altitude of the carrier
var takeoff_in_progress: bool = false # Check if take off in in progress
var target_position: Vector2
var beacon_ping_position: Vector2
var payload: Area2D = null  # The payload (crawler) the carrier is carrying
var payload_attached: bool = false

# Child Node References
@onready var shadow_sprite: Sprite2D = $shadow_sprite
@onready var carrier_sprite: Sprite2D = $carrier_sprite
@onready var collision: CollisionShape2D = $carrier_collision
@onready var animplayer: AnimationPlayer = $AnimationPlayer

# Other node references
@onready var platform: Area2D = get_parent() # Reference to the landing pad
@export var carrier_ui_widget_scene: PackedScene

# States
var state: String = "idle"  # States: "idle", "picking_up", "delivering", "returning"


func _ready() -> void:
	load_ui_widget()

func _process(delta: float) -> void:
	# Update visual effects
	update_shadow()
	update_sprite_position()
	
	# State Switcher
	match state:
		"idle":
			idle()
		"picking_up": # Moving with no payload, payload destination
			if takeoff_in_progress == true:
				process_takeoff(delta)
			else:
				move_to_target(delta)
			if has_arrived():
				process_landing("picking_up",delta)
		"delivering": # Moving with payload, beacon destination
			if takeoff_in_progress == true:
				process_takeoff(delta)
			else:
				move_to_target(delta)
			if has_arrived():
				process_landing("delivering",delta)
		"returning": # Moving with no payload, base destination
			if takeoff_in_progress == true:
				process_takeoff(delta)
			else:
				move_to_target(delta)
			if has_arrived():
				process_landing("returning",delta)



# Function for external setting of the target position
func set_target_position(world_position: Vector2) -> void:
	target_position = world_position
# Function for other nodes to check state of carrier
func get_state():
	return state
# Function to for set a new state - Use with caution
func force_state(new_state: String):
	state = new_state

# Called by the beacon when it is spawned
func activate(dropoff_position: Vector2, crawler: Area2D) -> void:
	# If carrier has a payload set, it's busy, ignore request
	# This shoould never call
	if payload:
		print("Nearest carrier is busy...")
		return  # Don't activate if the carrier is not idle
	
	print("Activating carrier...")
	# If landed, take off
	if altitude != max_altitude:
		takeoff_in_progress = true # Start take off
	
	state = "picking_up"  # Begin pick up
	# Set location targets
	payload = crawler
	target_position = crawler.global_position
	beacon_ping_position = dropoff_position
	
	##Debug Message
	#print(self.name, " picking up ", payload.name, " at ", target_position)


## Movement and state logic
# Takeoff Logic
func process_takeoff(delta: float) -> void:
	altitude = lerp(altitude, max_altitude, altitude_change_speed * delta)
	if abs(altitude - max_altitude) < 0.1:  # Once at max altitude, return
		takeoff_in_progress = false

# Landing Logic
func process_landing(reason: String, delta: float) -> void:
	var target_altitude: float
	if reason == "returning":
		target_altitude = landing_altitude
	else:
		target_altitude = payload_altitude
	##print("Target Alt: ", target_altitude, " | Current Alt: ", altitude)
	
	# Lower to target altitude
	altitude = lerp(altitude, target_altitude, altitude_change_speed * delta)
	
	# Check if alt is reached
	if abs(altitude - target_altitude) < 0.1:
		# Determine if we are picking up or delivering, if not landing complete.
		if reason == "delivering":
			drop_payload()
			state = "returning"
			print("Crawler delivered, taking off...")
		elif reason == "picking_up":
			pick_up_payload()
			state = "delivering"
			print("Crawler secured, taking off...")
		elif reason == "returning":
			print("Landing complete.")
			state = "idle"
		
		##Debug Message
		#print("Touch down at coords: ", global_position)

# State: Idle
func idle():
	animplayer.play("idle")

func move_to_target(delta: float) -> void:
	# Move towards the target position
	global_position = global_position.move_toward(target_position, speed * delta)

func has_arrived() -> bool:
	return global_position.distance_to(target_position) < arrival_distance

func pick_up_payload() -> void:
	print("Picked up payload")
	if payload:
		animplayer.play("carrying")
		payload_attached = true
		takeoff_in_progress = true
		payload.stop_mining()
		set_target_position(beacon_ping_position) # Change target to the beacon ping

func drop_payload() -> void:
	if payload:
		print("Dropping payload: ", payload.name)
		# Check if payload is overlapping it's pad, if so, prompt the payload to attach to pad
		if payload.platform.is_docked ==true:
			print("Payload docked, unloading.")
			payload.platform.unload_spice(payload)
		else:
			payload.start_mining()
		
		animplayer.play("idle")
		
		# Release the payload after prompting the crawler to start mining
		payload_attached = false
		payload = null
	
	takeoff_in_progress = true
	set_target_position(platform.global_position)  # Return to platform



# Update altitude logic (e.g., ascending or descending)
func update_altitude(delta: float) -> void:
	altitude = clamp(altitude + altitude_change_speed * delta, 0.0, max_altitude)

# Update shadow appearance based on altitude
func update_shadow() -> void:
	# Scale shadow size and adjust transparency
	var scale_factor = lerp(3.5, 2.5, altitude / max_altitude)  # Larger at lower altitudes
	var alpha = lerp(0.7, 0.3, altitude / max_altitude)  # Darker at lower altitudes
	
	shadow_sprite.scale = Vector2(scale_factor, scale_factor)
	shadow_sprite.modulate = Color(0, 0, 0, alpha)

# Update carrier sprite's position (Y-axis offset) based on altitude
func update_sprite_position() -> void:
	var y_offset = lerp(0.0, -55.0, altitude / max_altitude)
	carrier_sprite.position.y = y_offset
	collision.position.y = y_offset # Move collision body too
	
	# Offset the payload if attached     
	if payload_attached and payload:
		var max_crawler_offset = -5
		var crawler_offset = (altitude - payload_altitude) / (max_altitude - payload_altitude) * max_crawler_offset
		payload.global_position = global_position + Vector2(0, crawler_offset)


func load_ui_widget():
	var game_ui = GameManager.ui_manager.get_game_ui()
	
	# Ensure game_ui and its container are valid
	if game_ui:
		var carrier_info_container = game_ui.get_node("CarrierInfoContainer") as VBoxContainer
		
		if carrier_info_container:
			# Instantiate the UI widget
			var ui_widget = carrier_ui_widget_scene.instantiate()
			# Connect the widget to the carrier
			ui_widget.set_carrier(self)
			# Add the widget as a child of the container
			carrier_info_container.add_child(ui_widget)
		else:
			print("CarrierInfoContainer not found!")
	else:
		print("Game UI is not loaded! Retrying...")
		# Retry after a short delay
		await get_tree().create_timer(0.1).timeout
		load_ui_widget()
