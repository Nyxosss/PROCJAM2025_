extends PanelContainer

@onready var _window := get_window()


func _on_resolution_scale_slider_value_changed(value: float) -> void:
	_window.scaling_3d_scale = value
	%ResolutionScaleValue.text = str(roundi(value * 100.0)) + "%"


func _on_window_mode_button_item_selected(index: int) -> void:
	match index:
		0:
			_window.mode = Window.MODE_WINDOWED
		1:
			_window.mode = Window.MODE_FULLSCREEN
		2:
			_window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func _on_master_volume_slider_value_changed(value: float) -> void:
	%MasterVolumeValue.text = str(roundi(value)) + "%"


func _on_music_volume_slider_value_changed(value: float) -> void:
	%MusicVolumeValue.text = str(roundi(value)) + "%"


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	%SFXVolumeValue.text = str(roundi(value)) + "%"


func _on_v_sync_button_item_selected(index: int) -> void:
	DisplayServer.window_set_vsync_mode(index, _window.get_window_id())


func _on_back_button_pressed() -> void:
	queue_free()
