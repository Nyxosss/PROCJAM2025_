extends Control


func _unhandled_key_input(_event: InputEvent) -> void:
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
