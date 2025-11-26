extends Camera3D

var mouse_pos: Vector2 = Vector2(0.0, 0.0)

func _input(event):
	pass

func shoot_ray():
	mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	#intersect_ray parameters
	ray_query.from = from
	ray_query.to = to
	var raycast_results = space.intersect_ray(ray_query)
	print('RAYCAST RESULTS: ', raycast_results)
	mouse_pos = Vector2(raycast_results["position"][0], raycast_results["position"][2])
	print('MOUSE POS AFTER RAYCAST RESULTS: ', mouse_pos)
