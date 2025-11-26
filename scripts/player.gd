class_name Player
extends CharacterBody3D

@onready var camera_3d: Camera3D = $"../Camera3D"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var my_turn: bool = true
var health: int = 10
var is_moving: bool = false

#ADD UI FOR DISPLAYING A CIRCLE WITH THE BELOW RADIUS
#OR HIGHLIGHT ALL TILES WITHIN THIS RANGE 
var movement_area_radius: float = 15.0
var prop_being_observed: Prop
#REPLACE BY TILE CENTER POSITION
var destination_pos: Vector2 = Vector2(0.0, 0.0)
#var possible_walkable_tiles: Array[Tile]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		camera_3d.shoot_ray()
		select_destination(event)

func _physics_process(delta: float) -> void:
	if my_turn and is_moving:
		move_to_location(delta)
		'''
		if not is_on_floor():
			velocity += get_gravity() * delta
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		'''

func select_destination(event: InputEvent) -> void:
	if event is InputEventMouseButton and not is_moving and event.is_pressed():
		var player_pos: Vector2 = Vector2(global_position.x, global_position.z)
		print('MOUSE POS INSIDE PLAYER: ', camera_3d.mouse_pos)
		if camera_3d.mouse_pos.distance_to(player_pos) <= movement_area_radius:
			print('MOUSE GLOBAL POS: ', camera_3d.mouse_pos)
			print('PLAYER GLOBAL POS: ', str(player_pos))
			print('DISTANCE: ', camera_3d.mouse_pos.distance_to(player_pos))
			destination_pos = camera_3d.mouse_pos
			is_moving = true
		else:
			print('NOT VALID LOCATION')

func move_to_location(delta: float) -> void:
	self.global_position = self.global_position.move_toward(
		Vector3(destination_pos.x, self.global_position.y, destination_pos.y), delta * 2.0)
	if self.global_position.distance_to(Vector3(destination_pos.x, self.global_position.y, destination_pos.y)) <= 0.01:
		self.global_position = Vector3(destination_pos.x, self.global_position.y, destination_pos.y)
		is_moving = false
		my_turn = false
