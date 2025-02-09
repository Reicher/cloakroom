extends Node2D

@onready var queue = $Queue
@onready var counter = $Booth/Surface

func add_guest(guest: Node2D):
	guest.dropItem.connect(on_guest_drop)	
	counter.item_added.connect(guest.counter_item_added)
	
	guest._queue = queue
	queue.add_child(guest)

func on_guest_drop(item: Node2D):
	item.move_to_parent(self)
