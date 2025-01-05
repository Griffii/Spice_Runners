class_name MainMenu extends Control

@onready var start_button = $CanvasLayer/Button_manager/VBoxContainer/Start

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	print("Start Tutorial button pressed!")
	get_parent().start_tutorial()


func _on_quit_pressed() -> void:
	get_tree().quit()
