extends Spatial

var library = preload("library.gd").new()
const booster_engines = 31
var booster_raptors = Array()
var rigid_cg



# material to object mapping
var materials = [
    "heatshield_top", 'res://materials/stainless.material',
    "heatshield_bottom", 'res://materials/stainless.material',
    "booster_bottom", "res://materials/stainless.material",
    "booster_top", "res://materials/stainless.material",
    "bottom_dome_001", 'res://materials/heatshield.tres',
    "fin", 'res://materials/stainless.material',
    "fin_001", 'res://materials/stainless.material',
    "fin_002", 'res://materials/stainless.material',
    "fin_003", 'res://materials/stainless.material',
    "flag1", "res://materials/stainless.material",
    "flag2", "res://materials/stainless.material",
    "logo1", "res://materials/stainless.material",
    "logo2", "res://materials/stainless.material",
    "space1", "res://materials/stainless.material",
    "space2", "res://materials/stainless.material",
    "top_dome", 'res://materials/heatshield.tres',
    "x1", "res://materials/stainless.material",
    "x2", "res://materials/stainless.material"
]


func _ready():
    print("booster._ready")
    library.setMaterials(self, materials)
    rigid_cg = find_node('rigid_cg')
    
    # create the engines
    var raptor_scene = load("raptor2.tscn")

    for i in range(0, booster_engines):
        var engine = raptor_scene.instance()
        rigid_cg.add_child(engine)
        booster_raptors.append(engine)

        engine.seaNozzle.visible = true
        engine.vacuumNozzle.visible = false


    # position the booster engines.  From booster_engines.FCMacro
    # radius of each layer in m
    var layerRadius = [
        4.1,
        3.1,
        1.4,
        0.0
    ]

    # Z of each layer in m
    var layerZ = [
        0,
        -0.3,
        -0.4,
        -0.5,
    ]

    # starting angle of each layer
    var layerAngle = [
        library.toRad(0.0),
        library.toRad(17.0),
        library.toRad(0.0),
        library.toRad(0.0)
    ]

    # engines in each layer
    var layerTotal = [
        12,
        12,
        6,
        1
    ]
    
    # engine in the current layer
    var currentEngine = 0
    var currentLayer = 0

    for i in range(0, booster_raptors.size()):
        # calculate its angle
        var angle = 0.0
        if layerTotal[currentLayer] > 1:
            angle = layerAngle[currentLayer] + \
                library.toRad(float(currentEngine) * 360.0 / layerTotal[currentLayer])
        booster_raptors[i].angle = angle
        
        # polar to XY
        var xyz = library.polarToXYZ(angle, 
            layerRadius[currentLayer], 
            layerZ[currentLayer] - 30.75)
        
        
        booster_raptors[i].translation = xyz
        booster_raptors[i].rotate_y(angle + PI)
        # reset the default transform
        booster_raptors[i].defaultTransform = booster_raptors[i].transform

        currentEngine = currentEngine + 1
        if currentEngine >= layerTotal[currentLayer]:
            currentLayer = currentLayer + 1
            currentEngine = 0





func _process(delta):
    pass








