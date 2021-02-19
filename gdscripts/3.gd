extends Node
var library = preload("library.gd").new()


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():

    var node = find_node("3")
    node.set_surface_material(0, load("res://materials/stainless.material"))

