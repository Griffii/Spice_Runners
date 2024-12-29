extends CharacterBody2D

# Movement properties
@export var base_speed: float = 0.0
@export var max_speed: float = 400.0  # Maximum speed at max altitude
@export var acceleration: float = 800.0
@export var deceleration: float = 500.0
@export var rotation_speed: float = 10.0
@export var max_thopter_altitude: float = 10.0  # Maximum height
@export var altitude_change_speed: float = 3  # Speed of altitude adjustment

# Starting Altitude - 0 for landed
var thopter_altitude: float = 0.0

# Node References
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var thopter_sprite: AnimatedSprite2D = $BodySprite
@onready var thopter_collision: CollisionShape2D = $ThopterCollision
@onready var camera: Camera2D = $Camera2D


# Packed Scenes
@export var beacon_scene: PackedScene  # Assign the Beacon Scene in the Inspector



func _ready() -> void:
	print("Thopter ready!")


func _physics_process(delta: float) -> void:
	# Call movement function
	move_player(delta)
	# Move the shadow
	update_shadow()
	# Move camera
	update_camera()
	
	# Beacon handler
	handle_beacon_placement()
	
	# Turn off animation if altitude is 0.0
	if thopter_altitude == 0.0:
		thopter_sprite.stop()
	else:
		thopter_sprite.play()



## Movement Logic ##
# Main movement and speed control
func move_player(delta: float) -> void:
	# Update speed based on altitude
	var current_speed = base_speed + (max_speed - base_speed) * (thopter_altitude / max_thopter_altitude)
	
	# Initialize input direction
	var input_direction: Vector2 = Vector2.ZERO
	
	# Process input
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
	if Input.is_action_pressed("down"):
		input_direction.y += 1

	# Normalize input direction for consistent diagonal speed
	input_direction = input_direction.normalized()

	# Adjust velocity based on input
	if input_direction != Vector2.ZERO:
		# Apply the updated speed dynamically
		velocity = velocity.move_toward(input_direction * current_speed, acceleration * delta)
	else:
		# Decelerate to zero when no input
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	# Rotate to face the direction of travel if moving
	if velocity.length() > 0:  # Only rotate if there is movement
		thopter_sprite.rotation = lerp_angle(thopter_sprite.rotation, velocity.angle() + PI / 2, rotation_speed * delta)
		thopter_collision.rotation = lerp_angle(thopter_sprite.rotation, velocity.angle() + PI / 2, rotation_speed * delta)
	
	# Apply movement
	move_and_slide()
	
	# Process altitude adjustment
	if Input.is_action_pressed("alt_up"):
		thopter_altitude = clamp(thopter_altitude + altitude_change_speed * delta, 0.0, max_thopter_altitude)
	elif Input.is_action_pressed("alt_down"):
		thopter_altitude = clamp(thopter_altitude - altitude_change_speed * delta, 0.0, max_thopter_altitude)
	
	# Calculate the y-offset based on altitude
	var y_offset = lerp(0.0, -80.0, thopter_altitude / max_thopter_altitude)
	
	# Apply the offset to the thopter sprite
	thopter_sprite.position.y = y_offset
	thopter_collision.position.y = y_offset
	
	# Handle turning off collision at greater altitudes
	#if thopter_altitude > 3.0:
	#	thopter_collision.disabled = true
	#else:
	#	thopter_collision.disabled = false
	
	# Debug print for altitude and speed
	##print("Altitude: ", thopter_altitude, " | Speed: ", current_speed)

## Shadow movement logic ##
func update_shadow():
	# Calculate size and transparency based on altitude
	var scale_factor = lerp(2.0, 1.0, thopter_altitude / max_thopter_altitude)  # Larger at lower altitudes
	var alpha = lerp(0.5, 0.1, thopter_altitude / max_thopter_altitude)  # Darker at lower altitudes
	
	# Update the shadow's size
	shadow_sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Update the shadow's transparency
	shadow_sprite.modulate = Color(0, 0, 0, alpha)

## Camera movement logic
func update_camera():
	# Calculate zoom based on altitude
	var min_zoom = Vector2(3.0, 3.0)  # Closest zoom at low altitude
	var max_zoom = Vector2(1.0, 1.0)  # Farthest zoom at high altitude
	camera.zoom = min_zoom.lerp(max_zoom, thopter_altitude / max_thopter_altitude)



## Abilities
# Beacon Placement
func handle_beacon_placement() -> void:
	if thopter_altitude == 0 and Input.is_action_just_pressed("beacon"):
		print("Placing beacon...")
		
		# Spawn the beacon
		var beacon = beacon_scene.instantiate()
		beacon.global_position = global_position
		get_parent().add_child(beacon)
		
		# Notify the Game Manager to activate a carrier
		GameManager.activate_carrier_for_beacon(beacon.global_position)
