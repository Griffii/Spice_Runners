extends Area2D

@onready var crawler: Area2D = $Crawler  # Variable for the Crawler child node
var crawler_state: String = "idle"  # Default crawler state
@export var crawler_name: String = "CRAWLER NAME"

var max_base_storage: float = GameManager.base_manager.max_spice_storage


# Reference to the carrier
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


# Method to update the carrier state
func update_crawler_state(state: String) -> void:
	crawler_state = state
	print(crawler_name, " state updated: ", crawler_state)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("crawlers"):  # Ensure the entering body is a crawler
		print("Crawler entered the pad: ", area.name)
		unload_spice(area)


# Spice Unloading Logic
# Unload spice from the crawler to the base storage
func unload_spice(crawler):
	print("Crawler is carrying, ", crawler.current_spice, " spice.")
	
	if GameManager.base_manager.current_spice_storage >= GameManager.base_manager.max_spice_storage:
		print("No spice storage left!")
		return
	
	# Ensure the crawler has spice to unload
	if crawler.current_spice > 0:
		crawler.current_spice = GameManager.base_manager.add_spice(crawler.current_spice)
		
		# Debugging information
		print("Crawler remaining spice:", crawler.current_spice)