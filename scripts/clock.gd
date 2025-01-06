extends Node2D

@export var hour_hand_length: float = 30.0
@export var minute_hand_length: float = 45.0
@export var hand_thickness: float = 4.0
@export var start_time: float = 10.0  # Start time as a float between 0-12 (e.g., 6.0 = 6 o'clock)
@export var end_time: float = 4.0  # End time as a float between 0-12 (e.g., 12.0 = noon)

signal time_reached  # Signal emitted when the end time is reached

var current_time: float = 0.0  # Internal timer to track time as a float between 0-12

func _ready():
	set_physics_process(true)
	current_time = start_time  # Initialize the timer to the start time

func _process(delta: float) -> void:
	# Advance time: 1 minute of game time per real-time second
	current_time += (delta / 60.0)  # 1 real second = 1 game minute

	# Wrap the current time within 0-12 range (if needed)
	if current_time >= 12.0:
		current_time = 0.0

	# Check if the end time has been reached
	if current_time >= end_time:
		emit_signal("time_reached")  # Emit the signal
		set_physics_process(false)  # Stop updating the clock

	queue_redraw()  # Redraw the clock

func _draw():
	var hours = int(current_time)  # Whole hours (0-12)
	var minutes = (current_time - hours) * 60.0  # Fractional part converted to minutes

	# Calculate the angles for the hour and minute hands
	var hour_angle = deg_to_rad(-90 + (current_time / 12.0) * 360.0)
	var minute_angle = deg_to_rad(-90 + (minutes / 60.0) * 360.0)

	# Draw the hour hand
	var hour_end =  Vector2(cos(hour_angle), sin(hour_angle)) * hour_hand_length
	draw_line(Vector2.ZERO, hour_end, Color(0, 0, 0), hand_thickness)

	# Draw the minute hand
	var minute_end = Vector2(cos(minute_angle), sin(minute_angle)) * minute_hand_length
	draw_line(Vector2.ZERO, minute_end, Color(0, 0, 0), hand_thickness * 0.5)
