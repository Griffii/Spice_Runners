extends Area2D

@onready var carrier: Area2D = $Carrier  # Variable for the Carrier child node - Set in Inspector
var carrier_state: String = "idle"  # Default carrier state
@export var carrier_name: String = "CARRIER NAME"

# Reference to the carrier
func _ready() -> void:
	pass

# Method to update the carrier state
func update_carrier_state(state: String) -> void:
	carrier_state = state
	print(carrier_name, " state updated: ", carrier_state)
