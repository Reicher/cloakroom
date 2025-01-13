extends Node2D

@onready var counter_view = $CounterView
@onready var backroom = $Backroom

var active_view: Node2D = null

var guestScene = preload("res://scenes/guest.tscn")

# Club Night Settings
var total_guests = 10  # Total number of guests
var night_duration = 30  # Duration of the night in seconds

# Guest Management
var guests = []

func _ready():
	active_view = counter_view  # Default active view
	Hand.pick.connect(_on_pick)
	_create_guests()
	
func _create_guests():
	# Calculate guest arrival times with a uniform distribution between 0 and <night_duration>
	var arrival_times = []
	for i in range(total_guests):
		arrival_times.append(randi() % night_duration)
	
	# Sort the arrival times to make them sequential (optional but logical for gameplay)
	arrival_times.sort()
	print(arrival_times)
	
	# Instantiate guest scenes and set their properties
	for i in range(total_guests):
		var guest_instance = guestScene.instance()
		guest_instance.set("arrival_time", arrival_times[i])
		guests.append(guest_instance)
		add_child(guest_instance)  # Add guest instance to the scene tree
	
func _on_pick(item: Node2D):
	item.position = Vector2.ZERO
	item.move_to_parent(self)
	
func _on_texture_button_pressed() -> void:
	# Toggle view between counter and backroom
	counter_view.visible = !counter_view.visible
	backroom.visible = !backroom.visible
	active_view = counter_view if counter_view.visible else backroom
