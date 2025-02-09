extends Node2D

@onready var counter_view = $CounterView
@onready var backroom = $Backroom
@onready var hand = $Hand

var active_view: Node2D = counter_view
var guestScene = preload("res://scenes/guest.tscn")

# Club Night Settings
var total_guests = 9
var night_duration = 15  

var elapsed_time = 0
var guest_spawn_times = []  # List of spawn times
var guests_spawned = 0

func _ready():
	var spawn_interval = 0#(night_duration / 2.0) / total_guests
	for i in range(total_guests):
		guest_spawn_times.append(i * spawn_interval)  # Precompute spawn times
		
	print(guest_spawn_times)

func _process(delta):
	elapsed_time += delta

	while guests_spawned < total_guests and elapsed_time >= guest_spawn_times[guests_spawned]:
		spawn_guest()
		guests_spawned += 1

func spawn_guest():
	var guest = guestScene.instantiate()
	guest.dropItem.connect(hand.add_pickable)
	counter_view.add_guest(guest)
	guest.notify_opening_hours(0, night_duration)
	guest.change_state("Store") # Initial state

func _on_texture_button_pressed() -> void:
	counter_view.visible = !counter_view.visible
	backroom.visible = !backroom.visible
	active_view = counter_view if counter_view.visible else backroom
