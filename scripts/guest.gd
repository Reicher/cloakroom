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
	
func set_state(new_state: State):
	state = new_state
	
func goTo(targetPos: Vector2):
	set_state(State.FINDING_SPOT)
	global_position = Vector2(0, targetPos.y)
	move_to(targetPos, self._on_found_spot, 150 + (randi() % 150))

func move_to(target_pos: Vector2, on_complete: Callable, speed: int = 100):
	var duration = global_position.distance_to(target_pos) / speed
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(on_complete)

func _on_found_spot():
	_drop_thing(belonging) # Could be other shit in future
	belonging.picked.connect(_on_belonging_picked)
	state = State.WAITING_FOR_PICKUP
	
func _on_belonging_picked():
	set_state(State.WAITING_FOR_TICKET)
	_drop_thing(money)
	money.picked.connect(_on_money_picked)

func _leave():
	set_state(State.LEAVING)
	var target_pos = Vector2(get_viewport().size.x, position.y)
	move_to(target_pos, self._on_left, 150 + (randi() % 150))
	
func _on_left():	
	served.emit(self)
	Hand.remove_surface($Surface)

func _on_money_picked():
	set_state(State.WAITING_FOR_TICKET)

func _drop_thing(item: Node2D):
	if item:
		item.position = position + Vector2(0, 50)
		item.visible = true
	
func _on_surface_item_added(item: Node2D) -> void:
	print("Something drop in front of me! " + self.name)
	if state == State.WAITING_FOR_TICKET and item.name.begins_with("ticket"):
		ticket = item
		ticket.move_to_parent(self)
		ticket.visible = false
		_leave()

func _on_timer_timeout() -> void:
	pass # Replace with function body.
