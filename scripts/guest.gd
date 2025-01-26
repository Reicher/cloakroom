extends Sprite2D

signal going_to_queue(guest: Node2D) # To venue
signal leaving_spot(guest: Node2D) 
signal dropItem(item: Node2D)

# State management
enum State { HOME, ARRIVING, IN_LINE, WAITING_FOR_PICKUP, WAITING_FOR_DROPOFF, WAITING_FOR_TICKET, IN_CLUB, LEAVING }
var state: State = State.HOME

@onready var arriving = $ArrivalTimer
@onready var leaving = $LeaveTimer

var speed : int = 150 + (randi() % 150)
var tween : Tween = null

@onready var money = $Money
var belonging : Node2D
var ticket: Node2D

func _ready():
	global_position = Vector2(0, 300)
	var texture = AtlasTexture.new()
	texture.atlas = load("res://assets/image/people.png")
	texture.region = Rect2(145 * (randi() % 5), 0, 145, 300)
	self.texture = texture
	
	var belongingScene = load("res://scenes/pickableItems/black_jacket.tscn")
	belonging = belongingScene.instantiate()
	belonging.visible = false
	belonging.position = Vector2(0, 50)
	add_child(belonging)
	
func notify_opening_hours(opens: int, closes: int):
	var night_duration = closes - opens
	
	arriving.start(float(randi() % (night_duration/2)))
	arriving.timeout.connect(_set_state.bind(State.ARRIVING))
	
	leaving.start(float((night_duration/2) + randi() % (night_duration/2)))
	print("I will arrive at "+ str(arriving.get_wait_time()) + " and leave at " + str(leaving.get_wait_time()))

func _set_state(new_state: State):
	# What to do when entering a state
	match new_state:
		State.ARRIVING: 
			going_to_queue.emit(self)
		State.WAITING_FOR_PICKUP: 
			belonging.visible = true
			dropItem.emit(belonging)
			belonging.picked.connect(_set_state.bind(State.WAITING_FOR_TICKET))
		State.WAITING_FOR_DROPOFF: 
			ticket.visible = true
			dropItem.emit(ticket)
		State.WAITING_FOR_TICKET: 
			money.visible = true
			dropItem.emit(money)
			belonging.picked.disconnect(_set_state.bind(State.WAITING_FOR_TICKET))
		State.IN_CLUB: 
			if leaving.is_stopped():
				going_to_queue.emit(self)
		State.LEAVING: 
			belonging.visible = false
			leaving_spot.emit(self)
			_move_to(Vector2(0, position.y))

	state = new_state

func _on_leave_timer_timeout() -> void:
	if state == State.IN_CLUB:
		going_to_queue.emit(self)
	elif self.is_ancestor_of(belonging): # My jacket is allready on
		_set_state(State.LEAVING)
	elif $Surface.contains(belonging):
		belonging.move_to_parent(self)
		_set_state(State.LEAVING)

func _move_to(target_pos: Vector2) -> Tween:
	# Stop any existing tween
	if tween and tween.is_running():
		tween.kill()
		tween = null

	# Position tween
	var duration = global_position.distance_to(target_pos) / speed
	tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Rocking tween
	var rock_tween = create_tween()
	rock_tween.set_loops(-1)  # Loop indefinitely during the movement
	rock_tween.set_trans(Tween.TRANS_LINEAR)
	rock_tween.set_ease(Tween.EASE_IN_OUT)

	# Rock side-to-side by modifying the rotation property
	var rock_duration = 1.0 / (speed / 100.0)
	rock_tween.tween_property(self, "rotation", 0.1, rock_duration/2)
	rock_tween.tween_property(self, "rotation", -0.1, rock_duration/2)

	# Stop rocking when movement is finished
	tween.finished.connect(func() -> void:
		rock_tween.kill()
		self.rotation = 0  # Reset rotation to 0
	)
	return tween
	
func _on_counter_reached():
	if self.is_ancestor_of(belonging): # We have a belonging on
		_set_state(State.WAITING_FOR_PICKUP)
	else: # We are missing our belonging
		_set_state(State.WAITING_FOR_DROPOFF)

func goToQueueSpot(target_pos: Vector2, is_service_spot: bool):
	if state == State.LEAVING: 
		return
	_set_state(State.IN_LINE)
	var tween = _move_to(target_pos)
	if is_service_spot:
		tween.finished.connect(_on_counter_reached)

func _on_surface_item_added(item: Node2D):	
	if state == State.WAITING_FOR_TICKET and item.name.begins_with("ticket"):
		ticket = item
		ticket.move_to_parent(self)
		ticket.visible = false
		leaving_spot.emit(self)
		var target_pos = Vector2(get_viewport().size.x, position.y)
		var tween = _move_to(target_pos)
		tween.finished.connect(_set_state.bind(State.IN_CLUB))
	elif state == State.WAITING_FOR_DROPOFF and item == belonging:
		item.move_to_parent(self)
		_set_state(State.LEAVING)
