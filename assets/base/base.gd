extends Area2D

# Base Storage Properties
@export var max_storage: int = 1000  # Maximum spice the base can store
var current_storage: int = 0  # Current spice stored at the base

# Add spice to the base storage
func add_spice(amount: int) -> int:
	var remaining_capacity = max_storage - current_storage
	var added_spice = min(amount, remaining_capacity)
	current_storage += added_spice
	print("Added ", added_spice, " spice to base. Current storage: ", current_storage, "/", max_storage)
	return added_spice

# Signal handler for when a crawler enters the base
func _on_area_entered(body: Node) -> void:
	print(body, " entered the base area.")
	if body.is_in_group("crawlers"):
		var spice_to_transfer = body.get_spice()
		var transferred_spice = add_spice(spice_to_transfer)
		body.reduce_spice(transferred_spice)
		print("Transferred ", transferred_spice, " spice from crawler to base.")
