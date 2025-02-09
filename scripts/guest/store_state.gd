extends GuestState

func enter_state(guest: Node2D) -> void:
	super(guest)
	
	guest._queue.moving.connect(guest.find_better_spot)
	guest._move_to(guest._queue.get_best_spot(guest))

func exit_state() -> void:
	super()
	
func move_finished():
	if not guest._queue.at_counter(guest):
		return
	
	guest._queue.moving.disconnect(guest.find_better_spot)
	
	guest.belonging.visible = true
	guest.dropItem.emit(guest.belonging)

func item_presented(item: Node2D):
	if not guest.ticket and item.is_in_group("ticket"):
		print("Ticket dropped before guest " + str(guest.guest_id))
		guest.ticket = item
		guest.ticket.move_to_parent(self)
		guest.ticket.visible = false
		
		guest.pay(420)
		
		guest._queue.leave(guest)
		
		guest.change_state("Party")
