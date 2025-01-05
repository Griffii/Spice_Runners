extends Node2D

# References to managers
@onready var level_manager = get_node("/root/Main_Scene/Level_Manager")
@onready var base_manager = get_node("/root/Main_Scene/Base_Manager")
@onready var ui_manager = get_node("/root/Main_Scene/UI_Manager")
@onready var audio_manager = get_node("/root/Main_Scene/Audio_Manager")

# Reference to the currently loaded scene
var current_scene: Node = null

# Reference to players money
var money: float = 0.0


func _ready() -> void:
	ui_manager.load_main_menu()


func get_current_map() -> TileMapLayer:
	var current_map = level_manager.current_level.tilemap
	return current_map


func load_next_level():
	# Free current scene
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	if level_manager:
		if level_manager.in_tutorial == true:
			level_manager.load_tutorial()
		else:
			# Load random level
			print("Only tutorial levels are currently available.")
	
	
	# Load the base
	if base_manager:
		base_manager.load_base()
	else:
		print("Base Manager not found!")
	
	# Load UI
	if ui_manager:
		ui_manager.load_gameplay_ui()
	else:
		print("UI Manager not found!")
	
	# Load Audio
	## When I set it up...
	


###############################################################################
###
###       In Game Functions
###
###############################################################################

# Function to find the nearest idle carrier
func find_nearest_carrier(beacon_position: Vector2) -> Node2D:
	var nearest_carrier = null
	var min_distance = INF
	for carrier in get_tree().get_nodes_in_group("carriers"):
		if carrier.payload == null:
			var distance = carrier.global_position.distance_to(beacon_position)
			if distance < min_distance:
				min_distance = distance
				nearest_carrier = carrier
	return nearest_carrier

# Function to find the nearest idle crawler
func find_nearest_crawler(beacon_position: Vector2) -> Node2D:
	var nearest_crawler = null
	var min_distance = INF
	for crawler in get_tree().get_nodes_in_group("crawlers"):
		# Ensure the crawler is idle and has storage available
		if crawler.is_idle() and (crawler.current_spice < crawler.max_storage):
			var distance = crawler.global_position.distance_to(beacon_position)
			if distance < min_distance:
				min_distance = distance
				nearest_crawler = crawler
	return nearest_crawler

# Function to activate the carrier for the beacon
func activate_carrier_for_beacon(beacon_position: Vector2) -> void:
	var carrier = find_nearest_carrier(beacon_position)
	var crawler = find_nearest_crawler(beacon_position)
	if carrier and crawler:
		#print("Activating carrier for beacon at: ", beacon_position)
		carrier.activate(beacon_position, crawler)
	else:
		print("No available carrier or crawler!")

func activate_carrier_for_crawler(crawler: Area2D) -> void:
	var carrier = find_nearest_carrier(crawler.global_position)
	
	if carrier:
		#print("Activating carrier for crawler at: ", crawler.global_position)
		carrier.activate(crawler.platform.global_position, crawler)
