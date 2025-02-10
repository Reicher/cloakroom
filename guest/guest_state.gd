extends Node

class_name GuestState

var guest

func enter_state(guest: Node2D) -> void:
	self.guest = guest

func exit_state() -> void:
	pass
	
func item_presented(item: Node2D):
	pass
	
func move_finished():
	pass
