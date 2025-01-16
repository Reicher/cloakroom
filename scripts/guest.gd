extends Sprite2D

signal leaving_spot(guest: Node2D)
signal dropItem(item: Node2D)

# State management
enum State { IN_LINE, WAITING_FOR_PICKUP, WAITING_FOR_TICKET, IN_CLUB }
var state: State = State.IN_LINE

var belonging: Node2D
var money: Node2D
var ticket: Node2D

func _ready():
	global_position = Vector2(0, 300)
	_set_random_texture("res://assets/image/people.png", 5, 145, 252)


func _set_random_texture(atlas_path: String, frames: int, width: int, height: int):
	var texture = AtlasTexture.new()
	texture.atlas = load(atlas_path)
	texture.region = Rect2(width * (randi() % frames), 0, width, height)
	self.texture = texture

func _set_state(new_state: State):
	#print(str(state) + " -> " + str(new_state))
	state = new_state

func goToQueueSpot(target_pos: Vector2, is_service_spot: bool):
	var tween = _move_to(target_pos, 150 + (randi() % 150))
	if is_service_spot:
		tween.finished.connect(_on_counter_reached)
		_set_state(State.WAITING_FOR_PICKUP)
	else:
		_set_state(State.IN_LINE)

func _move_to(target_pos: Vector2, speed: int = 100) -> Tween:
	var duration = global_position.distance_to(target_pos) / speed
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	return tween

func _on_counter_reached():
	print("counter reached!")
	belonging = _create_item("black_jacket.tscn", Vector2(0, 30))
	dropItem.emit(belonging)
	belonging.picked.connect(_on_belonging_picked)
	_set_state(State.WAITING_FOR_PICKUP)

func _on_belonging_picked():
	_set_state(State.WAITING_FOR_TICKET)
	money = _create_item("money.tscn", Vector2(0, 30))
	dropItem.emit(money)

func _create_item(scene_path: String, item_pos: Vector2) -> Node2D:
	var scene = load("res://scenes/pickableItems/%s" % scene_path)
	var item = scene.instantiate()
	self.add_child(item)
	item.position = item_pos
	print("item created at: " + str(item.global_position))
	return item

func _go_away():
	var target_pos = Vector2(get_viewport().size.x, position.y)
	_move_to(target_pos, 150 + (randi() % 150))
	_set_state(State.IN_CLUB)

func _on_surface_item_added(item: Node2D):
	if state == State.WAITING_FOR_TICKET and item.name.begins_with("ticket"):
		ticket = item
		ticket.move_to_parent(self)
		ticket.visible = false
		leaving_spot.emit(self)
		_go_away()
