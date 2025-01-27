class_name Wardrobe

# List of available cloaks
var cloaks: Array[String] = []

# Constructor: Initialize and load cloaks
func _init():
	var cloak_dir = "res://scenes/pickableItems/cloaks/"
	var dir = DirAccess.open(cloak_dir)
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tscn"): 
				cloaks.append(cloak_dir + file)

# Returns an instance of a random cloak
func get_random_cloak() -> Node2D:
	if cloaks.size() == 0:
		push_error("No cloaks available!")
		return null
	var selected_cloak = cloaks.pick_random()
	var cloak_scene = load(selected_cloak)
	if cloak_scene:
		return cloak_scene.instantiate() as Node2D
	else:
		push_error("Failed to load cloak: " + selected_cloak)
		return null
