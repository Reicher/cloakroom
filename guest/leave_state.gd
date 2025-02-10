extends GuestState

var exit : Vector2

func enter_state(guest: Node2D) -> void:
	super(guest)
	
	exit = Vector2(0, guest.position.y)
	
	if guest.is_ancestor_of(guest.belonging):
		guest._move_to(exit)
		print("Guest " + str(guest.guest_id) + " moving straight home")
	elif guest.notificationArea.overlaps_area(guest.belonging.area):
		guest.belonging.move_to_parent(guest)
		guest._move_to(exit)
		print("Guest " + str(guest.guest_id) + " taking my coat and leaves!")
	elif not guest._queue.at_counter(guest): # Its queue time
		print("Guest " + str(guest.guest_id) + " going back to the counter")
		guest._move_to(guest._queue.get_best_spot(guest))
		guest._queue.moving.connect(guest.find_better_spot)
	else:
		print("Guest " + str(guest.guest_id) + " i will just stand here? ")

func exit_state() -> void:
	super()
	
func move_finished():
	if not guest._queue.at_counter(guest):
		return
	
	print("Guest " + str(guest.guest_id) + " at counter, ready")
	guest._queue.moving.disconnect(guest.find_better_spot)
	if guest.ticket:
		print("Guest " + str(guest.guest_id) + " leaving ticket")
		guest.ticket.visible = true
		guest.dropItem.emit(guest.ticket)

func item_presented(item: Node2D):
	if item == guest.belonging:
		print("Guest " + str(guest.guest_id) + " got the beloning")
		guest.belonging.move_to_parent(guest)
		guest._move_to(exit)
	else: 
		print("What the hell is this? Am i a joke to you? ")
