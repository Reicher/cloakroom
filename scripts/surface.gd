extends Area2D

signal item_added(item: Node2D)

func _ready() -> void:
	Hand.add_surface_for_dropping(self)

func item_dropped(item: Node2D):
	item_added.emit(item)
