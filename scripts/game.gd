extends Node2D

@onready var counter_view = $CounterView
@onready var backroom = $Backroom
@onready var hand = $Hand

var active_view: Node = null

func _ready():
	active_view = counter_view  # Default active view

func _on_texture_button_pressed() -> void:
	# Toggle view between counter and backroom
	counter_view.visible = !counter_view.visible
	backroom.visible = !backroom.visible
	active_view = counter_view if counter_view.visible else backroom

func pick(item: Node2D):
	item.position = Vector2.ZERO
	item.move_to_parent(hand)
	
func drop(item: Node2D):
	item.position = hand.global_position
	item.move_to_parent(active_view)
