extends Node2D

@onready var area : Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Detect right mouse button clicks
func _input(event):
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed and Hand.held_belonging \
		and area.overlaps_area(Hand.held_belonging.area):
			Hand.drop_item()
			
