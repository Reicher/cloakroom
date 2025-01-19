extends Node2D

@onready var counter_view = $CounterView
@onready var backroom = $Backroom

var active_view: Node2D = counter_view

var guestScene = preload("res://scenes/guest.tscn")

# Club Night Settings
var total_guests = 25  # Total number of guests
var night_duration = 10  # Duration of the night in seconds
var elapsed_time = 0

# Guest Management
var arrival_times = []
var leaving_times = []

func _ready():
	Hand.pick.connect(_on_pick)

	for i in range(total_guests):
		var guest = guestScene.instantiate()
		
		# Night data should be some sort of struct
		guest.arrival_time = randi() % 10
		guest.leave_time = 10 + randi() % 10
		
		counter_view.queue.add_guest(guest)	
		guest.dropItem.connect(counter_view.on_guest_drop)	

func _on_item_dropped(item: Node2D):
	item.move_to_parent(self)

func _on_pick(item: Node2D):
	item.position = Vector2.ZERO
	item.move_to_parent(self)
	
func _on_texture_button_pressed() -> void:
	# Toggle view between counter and backroom
	counter_view.visible = !counter_view.visible
	backroom.visible = !backroom.visible
	active_view = counter_view if counter_view.visible else backroom
