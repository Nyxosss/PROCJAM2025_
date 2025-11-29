extends Node


@onready var npc_node: Node = $"../NPCNode"
@onready var turn_label: Label = $"../CanvasLayer/TurnLabel"
@onready var player: Player = $"../Player"
var TURN_NUMBER: int = 0
var turn_flag: bool = true
var npcs: Array[Npc]

func _ready() -> void:
	add_player_and_npcs()

#VERY INNEFICIENT BUT WORKS
func _physics_process(delta: float) -> void:
	if player != null and not player.my_turn and turn_flag:
		now_its_npcs_turn()
	if player != null and player.my_turn and not turn_flag:
		if all_npcs_done():
			now_its_players_turn()

# ----------------------------------------------

func add_player_and_npcs() -> void:
	for npc: Npc in npc_node.get_children():
		npcs.append(npc)
		npc.player = player
	for child in owner.get_children():
		if child is Prop:
			for npc: Npc in npcs:
				npc.prop_list.append(child)
			
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
	print('NPCS TURN')
	turn_label.text = "NPC TURN"
	turn_flag = false
