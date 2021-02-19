extends Spatial

var library = preload("library.gd").new()
var windows = Array()
export var TOTAL_WINDOWS = 101

#var HEATSHIELD_MATERIAL = "res://materials/heatshield.tres"
var HEATSHIELD_MATERIAL = "res://materials/black.tres"

# material to object mapping
var materials = [
    "bottom dome", "res://materials/stainless.material",
    "bottom_fuse", "res://materials/stainless.material",
    "bottom_heatshield", HEATSHIELD_MATERIAL,
    "canard flange", "res://materials/stainless.material",
    "canard", "res://materials/stainless.material",
    "canard flange2", "res://materials/stainless.material",
    "canard2", "res://materials/stainless.material",
    "flag", "res://materials/flag.tres",
    "hatch1",  "res://materials/stainless.material",
    "hatch1_outline", "res://materials/black.tres",
    "hatch2", "res://materials/stainless.material",
    "hatch2_outline", "res://materials/black.tres",
    "spacex", "res://materials/spacex.tres",
    "top_fuse", "res://materials/stainless.material",
    "top_heatshield", HEATSHIELD_MATERIAL,
    "wing flange", "res://materials/stainless.material",
    "wing", "res://materials/stainless.material",
    "wing flange2", "res://materials/stainless.material",
    "wing2", "res://materials/stainless.material",
]

func _ready():
    # Called when the node is added to the scene for the first time.
    # Initialization here.
    for i in range(0, TOTAL_WINDOWS):
        var node = find_node("window_" + str(i))
        windows.append(node)
        node.set_surface_material(0, load("res://materials/window.material"))
    library.setMaterials(self, materials)

    # create mirrored objects
    

    
    
#func _process(delta):
#    # Called every frame. Delta is time since last frame.
#    # Update game logic here.
#    pass
