class_name MainMenu extends Control

@onready var start_button = $StartButton

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	print("Start Tutorial button pressed!")
	get_parent().start_tutorial()
