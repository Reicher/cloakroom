extends Node2D

@onready var area : Area2D = $Area2D

# TODO: Fix on hover material
@onready var shader_material: ShaderMaterial = $Sprite2D.material

func _ready():
	$ticket2/Number.text = $ticket1/Number.text # Duplicate number for tickets
	#shader_material.set_shader_param("is_hovering", false)

func _on_surface_item_added(item: Node2D) -> void:
	print("item hanged")
	item.move_to_parent(self)
	item.position = Vector2(0, 75)
