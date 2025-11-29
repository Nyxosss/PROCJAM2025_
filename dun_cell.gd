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
