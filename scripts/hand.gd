extends Node

var held_belonging: Node2D = null

signal pick(item: Node2D)
signal drop(item: Node2D)

var position : Vector2 = Vector2.ZERO

# Used for detecting valid places to drop items
var surfaces: Array = []

func pick_up_item(item: Node2D):
	if held_belonging:
		print("Allready holding something")
	else:
		held_belonging = item
		item.carried = true
		pick.emit(item)
		
func drop_item():
	drop.emit(held_belonging)
	held_belonging.carried = false
	held_belonging = null

func add_surface_for_dropping(surface: Area2D):
	if surface not in surfaces:
		surfaces.append(surface)

func is_valid_drop_position() -> bool:
	# Check if the current mouse position intersects any surface
	for surface in surfaces:
		if surface is Area2D and surface.overlaps_area(held_belonging.area):
			return true
	return false

# Detect right mouse button clicks
func _input(event):
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed and held_belonging:

		if is_valid_drop_position():
			drop_item()

# Update held item's position to follow the mouse
func _process(delta):
	position = get_viewport().get_mouse_position()
	if held_belonging:
		held_belonging.position = position
