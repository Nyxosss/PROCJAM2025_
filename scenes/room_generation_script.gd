@tool
extends Node3D

var grid_map: GridMap = null
@export var dun_mesh_path : NodePath
@onready var dun_mesh : Node3D = get_node(dun_mesh_path)
@export var player_path: NodePath
@onready var room_objects_root := $RoomObjs

func get_grid_map() -> GridMap:
	if grid_map == null:
		if has_node("GridMap"):
			grid_map = $GridMap
	return grid_map

@export var start : bool = false : set = set_start
var room_nodes := {}

var last_player_room_id := -1

func _ready():
	if not Engine.is_editor_hint():
		generate()

func set_start(val: bool) -> void:
	generate()

@export var border_size : int = 25 : set = set_border_size
@export var room_size : int = 7
@export var room_amount: int = 5
@export var room_margin: int = 0
@export var room_object_scene: PackedScene
var room_objects := {}  # room_id → spawned object
var tile_to_room_id := {}
var tile_to_door_id := {}

var room_tiles: Array[PackedVector3Array] = []
var room_pos: PackedVector3Array = []
var current_room_id : int = 0
var current_door_id : int = 1
var first_room_reserved_dir: Vector3i = Vector3i.ZERO
var reserved_side_chosen: bool = false

func _process(delta: float) -> void:
	var player = get_node(player_path)
	if player == null:
		return

	var room_id = get_player_room_id(player.global_position)

	if room_id != last_player_room_id:
		last_player_room_id = room_id
		_update_room_visibility(room_id)

func set_border_size(val: int) -> void:
	border_size = val
	if Engine.is_editor_hint():
		visualize_border()

func visualize_border():
	get_grid_map()
	if grid_map == null:
		print("GridMap not ready yet")
		return
	grid_map.clear()
	for i in range(-1, border_size + 1):
		grid_map.set_cell_item(Vector3i(i,0,-1),0)
		grid_map.set_cell_item(Vector3i(i,0,border_size),0)
		grid_map.set_cell_item(Vector3i(border_size,0,i),0)
		grid_map.set_cell_item(Vector3i(-1,0,i),0)

func generate():
	for c in room_objects_root.get_children():
		c.queue_free()
	room_objects.clear()
	room_tiles.clear()
	room_pos.clear()
	visualize_border()
	var current_room_id = 1
	for i in range(room_amount):
		make_room(current_room_id)
		current_room_id += 1

	var half_size = int(room_size / 2)  # 3
	var center = room_pos[0]
	var door_tile = Vector3i(
		int(center.x) + first_room_reserved_dir.x * half_size,
		0,
		int(center.z) + first_room_reserved_dir.z * half_size
	)
	grid_map.set_cell_item(door_tile, 2)  # 2 = door
	tile_to_door_id[door_tile] = current_door_id

	#var first_room_center = room_pos[0]
	#var door_pos = Vector3i(first_room_center) + first_room_reserved_dir * -3
	#grid_map.set_cell_item(door_pos, 3)  # 2 = door
	
	dun_mesh.tile_to_room_id = tile_to_room_id
	dun_mesh.tile_to_door_id = tile_to_door_id
	await get_tree().process_frame
	#print("--- DUN_MESH DEBUG START ---")
	#print("tile_to_door_id size: ", tile_to_door_id.size())
#
	#for k in tile_to_door_id.keys():
		#print(" key:", k, " type:", typeof(k), " is_Vector3i?:", k is Vector3i, " -> id:", tile_to_door_id[k])
#
	## Also print the first few used cells to compare types
	#var used = grid_map.get_used_cells()
	#print("example used cell count:", used.size())
	#for i in range(min(5, used.size())):
		#var cell = used[i]
		#print(" used cell[", i, "]:", cell, " type:", typeof(cell), " is_Vector3i?:", cell is Vector3i)
	#print("--- DUN_MESH DEBUG END ---")

	dun_mesh.create_dungeon()
	# After dun_mesh creates the dungeon, pull out the dun_cell instances
	room_nodes = dun_mesh.room_nodes
	spawn_room_objects()
	grid_map.hide()
	spawn_player_in_first_room()

func make_room(current_room_id:int) -> bool:
	var height := room_size
	var width := room_size

	# First room: place randomly
	if room_tiles.size() == 0:
		return place_first_room()

	# Next rooms: place adjacent to existing rooms
	var max_attempts := 500

	# Build border list
	var borders := get_all_room_borders()
	# Filter out borders that are “reserved” (-999)
	borders = borders.filter(func(b):
		return tile_to_room_id.get(b, 0) != -999
	)
	
	if borders.size() == 0:
		return false

	for attempt in max_attempts:
		var base = borders[randi() % borders.size()]   # random border tile

		# Try 4 directions around the border
		var directions = [
			Vector3(1,0,0),
			Vector3(-1,0,0),
			Vector3(0,0,1),
			Vector3(0,0,-1)
		]

		var dir = directions[randi() % 4]
		var start_pos = base + dir

		# Offset so the whole room extends from that side
		if dir.x == 1:  start_pos.x -= 0
		if dir.x == -1: start_pos.x -= (width - 1)
		if dir.z == 1:  start_pos.z -= 0
		if dir.z == -1: start_pos.z -= (height - 1)

		# Check if fits within grid
		if not is_room_inside_bounds(start_pos, width, height):
			continue

		# Check tile overlap
		if room_overlaps(start_pos, width, height):
			continue

		# Place room
		place_room(start_pos, width, height, current_room_id)
		
		#doors
		grid_map.set_cell_item(base,2)
		grid_map.set_cell_item(base+dir,2)
		tile_to_door_id[Vector3i(base)] = current_door_id
		tile_to_door_id[Vector3i(base + dir)] = current_door_id
		#tile_to_door_id[base] = current_door_id
		#tile_to_door_id[base+dir] = current_door_id
		#print("PLACED DOOR at ", base, " and ", base+dir, " ID=", current_door_id)
		current_door_id += 1
		return true

	return false


func place_first_room() -> bool:
	var height := room_size
	var width := room_size

	var start_pos := Vector3(
		randi() % (border_size - width + 1),
		0,
		randi() % (border_size - height + 1)
	)

	# Pick a random side to reserve (up/right/down/left)
	var sides = [
		Vector3i(1,0,0),
		Vector3i(-1,0,0),
		Vector3i(0,0,1),
		Vector3i(0,0,-1)
	]
	first_room_reserved_dir = sides[randi() % sides.size()]
	reserved_side_chosen = true

	place_room(start_pos, width, height, 1)
	var first_room := room_tiles[0]
	for tile in first_room:
		if first_room_reserved_dir.x > 0 and tile.x == start_pos.x + width - 1:
			tile_to_room_id[tile] = -999
		elif first_room_reserved_dir.x < 0 and tile.x == start_pos.x:
			tile_to_room_id[tile] = -999
		elif first_room_reserved_dir.z > 0 and tile.z == start_pos.z + height - 1:
			tile_to_room_id[tile] = -999
		elif first_room_reserved_dir.z < 0 and tile.z == start_pos.z:
			tile_to_room_id[tile] = -999
	
	return true


func room_overlaps(start_pos: Vector3, width: int, height: int) -> bool:
	for r in range(height):
		for c in range(width):
			var pos := start_pos + Vector3(c, 0, r)
			if grid_map.get_cell_item(pos) == 1:
				return true
	return false


func is_room_inside_bounds(start_pos: Vector3, width: int, height: int) -> bool:
	if start_pos.x < 0: return false
	if start_pos.z < 0: return false
	if start_pos.x + width >= border_size: return false
	if start_pos.z + height >= border_size: return false
	return true

func get_all_room_borders() -> Array:
	var borders := []

	for room in room_tiles:
		for tile in room:
			# check 4-neighbor directions
			var neighbors = [
				tile + Vector3(1,0,0),
				tile + Vector3(-1,0,0),
				tile + Vector3(0,0,1),
				tile + Vector3(0,0,-1)
			]

			for n in neighbors:
				if grid_map.get_cell_item(n) == -1:
					borders.append(tile)
					break

	return borders

func place_room(start_pos: Vector3, width: int, height: int, room_id:int):
	var room := PackedVector3Array()
	
	for r in range(height):
		for c in range(width):
			#var pos := start_pos + Vector3(c, 0, r)
			var pos := Vector3i(start_pos.x + c, 0, start_pos.z + r)
			grid_map.set_cell_item(pos, 1)
			room.append(pos)
			tile_to_room_id[pos] = room_id

	room_tiles.append(room)

	var center := Vector3(
		start_pos.x + width * 0.5,
		0,
		start_pos.z + height * 0.5
	)
	room_pos.append(center)

func isDiagonal(w: int,h: int) -> bool:
	if (w == -1 || w == room_size):
		return (h == -1 or h == room_size)
	return false

func spawn_player_in_first_room():
	if room_pos.size() == 0:
		print("No rooms generated")
		return

	var player = get_node(player_path)
	if player == null:
		print("Player error!")
		return

	var center = room_pos[0]

	player.global_position = Vector3(center.x, 1.5, center.z)

func world_to_tile(pos: Vector3) -> Vector3i:
	return Vector3i(int(pos.x), 0, int(pos.z))

func get_player_room_id(player_pos: Vector3) -> int:
	var tile := world_to_tile(player_pos)
	if tile_to_room_id.has(tile):
		return tile_to_room_id[tile]
	return -1

func get_rooms_player_is_not_in(player_pos: Vector3) -> Array[int]:
	var player_room = get_player_room_id(player_pos)
	var result := []

	for i in range(room_tiles.size()):
		var room_id = i + 1
		if room_id != player_room:
			result.append(room_id)

	return result

func _update_room_visibility(current_room_id: int) -> void:
	for id in room_nodes.keys():
		var visible = (id == current_room_id)
		for node in room_nodes[id]:
			node.visible = visible
	for id in room_objects.keys():
		room_objects[id].visible = (id == current_room_id)
		
#func spawn_room_objects():
	#for i in range(room_tiles.size()):
		#var room_id := i + 1
		#var tiles := room_tiles[i]
#
		#if tiles.size() == 0:
			#continue
#
		#
		## Pick a random tile inside the room
		#var tile := tiles[randi() % tiles.size()]
		#
		#var world_pos := Vector3(tile.x + 0.5, 0, tile.z + 0.5)
#
		#var obj := room_object_scene.instantiate()
		#room_objects_root.add_child(obj)
		#obj.global_position = world_pos
		#room_objects[room_id] = obj

#func spawn_room_objects():
	#for i in range(room_tiles.size()):
		#var room_id = i + 1
		#var tiles := room_tiles[i]
#
		## Skip empty rooms
		#if tiles.size() == 0:
			#continue
#
		## Filter out tiles that are doors
		#var valid_tiles = []
		#for tile in tiles:
			#if not tile_to_door_id.has(tile):
				#valid_tiles.append(tile)
#
		## If no valid tiles, just skip this room
		#if valid_tiles.size() == 0:
			#continue
#
		## Pick a random tile from the remaining ones
		#var tile = valid_tiles[randi() % valid_tiles.size()]
		#var world_pos := Vector3(tile.x + 0.5, 0, tile.z + 0.5)
#
		#var obj := room_object_scene.instantiate()
		#room_objects_root.add_child(obj)
		#obj.global_position = world_pos

func spawn_room_objects():
	if room_object_scene == null:
		return  # nothing to spawn

	var neighbor_dirs := [
		Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(-1,0,0),
		Vector3i(0,0,1), Vector3i(0,0,-1)
	]
	
	# Clear previous objects
	for c in room_objects_root.get_children():
		c.queue_free()
	room_objects.clear()

	for i in range(room_tiles.size()):
		var room_id := i + 1
		var tiles := room_tiles[i]
		if tiles.size() == 0:
			continue

		# Filter out tiles that are doors or adjacent to doors
		var valid_tiles := []
		for tile in tiles:
			var near_door := false
			if tile_to_door_id.has(tile):
				near_door = true
			for dir in neighbor_dirs:
				if tile_to_door_id.has(Vector3i(tile) + dir):
					near_door = true
					break
			if not near_door:
				valid_tiles.append(tile)

		if valid_tiles.size() == 0:
			continue

		# Pick a random tile
		var tile = valid_tiles[randi() % valid_tiles.size()]
		var world_pos = tile + Vector3(0.5, 0.5, 0.5)

		# Instance the object and add it to the container
		var obj := room_object_scene.instantiate()
		room_objects_root.add_child(obj)
		obj.global_position = world_pos

		# Store reference
		room_objects[room_id] = obj
