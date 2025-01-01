extends Node2D

var held_belonging: Node2D = null


func _process(delta):
	# Make the hand follow the mouse
	global_position = get_viewport().get_mouse_position()
