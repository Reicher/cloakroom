extends Node2D

# This file is a mess, hopefully I will never have to revisit it

@export var max_spots_per_row = 4
@export var row_spacing = 25 # Vertical spacing between rows
@export var total_rows = 5

# 2D array of rows, each containing spots with position and guest info
var rows: Array = []

func _ready() -> void:
	_initialize_rows()

# Sets up the queue with alternating rows of spots
func _initialize_rows() -> void:
	var window_size = $Window.size
	var start_pos = $Window.position + Vector2(0, window_size.y)
	var end_pos = $Window.position + Vector2(window_size.x, window_size.y)

	for row_index in range(total_rows):
		var spots_in_row = max_spots_per_row + (row_index % 2) # Add 1 for odd rows
		var spot_spacing = (end_pos.x - start_pos.x) / (spots_in_row - 1 if row_index % 2 != 0 else spots_in_row)
		var row_start = start_pos + Vector2((spot_spacing / 2 if row_index % 2 == 0 else 0), row_index * -row_spacing)

		var row: Array = []
		for column_index in range(spots_in_row):
			row.append({
				"row": row_index,
				"column": column_index,
				"guest": null,
				"position": row_start + Vector2(column_index * spot_spacing, 0)
			})
		rows.append(row)
		
func add_guest(guest: Node2D) -> void:
	add_child(guest)
	guest.leaving_spot.connect(_guest_left)
	guest.going_to_queue.connect(handle_guest)	
		
# Updates the modulate property of the guest based on its Y position
func _update_guest_modulate(guest: Node2D) -> void:
	var max_y = $Window.position.y + $Window.size.y
	var min_y = max_y - (total_rows * row_spacing)
	var fade_factor = clamp((guest.position.y - min_y) / (max_y - min_y), 0.0, 1.0)
	guest.modulate = Color(fade_factor, fade_factor, fade_factor, 1.0) # Fade to black

func _process(delta: float) -> void:
	for row in rows:
		for spot in row:
			if spot["guest"]:
				_update_guest_modulate(spot["guest"])

# Adds a guest to the first available spot
func handle_guest(guest: Node2D) -> void:
	for row in rows:
		for spot in row:
			if not spot["guest"]:
				spot["guest"] = guest
				guest.goToQueueSpot(spot["position"], row == rows[0]) # Mark as front row if applicable
				return

	push_error("No available spot for guest!") # No spots available

# Finds the spot where a specific guest is located
func _find_guest_spot(guest: Node2D) -> Dictionary:
	for row in rows:
		for spot in row:
			if spot["guest"] == guest:
				return spot
	return {}

# Handles a guest leaving their spot
func _guest_left(guest: Node2D) -> void:
	var vacated_spot = _find_guest_spot(guest)
	if vacated_spot:
		vacated_spot["guest"] = null
		_cascade_guests()

# Moves guests to fill empty spots
func _cascade_guests() -> void:
	for row in rows:
		for spot in row:
			if not spot["guest"]: # If the spot is empty
				var candidates = _get_occupied_spots_above(spot["row"], spot["column"])
				if candidates.size() > 0:
					var moving_spot = candidates.pick_random()
					var moving_guest = moving_spot["guest"]

					# Move the guest to the empty spot
					moving_guest.goToQueueSpot(spot["position"], spot["row"] == 0) # Front row check
					spot["guest"] = moving_guest
					moving_spot["guest"] = null

					# Restart cascade from the top
					_cascade_guests()
					return

# Retrieves occupied spots above a given spot
func _get_occupied_spots_above(row_index: int, column_index: int) -> Array:
	if row_index + 1 >= total_rows:
		return []

	var spots_above = []
	var above_row = rows[row_index + 1]

	# Determine the range of potential spots above, based on row alignment
	var potential_indices = []
	if row_index % 2 == 0: # Even row
		potential_indices = [column_index, column_index + 1]
	else: # Odd row
		potential_indices = [column_index - 1, column_index]

	for index in potential_indices:
		if index >= 0 and index < len(above_row):
			var spot = above_row[index]
			if spot["guest"]:
				spots_above.append(spot)

	return spots_above
