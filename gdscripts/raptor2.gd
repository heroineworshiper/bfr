# not used

extends Spatial
var library = preload("library.gd").new()



export (int)var state = library.ENGINE_OFF


var flame
var cones
var seaNozzle
var vacuumNozzle
export (Transform)var defaultTransform
var defaultFlameTransform
var defaultConeTransform
export var angle = 0.0
# user input value.  operating range is 0.5 - 1.0.
var commandedThrottle = 0.0
# delayed value
var currentThrottle = 0.0
var currentTime = 0.0
var STARTUP_TIME = 0.25
var SHUTDOWN_TIME = 0.25

func setThrottle(value):
    commandedThrottle = value
    


func _ready():
    print("raptor2.gd ready")
    # Called when the node is added to the scene for the first time.
    flame = find_node('flame2')
    cones = find_node('cones')
    seaNozzle = find_node('seaNozzle')
    vacuumNozzle = find_node('vacuumNozzle')
    state = library.ENGINE_JOYSTICK_INIT
    defaultTransform = transform
    defaultFlameTransform =  flame.transform
    defaultConeTransform = cones.transform
    


# do scaling indepedent of position
func flameTransform(mesh, scale, rotate, default):
    mesh.transform = default
    mesh.transform.basis = mesh.transform.basis.scaled(Vector3(1, scale, 1))
    mesh.rotate_y(rotate)



func _process(delta):
    var throttleStep = library.THROTTLE_RATE * delta
    currentThrottle = library.doGimbal(commandedThrottle, currentThrottle, throttleStep)

# flame scale is 0.7-1.0
# scale throttle to flame scale
    var currentSize = (currentThrottle - 0.5) * 0.3 * 2 + 0.7 
    if currentSize < 0.7:
        currentSize = 0.7

    match state:
        # wait for the joystick to zero out
        library.ENGINE_JOYSTICK_INIT:
            if commandedThrottle < library.CUTOFF_THROTTLE2:
                state = library.ENGINE_OFF
        
        library.ENGINE_OFF:
            if commandedThrottle > library.CUTOFF_THROTTLE1:
                state = library.ENGINE_STARTING1
                currentTime = 0.0
                flameTransform(flame, 0, 0, defaultFlameTransform)
                flameTransform(cones, 0, 0, defaultConeTransform)
                flame.show()
                cones.show()

        library.ENGINE_STARTING1:
            currentTime += delta
            var scale = currentTime / STARTUP_TIME * currentSize
            if currentTime >= STARTUP_TIME:
                state = library.ENGINE_RUNNING
                scale = 1.0
            flameTransform(flame, scale, 0, defaultFlameTransform)
            flameTransform(cones, scale, 0, defaultConeTransform)
            if commandedThrottle < library.CUTOFF_THROTTLE2:
                state = library.ENGINE_SHUTDOWN1
                currentTime = 0.0


        library.ENGINE_RUNNING:
            var jitterRotate = (randf() * 10 - 5) * 2 * PI / 360
            var jitterScale = 1.0 + randf() * 0.1 - 0.05
            var scale = currentSize * jitterScale
            

            flameTransform(flame, scale, jitterRotate, defaultFlameTransform)
            flameTransform(cones, scale, jitterRotate, defaultConeTransform)

            if commandedThrottle < library.CUTOFF_THROTTLE2:
                state = library.ENGINE_SHUTDOWN1
                currentTime = 0.0



        library.ENGINE_SHUTDOWN1:
            currentTime += delta
            var scale = (1.0 - currentTime / SHUTDOWN_TIME) * currentSize
            if currentTime >= SHUTDOWN_TIME:
                state = library.ENGINE_OFF
                scale = 0.0
                flame.hide()
                cones.hide()
            flameTransform(flame, scale, 0, defaultFlameTransform)
            flameTransform(cones, scale, 0, defaultConeTransform)
                
            
            
            
