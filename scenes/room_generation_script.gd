@tool
extends Node3D

var grid_map: GridMap = null

func get_grid_map() -> GridMap:
	if grid_map == null:
		if has_node("GridMap"):
			grid_map = $GridMap
	return grid_map

@export var start : bool = false : set = set_start

func set_start(val: bool) -> void:
	generate()

@export var border_size : int = 25 : set = set_border_size
@export var room_size : int = 7
@export var room_amount: int = 5
@export var room_margin: int = 0

var room_tiles: Array[PackedVector3Array] = []
var room_pos: PackedVector3Array = []


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
	room_tiles.clear()
	room_pos.clear()
	visualize_border()
	for i in range(room_amount):
		print(i)
		make_room()

func make_room() -> bool:
	var height := room_size
	var width := room_size

	# First room: place randomly
	if room_tiles.size() == 0:
		return place_first_room()

	# Next rooms: place adjacent to existing rooms
	var max_attempts := 500

	# Build border list
	var borders := get_all_room_borders()
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
		place_room(start_pos, width, height)
		
		#doors
		grid_map.set_cell_item(base,2)
		grid_map.set_cell_item(base+dir,2)
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

	place_room(start_pos, width, height)
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

func place_room(start_pos: Vector3, width: int, height: int):
	var room := PackedVector3Array()
	
	for r in range(height):
		for c in range(width):
			var pos := start_pos + Vector3(c, 0, r)
			grid_map.set_cell_item(pos, 1)
			room.append(pos)

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
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
