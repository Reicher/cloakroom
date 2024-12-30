extends Node2D

@onready var CounterView = $CounterView
@onready var BackRoom = $Backroom


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	if CounterView.visible: 
		CounterView.visible = false
		BackRoom.visible = true
	else:
		CounterView.visible = true
		BackRoom.visible = false
