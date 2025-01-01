extends Sprite2D

signal created(belonging: Node2D)
signal picked_up(belonging: Node2D)
signal dropped(belonging: Node2D)

var is_picked_up = false

var belongings_texture = preload("res://assets/image/belongings.png")
const belongings_in_texture = 5


func _ready() -> void:
	# Create a new AtlasTexture with the selected region
	var newTexture = AtlasTexture.new()
	newTexture.atlas = belongings_texture  # Set the atlas to the full texture
	newTexture.region = Rect2(100 * (randi() % belongings_in_texture), 0, 100, 100)  # Set the region for the specific character	
	texture = newTexture
	
	created.emit(self)

func move_to_parent(new_parent: Node):
	# Remove from current parent and add to the new parent
	if get_parent():
		get_parent().remove_child(self)
	new_parent.add_child(self)

func _process(_delta):
	if is_picked_up:
		# Make the belonging follow the mouse
		global_position = get_viewport().get_mouse_position()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and not is_picked_up:
			is_picked_up = true
			picked_up.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and is_picked_up:
			is_picked_up = false
			dropped.emit(self)
