extends Sprite2D

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

var _queue : Node2D
static var guests = 1
var guest_id = guests



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

	print("Guest " + str(guest_id) + " Initialized with speed: " + str(speed) + ", Belonging: " + str(belonging))
	guests += 1
	

func stand_in_queue(queue: Node2D):
	_queue = queue
	queue.moving.connect(find_better_spot)
	var pos = queue.join(self)
	print("Guest " + str(guest_id) + " Joining queue at position: " + str(pos))
	_move_to(pos)
	_set_state(State.IN_LINE)
	
func leave_queue():
	_queue.moving.disconnect(find_better_spot)
	if position_tween.finished:
		position_tween.finished.disconnect(_check_counter)
	_queue.leave(self)

func find_better_spot():
	var position = _queue.get_best_spot(self)
	if position:
		print("Guest " + str(guest_id) + " Found a better queue spot: " + str(position))
		_move_to(position)

func notify_opening_hours(opens: int, closes: int):
	var night_duration = closes - opens
	leaving.start(float((night_duration/2) + randi() % (night_duration/2)))
	print("Guest " + str(guest_id) + " Notified opening hours: " + str(opens) + " - " + str(closes))

func _set_state(new_state: State):
	print("Guest " + str(guest_id) + " Transitioning from " + str(state) + " to " + str(new_state))
	match new_state:
		State.WAITING_FOR_PICKUP:
			belonging.visible = true
			print("Guest " + str(guest_id) + " Waiting for pickup - Belonging Visible")
			dropItem.emit(belonging)
			belonging.picked.connect(_belonging_dropped)
		State.WAITING_FOR_DROPOFF: 
			ticket.visible = true
			print("Guest " + str(guest_id) + " Waiting for dropoff - Ticket Visible")
			dropItem.emit(ticket)
		State.WAITING_FOR_TICKET:
			money.visible = true
			print("Guest " + str(guest_id) + " Waiting for ticket - Money Visible")
			dropItem.emit(money)
			belonging.picked.disconnect(_belonging_dropped)
		State.IN_CLUB: 
			if leaving.is_stopped():
				print("Guest " + str(guest_id) + " Entered club, waiting for time to leave")
				stand_in_queue(_queue)
		State.LEAVING: 
			belonging.visible = false
			print("Guest " + str(guest_id) + " Leaving club, heading out")
			leave_queue()
			_move_to(Vector2(0, position.y))

	state = new_state

func _belonging_dropped(item: Node2D):
	print("Guest " + str(guest_id) + " Belonging dropped: " + str(item))
	_set_state(State.WAITING_FOR_TICKET)

func _on_leave_timer_timeout() -> void:
	print("Guest " + str(guest_id) + " Leave timer triggered")
	if state == State.IN_CLUB:
		stand_in_queue(_queue)
	elif self.is_ancestor_of(belonging):
		print("Guest " + str(guest_id) + " Belonging already worn, leaving now")
		_set_state(State.LEAVING)
	elif notificationArea.overlaps_area(belonging.area):
		print("Guest " + str(guest_id) + " Found belonging, putting it on and leaving")
		belonging.move_to_parent(self)
		_set_state(State.LEAVING)

func _move_to(target_pos: Vector2) -> Tween:
	print("Guest " + str(guest_id) + " Moving to: " + str(target_pos))

	if position_tween and position_tween.is_running():
		position_tween.kill()
	if rock_tween and rock_tween.is_running():
		rock_tween.kill()

	var duration = global_position.distance_to(target_pos) / speed
	position_tween = create_tween()
	position_tween.tween_property(self, "global_position", target_pos, duration)
	position_tween.set_trans(Tween.TRANS_LINEAR)
	position_tween.set_ease(Tween.EASE_IN_OUT)

	rock_tween = create_tween()
	if _queue._find_guest_spot(self):
		position_tween.finished.connect(_check_counter)

	rock_tween.set_loops(-1)
	rock_tween.set_trans(Tween.TRANS_LINEAR)
	rock_tween.set_ease(Tween.EASE_IN_OUT)

	var rock_duration = 1.0 / (speed / 100.0)
	rock_tween.tween_property(self, "rotation", 0.1, rock_duration/2)
	rock_tween.tween_property(self, "rotation", -0.1, rock_duration/2)

	position_tween.finished.connect(func() -> void:
		print("Guest " + str(guest_id) + " Finished moving to: " + str(target_pos))
		rock_tween.kill()
		self.rotation = 0
	)
	return position_tween

func _check_counter() -> bool:
	if not _queue.at_counter(self):
		return false

	print("Guest " + str(guest_id) + " Reached counter")
	if self.is_ancestor_of(belonging):
		print("Guest " + str(guest_id) + " Belonging on, waiting for pickup")
		_set_state(State.WAITING_FOR_PICKUP)
	elif leaving.is_stopped():
		print("Guest " + str(guest_id) + " Leaving but missing belonging, waiting for dropoff")
		_set_state(State.WAITING_FOR_DROPOFF)
	return true

func counter_item_added(item: Node2D):
	if not notificationArea.overlaps_area(item.area):
		return
		
	print("Guest " + str(guest_id) + " Counter item added in front of me: " + str(item))

	if state == State.WAITING_FOR_TICKET and item.name.begins_with("ticket"):		
		ticket = item
		ticket.move_to_parent(self)
		ticket.visible = false
		leave_queue()
		print("Guest " + str(guest_id) + " going clubbing!")
		var target_pos = Vector2(get_viewport().size.x, position.y)
		var tween = _move_to(target_pos)
		tween.finished.connect(_set_state.bind(State.IN_CLUB))
	elif state == State.WAITING_FOR_DROPOFF and item == belonging:
		item.move_to_parent(self)
		_set_state(State.LEAVING)
