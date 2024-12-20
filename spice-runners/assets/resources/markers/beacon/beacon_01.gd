extends Node2D

@export var lifespan: float = 30.0  # Time in seconds before the beacon disappears
var time_alive: float = 0.0  # Tracks how long the beacon has been active

func _ready() -> void:
	print("Beacon placed at: ", global_position)

func _process(delta: float) -> void:
	# Increment the time the beacon has been alive
	time_alive += delta
	
	# Remove the beacon after it expires
	if time_alive >= lifespan:
		print("Beacon expired at: ", global_position)
		queue_free()
