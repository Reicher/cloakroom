extends Node2D

@onready var queue = $Queue

func on_guest_arrive(guest: Node2D):
	queue.handle_guest(guest)
	
func on_guest_leave(guest: Node2D):
	queue.handle_guest(guest)

func on_guest_drop(item: Node2D):
	item.move_to_parent(self)
