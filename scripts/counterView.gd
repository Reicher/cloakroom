extends Node2D

@onready var queue = $Queue

func handle_guest(guest: Node2D):
	guest.dropItem.connect(_on_guest_drop)
	queue.handle_guest(guest)

func _on_guest_drop(item: Node2D):
	item.move_to_parent(self)
