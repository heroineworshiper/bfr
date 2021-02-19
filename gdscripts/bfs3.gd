extends Spatial

var library = preload("library.gd").new()
var windows = Array()
export var TOTAL_WINDOWS = 101

# material to object mapping
var materials = [
    "bottom_fuse", "res://materials/stainless.material",
    "bottom_heatshield", "res://materials/stainless.material",
    "canard flange1", "res://materials/stainless.material",
    "canard flange2", "res://materials/stainless.material",
    "canard1", "res://materials/stainless.material",
    "canard2", "res://materials/stainless.material",
    "flag", "res://materials/stainless.material",
    "hatch1",  "res://materials/stainless.material",
    "hatch1_outline", "res://materials/black.tres",
    "hatch2", "res://materials/stainless.material",
    "hatch2_outline", "res://materials/black.tres",
    "pipes", "res://materials/heatshield.tres",
    "spacex", "res://materials/stainless.material",
    "tank rear", "res://materials/heatshield.tres",
    "top dome",  "res://materials/stainless.material",
    "top_fuse", "res://materials/stainless.material",
    "top_heatshield", "res://materials/stainless.material",
    "wing base3", "res://materials/stainless.material",
    "wing base4", "res://materials/stainless.material",
    "wing cylinder3", "res://materials/stainless.material",
    "wing cylinder4", "res://materials/stainless.material",
    "wing2", "res://materials/stainless.material",
    "wing3", "res://materials/stainless.material",
    "wing4", "res://materials/stainless.material",
    "wing_heatshield", "res://materials/stainless.material",

]

func _ready():
    # Called when the node is added to the scene for the first time.
    # Initialization here.
    for i in range(0, TOTAL_WINDOWS):
        var node = find_node("window_" + str(i))
        windows.append(node)
        node.set_surface_material(0, load("res://materials/window.material"))
    library.setMaterials(self, materials)
    
    
    
#func _process(delta):
#    # Called every frame. Delta is time since last frame.
#    # Update game logic here.
#    pass
