class_name Player
extends CharacterBody3D

@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var npc_node: Node = $"../NPCNode"
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var npc_detection_area: Area3D = $NpcDetectionArea
@onready var npc_detection_collision: CollisionShape3D = $NpcDetectionArea/NpcDetectionCollision

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var my_turn: bool = true
var health: int = 10
var is_moving: bool = false
var prop_being_observed: Prop

var destination_tiles: Array = []
var destination_tile_pos: Vector3
var tile_radius: float = 2.0

var end_turn_flag: bool = false
var end_turn_time: float = 1.0
var end_turn_timer: float = 1.0

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and \
	my_turn and not is_moving:
		select_destination(event)

func _physics_process(delta: float) -> void:
	if my_turn and is_moving:
		move_to_location(delta)
		
	if not is_on_floor():
		velocity.y -= gravity * delta		
	move_and_slide()

	if end_turn_flag:
		begin_next_turn_countdown(delta)
# ------------------------ MOVEMENT ----------------------

func select_destination(event: InputEvent) -> void:
	destination_tiles = get_tiles_around(global_position, tile_radius)
	if event is InputEventMouseButton and not is_moving and event.is_pressed():
		print('PLAYER POSITION: ', global_position)
		var intersected_floor_tile: StaticBody3D = camera_3d.shoot_ray()
		print('DESTINATION TILES: ', destination_tiles)
		print('INTERSECTED FLOOR TILE: ', intersected_floor_tile)
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
		destination_tile_pos, delta * 5.0)
	if self.global_position.distance_to(destination_tile_pos) <= 0.01:
		self.global_position = destination_tile_pos
		print('PLAYER DONE MOVING')
		print('RESTRUCTURING DESTINATION TILES')
		destination_tiles = get_tiles_around(global_position, tile_radius)
		print('PLAYER IS GOING TO TRY AND DETECT NPCS NEAR HIM')
		end_turn_flag = true
		
func begin_next_turn_countdown(delta: float) -> void:
	end_turn_time -= delta
	if end_turn_time <= 0.0:
		end_turn()

func end_turn() -> void:
	end_turn_flag = false
	end_turn_time = end_turn_timer
	is_moving = false
	my_turn = false

# ----------------------------------------------------------------

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
	
	for res in results:
		tiles.append(res.collider)
	print(tiles[0].name)
	var floor_tiles: Array = tiles.filter(func(node): return node.name == "floor_colision")
	print("Detected tiles after filtering by floor:", floor_tiles)
	return floor_tiles

func _on_npc_detection_area_body_entered(body: Node3D) -> void:
	if body is Npc and self.my_turn:
		body.trigger_behavior()
