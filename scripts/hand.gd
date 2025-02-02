extends Node2D

const MAX_HELD_ITEMS := 3  
var held_items: Array = []  # Stack to hold items
var item_offset := Vector2(25, 25)  # spacing between items

func _ready() -> void:
	# Store all pickable items
	for pickable in get_tree().get_nodes_in_group("pickable"):
		if pickable.has_signal("picked"):
			add_pickable(pickable)

func add_pickable(item: Node2D):
	item.picked.connect(pick_up_item)

func pick_up_item(item: Node2D):
	if held_items.size() >= MAX_HELD_ITEMS:
		print("Hands are full")
	else:
		item.move_to_parent(self)
		held_items.append(item)
		item.carried = true

func _drop_item():
	if held_items.is_empty():
		return

	var affected_surfaces = []
	for surface in get_tree().get_nodes_in_group("surface"):
		if surface.is_visible_in_tree() and surface.mouse_inside():
			affected_surfaces.append(surface)
	
	if len(affected_surfaces) > 0:
		var item_dropped = held_items.pop_back() 
		item_dropped.global_position = get_global_mouse_position()
		item_dropped.carried = false
	
		for surface in affected_surfaces:
			surface.item_dropped(item_dropped)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and not held_items.is_empty():
		_drop_item()

func _process(delta):
	# Update positions of held items relative to mouse
	var hand_pos = Vector2(40, 40) + get_global_mouse_position()
	for i in range(held_items.size()):
		held_items[i].position = hand_pos + item_offset * i
