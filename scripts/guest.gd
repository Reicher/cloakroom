extends Sprite2D

signal arriving(guest: Node2D) # To venue
signal leaving(guest: Node2D) # The venue
signal leaving_spot(guest: Node2D) 
signal dropItem(item: Node2D)

# State management
enum State { AT_HOME, IN_LINE, WAITING_FOR_PICKUP, WAITING_FOR_DROPOFF, WAITING_FOR_TICKET, IN_CLUB }
var state: State = State.AT_HOME

var belonging: Node2D
var money: Node2D
var ticket: Node2D

var time = 0.0
var arrival_time = 999999.0
var leave_time = 0.0

func _ready():
	global_position = Vector2(0, 300)
	_set_random_texture("res://assets/image/people.png", 5, 145, 252)
	
	print("I will arrive at "+ str(arrival_time) + " and leave at " + str(leave_time))

func _set_random_texture(atlas_path: String, frames: int, width: int, height: int):
	var texture = AtlasTexture.new()
	texture.atlas = load(atlas_path)
	texture.region = Rect2(width * (randi() % frames), 0, width, height)
	self.texture = texture

func _set_state(new_state: State):
	#print(str(state) + " -> " + str(new_state))
	state = new_state
	
func _process(delta: float) -> void:
	time += delta
	if state == State.AT_HOME and time >= arrival_time:
		arriving.emit(self)
	elif state == State.IN_CLUB and time >= leave_time:
		leaving.emit(self)
		
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
		if time < leave_time:
			belonging = _create_item("black_jacket.tscn", Vector2(0, 30))
			dropItem.emit(belonging)
			belonging.picked.connect(_on_belonging_picked)
			_set_state(State.WAITING_FOR_PICKUP)
		else: 
			ticket.visible = true
			dropItem.emit(ticket)
			_set_state(State.WAITING_FOR_DROPOFF)

func _on_belonging_picked():
	_set_state(State.WAITING_FOR_TICKET)
	money = _create_item("money.tscn", Vector2(0, 30))
	dropItem.emit(money)
	belonging.picked.disconnect(_on_belonging_picked)

func _create_item(scene_path: String, item_pos: Vector2) -> Node2D:
	var scene = load("res://scenes/pickableItems/%s" % scene_path)
	var item = scene.instantiate()
	self.add_child(item)
	item.position = item_pos
	return item

func _go_into_club():
	var target_pos = Vector2(get_viewport().size.x, position.y)
	var tween = _move_to(target_pos, 150 + (randi() % 150))
	tween.finished.connect(_set_state.bind(State.IN_CLUB))

func _go_home():
	var target_pos = Vector2(0, position.y)
	_move_to(target_pos, 150 + (randi() % 150))
	_set_state(State.AT_HOME)

func _on_surface_item_added(item: Node2D):	
	if state == State.WAITING_FOR_TICKET and item.name.begins_with("ticket"):
		ticket = item
		ticket.move_to_parent(self)
		ticket.visible = false
		leaving_spot.emit(self)
		_go_into_club()
	elif state == State.WAITING_FOR_DROPOFF and item == belonging:
		item.move_to_parent(self)
		item.visible = false
		leaving_spot.emit(self)
		_go_home()
