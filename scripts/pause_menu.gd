class_name PauseMenu
extends Control

signal return_button_pressed

var _options_menu: OptionsMenu = preload("uid://151t4be33871").instantiate()


func _init() -> void:
	_options_menu.back_button_pressed.connect(_on_options_menu_back_button_pressed)


func _on_return_button_pressed() -> void:
	return_button_pressed.emit()


func _on_options_button_pressed() -> void:
	add_child(_options_menu)


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_options_menu_back_button_pressed() -> void:
	remove_child(_options_menu)
