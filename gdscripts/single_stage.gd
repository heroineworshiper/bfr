# the model being used when the rocket is lifting off


extends Node

var library = preload("library.gd").new()
var sound = preload("sound.gd").new()
var grid_deploy_sound
var grid_retract_sound


const booster_engines = 31
const total_flames = 2
var booster_raptors = Array()
var flames = Array()
var flame_origin = Vector3(0, 10, 0)
var flame_bounds = Vector3(5, 1, 5)

var smoke
var defaultSmokeTransform
var defaultSmokeScale

onready var rigid = get_node('rigid')
var bfs

# RUD states
const RUD_NONE = 0
const RUD_RUDDING = 1
var rud_state = RUD_NONE
var rud_time = 0.0
const RUD_TIME = 1.0

const IDLE = 0
const LIFTOFF = 1
var state = IDLE

# player number
var number = 0

# roll, pitch, yaw of the center engines in rads
export var commanded_thrust_vector = Vector3()
# delayed thrust vector
var true_thrust_vector = Vector3()


# rate of gimbal in rads/second
var GIMBAL_RATE = library.toRad(45)
const TORQUE_DEADBAND = 0.005
const PITCH_TORQUE = 20000
const ROLL_TORQUE = 1000

# engine thrust 01
export var commanded_throttle = 0.0
var prevEngineState = library.ENGINE_JOYSTICK_INIT


# RUD

var grids = Array()
var grid_names = [
    'grid0',   # bottom right
    'grid1',   # top left
    'grid2',   # top right
    'grid3',   # bottom left
]



# get the highest state of any grid
func gridState():
    var highest = library.GRID_RETRACTED
    for i in range(0, grids.size()):
        if grids[i].state > highest:
            highest = grids[i].state
    return highest

func toggleGrids():
    var state = gridState()
    if state == library.GRID_RETRACTED:
        grid_deploy_sound.play()
        for i in range(0, grids.size()):
            grids[i].deploy()
    elif state == library.GRID_EXTENDED:
        grid_retract_sound.play()
        for i in range(0, grids.size()):
            grids[i].retract()




func _ready():
    #print("single_stage.ready");

    sound.initFlames(self)

    # test vehicle domane rotations
    #rigid.rotate_z(PI / 2)

    var rigid_cg = find_node('rigid_cg')

    # create the engines
    var raptor_scene = load("res://scenes/raptor.tscn")

    for i in range(0, booster_engines):
        var engine = raptor_scene.instance()
        booster_raptors.append(engine)
        rigid_cg.add_child(engine)
        engine.seaNozzle.visible = true
        engine.vacuumNozzle.visible = false

    smoke = find_node("smoke")
    defaultSmokeTransform = smoke.transform
    defaultSmokeScale = smoke.transform.basis


    library.tabulate_nodes(self, grids, grid_names)
    grid_deploy_sound = grids[0].find_node('grid_deploy')
    grid_retract_sound = grids[0].find_node('grid_retract')

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
    
#    print("joy_guid=%s" % Input.get_joy_guid(0)) 


    # show the flames
    #var counter = 0
    #for engine in booster_raptors:
        #var flame = engine.flame
        #var euler = flame.transform.basis.get_euler()
        #print("flame %d: %f, %f, %f" % [counter, euler.x, euler.y, euler.z])
        #counter = counter + 1


var debug = 5
func _process(delta):
    handle_rud(delta)
    debug = debug - 1

# animate flames
    var camera = ProjectSettings.get("camera")
    for engine in booster_raptors:
        var flame2 = engine.flame2
        flame2.transform = engine.defaultFlame2Transform
        var scale2 = flame2.transform.basis.get_scale()
        if camera != null:
# make flame look at the camera.  look_at resets the scale
            flame2.look_at(camera.global_transform.origin, Vector3(0, 1, 0))
            var oscillation = 0.75 + randf() * 0.2
            flame2.transform.basis = flame2.transform.basis.scaled( \
                Vector3(scale2.x, scale2.y, scale2.z * oscillation))


#        print("single_stage.process scale=%f %f %f" % \
#            [scale2.x, scale2.y, scale2.z])

        var flame = engine.seaFlame
        flame.transform = engine.defaultFlameTransform
        var scale = flame.transform.basis.get_scale()
        if camera != null:
            var euler = flame.transform.basis.get_euler()
# make flame look at the camera.  look_at resets the scale
            flame.look_at(camera.global_transform.origin, Vector3(0, 1, 0))
# scale it again
            var oscillation = 0.75 + randf() * 0.2
            flame.transform.basis = flame.transform.basis.scaled( \
                Vector3(scale.x, scale.y, scale.z * oscillation))


# reset the x & z rotations
            var euler2 = flame.transform.basis.get_euler()
            flame.set_rotation(Vector3(euler.x, euler2.y, euler.z))
# scale it back
#        flame.transform.basis = flame.transform.basis.scaled(scale)
#            Vector3(scale.x * 1, scale.y * 0.75 + randf() * 0.2, scale.z * 1)


# make smoke look at the camera.  loot_at resets the scale
    smoke.transform = defaultSmokeTransform
    var euler = smoke.transform.basis.get_euler()
    smoke.look_at(camera.global_transform.origin, Vector3(0, 1, 0))
    var euler2 = smoke.transform.basis.get_euler()
    smoke.set_rotation(Vector3(euler.x, euler2.y, euler.z))
    var scale = defaultSmokeTransform.basis.get_scale()
#    print("single_stage.process %f %f %f" % [scale.x, scale.y, scale.z])
    smoke.transform.basis = smoke.transform.basis.scaled(scale)



# handle throttle
#    for i in range(24, 31):
    for i in range(0, 31):
        booster_raptors[i].setThrottle(commanded_throttle)

# gimbal the true thrust vector at its maximum rate
    var step = GIMBAL_RATE * delta
    true_thrust_vector.x = library.doGimbal(commanded_thrust_vector.x, true_thrust_vector.x, step)
    true_thrust_vector.y = library.doGimbal(commanded_thrust_vector.y, true_thrust_vector.y, step)
    true_thrust_vector.z = library.doGimbal(commanded_thrust_vector.z, true_thrust_vector.z, step)

    
    # move center engines
    #for i in range(24, 31):
    # looks brutal if they don't all pivot
    for i in range(0, 31):
        # reset the engine transformation
        if booster_raptors[i] == null:
            print("single_stage.process booster_raptors[i]=%s" % [str(booster_raptors[i])])
        booster_raptors[i].transform = booster_raptors[i].defaultTransform
        # apply pitch & yaw to X & Z axes
        var thrust_vector2 = Vector3(true_thrust_vector.y, 0, true_thrust_vector.z)
        
        # don't roll the center engine
        # roll direction is tangent of engine angle
        if i < 30:
            var angle2 = booster_raptors[i].angle + PI / 2
            thrust_vector2.x += true_thrust_vector.x * sin(angle2)
            thrust_vector2.z += true_thrust_vector.x * cos(angle2)

# don't gimbal if outer engines are on
        if(booster_raptors[0].currentThrottle > 0.1):
            thrust_vector2.x *= 0.5
            thrust_vector2.z *= 0.5
        booster_raptors[i].rotate_x(thrust_vector2.x)
        booster_raptors[i].rotate_z(thrust_vector2.z)

# handle engine sound based on 1 engine
    var refRaptor = booster_raptors[24]
# get out of joystick init
    if refRaptor.state != library.ENGINE_JOYSTICK_INIT && \
        prevEngineState == library.ENGINE_JOYSTICK_INIT:
        prevEngineState = refRaptor.state
        if refRaptor.state != library.ENGINE_OFF:
            sound.startFlames()
    elif refRaptor.state != library.ENGINE_OFF && \
        prevEngineState == library.ENGINE_OFF:
        sound.startFlames()
        prevEngineState = refRaptor.state
    elif refRaptor.state == library.ENGINE_OFF && \
        prevEngineState != library.ENGINE_OFF && \
        prevEngineState != library.ENGINE_JOYSTICK_INIT:
        prevEngineState = refRaptor.state
        sound.handleCutoff()
    elif refRaptor.state != library.ENGINE_OFF:
        sound.handleFlames(delta, 
            refRaptor.commandedThrottle, 
            refRaptor.currentThrottle)
    #print("single_stage.process %f" % (refRaptor.currentThrottle))




# vector the grid fins
    grids[0].commanded_angle = 0
    grids[1].commanded_angle = 0
    grids[2].commanded_angle = 0
    grids[3].commanded_angle = 0
    if abs(commanded_thrust_vector.y) > TORQUE_DEADBAND:
# pitch
        grids[0].commanded_angle -= library.toRad(4 * 45.0 * commanded_thrust_vector.y)
        grids[1].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.y)
        grids[2].commanded_angle -= library.toRad(4 * 45.0 * commanded_thrust_vector.y)
        grids[3].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.y)

    if abs(commanded_thrust_vector.z) > TORQUE_DEADBAND:
# yaw
        grids[0].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.z)
        grids[1].commanded_angle -= library.toRad(4 * 45.0 * commanded_thrust_vector.z)
        grids[2].commanded_angle -= library.toRad(4 * 45.0 * commanded_thrust_vector.z)
        grids[3].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.z)

    if abs(commanded_thrust_vector.x) > TORQUE_DEADBAND:
# roll
        grids[0].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.x)
        grids[1].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.x)
        grids[2].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.x)
        grids[3].commanded_angle += library.toRad(4 * 45.0 * commanded_thrust_vector.x)







func _physics_process(delta):
    var refRaptor = booster_raptors[24]

# rigid body motion
    match state:
        LIFTOFF:
#            var rotationMatrix = rigid.transform.basis.orthonormalized()
#            var thrustVector = rotationMatrix * Vector3(0.0, 0.4, 0.0)
#            rigid.apply_impulse(Vector3(0.0, 0.0, 0.0), thrustVector)
#            print("single_stage.process LIFTOFF")
            pass


# dampen motion
# get rotation rate in world domane
    var rotationRate = rigid.get_angular_velocity()

    if number == 0:
        print("single_stage._physics_process %s" % [str(rotationRate)])
    rigid.set_angular_velocity(rotationRate * 0)

# apply reversed rotation rate in world domane
#    var rotationDamping = -1000 * rotationRate
#    rigid.apply_torque_impulse(delta * rotationDamping)

# handle thrust
    var rotationMatrix = rigid.transform.basis.orthonormalized()
    if refRaptor.currentThrottle > library.MIN_THROTTLE:
# get the current speed in vehicle frame
        #print("single_stage.process %s" % \
        #    str(Globals.player.rigid.linear_velocity))
# thrust vector in world frame
        var thrustVector = rotationMatrix * library.calculate_thrust( \
            Globals.player.rigid.linear_velocity.length(), \
            Globals.BFR_PARAMS[Globals.current_iteration])
        rigid.apply_impulse(Vector3(0.0, 0.0, 0.0), 
            thrustVector)
        #print("single_stage.process refRaptor.currentThrottle=%f thrustVector=%f,%f,%f" % \
        #    [refRaptor.currentThrottle,
        #    thrustVector.x, 
        #    thrustVector.y, 
        #    thrustVector.z])


# handle steering.  Important to set damping in the rigidbody fields.
#    print('%f, %f, %f' % [rigid.transform.origin.x,
#        rigid.transform.origin.y,
#        rigid.transform.origin.z])
    if rigid.transform.origin.y > 60:
# pitch
        if abs(commanded_thrust_vector.y) > TORQUE_DEADBAND:
            rigid.apply_torque_impulse(
                rotationMatrix * Vector3(-commanded_thrust_vector.y * delta * PITCH_TORQUE, 0, 0))

# yaw
        if abs(commanded_thrust_vector.z) > TORQUE_DEADBAND:
            rigid.apply_torque_impulse(
                rotationMatrix * Vector3(0, 0, -commanded_thrust_vector.z * delta * PITCH_TORQUE))

# roll
        if abs(commanded_thrust_vector.x) > TORQUE_DEADBAND:
            rigid.apply_torque_impulse(
                rotationMatrix * Vector3(0, -commanded_thrust_vector.x * delta * ROLL_TORQUE, 0))






func liftoff():
# enable physics
    rigid.sleeping = false
    for engine in booster_raptors:
        engine.flame2.show()
        engine.seaFlame.show()
    smoke.emitting = true
    state = LIFTOFF
    commanded_throttle = 1.0




# rapid unscheduled disassembly
func rud():
    print('single_stage.rud')
    if rud_state == RUD_NONE:
        rud_state = RUD_RUDDING
        rud_time = 0.0



func handle_rud(delta):
    if rud_state == RUD_RUDDING:
        rud_time += delta
        if rud_time < RUD_TIME: 
            for i in range(0, bfs.TOTAL_WINDOWS):
                bfs.windows[i].translate(Vector3(1.0 * rud_time / RUD_TIME, 0.0, 0.0))
        else:
            rud_state = RUD_NONE
        
    








