extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_force: float = 4.5
@export var mouse_sensitivity: float = 0.1
@onready var node_3d: Node3D = $".."


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera_pivot: Node3D

func _ready():
	camera_pivot = $CameraPivot
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("interact"):
		try_interact()
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

		camera_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, -85, 85)

	# ESC to free mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# Move
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

#func try_interact():
	#var cam: Camera3D = $CameraPivot/Camera3D
	#var from = cam.global_transform.origin
	#var to = from + -cam.global_transform.basis.z * 3.0
#
	#print("Ray from: ", from, "  to: ", to)
#
	#var space = get_world_3d().direct_space_state
#
	#var query := PhysicsRayQueryParameters3D.new()
	#query.from = from
	#query.to = to
	#query.exclude = [self]
	#query.collision_mask = 0xFFFFFFFF  # hit everything
#
	#var result = space.intersect_ray(query)
#
	#print("Ray hit: ", result)
#
	#if result:
		#var collider = result.get("collider")
		#print("Collider: ", collider)
#
		#if collider and collider.has_method("use"):
			#print("USE CALLED ON: ", collider)
			#collider.use()
		#else:
			#print("Hit, but collider has no use() method")
	#else:
		#print("NO HIT")
		
		
func try_interact():
	var cam: Camera3D = $CameraPivot/Camera3D
	var from = cam.global_transform.origin
	var to = from + -cam.global_transform.basis.z * 3.0

	print("Ray from: ", from, "  to: ", to)

	var space = get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.exclude = [self]
	query.collision_mask = 1 | 2


	var result = space.intersect_ray(query)

	print("Ray hit: ", result)

	if result:
		var collider = result.get("collider")
		print("Collider: ", collider)

		if collider and collider.has_method("use"):
			print("USE CALLED ON: ", collider)
			collider.use()
			open_sibling_door(collider)
		else:
			print("Hit, but collider has no use() method")
	else:
		print("NO HIT")

func open_sibling_door(clicked_door):
	var clicked_id = clicked_door.door_id
	if clicked_id == -1:
		return

	# Find ALL door nodes in the dungeon and interact with same-id ones
	for door in node_3d.get_tree().get_nodes_in_group("door"):
		print("found")
		if door != clicked_door and door.door_id == clicked_id:
			door.use()
