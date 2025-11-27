class_name Player
extends CharacterBody3D

@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var npc_node: Node = $"../NPCNode"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var my_turn: bool = true
var health: int = 10
var is_moving: bool = false

#TODO ADD UI FOR HIGHLIGHTING ALL TILES WITHIN THIS RANGE 
var movement_area_radius: float = 15.0
var prop_being_observed: Prop
#TODO REPLACE BY TILE CENTER POSITION
var destination_pos: Vector2 = Vector2(0.0, 0.0)
#var possible_walkable_tiles: Array[Tile]

#MINIMUM DISTANCE TO NPC TO TRIGGER THEIR BEHAVIOR
#TODO REPLACE LATER WITH A CHECK TO SEE IF PLAYER
#SELECTED A PROP TILE, AND IF ANY NPCS ARE HIDING
#IN THAT TILE
var min_npc_distance: float = 3.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and \
	my_turn and not is_moving:
		camera_3d.shoot_ray()
		select_destination(event)

func _physics_process(delta: float) -> void:
	if my_turn and is_moving:
		move_to_location(delta)
		
# ------------------------ MOVEMENT ----------------------

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
			if distance <= min_npc_distance:
				selected_npc = npc
				print('PLAYER IS MAKING NPC TRIGGER THEIR BEHAVIOR')
				break
	return selected_npc
