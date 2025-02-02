extends Area2D

signal item_added(item: Node2D)
signal right_clicked(surface: Area2D)

func _ready() -> void:
	add_to_group("surface")

func add_item(item: Node2D):
	item.carried = false # Needed? 
	item.move_to_parent(self)
	item_added.emit(item)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		right_clicked.emit(self)
