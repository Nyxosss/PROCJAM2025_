class_name Player
extends CharacterBody3D

@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var npc_node: Node = $"../NPCNode"
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var my_turn: bool = true
var health: int = 10
var is_moving: bool = false
var prop_being_observed: Prop

var tiles_setup_flag: bool = false
var destination_tiles: Array = []
var destination_tile_pos: Vector3

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and \
	my_turn and not is_moving:
		select_destination(event)

func _physics_process(delta: float) -> void:
	if my_turn and is_moving:
		move_to_location(delta)
	if tiles_setup_flag:
		destination_tiles = get_tiles_around(global_position, 2.0)
		tiles_setup_flag = false
		
	if not is_on_floor():
		velocity.y -= gravity * delta		
	move_and_slide()

# ------------------------ MOVEMENT ----------------------

func select_destination(event: InputEvent) -> void:
	if event is InputEventMouseButton and not is_moving and event.is_pressed():
		print('PLAYER POSITION: ', global_position)
		var intersected_floor_tile: StaticBody3D = camera_3d.shoot_ray()
		if destination_tiles.has(intersected_floor_tile):
			destination_tile_pos = Vector3(
				intersected_floor_tile.global_position.x, 
				global_position.y,
				intersected_floor_tile.global_position.z
			)
			print('TIME FOR PLAYER TO MOVE TO: ', destination_tile_pos)
			is_moving = true
		else:
			print('NOT VALID LOCATION')

func move_to_location(delta: float) -> void:
	self.global_position = self.global_position.move_toward(
		destination_tile_pos, delta * 2.0)
	if self.global_position.distance_to(destination_tile_pos) <= 0.01:
		self.global_position = destination_tile_pos
		print('PLAYER DONE MOVING')
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


func get_tiles_around(center: Vector3, radius: float) -> Array:
	var space := get_world_3d().direct_space_state

	var sphere := SphereShape3D.new()
	sphere.radius = radius

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = sphere
	params.transform = Transform3D(Basis(), center)
	params.collide_with_bodies = true

	var results = space.intersect_shape(params)
	var tiles: Array = []
	
	#TODO IF THIS DETECTION IS SUCCESSFUL, EVERYTHING ELSE CAN
	#IF ITS A PROP, CHECK THAT TILE TO SEE IF AN NPC IS THERE;
	#AI LOGIC IS ALREADY IMPLEMENTED, THIS IS THE ONLY THING LEFT
	for res in results:
		tiles.append(res.collider)
	print(tiles[0].name)
	var floor_tiles: Array = tiles.filter(func(node): return node.name == "floor_colision")
	print("Detected tiles after filtering by floor:", floor_tiles)
	return floor_tiles
