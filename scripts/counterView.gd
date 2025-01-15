extends Node2D

@onready var queue = $Queue

func _ready() -> void:
	pass
	
func handle_guest(guest: Node2D):
	guest.dropItem.connect(_on_item_dropped)
	queue.handle_guest(guest)

func _on_item_dropped(item: Node2D):
	item.move_to_parent(self)
