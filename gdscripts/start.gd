extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var node = find_node("start")
	node.set_surface_material(0, load("res://materials/white.material"))

