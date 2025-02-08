extends Node2D

@onready var queue = $Queue
@onready var counter = $Booth/Surface

func add_guest(guest: Node2D):
	guest.stand_in_queue(queue)
	
	guest.dropItem.connect(on_guest_drop)	
	counter.item_added.connect(guest.counter_item_added)

func on_guest_arrive(guest: Node2D):
	queue.handle_guest(guest)
	
func on_guest_leave(guest: Node2D):
	queue.handle_guest(guest)

func on_guest_drop(item: Node2D):
	item.move_to_parent(self)
