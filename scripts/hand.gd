extends Node2D

var held_belonging: Node2D = null

# Used for detecting valid places to drop items
var surfaces: Array = []

func _ready() -> void:
	# Loop over all pickable objects in the "pickable" group
	for pickable in get_tree().get_nodes_in_group("pickable"):
		if pickable.has_signal("picked"):  # Ensure it has the signal
			add_pickable(pickable)
			
	for surface in get_tree().get_nodes_in_group("surface"):
		add_surface(surface)

func add_pickable(item: Node2D):
	item.picked.connect(pick_up_item)
	
func add_surface(surface: Node2D):
	surfaces.append(surface)

func pick_up_item(item: Node2D):
	if held_belonging:
		print("Allready holding something")
	else:
		item.move_to_parent(self)
		held_belonging = item
		item.carried = true
		
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
		
	return true
		
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed and held_belonging:
		if _drop_item(held_belonging):
			held_belonging.carried = false
			held_belonging = null

# Update held item's position to follow the mouse
func _process(delta):
	position = get_viewport().get_mouse_position()
