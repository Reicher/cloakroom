extends GuestState

func enter_state(guest: Node2D) -> void:
	super(guest)
	var target_pos = Vector2(get_viewport().size.x, guest.position.y)
	guest._move_to(target_pos)
	
func exit_state() -> void:
	super()
	pass
