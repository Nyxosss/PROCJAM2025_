extends Control

var _options_menu := preload("res://scenes/options_menu.tscn")

@onready var _scene_tree := get_tree()


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		visible = !visible
		_scene_tree.paused = visible


func _on_return_button_pressed() -> void:
	visible = false
	_scene_tree.paused = false


func _on_options_button_pressed() -> void:
	add_child(_options_menu.instantiate())


func _on_quit_button_pressed() -> void:
	_scene_tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	_scene_tree.quit()
