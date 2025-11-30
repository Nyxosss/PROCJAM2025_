extends StaticBody3D

@export var door_mesh_path: NodePath
@onready var door_mesh = get_node(door_mesh_path)
@onready var door_mesh_audio: AudioStreamPlayer = door_mesh.get_node("../AudioStreamPlayer")
@onready var collision : CollisionShape3D = $CollisionShape3D
@onready var audio_stream_player := AudioStreamPlayer.new()

const SFX_OPEN_DOOR := preload("res://assets/audio/sfx/open_door.wav")
const SFX_CLOSE_DOOR := preload("res://assets/audio/sfx/close_door.wav")

var door_id : int
var is_open = false

func _ready() -> void:
	add_child(audio_stream_player)

func open_door():
	audio_stream_player.stream = SFX_OPEN_DOOR
	audio_stream_player.play()

	door_mesh.visible = false
	is_open = true
	# Keep collision enabled for raycasts, but disable physical blocking
	collision.disabled = false
	self.collision_layer = 2  # raycast-only layer
	self.collision_mask = 1   # only raycasts detect it

func close_door():
	audio_stream_player.stream = SFX_CLOSE_DOOR
	audio_stream_player.play()

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
