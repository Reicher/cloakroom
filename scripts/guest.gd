extends Sprite2D

signal going_to_queue(guest: Node2D) # To venue
signal leaving_spot(guest: Node2D) 
signal dropItem(item: Node2D)

# State management
enum State { HOME, IN_LINE, WAITING_FOR_PICKUP, WAITING_FOR_DROPOFF, WAITING_FOR_TICKET, IN_CLUB }
var state: State = State.HOME

var belonging: Node2D
var money: Node2D
var ticket: Node2D

var time = 0.0
var arrival_time = 999999.0
var leave_time = 0.0

func _ready():
	global_position = Vector2(0, 300)
	var texture = AtlasTexture.new()
	texture.atlas = load("res://assets/image/people.png")
	texture.region = Rect2(145 * (randi() % 5), 0, 145, 300)
	self.texture = texture
	
	belonging = _create_item("black_jacket.tscn", Vector2(0, 30))
	belonging.visible = false
	
	print("I will arrive at "+ str(arrival_time) + " and leave at " + str(leave_time))

func _set_state(new_state: State):
	match new_state:
		State.WAITING_FOR_PICKUP: 
			belonging.visible = true
			dropItem.emit(belonging)
			belonging.picked.connect(_set_state.bind(State.WAITING_FOR_TICKET))
		State.WAITING_FOR_DROPOFF: 
			ticket.visible = true
			dropItem.emit(ticket)
		State.WAITING_FOR_TICKET: 
			money = _create_item("money.tscn", Vector2(0, 30))
			dropItem.emit(money)
			belonging.picked.disconnect(_set_state.bind(State.WAITING_FOR_TICKET))
		State.HOME: 
			belonging.visible = false
			leaving_spot.emit(self)
			_move_to(Vector2(0, position.y), 150 + (randi() % 150))
	
	state = new_state
	
func _process(delta: float) -> void:
	time += delta
	if state == State.HOME and time >= arrival_time:
		going_to_queue.emit(self)
	elif state == State.IN_CLUB and time >= leave_time:
		going_to_queue.emit(self)
		
func goToQueueSpot(target_pos: Vector2, is_service_spot: bool):
	_set_state(State.IN_LINE)
	var tween = _move_to(target_pos, 150 + (randi() % 150))
	if is_service_spot:
		tween.finished.connect(_on_counter_reached)

func _move_to(target_pos: Vector2, speed: int = 100) -> Tween:
	var duration = global_position.distance_to(target_pos) / speed
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	return tween

func _on_counter_reached():
	if self.is_ancestor_of(belonging): # We have a belonging on
		_set_state(State.WAITING_FOR_PICKUP)
	else: # We are missing our belonging
		_set_state(State.WAITING_FOR_DROPOFF)

func _create_item(scene_path: String, item_pos: Vector2) -> Node2D:
	var scene = load("res://scenes/pickableItems/%s" % scene_path)
	var item = scene.instantiate()
	self.add_child(item)
	item.position = item_pos
	return item

func _on_surface_item_added(item: Node2D):	
	if state == State.WAITING_FOR_TICKET and item.name.begins_with("ticket"):
		ticket = item
		ticket.move_to_parent(self)
		ticket.visible = false
		leaving_spot.emit(self)
		var target_pos = Vector2(get_viewport().size.x, position.y)
		var tween = _move_to(target_pos, 150 + (randi() % 150))
		tween.finished.connect(_set_state.bind(State.IN_CLUB))
	elif state == State.WAITING_FOR_DROPOFF and item == belonging:
		item.move_to_parent(self)
		_set_state(State.HOME)
