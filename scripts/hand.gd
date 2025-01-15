extends Node

signal pick(item: Node2D)

var held_belonging: Node2D = null
var position : Vector2 = Vector2.ZERO

# Used for detecting valid places to drop items
var surfaces: Array = []

# Detect right mouse button clicks (Should be able to pick up stuff as well?)
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed and held_belonging:
		if _drop_item(held_belonging):
			held_belonging.carried = false
			held_belonging = null

func pick_up_item(item: Node2D):
	if held_belonging:
		print("Allready holding something")
	else:
		held_belonging = item
		item.carried = true
		pick.emit(item)

func add_surface_for_dropping(surface: Area2D):
	if surface not in surfaces:
		surfaces.append(surface)
		
func _drop_item(item: Node2D):
	var affected_surfaces = []
	for surface in surfaces:
		if surface.is_visible_in_tree() and surface is Area2D \
		and surface.overlaps_area(item.area):
			affected_surfaces.append(surface)
	
	if len(affected_surfaces) == 0:
		return false
	
	for surface in affected_surfaces:
		surface.item_dropped(item)
		print(surface.name + " got an " + item.name + " on it")
		
	return true

# Update held item's position to follow the mouse
func _process(delta):
	position = get_viewport().get_mouse_position()
	if held_belonging:
		held_belonging.position = position
