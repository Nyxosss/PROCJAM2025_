class_name Player
extends CharacterBody3D

@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var npc_node: Node = $"../NPCNode"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var my_turn: bool = true
var health: int = 10
var is_moving: bool = false
var prop_being_observed: Prop

var tiles_setup_flag: bool = true
var detection_radius: float = 40.0
var destination_tiles: Array = []
var destination_tile_pos: Vector3 = Vector3(0.0, 0.0, 0.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and \
	my_turn and not is_moving:
		select_destination(event)

func _physics_process(delta: float) -> void:
	if my_turn and is_moving:
		move_to_location(delta)
	if tiles_setup_flag:
		get_tiles_around(global_position, 20.0)
		tiles_setup_flag = false
# ------------------------ MOVEMENT ----------------------

func select_destination(event: InputEvent) -> void:
	if event is InputEventMouseButton and not is_moving and event.is_pressed():
		var player_pos: Vector2 = Vector2(global_position.x, global_position.z)
		print('MOUSE POS INSIDE PLAYER: ', camera_3d.mouse_pos)
		print('DISTANCE: ', camera_3d.mouse_pos.distance_to(player_pos))
		#if camera_3d.mouse_pos.distance_to(player_pos) <= movement_area_radius:
		#	print('TIME FOR PLAYER TO MOVE')
		#	print('MOUSE GLOBAL POS: ', camera_3d.mouse_pos)
		#	print('PLAYER GLOBAL POS: ', str(player_pos))
		#	destination_pos = camera_3d.mouse_pos
		#	is_moving = true
		#else:
		#	print('NOT VALID LOCATION')

func move_to_location(delta: float) -> void:
	#self.global_position = self.global_position.move_toward(
	#	Vector3(destination_pos.x, self.global_position.y, destination_pos.y), delta * 2.0)
	#if self.global_position.distance_to(Vector3(destination_pos.x, self.global_position.y, destination_pos.y)) <= 0.01:
	#	self.global_position = Vector3(destination_pos.x, self.global_position.y, destination_pos.y)
		var selected_npc: Npc = select_npc_to_interact()
		if selected_npc == null:
			pass
		else:
			selected_npc.trigger_behavior()
		is_moving = false
		my_turn = false
	
func select_npc_to_interact() -> Npc:
	var selected_npc: Npc
	var npc_list: Array[Npc]
	for child in npc_node.get_children():
		if child is Npc:
			npc_list.append(child)
	print('NPC LIST: ', npc_list)
	if npc_list.size() > 0:
		for npc: Npc in npc_list:
			var distance: float = global_position.distance_to(npc.global_position)
			#if distance <= min_npc_distance:
			#	selected_npc = npc
			#	print('PLAYER IS MAKING NPC TRIGGER THEIR BEHAVIOR')
			#	break
	return selected_npc

func get_tiles_around(center: Vector3, radius: float):
	var space := get_world_3d().direct_space_state

	var sphere := SphereShape3D.new()
	sphere.radius = radius

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = sphere
	params.transform = Transform3D(Basis(), center)
	params.collide_with_bodies = true

	var results = space.intersect_shape(params)

	var tiles: Array = []

	for res in results:
		tiles.append(res.collider)

	print("Detected tiles:", tiles)
	return tiles
