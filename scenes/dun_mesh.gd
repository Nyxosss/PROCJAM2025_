@tool
extends Node3D

@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)
@export var tile_to_room_id : Dictionary = {}

@export var start : bool = false : set = set_start
func set_start(val:bool)->void:
	if Engine.is_editor_hint():
		create_dungeon()

var dun_cell_scene : PackedScene = preload("res://scenes/dun_cell.tscn")

var directions : Dictionary = {
	"up": Vector3i.FORWARD, "down" : Vector3i.BACK,
	"left":Vector3i.LEFT, "right": Vector3i.RIGHT
}

func handle_none(cell:Node3D, dir:String):
	cell.call("remove_frame_"+dir)
func handle_11(cell:Node3D, dir:String, my_room_id:int, neighbor_room_id:int):
	if my_room_id == neighbor_room_id:
		cell.call("remove_wall_"+dir)
	cell.call("remove_frame_"+dir)
func handle_12(cell:Node3D, dir:String, my_room_id:int, neighbor_room_id:int):
	if my_room_id == neighbor_room_id:
		cell.call("remove_wall_"+dir)
	cell.call("remove_frame_"+dir)
func handle_21(cell:Node3D, dir:String, my_room_id:int, neighbor_room_id:int):
	if my_room_id == neighbor_room_id:
		cell.call("remove_wall_"+dir)
	cell.call("remove_frame_"+dir)
func handle_22(cell:Node3D, dir:String, my_room_id:int, neighbor_room_id:int):
	cell.call("remove_wall_"+dir)
	#cell.call("remove_frame_"+dir)
func handle_02(cell:Node3D, dir:String):
	cell.call("remove_wall_"+dir)

func create_dungeon():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	for cell in grid_map.get_used_cells():
		var cell_index : int = grid_map.get_cell_item(cell)
		if cell_index == 2 or cell_index == 1:
			var dun_cell: Node3D = dun_cell_scene.instantiate()
			dun_cell.position = Vector3(cell) + Vector3(0.5, 0, 0.5)
			add_child(dun_cell)
			for i in 4:
				var cell_n : Vector3i = cell + directions.values()[i]
				var cell_n_index : int = grid_map.get_cell_item(cell_n)
				var my_room_id = tile_to_room_id.get(cell, -1)
				var neighbor_room_id = tile_to_room_id.get(cell_n, -1)
				print(my_room_id)
				print(neighbor_room_id)
				if cell_n_index == -1 or cell_n_index == 0:
					if cell_index == 2 and my_room_id == 1:
						handle_02(dun_cell, directions.keys()[i])
					else:
						handle_none(dun_cell, directions.keys()[i])
				else:
					var key: String = str(cell_index) + str(cell_n_index)
					call("handle_"+key, dun_cell, directions.keys()[i], my_room_id, neighbor_room_id)
