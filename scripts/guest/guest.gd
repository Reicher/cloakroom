extends Sprite2D

signal dropItem(item: Node2D)

@onready var leaving = $LeaveTimer
@onready var notificationArea = $NotificationArea

var speed : int = 150 + (randi() % 150)
var position_tween : Tween = null
var rock_tween: Tween = null

var belonging : Node2D
var ticket: Node2D

var _queue : Node2D
static var guests = 0
var guest_id = guests

var current_state

func _ready():
	guests += 1
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
		
	$Label.text = str(guest_id)

func change_state(new_state: String) -> void:
	print("Guest " + str(guest_id) + " transition from " + str(current_state) + " to " + new_state)
	if current_state:
		current_state.exit_state()
	current_state = get_node(new_state)
	if current_state:
		current_state.enter_state(self)

func find_better_spot():
	var position = _queue.get_best_spot(self)
	if position:
		_move_to(position)
		
func pay(amount: int):
	var money = load("res://scenes/pickableItems/money.tscn").instantiate()
	money.position = position + Vector2(0, 62)
	dropItem.emit(money)

func _move_to(target_pos: Vector2) -> Tween:
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

	rock_tween.set_loops(-1)
	rock_tween.set_trans(Tween.TRANS_LINEAR)
	rock_tween.set_ease(Tween.EASE_IN_OUT)

	var rock_duration = 1.0 / (speed / 100.0)
	rock_tween.tween_property(self, "rotation", 0.1, rock_duration/2)
	rock_tween.tween_property(self, "rotation", -0.1, rock_duration/2)

	position_tween.finished.connect(func() -> void:
		rock_tween.kill()
		self.rotation = 0
		current_state.move_finished()
	)
	return position_tween

# Stupid function that nees to die
func notify_opening_hours(opens: int, closes: int):
	var night_duration = closes - opens
	leaving.start(float((night_duration/2) + randi() % (night_duration/2)))
	leaving.timeout.connect(change_state.bind("Leave"))

func counter_item_added(item: Node2D):
	await get_tree().physics_frame  # Wait until physics updates so that item box is correct
	if _queue.at_counter(self) and not position_tween.is_running() and notificationArea.overlaps_area(item.area): 
		current_state.item_presented(item)
