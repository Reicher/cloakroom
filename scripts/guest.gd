extends Sprite2D

signal going_to_queue(guest: Node2D) # To venue
signal leaving_spot(guest: Node2D) 
signal dropItem(item: Node2D)

# State management
enum State { IN_LINE, WAITING_FOR_PICKUP, WAITING_FOR_DROPOFF, WAITING_FOR_TICKET, IN_CLUB, LEAVING }
var state: State = State.IN_LINE

# New State management
enum Wants { STORE, PARTY, GO_HOME }
var want: Wants = Wants.STORE

@onready var leaving = $LeaveTimer
@onready var notificationArea = $NotificationArea

var speed : int = 150 + (randi() % 150)
var position_tween : Tween = null
var rock_tween: Tween = null

@onready var money = $Money
var belonging : Node2D
var ticket: Node2D

func _ready():
	global_position = Vector2(0, 300)
	var texture = AtlasTexture.new()
	texture.atlas = load("res://assets/image/people.png")
	texture.region = Rect2(145 * (randi() % 5), 0, 145, 300)
	self.texture = texture
	
	# Get a random cloak and add it as the guest's belonging
	belonging = Wardrobe.new().get_random_cloak()
	if belonging:
		belonging.position = Vector2(0, 50)
		add_child(belonging)

	
func notify_opening_hours(opens: int, closes: int):
	var night_duration = closes - opens
	leaving.start(float((night_duration/2) + randi() % (night_duration/2)))
	going_to_queue.emit(self)

func _set_state(new_state: State):
	# What to do when entering a state
	match new_state:
		State.WAITING_FOR_PICKUP:
			belonging.visible = true
			dropItem.emit(belonging)
			belonging.picked.connect(_belonging_dropped)
		State.WAITING_FOR_DROPOFF: 
			ticket.visible = true
			dropItem.emit(ticket)
		State.WAITING_FOR_TICKET:
			money.visible = true
			dropItem.emit(money)
			belonging.picked.disconnect(_belonging_dropped)
		State.IN_CLUB: 
			if leaving.is_stopped():
				going_to_queue.emit(self)
		State.LEAVING: 
			belonging.visible = false
			leaving_spot.emit(self)
			_move_to(Vector2(0, position.y))

	state = new_state
	
func _belonging_dropped(item: Node2D):
	_set_state(State.WAITING_FOR_TICKET)

func _on_leave_timer_timeout() -> void:
	if state == State.IN_CLUB:
		going_to_queue.emit(self)
	elif self.is_ancestor_of(belonging): # My jacket is allready on
		_set_state(State.LEAVING)
	elif notificationArea.overlaps_area(belonging.area):
		belonging.move_to_parent(self)
		_set_state(State.LEAVING)

func _move_to(target_pos: Vector2) -> Tween:
	# Stop any existing tween
	if position_tween and position_tween.is_running():
		position_tween.kill()
		position_tween = null
	if rock_tween and rock_tween.is_running():
		rock_tween.kill()
		rock_tween = null

	# Position tween
	var duration = global_position.distance_to(target_pos) / speed
	position_tween = create_tween()
	position_tween.tween_property(self, "global_position", target_pos, duration)
	position_tween.set_trans(Tween.TRANS_LINEAR)
	position_tween.set_ease(Tween.EASE_IN_OUT)

	# Rocking tween
	rock_tween = create_tween()
	rock_tween.set_loops(-1)  # Loop indefinitely during the movement
	rock_tween.set_trans(Tween.TRANS_LINEAR)
	rock_tween.set_ease(Tween.EASE_IN_OUT)

	# Rock side-to-side by modifying the rotation property
	var rock_duration = 1.0 / (speed / 100.0)
	rock_tween.tween_property(self, "rotation", 0.1, rock_duration/2)
	rock_tween.tween_property(self, "rotation", -0.1, rock_duration/2)

	# Stop rocking when movement is finished
	position_tween.finished.connect(func() -> void:
		rock_tween.kill()
		self.rotation = 0  # Reset rotation to 0
	)
	return position_tween
	
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

func counter_item_added(item: Node2D):
	if not notificationArea.overlaps_area(item.area):
		return
	
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
