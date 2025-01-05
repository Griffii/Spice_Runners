extends Node2D

# References
@onready var canvaslayer: CanvasLayer = $CanvasLayer
 
@export var in_game_ui: PackedScene
@export var day_end_scene: PackedScene
var game_ui_instance: Control = null
var day_end_instance: Control = null

# Radio chatter format {Sender: Message}
var radio_chatter: Array

var end_day_button = null



func get_game_ui() -> Control:
	return game_ui_instance

# Function to load main menu
func load_main_menu():
	# Free current scene
	if GameManager.current_scene:
		GameManager.current_scene.queue_free()
		GameManager.current_scene = null
	
	# Load Main Menu
	var main_menu_scene = load("res://menus/main_menu.tscn")
	if main_menu_scene:
		GameManager.current_scene = main_menu_scene.instantiate()
		add_child(GameManager.current_scene)
	else:
		print("Failed to load Main Menu.")


# Load into the first tutorial level map
func start_tutorial():
	print("Starting tutorial...")
	GameManager.level_manager.in_tutorial = true
	GameManager.load_next_level()


# Load gameplay UI overlay
func load_gameplay_ui():
	if in_game_ui:
		game_ui_instance = in_game_ui.instantiate()
		canvaslayer.add_child(game_ui_instance)
		# Add End Day button reference
		end_day_button = game_ui_instance.get_node("EndDayButton")
		print("Game UI loaded.")
	else:
		print("Game UI failed to load.")

func unload_gameplay_ui():
	canvaslayer.get_node("game_ui").queue_free()

# Load End of Day screen before unloading the level and calling the next level
func end_day():
	# Load End Day Screen
	day_end_instance = day_end_scene.instantiate()
	canvaslayer.add_child(day_end_instance)

# Collects and unloads all currently loaded ui scenes
func unload_all_ui():
	var loaded_ui = canvaslayer.get_children()
	for i in loaded_ui:
		i.queue_free()



func radio_message(sender: String, message: String):
	# Add the new sender-message pair as a dictionary
	radio_chatter.append({
		"sender": sender,
		"message": message
	})
	
	# Limit the array to the 50 most recent messages (optional)
	if radio_chatter.size() > 50:
		radio_chatter.pop_front()
