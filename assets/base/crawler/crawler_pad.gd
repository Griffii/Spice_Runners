extends Area2D

@onready var crawler: Area2D = $Crawler  # Variable for the Crawler child node
var crawler_state: String = "idle"  # Default crawler state
@export var crawler_name: String = "CRAWLER NAME"

var is_docked: bool = true


# Reference to the carrier
func _ready() -> void:
	pass




# Track if the crawler is overlapping with the pad or not
func _on_area_entered(area: Area2D) -> void:
	if area == crawler:
		is_docked = true
func _on_area_exited(area: Area2D) -> void:
	if area == crawler:
		is_docked = false


# Spice Unloading Logic
# Unload spice from the crawler to the base storage
func unload_spice(source_crawler):
	print("Crawler is carrying, ", source_crawler.current_spice, " spice.")
	if GameManager.base_manager.get_stored_spice_amount() >= GameManager.base_manager.base_max_spice_storage:
		print("No spice storage left!")
		return
	# Ensure the crawler has spice to unload: Call add_spice from base manager
	if source_crawler.current_spice > 0.0:
		GameManager.base_manager.add_spice(source_crawler.current_spice)
		
		# After spice is added to base, remove from crawler
		source_crawler.current_spice = 0
