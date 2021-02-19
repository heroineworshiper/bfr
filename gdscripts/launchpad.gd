extends RigidBody

var library = preload("library.gd").new()

var smoke1
var smoke2


var materials = [
    'tower', 'res://materials/white.tres'
]

# Called when the node enters the scene tree for the first time.
func _ready():
    smoke1 = find_node('smoke1')
    smoke2 = find_node('smoke2')
    library.setMaterials(self, materials)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass




func liftoff():
    smoke1.find_node('particles').emitting = true
