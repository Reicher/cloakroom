extends Node2D

@onready var queue = $Queue

func add_guest(guest: Node2D):
	queue.add_guest(guest)
	guest.dropItem.connect(on_guest_drop)	

func on_guest_arrive(guest: Node2D):
	queue.handle_guest(guest)
	
func on_guest_leave(guest: Node2D):
	queue.handle_guest(guest)

func on_guest_drop(item: Node2D):
	item.move_to_parent(self)
