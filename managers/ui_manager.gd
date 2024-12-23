extends Node2D

@onready var level_manager = get_node("/root/Main_Scene/Level_Manager")
@onready var base_manager = get_node("/root/Main_Scene/Base_Manager")
@onready var audio_manager = get_node("/root/Main_Scene/Audio_Manager")


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
	if level_manager:
		level_manager.load_level("res://levels/tutorial/tutorial_level_01.tscn")
	else:
		print ("Level Manager not found!")
	
	# Load the base
	if base_manager:
		base_manager.load_base()
	else:
		print("Base Manager not found!")
