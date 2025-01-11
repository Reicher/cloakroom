extends Node2D

@onready var counter_view = $CounterView
@onready var backroom = $Backroom

var active_view: Node2D = null

func _ready():
	active_view = counter_view  # Default active view
	Hand.pick.connect(_on_pick)

func _on_pick(item: Node2D):
	item.position = Vector2.ZERO
	item.move_to_parent(self)
	
func _on_texture_button_pressed() -> void:
	# Toggle view between counter and backroom
	counter_view.visible = !counter_view.visible
	backroom.visible = !backroom.visible
	active_view = counter_view if counter_view.visible else backroom
