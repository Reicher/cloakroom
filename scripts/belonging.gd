extends Sprite2D

var belongings_texture = preload("res://assets/image/belongings.png")
const belongings_in_texture = 5

func _ready() -> void:
	# Create a new AtlasTexture with the selected region
	var newTexture = AtlasTexture.new()
	newTexture.atlas = belongings_texture  # Set the atlas to the full texture
	newTexture.region = Rect2(100 * (randi() % belongings_in_texture), 0, 100, 100)  # Set the region for the specific character	
	texture = newTexture
	
