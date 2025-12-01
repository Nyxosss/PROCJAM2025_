extends Control

var _options_menu: OptionsMenu = preload("res://scenes/options_menu.tscn").instantiate()


func _init() -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), 0.5)
	_options_menu.back_button_pressed.connect(_on_options_menu_back_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_options_button_pressed() -> void:
	add_child(_options_menu)


func _on_options_menu_back_button_pressed() -> void:
	remove_child(_options_menu)
