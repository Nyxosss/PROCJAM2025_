class_name Npc
extends RigidBody3D

enum Behavior {CALM = 0, SCAREDY = 1, BRAVE = 2}
var behavior: Behavior
var movement_amount: int
#DIE, ATTACK/RUN
var behavior_weights: Array[float] = [0.0, 0.0]
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
	assign_random_behavior()

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

func assign_random_behavior() -> void:
	var rand_behavior: int = randi_range(0, Behavior.size() - 1)
	self.behavior = rand_behavior
	print('NPC BEHAVIOR: ', str(self.behavior))
	define_behavior_weights()
	
func define_behavior_weights() -> void:
	match self.behavior:
		Behavior.CALM:
			behavior_weights = [0.5, 0.5]
		Behavior.SCAREDY:
			behavior_weights = [0.9, 0.1]
		Behavior.BRAVE:
			behavior_weights = [0.1, 0.9]

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
	if global_position.distance_to(destination_prop.back_area.global_position) > 0.3:
		global_position = global_position.move_toward(destination_prop.back_area.global_position, delta * 5.0)
	else:
		global_position = destination_prop.back_area.global_position
		current_prop = destination_prop
		is_hiding = true
		is_moving = false
		end_turn()
# ------------------------- ACTIONS -------------------------

func die() -> void:
	pass

func attack_and_run() -> void:
	attack(player)
	run()
	
func attack(player: Player) -> void:
	pass

func run() -> void:
	pass

func end_turn() -> void:
	my_turn = false
