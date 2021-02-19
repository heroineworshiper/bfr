extends Spatial

var library = preload("library.gd").new()

var materials = [
    'vab', 'res://materials/white.tres',
    'beach', 'res://materials/beach.tres',
    'ground_cutout', 'res://materials/ground.tres',
    'ocean_cutout', 'res://materials/water.tres',
    'road_cutout', 'res://materials/road.tres',
    'shuttle_landing', 'res://materials/road.tres',
    'water1', 'res://materials/water.tres'
]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    library.setMaterials(self, materials)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
