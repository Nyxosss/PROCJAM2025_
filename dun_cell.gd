@tool
extends Node3D

func remove_wall_up():
	$wall_up.free()
	$wall_colision_up.free()
func remove_wall_down():
	$wall_down.free()
	$wall_colision_down.free()
func remove_wall_left():
	$wall_left.free()
	$wall_colision_left.free()
func remove_wall_right():
	$wall_right.free()
	$wall_colision_right.free()
func remove_frame_up():
	$door_frame_up.free()
func remove_frame_down():
	$door_frame_down.free()
func remove_frame_left():
	$door_frame_left.free()
func remove_frame_right():
	$door_frame_right.free()
func remove_door_up():
	$door_up.free()
	$door_colision_up.free()
func remove_door_down():
	$door_down.free()
	$door_colision_down.free()
func remove_door_left():
	$door_left.free()
	$door_colision_left.free()
func remove_door_right():
	$door_right.free()
	$door_colision_right.free()

func set_door_up(doorID : int):
	$door_colision_up.setID(doorID)

func set_door_down(doorID : int):
	$door_colision_down.setID(doorID)

func set_door_left(doorID : int):
	$door_colision_left.setID(doorID)
	
func set_door_right(doorID : int):
	$door_colision_right.setID(doorID)
	
func set_door_group_up():
	$door_colision_up.addToGroup()

func set_door_group_down():
	$door_colision_down.addToGroup()

func set_door_group_left():
	$door_colision_left.addToGroup()
	
func set_door_group_right():
	$door_colision_right.addToGroup()
