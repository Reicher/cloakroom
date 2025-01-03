extends Node

var held_belonging: Node2D = null

signal pick(item: Node2D)
signal drop(item: Node2D)

var position : Vector2 = Vector2.ZERO

func pick_up_item(item: Node2D):
	if held_belonging:
		print("Allready holding something")
	else:
		held_belonging = item
		item.carried = true
		pick.emit(item)

# Detect right mouse button clicks
func _input(event):
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed and held_belonging:
			
		drop.emit(held_belonging)
		held_belonging.carried = false
		held_belonging = null

# Update held item's position to follow the mouse
func _process(delta):
	position = get_viewport().get_mouse_position()
	if held_belonging:
		held_belonging.position = position
