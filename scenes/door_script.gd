extends StaticBody3D

@export var door_mesh_path: NodePath
@onready var door_mesh = get_node(door_mesh_path)
@onready var collision : CollisionShape3D = $CollisionShape3D

var door_id : int
var is_open = false

func open_door():
	door_mesh.visible = false
	is_open = true
	# Keep collision enabled for raycasts, but disable physical blocking
	collision.disabled = false
	self.collision_layer = 2  # raycast-only layer
	self.collision_mask = 1   # only raycasts detect it

func close_door():
	door_mesh.visible = true
	is_open = false
	# Restore collision layer so physics and raycasts detect it
	self.collision_layer = 1 | 2
	self.collision_mask = 0xFFFFFFFF


func toggle():
	if is_open:
		close_door()
	else:
		open_door()

func use():
	toggle()

func setID(myID : int):
	door_id = myID

func addToGroup():
	self.add_to_group("door")
