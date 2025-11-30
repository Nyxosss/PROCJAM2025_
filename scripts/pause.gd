class_name Pause
extends Node

var _pause_menu: PauseMenu = preload("res://scenes/pause_menu.tscn").instantiate()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_menu.return_button_pressed.connect(_on_pause_menu_return_button_pressed)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		if is_ancestor_of(_pause_menu):
			remove_child(_pause_menu)
			get_tree().paused = false
		else:
			add_child(_pause_menu)
			get_tree().paused = true


func _on_pause_menu_return_button_pressed() -> void:
	remove_child(_pause_menu)
	get_tree().paused = false
