extends Node2D

@onready var area : Area2D = $Area2D
@onready var shader_material: ShaderMaterial = $Sprite2D.material

func _ready():
	if shader_material and shader_material is ShaderMaterial:
		shader_material.set_shader_param("is_hovering", false)

func _on_surface_item_added(item: Node2D) -> void:
	print("item hanged")
