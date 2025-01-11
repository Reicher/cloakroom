extends Area2D

signal item_added(item: Node2D)

func _ready() -> void:
	Hand.add_surface_for_dropping(self)
	print(self.get_path())

func item_dropped(item: Node2D):
	var global_position = item.global_position # Get position first
	
	item.move_to_parent(self)
	print(item.get_parent().get_path())
	# Set the item's position relative to the new parent
	item.position = self.to_local(global_position)
	
	item_added.emit(item)
