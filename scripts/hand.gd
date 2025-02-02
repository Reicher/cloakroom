extends Node2D

const MAX_HELD_ITEMS := 3  
var held_items: Array = []  # Stack to hold items
var item_offset := Vector2(25, 25)  # spacing between items

func _ready() -> void:
	for pickable in get_tree().get_nodes_in_group("pickable"):
		add_pickable(pickable)
	for surface in get_tree().get_nodes_in_group("surface"):
		surface.right_clicked.connect(item_dropped)

func add_pickable(item: Node2D):
	item.picked.connect(pick_up_item)

func item_dropped(surface: Area2D):
	if held_items.is_empty():
		return 
		
	var item = held_items.pop_back() 
	item.global_position = get_global_mouse_position()
	surface.add_item(item)

func pick_up_item(item: Node2D):
	if held_items.size() >= MAX_HELD_ITEMS:
		print("Hands are full")
	else:
		item.move_to_parent(self)
		held_items.append(item)
		item.carried = true

func _process(delta):
	# Update positions of held items relative to mouse
	var hand_pos = Vector2(40, 40) + get_global_mouse_position()
	for i in range(held_items.size()):
		held_items[i].position = hand_pos + item_offset * i
