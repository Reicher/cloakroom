extends Node2D

@onready var serviceWindow = $Booth/ServiceWindow
@onready var windowShape = $Booth/ServiceWindow/Shape
@onready var guests = $"Guests"
@onready var pickables = $"Pickables"

var maxCustomers = 4

enum SlotKeys { GUEST, POSITION, INTERACTION_BOX }
var guestSlots = {}  # Initialize an empty dictionary to hold guest slots

func _ready() -> void:	
	var extents = windowShape.shape.extents
	var start = serviceWindow.global_position + Vector2(0, extents.y*2)
	var end = serviceWindow.global_position + Vector2(extents.x*2, extents.y*2)
	var box_width = (end.x - start.x) / maxCustomers
	var box_height = 100
	
	for i in range(maxCustomers):
		guestSlots[i] = _create_guest_slot(i, start, box_width, box_height)
	
func new_guest(guest: Node2D):
	for key in guestSlots.keys():
		if guestSlots[key][SlotKeys.GUEST] == null:
			guest.served.connect(_guest_left)
			guests.add_child(guest)
			pickables.add_child(guest.belonging)
			pickables.add_child(guest.money)

			guestSlots[key][SlotKeys.GUEST] = guest
			guest.goTo(guestSlots[key][SlotKeys.POSITION])
			break

func _create_guest_slot(index: int, start: Vector2, box_width: float, box_height: float) -> Dictionary:
	var position = Vector2(start.x + index * box_width, start.y)
	return {
		SlotKeys.GUEST: null,
		SlotKeys.POSITION: position + Vector2(box_width / 2, 0)
	}

func _guest_left(guest: Node2D):
	for key in guestSlots.keys():
		if guestSlots[key][SlotKeys.GUEST] == guest:
			guestSlots[key][SlotKeys.GUEST] = null
			guest.queue_free()
