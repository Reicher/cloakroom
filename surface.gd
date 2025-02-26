extends Area2D

signal item_added(item: Node2D)
signal right_clicked(surface: Area2D)

func add_item(item: Node2D):
	print(str(item) + " dropped on surface " + str(self))
	item.move_to_parent(self)
	item_added.emit(item)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		right_clicked.emit(self)
