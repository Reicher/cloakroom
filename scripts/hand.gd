extends Node2D

var held_belonging: Node2D = null
var surfaces: Array = []
var item_offset := Vector2(40, 40)  # Offset for item placement

func _ready() -> void:
	# Store all pickable items
	for pickable in get_tree().get_nodes_in_group("pickable"):
		if pickable.has_signal("picked"):
			add_pickable(pickable)

	# Store all surfaces
	for surface in get_tree().get_nodes_in_group("surface"):
		add_surface(surface)

func add_pickable(item: Node2D):
	item.picked.connect(pick_up_item)

func add_surface(surface: Area2D):
	surfaces.append(surface)

func pick_up_item(item: Node2D):
	if held_belonging:
		print("Already holding something")
	else:
		item.move_to_parent(self)
		held_belonging = item
		item.carried = true

func _drop_item():
	var affected_surfaces = []
	for surface in surfaces:
		if surface.is_visible_in_tree() and surface.mouse_inside():
			affected_surfaces.append(surface)
	
	var item_dropped = held_belonging
	if len(affected_surfaces) > 0:
		held_belonging.global_position = get_global_mouse_position()
		# Drop the item at mouse position
		held_belonging.carried = false
		held_belonging = null
	
		for surface in affected_surfaces:
			surface.item_dropped(item_dropped)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and held_belonging != null:
		_drop_item()

func _process(delta):
	if held_belonging:
		held_belonging.position = get_global_mouse_position() + item_offset
