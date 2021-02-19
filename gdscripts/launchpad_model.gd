extends Spatial
var library = preload("library.gd").new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var materials = [
    'hangar', 'res://materials/hangar_ext.tres',
    'launchpad', 'res://materials/launchpad.tres',
    'tower', 'res://materials/white.material'
]

# Called when the node enters the scene tree for the first time.
func _ready():
    library.setMaterials(self, materials)
    # must hide the -col if the shapes are different.  Ignore if the shapes are the same
    find_node('launchpad-col').hide()
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass







