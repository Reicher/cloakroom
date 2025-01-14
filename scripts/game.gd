extends Node2D

@onready var counter_view = $CounterView
@onready var backroom = $Backroom

var active_view: Node2D = null

var guestScene = preload("res://scenes/guest.tscn")

# Club Night Settings
var total_guests = 16  # Total number of guests
var night_duration = 10  # Duration of the night in seconds
var elapsed_time = 0

# Guest Management
var arrival_times = []

func _ready():
	active_view = counter_view  # Default active view
	Hand.pick.connect(_on_pick)
	
	# Calculate guest arrival times with a linearly decreasing probability distribution
	for i in range(total_guests):
		# Randomly pick a number between 0 and 1, then apply linear weighting
		arrival_times.append((1 - sqrt(randf())) * night_duration)
		
	arrival_times.sort()
	
func _process(delta: float) -> void:
	elapsed_time += delta	

	# Creat a new guest and have them go to the counter
	if not arrival_times.is_empty() and elapsed_time >= arrival_times.front():
		arrival_times.pop_front()
		var guest_insance = guestScene.instantiate()
		# Set tons of things
		counter_view.queue.handle_guest(guest_insance)

func _on_pick(item: Node2D):
	item.position = Vector2.ZERO
	item.move_to_parent(self)
	
func _on_texture_button_pressed() -> void:
	# Toggle view between counter and backroom
	counter_view.visible = !counter_view.visible
	backroom.visible = !backroom.visible
	active_view = counter_view if counter_view.visible else backroom
