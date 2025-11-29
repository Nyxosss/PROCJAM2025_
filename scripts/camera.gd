extends Camera3D

@export var player: Player

func _ready() -> void:
	top_level = true

func _input(event):
	pass
	
func _physics_process(delta: float) -> void:
	if player != null:
		global_transform.origin = player.global_transform.origin + Vector3(17, 9, 13)

func shoot_ray() -> StaticBody3D:
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) *	ray_length

	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = false
	ray_query.collide_with_bodies = true

	var result = space.intersect_ray(ray_query)

	if result and result.has("collider"):
		var body := result["collider"] as Node3D

		if body is StaticBody3D and body.name == "floor_colision":
			print('HIT BODY WITH NAME: ', body.name)
			print('FLOOR POSITION: ', body.global_position)
			return body

	print("Ray hit something else or nothing")
	return null
