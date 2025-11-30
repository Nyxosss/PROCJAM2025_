extends Node

@onready var npc_node: Node = $"../NPCNode"
@onready var player: Player = $"../Player"
var TURN_NUMBER: int = 0
var turn_flag: bool = true
var npcs: Array[Npc]

@onready var turn_label: Label = $"../CanvasLayer/TurnLabel"
@onready var health_label: Label = $"../CanvasLayer/HealthLabel"
@onready var npc_num_label: Label = $"../CanvasLayer/NpcNumLabel"

var kitchen : Node3D 
var living_room : Node3D
var bathroom : Node3D
var bedroom : Node3D
@onready var room_templates: Node3D = $"../RoomTemplates"

func _ready() -> void:
	await wait_for_children()
	kitchen = $"../RoomTemplates/kitchen_template"
	living_room = $"../RoomTemplates/living_room_template"
	bathroom = $"../RoomTemplates/bathroom_template"
	bedroom = $"../RoomTemplates/BedroomTemplate"
	add_player_and_npcs()

func wait_for_children() -> void:
	while room_templates.get_child_count() != 4:
		await get_tree().process_frame

#VERY INEFFICIENT BUT WORKS
func _physics_process(delta: float) -> void:
	if player != null and not player.my_turn and turn_flag:
		now_its_npcs_turn()
	if player != null and player.my_turn and not turn_flag:
		if all_npcs_done():
			now_its_players_turn()
	
	if player != null:
		health_label.text = "PLAYER HP: " + str(player.health)
	if npcs.size() > 0:
		npc_num_label.text = "NPCS LEFT: " + str(npcs.size())
# ----------------------------------------------

func add_player_and_npcs() -> void:
	for npc: Npc in npc_node.get_children():
		npcs.append(npc)
		if player != null:
			npc.player = player
	#for child in owner.get_children():
		#if child is Prop:
			#for npc: Npc in npcs:
				#npc.prop_list.append(child)
	set_all_props()
	
func all_npcs_done() -> bool:
	#FILTER OUT REMOVED NPCS
	npcs = npcs.filter(is_instance_valid)
	var all_npcs_ended: bool = true
	for npc: Npc in npcs:
		if npc.my_turn:
			all_npcs_ended = false
			break
	if all_npcs_ended:
		player.my_turn = true
	print('ARE ALL NPCS DONE? ', all_npcs_ended)
	return all_npcs_ended

func now_its_players_turn() -> void:
	for npc: Npc in npcs:
		npc.my_turn = false
	print('PLAYER TURN')
	turn_label.text = "PLAYER TURN"
	player.my_turn = true
	turn_flag = true

func now_its_npcs_turn() -> void:
	for npc: Npc in npcs:
		npc.my_turn = true
		npc.is_moving = true
		npc.select_prop_flag = true
		if not npc.axis_lock_linear_y:
			npc.axis_lock_linear_y = !npc.axis_lock_linear_y
		if not npc.axis_lock_angular_y:
			npc.axis_lock_angular_y = !npc.axis_lock_angular_y
	print('NPCS TURN')
	turn_label.text = "NPC TURN"
	turn_flag = false

func set_all_props():
	for child in bedroom.get_children():
		if child is Prop:
			for npc: Npc in npcs:
				npc.prop_list.append(child)
	for child in living_room.get_children():
		if child is Prop:
			for npc: Npc in npcs:
				npc.prop_list.append(child)
	for child in bathroom.get_children():
		if child is Prop:
			for npc: Npc in npcs:
				npc.prop_list.append(child)
	for child in kitchen.get_children():
		if child is Prop:
			for npc: Npc in npcs:
				npc.prop_list.append(child)
