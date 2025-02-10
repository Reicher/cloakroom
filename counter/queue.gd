extends Node2D

signal moving

@export var counter_spots = 4 
@export var row_spacing = 25 
@export var total_rows = 5

var rows: Array = []

func _ready() -> void:
	_initialize_rows()

func _initialize_rows() -> void:
	var window_size = $Window.size
	var start_pos = $Window.position + Vector2(0, window_size.y)
	var end_pos = $Window.position + Vector2(window_size.x, window_size.y)

	for row_index in range(total_rows):
		var spots_in_row = counter_spots + (row_index % 2)
		var spot_spacing = (end_pos.x - start_pos.x) / (spots_in_row if row_index % 2 == 0 else spots_in_row - 1)
		var row_start = start_pos + Vector2((spot_spacing / 2 if row_index % 2 == 0 else 0), row_index * -row_spacing)
		var row = []

		for column_index in range(spots_in_row):
			row.append({
				"row": row_index,
				"column": column_index,
				"guest": null,
				"position": row_start + Vector2(column_index * spot_spacing, 0)
			})
		rows.append(row)

func _update_guest_modulate(guest: Node2D) -> void:
	var max_y = $Window.position.y + $Window.size.y
	var min_y = max_y - (total_rows * row_spacing)
	var fade_factor = clamp((guest.position.y - min_y) / (max_y - min_y), 0.0, 1.0)
	guest.modulate = Color(fade_factor, fade_factor, fade_factor, 1.0)

func leave(guest: Node2D) -> void:
	_find_guest_spot(guest)["guest"] = null
	moving.emit()

func at_counter(guest: Node2D) -> bool:
	var spot = _find_guest_spot(guest)
	if spot != {}: 
		return spot["row"] == 0
	return false

func _process(delta: float) -> void:
	for row in rows:
		for spot in row:
			if spot["guest"]:
				_update_guest_modulate(spot["guest"])

func get_best_spot(guest: Node2D):
	var current_spot = _find_guest_spot(guest)
	if current_spot and current_spot["row"] == 0: # alread at counter
		return null

	if current_spot:
		var better_spot = _get_free_spot_below(current_spot["row"], current_spot["column"])
		if better_spot:
			current_spot["guest"] = null
			better_spot["guest"] = guest
			return better_spot["position"]
		return null

	for row in rows:
		for spot in row:
			if not spot["guest"]:
				spot["guest"] = guest
				return spot["position"]

	push_error("No available spot found for guest!")
	return null

func _find_guest_spot(guest: Node2D) -> Dictionary:
	for row in rows:
		for spot in row:
			if spot["guest"] == guest:
				return spot
	return {}

func _get_free_spot_below(row_index: int, column_index: int) -> Dictionary:
	if row_index - 1 < 0:
		return {}

	var below_row = rows[row_index - 1]
	var potential_indices = [column_index, column_index + 1] if row_index % 2 == 0 else [column_index, column_index - 1]

	for index in potential_indices:
		if index >= 0 and index < len(below_row) and not below_row[index]["guest"]:
			return below_row[index]
	return {}
