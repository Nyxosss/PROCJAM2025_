extends Node

@onready var npc_node: Node = $"../NPCNode"
var TURN_NUMBER: int = 0
@onready var turn_label: Label = $"../CanvasLayer/TurnLabel"
var player: Player
var npcs: Array[Npc]
#
var turn_flag: bool = true

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
	for child in npc_node.get_children():
		npcs.append(child)
	for child in owner.get_children():
		if child is Player:
			player = child
			
func all_npcs_done() -> bool:
	var all_npcs_ended: bool = true
	#FILTER OUT REMOVED NPCS
	npcs = npcs.filter(is_instance_valid)
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
