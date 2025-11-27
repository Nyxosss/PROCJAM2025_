class_name Npc
extends RigidBody3D

#PERSONALITY
enum Personality {CALM = 0, SCAREDY = 1, BRAVE = 2}
var personality: Personality = Personality.CALM
#BEHAVIOR
enum Behavior {DIE = 0, ATK_RUN_AWAY = 1}
var behavior_weights: Dictionary = {
	Behavior.DIE : 1.0, Behavior.ATK_RUN_AWAY : 0.0
}
var behavior_choice_array: Array[Behavior]

#PROP LOGIC
var current_prop: Prop
var destination_prop: Prop
#FLAGS
var is_moving: bool = false
var is_hiding: bool = false
#
var prop_list: Array[Prop]
var select_prop_flag: bool = true

var player: Player
var my_turn: bool = false
#

func _ready() -> void:
	obtain_prop_list()
	assign_random_personality()

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	#HIDE BEHIND PROP
	if my_turn and is_moving:
		if select_prop_flag:
			select_random_destination_prop()
		else:
			hide_behind_prop(delta)

# ---------------------------- SETUP --------------------------

func obtain_prop_list() -> void:
	print('NPC OWNER: ', owner.name)
	for child in owner.get_children(true):
		print(child)
		#quick and dirty way to obtain the prop list while
		#keeping the hierarchy in place
		if child is Node:
			for c in child.get_children():
				if c is Prop:
					prop_list.append(c)
		if child is Player:
			player = child

func assign_random_personality() -> void:
	var rand_personality: int = randi_range(0, Personality.size() - 1)
	self.personality = rand_personality
	print('NPC personality: ', str(self.personality))
	define_behavior_weights()
	
func define_behavior_weights() -> void:
	match self.personality:
		Personality.CALM:
			behavior_weights[Behavior.DIE] = 0.5
			behavior_weights[Behavior.ATK_RUN_AWAY] = 0.5
		Personality.SCAREDY:
			behavior_weights[Behavior.DIE] = 0.9
			behavior_weights[Behavior.ATK_RUN_AWAY] = 0.1
		Personality.BRAVE:
			behavior_weights[Behavior.DIE] = 0.1
			behavior_weights[Behavior.ATK_RUN_AWAY] = 0.9

# ----------------------- MOVEMENT ------------------------------

func select_random_destination_prop() -> void:
	if prop_list.size() > 0:
		var random_prop: Prop = prop_list[randi_range(0, prop_list.size()-1)]
		print('RANDOM PROP SELECTED: ', random_prop)
		
		if current_prop == null:
			current_prop = prop_list[randi_range(0, prop_list.size()-1)]
		
		while current_prop == random_prop:
			random_prop = prop_list[randi_range(0, prop_list.size()-1)]
		destination_prop = random_prop
		select_prop_flag = false
		
func hide_behind_prop(delta: float) -> void:
	if global_position.distance_to(destination_prop.back_area.global_position) > 0.01:
		global_position = global_position.move_toward(destination_prop.back_area.global_position, delta * 5.0)
	else:
		global_position = destination_prop.back_area.global_position
		current_prop = destination_prop
		if my_turn:
			is_hiding = true
			is_moving = false
			my_turn = false
			player.my_turn = true

# ------------------------- ACTIONS -------------------------

func trigger_behavior() -> void:
	var random_number: float = randf()
	print('DECIDING ', name, ' ACTION')
	fill_behavior_choice_array()
	#PICK RANDOM BEHAVIOR BASED ON WEIGHTS
	var chosen_behavior: Behavior = behavior_choice_array.pick_random()
	print(name, ' CHOSE BEHAVIOR ', chosen_behavior)
	match chosen_behavior:
		Behavior.DIE:
			die()
		Behavior.ATK_RUN_AWAY:
			attack_and_run(get_physics_process_delta_time())
	
func fill_behavior_choice_array() -> void:
	var max_size: int = 20
	var die_amount: int = max_size * behavior_weights[Behavior.DIE]
	var atk_run_amount: int = max_size * behavior_weights[Behavior.ATK_RUN_AWAY]
	for i in randi_range(0, die_amount):
		behavior_choice_array.append(Behavior.DIE)
	for i in randi_range(0, atk_run_amount):
		behavior_choice_array.append(Behavior.ATK_RUN_AWAY)
	print('BEHAVIOR CHOICE ARRAY: ', behavior_choice_array)
	
func die() -> void:
	queue_free()

func attack_and_run(delta: float) -> void:
	attack(player)
	run(delta)
	
func attack(player: Player) -> void:
	player.health -= 2

func run(delta: float) -> void:
	select_random_destination_prop()
	hide_behind_prop(delta)
