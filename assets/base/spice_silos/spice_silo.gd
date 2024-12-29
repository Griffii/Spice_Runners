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

var silo1_x: int = -6
var silo2_x: int = 4
var silo3_x: int = 14

var silo_lvl2_y: int = 12

var silo_lvl1_max_size: int = 11
var silo_lvl2_max_size: int = 22

@onready var animplayer: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $StorageLabel

func _ready() -> void:
	load_silo()
	

func _process(delta: float) -> void:
	update_spice_meter()
	label.text = str(silo1_storage) + "|" + str(silo2_storage) + "|" + str(silo3_storage)


func load_silo():
	#Check Level and set sprite
	if silo_level == 2:
		animplayer.play("lvl_2")
		## Set spice meters
		# Get max height of color rectangles (should all be the same)
		spice_meter_max = silo_lvl2_max_size
		# Set start x position for all 3 meters
		silo1_spice.position.x = silo1_x
		silo2_spice.position.x = silo2_x
		silo3_spice.position.x = silo3_x
		# Set start y position for all 3 meters
		silo1_spice.position.y = silo_lvl2_y
		silo2_spice.position.y = silo_lvl2_y
		silo3_spice.position.y = silo_lvl2_y
		
		# Empty silos of spice on spawn (Set color rects to 0)
		silo1_spice.size.y = 0
		silo2_spice.size.y = 0
		silo3_spice.size.y = 0
	
	elif silo_level == 3:
		animplayer.play("lvl_3")
	
	else:
		animplayer.play("lvl_1")
		# Get max height of color rectangles (should all be the same)
		spice_meter_max = silo_lvl1_max_size
		# Set start position for all 3 meters
		silo1_spice.position.x = silo1_x
		silo2_spice.position.x = silo2_x
		silo3_spice.position.x = silo3_x
		# Empty silos of spice on spawn (Set color rects to 0)
		silo1_spice.size.y = 0
		silo2_spice.size.y = 0
		silo3_spice.size.y = 0


# Checks how much spice storage there is, takes it from the pad and returns the leftover amount
func receive_spice(amount: float) -> float:
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
		return 0.0;

# Distributes the spice taken from receive_spice among the silos
func fill_silo(amount: float):
	# Add to total storage
	current_storage += amount
	
	# Pick a specific silo to fill, starting with 1
	if silo1_storage < single_silo_storage:
		print("Filling Silo 1...")
		silo1_storage += amount
		# Check for overflow
		if silo1_storage > single_silo_storage:
			var overflow = silo1_storage - single_silo_storage
			silo1_storage = single_silo_storage
			amount = overflow
		else:
			amount = 0.0
	# Fill silo 2
	if amount != 0 and silo2_storage < single_silo_storage:
		print("Filling Silo 2...")
		silo2_storage += amount
		# Check for overflow
		if silo2_storage > single_silo_storage:
			var overflow = silo2_storage - single_silo_storage
			silo2_storage = single_silo_storage
			amount = overflow
		else:
			amount = 0.0
	# Fill silo 3
	if amount != 0 and silo3_storage < single_silo_storage:
		print("Filling Silo 3...")
		silo3_storage += amount
		# Check for overflow
		if silo3_storage > single_silo_storage:
			var overflow = silo3_storage - single_silo_storage
			silo3_storage = single_silo_storage
			amount = overflow
		else:
			amount = 0.0
	# Debug check - SHould never call
	if amount != 0.0:
		print("Silos received too much spice, overflow loss of: ", amount)


# Function to update the spice meter in real time
func update_spice_meter():
	# Silo 1 meter
	var percentage_1 = silo1_storage / single_silo_storage
	silo1_spice.size.y = spice_meter_max * percentage_1
	
	# Silo 2 meter
	var percentage_2 = silo2_storage / single_silo_storage
	silo2_spice.size.y = spice_meter_max * percentage_2
	
	# Silo 3 meter
	var percentage_3 = silo3_storage / single_silo_storage
	silo3_spice.size.y = spice_meter_max * percentage_3



# Level up the silo
func level_up():
	silo_level += 1


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		print("Current Spice Stored: ", current_storage)
		
		#if silo_level < 3:
		#	print(self.name, " clicked. Leveling up!")
		#	level_up()
		#	load_silo()
