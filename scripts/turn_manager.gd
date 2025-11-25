extends Node

var TURN_NUMBER: int = 0
@onready var turn_label: Label = $"../CanvasLayer/TurnLabel"

var player: Player
var npcs: Array[Npc]
#
var turn_flag: bool = true

func _ready() -> void:
	for child in owner.get_children():
		if child is Player:
			player = child
		if child is Npc:
			npcs.append(child)

func _physics_process(delta: float) -> void:
	if player != null and not player.my_turn and turn_flag:
		now_its_npcs_turn()
	elif player != null and player.my_turn and not turn_flag:
		now_its_players_turn()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_turn"):
		end_player_turn()

func now_its_players_turn() -> void:
	for npc: Npc in npcs:
		npc.my_turn = false
	print('PLAYER TURN')
	player.my_turn = true
	turn_flag = true

func now_its_npcs_turn() -> void:
	for npc: Npc in npcs:
		npc.my_turn = true
		npc.is_moving = true
		npc.select_prop_flag = true
	print('NPCS TURN')
	turn_flag = false
	
#TEST
func end_player_turn() -> void:
	player.my_turn = !player.my_turn
