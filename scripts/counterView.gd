extends Node2D

var guestScene = preload("res://scenes/guest.tscn")
@onready var serviceWindow = $"ServiceWindow"
@onready var club = $"Club"

var maxCustomers = 5
var guestSlots = {}  # Map representing slots for customers at the counter

func _ready() -> void:
	# Calculate intervals and assign service spots
	var start = $ServiceWindow/length.points[0]
	var end = $ServiceWindow/length.points[1]
	var interval = (end.x - start.x) / (maxCustomers + 1)
	for i in range(1, maxCustomers + 1):
		guestSlots[i] = { "guest": null, 
						  "position": Vector2(start.x + i * interval, start.y)}
		
	_fillEmptySpots()
		
func _fillEmptySpots() -> void:
	for key in guestSlots.keys():
		if guestSlots[key]["guest"] == null:
			_addGuest(key)
			
func _addGuest(spotIndex) -> void:
	print("New guest created!")
	var guest = guestScene.instantiate()
	guestSlots[spotIndex]["guest"] = guest
	guest.goTo(serviceWindow, guestSlots[spotIndex]["position"])
	club.add_child(guest)