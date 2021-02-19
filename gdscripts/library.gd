# navigate instead of play
const TEST_MODE = true

# rate of throttle change per second
export var THROTTLE_RATE = 0.75
# rate of keyboard input deflection in rads/second
var KEYBOARD_RATE = toRad(45)

# shutdown with hysterisis
export var CUTOFF_THROTTLE1 = 0.25
export var CUTOFF_THROTTLE2 = 0.15
# min to produce thrust
export var MIN_THROTTLE = 0.5
# maximum engine deflection in rads
var MAX_VECTOR = toRad(10)
# maximum engine roll in rads
var MAX_ROLL = toRad(5)

# engine states
const ENGINE_JOYSTICK_INIT = -1
const ENGINE_OFF = 0
const ENGINE_STARTING1 = 1
const ENGINE_STARTING2 = 2
const ENGINE_RUNNING = 3
const ENGINE_SHUTDOWN1 = 4
const ENGINE_SHUTDOWN2 = 5


# grid states
const GRID_RETRACTED = 0
const GRID_EXTENDING = 1
const GRID_EXTENDED = 2
const GRID_RETRACTING = 3


var GRID_LIMIT = toRad(45.0)


const USE_KEYBOARD = true
var test_time = 0
var test_time2 = 0
var got_change = false
var shift_down = false
var ctrl_down = false
var key_pressed = false
var mouse_current_position
# button press position on the screen
var mouse_start_position
var cam_start_transform = Transform()
var cam_start_rotation = Vector3(0.0, 0.0, 0.0)
var cam_offset_rotation = Vector3(0.0, 0.0, 0.0)
var cam_offset_position = Vector3(0.0, 0.0, 0.0)
var cam_rotation = Vector3(0.0, 0.0, 0.0)
# following the player
var player_cam

var KEYBOARD_TO_XYZ = 100
var KEYBOARD_TO_XYZ2 = 1
var KEYBOARD_TO_RADS = toRad(90)

# absolute times to change cameras during the startup sequence
var camera_times = [ 0.0, 3.0, 5.0, 7.0, 9.0 ]


func fromRad(angle):
    return angle * 360 / PI / 2.0

func toRad(angle):
    return angle * PI * 2.0 / 360.0

func hypot3(a, b):
    var dist1 = a.x - b.x
    var dist2 = a.y - b.y
    var dist3 = a.z - b.z
    return sqrt(dist1 * dist1 + \
         dist2 * dist2 + \
         dist3 * dist3)

# xzy correspond to xyz from blender
func polarToXYZ(angle, radius, y):
    var x = radius * cos(angle)
    var z = -radius * sin(angle)
    return Vector3(x, y, z)

func polarToXYZ2(angle, radius, y, center):
    var x = radius * cos(angle) + center.x
    var z = -radius * sin(angle) + center.z
    return Vector3(x, y, z)

# returns a vector with angle, max, y
func XYZToPolar(xyz, center):
    var dx = xyz.x - center.x
    var dz = xyz.z - center.z
    var angle = -atan2(dz, dx)
    var mag = sqrt(dx * dx + dz * dz)
    return Vector3(angle, mag, xyz.y)

func clamp(angle, min_, max_):
    if angle < min_:
        return min_
    if angle > max_:
        return max_
    return angle


func doGimbal(target, current, step):
    if current < target:
        current += step
        if current > target:
            current = target
    elif current > target:
        current -= step
        if current < target:
            current = target
    return current



func findNodeRecursive(parent, name):
#    print("findNodeRecursive 1 parent=%s name=%s" % [parent.get_name(), name])
    if parent.get_name() == name:
        return parent
    for n in parent.get_children():
        var n2 = findNodeRecursive(n, name)
        if n2 != null:
            return n2
    return null


func setMaterialRecursive(object, material):
    for n in object.get_children():
        setMaterialRecursive(n, material)
#    print("setMaterialRecursive name=%s type=%s" % [object.get_name(), object.get_class()])
    if object is MeshInstance:
        if object.get_name() == 'left':
            print("setMaterialRecursive name=%s" % [object.get_name()])
        object.set_surface_material(0, material)

func setMaterial(parent, targetName, materialName):
    var target = findNodeRecursive(parent, targetName)
    var material = load(materialName)
    setMaterialRecursive(target, material)
    #print("target=%s material=%s" % [target, material])
    #if target != None:
    #target.set_surface_material(0, material)

func setMaterials(parent, map):
    for i in range(0, map.size() / 2):
        var object = map[i * 2]
        var material = map[i * 2 + 1]
        setMaterial(parent, object, material)
    
    


func tabulate_nodes(parent, array, names):
    for i in range(0, names.size()):
        var node = parent.find_node(names[i])
        array.append(node)



# used during test mode
func apply_cam_offset():
    player_cam.transform = cam_start_transform
    # translate the global position
    var xyz = player_cam.global_transform.origin
    xyz.y += cam_offset_position.y
    xyz.x += cam_offset_position.x * sin(cam_rotation.y + PI / 2) + \
        cam_offset_position.z * sin(cam_rotation.y)
    xyz.z += cam_offset_position.x * cos(cam_rotation.y + PI / 2) + \
        cam_offset_position.z * cos(cam_rotation.y)
    player_cam.global_transform.origin = xyz
    
    # rotate the global rotation by looking at a point on a sphere
    var test_look_at = player_cam.global_transform.origin
    var r = cos(cam_rotation.x)
    test_look_at.x -= r * sin(cam_rotation.y)
    test_look_at.z -= r * cos(cam_rotation.y)
    test_look_at.y += sin(cam_rotation.x)
    player_cam.look_at(test_look_at, Vector3(0, 1, 0))
    
    


func bake_cam_offset():
    cam_start_transform = player_cam.transform
    mouse_start_position = mouse_current_position
    cam_start_rotation = cam_rotation
    cam_offset_position = Vector3(0.0, 0.0, 0.0)
    cam_offset_rotation = Vector3(0.0, 0.0, 0.0)

    
func do_test_mode(scene, delta):
    if Input.is_action_pressed("ui_cancel"):
        scene.get_tree().quit()

    if !is_instance_valid(player_cam):
        pass

    test_time += delta
    if Input.is_action_pressed("ui_up") || \
        Input.is_action_pressed("ui_down") || \
        Input.is_action_pressed("ui_left") || \
        Input.is_action_pressed("ui_right") || \
        Input.is_action_pressed("ui_page_up") || \
        Input.is_action_pressed("ui_page_down"):
        if !key_pressed:
            key_pressed = true
            bake_cam_offset()
    else:
        if key_pressed:
            key_pressed = false
            bake_cam_offset()

    if Input.is_action_pressed("ui_shift"):
        if !shift_down:
            shift_down = true
            bake_cam_offset()
    else:
        shift_down = false
        bake_cam_offset()


    if Input.is_action_pressed("ui_alt"):
        if !ctrl_down:
            ctrl_down = true
            bake_cam_offset()
    else:
        ctrl_down = false
        bake_cam_offset()

# fine or coarse velocity with the ctrl key
    var velocity = KEYBOARD_TO_XYZ
    if ctrl_down:
        velocity = KEYBOARD_TO_XYZ2

# translation
    if shift_down || ctrl_down:
        if Input.is_action_pressed("ui_up"):
            cam_offset_position.y += delta * velocity
            got_change = true
        if Input.is_action_pressed("ui_down"):
            cam_offset_position.y -= delta * velocity
            got_change = true
        if Input.is_action_pressed("ui_left"):
            cam_offset_position.x -= delta * velocity
            got_change = true
        if Input.is_action_pressed("ui_right"):
            cam_offset_position.x += delta * velocity
            got_change = true
    else:
# rotation
        if Input.is_action_pressed("ui_up"):
            cam_rotation.x += delta * KEYBOARD_TO_RADS
            got_change = true
        if Input.is_action_pressed("ui_down"):
            cam_rotation.x -= delta * KEYBOARD_TO_RADS
            got_change = true
        if Input.is_action_pressed("ui_left"):
            cam_rotation.y += delta * KEYBOARD_TO_RADS
            got_change = true
        if Input.is_action_pressed("ui_right"):
            cam_rotation.y -= delta * KEYBOARD_TO_RADS
            got_change = true

# altitude
    if Input.is_action_pressed("ui_page_up"):
        cam_offset_position.z -= delta * velocity
        got_change = true
    if Input.is_action_pressed("ui_page_down"):
        cam_offset_position.z += delta * velocity
        got_change = true


    if got_change:
        apply_cam_offset()

    if test_time - test_time2 > 1:
        test_time2 = test_time
#        print("do_test_mode test_time=%f" % [test_time])
        
        if got_change:
            got_change = false
            var xyz = player_cam.global_transform.origin
            var quat = Quat(player_cam.global_transform.basis)
            print("do_test_mode position=%f, %f, %f quat=%f, %f, %f, %f" % \
                [xyz.x, xyz.y, xyz.z, quat.x, quat.y, quat.z, quat.w ])




func general_keys():
    pass


# pixels are doubled on the mac
var is_screenshot = false
func screenshot(scene):
    if(!is_screenshot):
        is_screenshot = true

        # get screen capture
        var capture = scene.get_viewport().get_texture().get_data()
        # save to a file
        capture.save_png("user://screenshot.png")


# replacement for get_tree().change_scene
func goto_scene(scene, path):
    var s = ResourceLoader.load(path)
    var new_scene = s.instance()
    scene.get_tree().get_root().add_child(new_scene)
    scene.get_tree().set_current_scene(new_scene)
    #current_scene.queue_free()
    #current_scene = new_scene
    scene.queue_free()



# convert the physics speed to the displayed speed in km/h
# altitude = km
# linear_velocity = lowpassed km/h from the rigid body
func calculate_speed(linear_velocity, altitude, params):
    var max_displayed = params[0]
    var max_physics = params[1]
    var current_max_displayed = max_physics + \
        (max_displayed - max_physics) * \
        altitude / \
        Globals.TOP_PHYSICS_ALTITUDE
    if current_max_displayed > max_displayed:
        current_max_displayed = max_displayed
    var fraction = linear_velocity / \
        max_physics
    #print("library.calculate_speed current_max_displayed=%f fraction=%f" % \
    #    [current_max_displayed, fraction])
    var displayed = current_max_displayed * fraction
    return displayed


# translate physics altitude to displayed altitude in km
# altitude = km
func calculate_altitude(altitude):
    return altitude * \
        Globals.DIAL_ALTITUDE \
        / Globals.TOP_PHYSICS_ALTITUDE



# calculate thrust based on current speed & params
# speed is limited to the parameters of the iteration
# linear_velocity = instantaneous vector length
func calculate_thrust(linear_velocity, params):
# get km/h
        var currentSpeed = linear_velocity * 3600 / 1000
        var max_physics = params[1]
        #print("library.calculate_thrust currentSpeed=%f" % currentSpeed)
# pulse the thrust if over the maximum
        if currentSpeed > max_physics:
            return Vector3(0.0, 0.0, 0.0)
        elif currentSpeed < 100:
            return Vector3(0.0, (100.0 - currentSpeed) * 4.0 / 100, 0.0)
        else:
            return Vector3(0.0, 0.3, 0.0)







