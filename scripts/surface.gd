extends Area2D

signal item_added(item: Node2D)

@export var can_hold_items = false # Should this surface be the parent of the item? 

func _ready() -> void:
	Hand.add_surface_for_dropping(self)

func item_dropped(item: Node2D):
	item_added.emit(item)
	if can_hold_items:
		item.move_to_parent(self)
