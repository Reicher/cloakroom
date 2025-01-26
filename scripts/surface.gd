extends Area2D

signal item_added(item: Node2D)

@export var can_hold_items = false # Should this surface be the parent of the item? 

func _ready() -> void:
	add_to_group("surface")

func item_dropped(item: Node2D):
	item_added.emit(item)
	if can_hold_items:
		item.move_to_parent(self)

func contains(item: Node2D) -> bool:
	if is_visible_in_tree() and overlaps_area(item.area):
		return true
	return false
