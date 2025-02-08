extends Node2D

# This file is a mess, hopefully I will never have to revisit it

signal moving

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
		print(row)
		rows.append(row)

# Updates the modulate property of the guest based on its Y position
func _update_guest_modulate(guest: Node2D) -> void:
	var max_y = $Window.position.y + $Window.size.y
	var min_y = max_y - (total_rows * row_spacing)
	var fade_factor = clamp((guest.position.y - min_y) / (max_y - min_y), 0.0, 1.0)
	guest.modulate = Color(fade_factor, fade_factor, fade_factor, 1.0) # Fade to black
		
func join(guest: Node2D) -> Vector2:
	if not guest.is_ancestor_of(self):
		add_child(guest)
	return get_best_spot(guest)
	
# Handles a guest leaving their spot
func leave(guest: Node2D) -> void:
	var vacated_spot = _find_guest_spot(guest)
	vacated_spot["guest"] = null
	moving.emit()
	
func at_counter(guest: Node2D) -> bool:
	var spot = _find_guest_spot(guest)
	return spot && spot["row"] == 0

func _process(delta: float) -> void:
	for row in rows:
		for spot in row:
			if spot["guest"]:
				_update_guest_modulate(spot["guest"])

func get_best_spot(guest: Node2D):
	if at_counter(guest):
		return null
	
	var current_spot = _find_guest_spot(guest)
	if current_spot:
		var better_spot = _get_free_spot_below(current_spot["row"], current_spot["column"])
		if better_spot:
			current_spot["guest"] = null
			better_spot["guest"] = guest
			return better_spot["position"]
		else:
			return null
	
	# Search for the first available spot in the queue
	var best_spots: Array = []
	for row in rows:
		for spot in row:
			if spot["guest"] == null:  # Only collect free spots
				best_spots.append(spot)
		if best_spots.size() > 0:
			break  # Stop at the first non-empty row

	# Ensure we have a valid spot before assigning
	if best_spots.size() == 0:
		push_error("No available spot found for guest!")
		return null

	var slot_given = best_spots.pick_random()
	if slot_given == null:
		push_error("Unexpected null slot selection!")
		return null

	slot_given["guest"] = guest
	return slot_given["position"]

# Finds the spot where a specific guest is located
func _find_guest_spot(guest: Node2D) -> Dictionary:
	for row in rows:
		for spot in row:
			if spot["guest"] == guest:
				return spot
	return {}

func _get_free_spot_below(row_index: int, column_index: int) -> Dictionary:
	print("check free spot below row/col: " + str(row_index) + "/" + str(column_index))
	# If there's no row below, return an empty dictionary (no spot available)
	if row_index - 1 < 0:
		return {}

	var below_row = rows[row_index - 1]  # Get the row below
	var free_spots = []

	# Determine the range of potential spots below, based on row alignment
	var potential_indices = []
	if row_index % 2 == 0: # Even row
		potential_indices = [column_index, column_index + 1]
	else: # Odd row
		potential_indices = [column_index, column_index - 1]
		
	print("potential_indices: " + str(potential_indices))

	for index in potential_indices:
		# Ensure the index is within bounds
		if index >= 0 and index < len(below_row):
			var spot = below_row[index]
			# Check if the spot is free (no guest assigned)
			if not spot["guest"]:
				free_spots.append(spot)

	# Return the first available spot if there is one, otherwise return an empty dictionary
	return free_spots.pick_random() if free_spots.size() > 0 else {}
