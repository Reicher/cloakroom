extends Node2D

@export var maxCustomers = 4
@export var row_offset = 30 # Vertical spacing between rows

# A 2D array representing rows with spots containing position and status
var rows: Array = []

func _ready() -> void:
	_initialize_queue()

func _initialize_queue() -> void:
	var size = $Window.size
	var start = $Window.position + Vector2(0, size.y)
	var end = $Window.position + Vector2(size.x, size.y)

	for row_index in range(8): # Number of rows
		var spots_in_row = maxCustomers + (1 if row_index % 2 != 0 else 0)
		var spacing = (end.x - start.x) / (spots_in_row if row_index % 2 == 0 else spots_in_row-1)
		var row_start = start + Vector2(spacing/2 if row_index % 2 == 0 else 0,  
										row_index * -row_offset)
		
		var row: Array = []
		for i in range(spots_in_row):
			row.append({"position": row_start + Vector2(i * spacing, 0), "occupied": false})
		rows.append(row)

func handle_guest(guest: Node2D) -> void:
	for row in rows:
		for spot in row:
			if not spot["occupied"]: # Check if spot is unoccupied
				spot["occupied"] = true # Mark spot as occupied
				add_child(guest)
				guest.goToQueueSpot(spot["position"], row == rows[0]) # If in the front row
				return

	push_error("No available spot for guest!") # No spot available
