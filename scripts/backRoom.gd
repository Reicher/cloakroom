extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Hand.add_surface_for_dropping($Surface)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
