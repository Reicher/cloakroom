extends Node2D

var guestScene = preload("res://scenes/guest.tscn")
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
	_fillEmptySpots()

func _create_guest_slot(index: int, start: Vector2, box_width: float, box_height: float) -> Dictionary:
	var position = Vector2(start.x + index * box_width, start.y)
	return {
		SlotKeys.GUEST: null,
		SlotKeys.POSITION: position + Vector2(box_width / 2, 0)
	}

func _fillEmptySpots() -> void:
	for key in guestSlots.keys():
		if guestSlots[key][SlotKeys.GUEST] == null:
			_addGuest(key)

func _guest_left(guest: Node2D):
	for key in guestSlots.keys():
		if guestSlots[key][SlotKeys.GUEST] == guest:
			guestSlots[key][SlotKeys.GUEST] = null
			guest.queue_free()
			_fillEmptySpots()

func _addGuest(spotIndex) -> void:
	print("New guest created!")
	var guest = guestScene.instantiate()
	guest.served.connect(_guest_left)
	guests.add_child(guest)
	pickables.add_child(guest.belonging)
	pickables.add_child(guest.money)

	guestSlots[spotIndex][SlotKeys.GUEST] = guest
	guest.goTo(guestSlots[spotIndex][SlotKeys.POSITION])
