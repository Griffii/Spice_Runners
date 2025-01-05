extends Control

# Variables
var spice_collected = 0  # Amount of spice collected (loaded from game data)
var money_made = 0       # Current money (loaded from game data)
var spice_value = 10     # The value of each unit of spice
var animation_duration = 2.0  # Duration of the animation in seconds


# Nodes
@onready var spice_label = $CanvasLayer/Spice_Collected
@onready var money_label = $CanvasLayer/Money_Label
@onready var timer = $Timer

func _ready():
	# Load game data (adjust this to your game's global structure)
	spice_collected = GameManager.base_manager.get_stored_spice_amount()
	money_made = spice_collected * spice_value
	##Debug
	print("Spice Collected: ", spice_collected)
	print("Money Made: $%.2f" % money_made)
	
	# Start the animation for spice tally
	#animate_label(spice_label, 0, spice_collected, animation_duration, "_on_spice_tally_done")
	
	spice_label.text = "%.0f kilos" % spice_collected
	money_label.text = "$%.2f" % money_made
	
	GameManager.money += money_made


func _on_next_day_pressed() -> void:
	print("Next Day Button Pressed")
	
	## Unload Level
	GameManager.level_manager.unload_level()
	## Unload UI
	GameManager.ui_manager.unload_all_ui()
	## Unload the base
	GameManager.base_manager.unload_base()
	
	
	# Load Next Level
	if GameManager.level_manager.in_tutorial == true:
		GameManager.load_next_level()
	else:
		# Load a randomly generated map - Once I can make those
		GameManager.ui_manager.load_main_menu()
	
	# Free/unload self
	self.queue_free()
