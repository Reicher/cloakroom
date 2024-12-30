extends Sprite2D

var people_texture = preload("res://assets/image/people.png")
const people_in_texture = 5

var belonging_scene: PackedScene = preload("res://scenes/belonging.tscn")
var belonging

var serviceWindow : Sprite2D

# State management
enum State {
	IN_LINE,
	FINDING_SPOT,
	WAITING_FOR_PICKUP
}
var state: State = State.IN_LINE 

func _ready():
	# Create a new AtlasTexture with the selected region
	var new_texture = AtlasTexture.new()
	new_texture.atlas = people_texture  # Set the atlas to the full texture
	new_texture.region = Rect2(145 * (randi() % people_in_texture), 0, 145, 252)  # Set the region for the specific character	
	texture = new_texture
	offset.y -= 50

func goTo(serviceWindow: Sprite2D, targetPos: Vector2):
	self.serviceWindow = serviceWindow
	global_position = Vector2(0, targetPos.y)

	state = State.FINDING_SPOT  # Change state to "finding spot" when moving
	
	# Calculate the movement duration based on the desired speed
	var speed = 50 + (randi() % 150)
	var duration = global_position.distance_to(targetPos) / speed
	
	# Create a tween to move the customer to the target position
	var tween = create_tween()
	tween.tween_property(
		self, 
		"global_position", 
		targetPos,    # Target position
		duration            # Duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	# When the tween finishes, call a function (or connect a signal)
	tween.finished.connect(self._on_tween_finished)
	
	
func _on_tween_finished():
	belonging = belonging_scene.instantiate()
	belonging.global_position = Vector2(position.x, position.y+50)
	serviceWindow.add_child(belonging)

	# Update state
	state = State.WAITING_FOR_PICKUP
	print("Customer is now waiting for pickup.")
