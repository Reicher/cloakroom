extends Node2D

@onready var counter_view = $CounterView
@onready var backroom = $Backroom
@onready var hand = $Hand

var active_view: Node2D = counter_view

var guestScene = preload("res://scenes/guest.tscn")

# Club Night Settings
var total_guests = 25  # Total number of guests
var night_duration = 30  # Duration of the night in seconds
var elapsed_time = 0

func _ready():
	for i in range(total_guests):
		var guest = guestScene.instantiate()
		
		# Ugly connection
		guest.dropItem.connect(hand.add_pickable)
		
		counter_view.add_guest(guest)
		
		# Night data should be some sort of struct
		guest.notify_opening_hours(0, night_duration)

func _on_texture_button_pressed() -> void:
	# Toggle view between counter and backroom
	counter_view.visible = !counter_view.visible
	backroom.visible = !backroom.visible
	active_view = counter_view if counter_view.visible else backroom
