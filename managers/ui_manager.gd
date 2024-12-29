extends Node2D

# References
@onready var canvaslayer: CanvasLayer = $CanvasLayer
 
@export var in_game_ui: PackedScene
var game_ui_instance: Control = null

# Radio chatter foramter {Sender: Message}
var radio_chatter: Array

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

func start_tutorial():
	print("Starting tutorial...")
	
	# Unload scene
	if GameManager.current_scene:
		GameManager.current_scene.queue_free()
		GameManager.current_scene = null
	
	# Load tutorial map
	if GameManager.level_manager:
		GameManager.level_manager.load_level("res://levels/tutorial/tutorial_level_01.tscn")
	else:
		print ("Level Manager not found!")
	
	# Load the base
	if GameManager.base_manager:
		GameManager.base_manager.load_base()
	else:
		print("Base Manager not found!")
	
	# Load UI
	load_gameplay_ui()


func load_gameplay_ui():
	if in_game_ui:
		game_ui_instance = in_game_ui.instantiate()
		canvaslayer.add_child(game_ui_instance)
		
		print("Game UI loaded.")
	else:
		print("Game UI failed to load.")

func radio_message(sender: String, message: String):
	# Add the new sender-message pair as a dictionary
	radio_chatter.append({
		"sender": sender,
		"message": message
	})
	
	# Limit the array to the 50 most recent messages (optional)
	if radio_chatter.size() > 50:
		radio_chatter.pop_front()
