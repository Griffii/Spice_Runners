extends Area2D

@export var silo_level: int = 1
@export var max_storage: int = 1500
@export var single_silo_storage: int = 500

var current_storage: int = 0

var silo1_storage: int = 0
var silo2_storage: int = 0
var silo3_storage: int = 0

var spice_meter_max
@onready var silo1_spice: ColorRect = $Silo1_spice
@onready var silo2_spice: ColorRect = $Silo2_spice
@onready var silo3_spice: ColorRect = $Silo3_spice



func _ready() -> void:
	# Get max height of color rectangles (should all be the same)
	spice_meter_max = silo1_spice.size.y
	# Empty silos of spice on spawn (Set color rects to 0)
	silo1_spice.size.y = 0
	silo2_spice.size.y = 0
	silo3_spice.size.y = 0

func _process(delta: float) -> void:
	update_spice_meter()


# Checks how much spice storage there is, takes it from the pad and returns the leftover amount
func receive_spice(amount: int) -> int:
	# Check for storage space
	if current_storage < max_storage:
		# Find out how much storage is available
		var storage_space = max_storage - current_storage
		var spice_stored
		# Check if all spice passed will fit in storage, track how much is stored
		if amount < storage_space:
			spice_stored = amount
		else:
			spice_stored = storage_space
		
		fill_silo(spice_stored)
		return spice_stored
	else:
		return 0;
# Distributes the spice taken from receive_spice among the silos
func fill_silo(amount: int):
	# Add to total storage
	current_storage += amount
	
	# Pick a specific silo to fill, starting with 1
	if silo1_storage < single_silo_storage:
		silo1_storage += amount
		# Check for overflow
		if silo1_storage > single_silo_storage:
			var overflow = silo1_storage - single_silo_storage
			silo1_storage = single_silo_storage
			amount = overflow
		else:
			amount = 0
	# Fill silo 2
	if amount != 0 and silo2_storage < single_silo_storage:
		silo2_storage += amount
		# Check for overflow
		if silo2_storage > single_silo_storage:
			var overflow = silo2_storage - single_silo_storage
			silo2_storage = single_silo_storage
			amount = overflow
		else:
			amount = 0
	# Fill silo 3
	if amount != 0 and silo3_storage < single_silo_storage:
		silo3_storage += amount
		# Check for overflow
		if silo3_storage > single_silo_storage:
			var overflow = silo3_storage - single_silo_storage
			silo3_storage = single_silo_storage
			amount = overflow
		else:
			amount = 0
	# Debug check - SHould never call
	if amount != 0:
		print("Silo received too much spice, overflow loss of: ", amount)


# Function to update the spice meter in real time
func update_spice_meter():
	# Silo 1 meter
	var difference_1 = abs(single_silo_storage - silo1_storage)
	var percentage_1 = float(difference_1) / single_silo_storage
	silo1_spice.size.y = spice_meter_max * percentage_1
	
	# Silo 2 meter
	var difference_2 = abs(single_silo_storage - silo2_storage)
	var percentage_2 = float(difference_2) / single_silo_storage
	silo2_spice.size.y = spice_meter_max * percentage_2
	
	# Silo 3 meter
	var difference_3 = abs(single_silo_storage - silo3_storage)
	var percentage_3 = float(difference_3) / single_silo_storage
	silo3_spice.size.y = spice_meter_max * percentage_3



# Level up the silo: Cha
