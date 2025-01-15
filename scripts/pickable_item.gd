extends Node2D

signal picked
var carried: bool = false

@onready var area: Area2D = $Area2D

func move_to_parent(new_parent: Node):
	var global_position = self.global_position # Get position first
	
	# Remove from current parent and add to the new parent
	if get_parent():
		get_parent().remove_child(self)
	new_parent.add_child(self)
	
	# Set the item's position relative to the new parent
	#self.position = new_parent.to_local(global_position)
	self.global_position = global_position


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and not carried:
			Hand.pick_up_item(self)
			if carried:
				picked.emit()
