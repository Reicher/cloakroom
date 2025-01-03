extends Node2D

var guestScene = preload("res://scenes/guest.tscn")
@onready var windowLength = $"ServiceWindow/length"
@onready var guests = $"Guests"
@onready var pickables = $"Pickables"
@onready var interactionZones = $"ServiceWindow/InteractionZones"  # Node to hold interaction areas

var maxCustomers = 5

enum SlotKeys { GUEST, POSITION, INTERACTION_BOX }

var guestSlots = {}  # Initialize an empty dictionary to hold guest slots

func _ready() -> void:
	initialize_guest_slots()
	_fillEmptySpots()

func initialize_guest_slots():
	var start = windowLength.points[0]
	var end = windowLength.points[1]
	var box_width = (end.x - start.x) / maxCustomers
	var box_height = 100

	for i in range(maxCustomers):
		var position = Vector2(start.x + i * box_width, start.y)
		var box = _create_interaction_box(position, box_width, box_height)
		guestSlots[i] = {
			SlotKeys.GUEST: null,
			SlotKeys.POSITION: position + Vector2(box_width / 2, 0),
			SlotKeys.INTERACTION_BOX: box
		}

func _create_interaction_box(position: Vector2, width: float, height: float) -> Area2D:
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.extents = Vector2(width / 2, height / 2)

	# Centering area position
	area.position = position + Vector2(width / 2, height / 2)

	area.add_child(collision_shape)
	interactionZones.add_child(area)
	return area

func item_dropped(item: Node2D):
	print("Item dropped on counter!")
	
	# Get the Area2D child from the dropped item
	var item_area = item.get_node("Area2D")
	if item_area == null:
		print("Error: Dropped item does not have an Area2D!")
		return

	# Check for overlaps with each interaction box
	for key in guestSlots.keys():
		var box = guestSlots[key][SlotKeys.INTERACTION_BOX]
		if box.overlaps_area(item_area):
			print("Item in box!")
			if guestSlots[key][SlotKeys.GUEST] != null:
				guestSlots[key][SlotKeys.GUEST].item_presented(item)
			return

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
	guest.interactionZone = guestSlots[spotIndex][SlotKeys.INTERACTION_BOX]
	guest.served.connect(_guest_left)
	guests.add_child(guest)
	pickables.add_child(guest.belonging)
	pickables.add_child(guest.money)

	guestSlots[spotIndex][SlotKeys.GUEST] = guest
	guest.goTo(guestSlots[spotIndex][SlotKeys.POSITION])
