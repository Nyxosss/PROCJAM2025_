extends Camera3D

var mouse_pos: Vector2 = Vector2(0.0, 0.0)
@onready var player: Player = $"../Player"

func _ready() -> void:
	top_level = true

func _input(event):
	pass
	
func _physics_process(delta: float) -> void:
	global_transform.origin = player.global_transform.origin + Vector3(17, 9, 13)
