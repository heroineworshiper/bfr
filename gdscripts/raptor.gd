# the current raptor script

extends Spatial
var library = preload("library.gd").new()

export (int)var state = library.ENGINE_OFF

var seaFlame
var seaNozzle
# combustion chamber
var flame2
var vacuumNozzle
var angle
var defaultTransform
var defaultFlameTransform
var defaultFlame2Transform
# user input value.  operating range is 0.5 - 1.0.
var commandedThrottle = 0.0
# delayed value
var currentThrottle = 0.0
var currentTime = 0.0
var STARTUP_TIME = 0.25
var SHUTDOWN_TIME = 0.25


var materials = [
    'charcoal01', "res://materials/heatshield.tres",
    'charcoal02', "res://materials/heatshield.tres",
    'sea_nozzle', "res://materials/heatshield2side.tres",
    'vacuum_nozzle', "res://materials/heatshield2side.tres",
    'sea_flame', "res://materials/flame2.material",
    'flame2', "res://materials/flame3.tres"
]


func setThrottle(value):
    commandedThrottle = value
    

# Called when the node enters the scene tree for the first time.
func _ready():
    #print("raptor.ready")
    flame2 = find_node('flame2')
    flame2.hide()
    seaFlame = find_node('sea_flame')
    seaFlame.hide()
    seaNozzle = find_node('sea_nozzle')
    vacuumNozzle = find_node('vacuum_nozzle')
    vacuumNozzle.hide()
    library.setMaterials(self, materials)
    state = library.ENGINE_JOYSTICK_INIT
    defaultTransform = transform
    defaultFlameTransform = seaFlame.transform
    defaultFlame2Transform = flame2.transform


# do scaling indepedent of position
func flameTransform(mesh, scale, rotate, default):
    mesh.transform = default
    mesh.transform.basis = mesh.transform.basis.scaled(Vector3(1, scale, 1))
    mesh.rotate_y(rotate)



func _process(delta):
    var throttleStep = library.THROTTLE_RATE * delta
    currentThrottle = library.doGimbal(commandedThrottle, currentThrottle, throttleStep)












