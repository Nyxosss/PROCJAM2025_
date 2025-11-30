class_name OptionsMenu
extends PanelContainer

signal back_button_pressed

@onready var _resolution_scale_value: Label = %ResolutionScaleValue
@onready var _master_volume_value: Label = %MasterVolumeValue
@onready var _music_volume_value: Label = %MusicVolumeValue
@onready var _sfx_volume_value: Label = %SFXVolumeValue


func _on_resolution_scale_slider_value_changed(value: float) -> void:
	get_window().scaling_3d_scale = value
	_resolution_scale_value.text = "%d%%" % roundi(value * 100.0)


func _on_window_mode_button_item_selected(index: int) -> void:
	match index:
		0:
			get_window().mode = Window.MODE_WINDOWED
		1:
			get_window().mode = Window.MODE_FULLSCREEN
		2:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Master"), value)
	_master_volume_value.text = "%d%%" % roundi(value * 100.0)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), value)
	_music_volume_value.text = "%d%%" % roundi(value * 100.0)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), value)
	_sfx_volume_value.text = "%d%%" % roundi(value * 100.0)


func _on_v_sync_button_item_selected(index: int) -> void:
	DisplayServer.window_set_vsync_mode(index, get_window().get_window_id())


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
