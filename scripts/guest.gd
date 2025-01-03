extends Sprite2D

signal served(guest: Node2D)

# State management
enum State {
	IN_LINE,
	FINDING_SPOT,
	WAITING_FOR_PICKUP,
	WAITING_FOR_TICKET,
	LEAVING
}
var state: State = State.IN_LINE 

var belonging : Node2D
var money : Node2D
var ticket : Node2D

var interactionZone : Area2D

func _ready():
	var people_texture = load("res://assets/image/people.png")
	const people_in_texture = 5
	
	# Add a random sprite atlas region to the guest
	var new_texture = AtlasTexture.new()
	new_texture.atlas = people_texture  # Set the atlas to the full texture
	new_texture.region = Rect2(145 * (randi() % people_in_texture), 0, 145, 252)  # Set the region for the specific character	
	texture = new_texture
	offset.y -= 50
	
	# Add a random belonging
	var b_str = ["black_jacket.tscn"].pick_random()
	var b_scene = load("res://scenes/pickableItems/" + b_str)
	belonging = b_scene.instantiate()
	belonging.visible = false
	
	# Add some money
	var money_scene = load("res://scenes/pickableItems/money.tscn")
	money = money_scene.instantiate()
	money.visible = false
	
func goTo(targetPos: Vector2): # rename
	state = State.FINDING_SPOT  # Change state to "finding spot" when moving
	
	global_position = Vector2(0, targetPos.y) # start pos ( a bit ugly )
	
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
	
	tween.finished.connect(self._on_found_spot)
	
func _on_found_spot():
	_drop_thing(belonging) # Could be other shit in future
	belonging.picked.connect(_on_belonging_picked)
	state = State.WAITING_FOR_PICKUP
	
func _on_belonging_picked():
	_drop_thing(money)
	money.picked.connect(_on_money_picked)

func item_presented(item: Node2D):
	print("GOT ITEM " + item.name)
	if state == State.WAITING_FOR_TICKET and item.name.begins_with("ticket"):
		ticket = item
		ticket.move_to_parent(self)
		ticket.visible = false
		_leave()
		
func _leave():
	state = State.LEAVING
	var targetPos = Vector2(get_viewport().size.x, position.y)
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
	
	tween.finished.connect(self._on_left)
	
func _on_left():	
	served.emit(self)

func _on_money_picked():
	print("GIVE ME MY TICKET!")
	state = State.WAITING_FOR_TICKET

func _drop_thing(item: Node2D):
	# Should be a little animation in the future?
	item.position = Vector2(position.x, position.y + 50)
	item.visible = true
	
