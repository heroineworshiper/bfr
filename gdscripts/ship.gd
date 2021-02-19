extends Spatial

var library = preload("library.gd").new()

var windows = Array()
export var TOTAL_WINDOWS = 101

const sea_engines = 2
const vac_engines = 4


var sea_raptors = Array()
var vac_raptors = Array()
var rigid_cg


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
    "pipes", "res://materials/heatshield2side.tres",
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

# Called when the node enters the scene tree for the first time.
func _ready():
    print("ship._ready")
    rigid_cg = find_node('rigid_cg')

    # Called when the node is added to the scene for the first time.
    # Initialization here.
    for i in range(0, TOTAL_WINDOWS):
        var node = find_node("window_" + str(i))
        windows.append(node)
        node.set_surface_material(0, load("res://materials/window.material"))
    library.setMaterials(self, materials)

    var engine = find_node('sea engine1')
    sea_raptors.append(engine)
    engine.seaNozzle.visible = true
    engine.vacuumNozzle.visible = false

# create the engines
# duplicate method doesn't work
    var raptor_scene = load("raptor2.tscn")
    var engine2 = raptor_scene.instance()
    sea_raptors.append(engine2)
    rigid_cg.add_child(engine2)
    engine2.transform = engine.transform
    #print("transform=%f,%f,%f" % [engine2.translation.x, engine2.translation.y, engine2.translation.z])
    engine2.rotate_y(library.toRad(180))
    engine2.translation.x *= -1
    engine2.translation.z *= -1
    engine2.defaultTransform = engine2.transform
    engine2.seaNozzle.visible = true
    engine2.vacuumNozzle.visible = false

    engine = find_node('vac engine1')
    engine2 = raptor_scene.instance()
    vac_raptors.append(engine2)
    rigid_cg.add_child(engine2)
    engine2.transform = engine.transform
    engine2.seaNozzle.visible = false
    engine2.vacuumNozzle.visible = true
    engine2.rotate_y(library.toRad(180))
    engine2.translation.x *= -1
    engine2.translation.z *= -1
    engine2.defaultTransform = engine2.transform

    engine2 = raptor_scene.instance()
    vac_raptors.append(engine2)
    rigid_cg.add_child(engine2)
    engine2.transform = engine.transform
    engine2.seaNozzle.visible = false
    engine2.vacuumNozzle.visible = true
    engine2.rotate_y(library.toRad(90))
    engine2.translation.x = engine2.translation.z
    engine2.translation.z = 0
    engine2.defaultTransform = engine2.transform

    engine2 = raptor_scene.instance()
    vac_raptors.append(engine2)
    rigid_cg.add_child(engine2)
    engine2.transform = engine.transform
    engine2.seaNozzle.visible = false
    engine2.vacuumNozzle.visible = true
    engine2.rotate_y(library.toRad(-90))
    engine2.translation.x = -engine2.translation.z
    engine2.translation.z *= 0
    engine2.defaultTransform = engine2.transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
