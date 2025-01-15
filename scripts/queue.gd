extends Node2D

@export var maxCustomers = 4

@onready var order = [$Counter, $Row1, $Row2, $Row3]
@onready var counter = $Counter
@onready var rest = $Rest

func _ready() -> void:
	var service_window = $ServiceWindow
	var window_shape = service_window.get_node("Shape") as CollisionShape2D

	# Calculate dimensions
	var extents = window_shape.shape.extents
	var box_width = (extents.x * 2) / maxCustomers
	var start = window_shape.position + Vector2(0, extents.y * 1.8)

	# Create spots dynamically for each row in the order array
	for row_index in range(order.size()):
		var parent = order[row_index]
		var spots_in_row = maxCustomers if row_index % 2 == 0 else maxCustomers + 1
		var row_offset = -row_index * 30 # Calculate vertical offset for rows

		for i in range(spots_in_row):
			var x_offset = 0 if row_index % 2 == 0 else -(box_width / 2) # Offset alternating rows
			var spot_position = start + Vector2(i * box_width + x_offset, row_offset)
			_add_spot(parent, spot_position)

	# Add a single spot for the rest node
	_add_spot(rest, Vector2.ZERO)

func _add_spot(parent: Node2D, position: Vector2) -> void:
	# Create a new Node2D as a spot
	var spot = Node2D.new()
	spot.position = position
	parent.add_child(spot)
	
func handle_guest(guest: Node2D) -> void:
	for parent in order:
		for child in parent.get_children():
			#print(child.name)
			# Check if the spot is empty (no children other than the guest node)
			if child.get_child_count() == 0:
				# Assign the guest to this spot
				child.add_child(guest)
				guest.goToQueueSpot(child.position, parent == counter)
				return
	
	print("No available spot for guest, goes into rest")
	rest.add_child(guest)
