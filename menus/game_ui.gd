extends Control


@onready var spice_amount_label: Label = $CenterScreenContainer/SpiceLabel
@onready var radio_label: Label = $RadioChatterContainer/MarginContainer/RadioLabel

# Maximum number of lines to keep in the debug label
@export var max_lines: int = 5


func _ready() -> void:
	spice_amount_label.text = "No Spice"


func _process(delta: float) -> void:
	# Update spice tracker label
	update_base_spice_tracker()
	update_radio_chatter()

func update_radio_chatter():
	# Get the last `max_label_lines` entries
	var start_index = max(0, GameManager.ui_manager.radio_chatter.size() - max_lines)
	var recent_messages = GameManager.ui_manager.radio_chatter.slice(start_index)
	
	var output_text = ""
	for entry in recent_messages:
		output_text += "[%s]: %s\n" % [entry["sender"], entry["message"]]
	radio_label.text = output_text
	

func update_base_spice_tracker():
	# Update spice tracker label
	spice_amount_label.text = "Spice: %d / %d" % [
		GameManager.base_manager.get_stored_spice_amount(), 
		GameManager.base_manager.base_max_spice_storage
		]


func _on_radio_button_pressed() -> void:
	print(GameManager.ui_manager.radio_chatter)
