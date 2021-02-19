extends Node

var library = preload("library.gd").new()

var prev_trigger = false
var launchpad
var starting_cam0
var starting_cam1
var starting_cam2
var starting_cam3
var count = []
var blanker
var overlay

const STATE_TEST = 0
const STATE_INIT1 = 1
const STATE_INIT2 = 2
const STATE_COUNTDOWN = 3
const STATE_COUNTDOWN1 = 4
const STATE_COUNTDOWN2 = 5
const STATE_COUNTDOWN3 = 6
const STATE_LIFTOFF0 = 7
const STATE_LIFTOFF1 = 8
const STATE_LIFTOFF2 = 9
const STATE_PLAYBACK = 10

var state = STATE_INIT2
var starting_time = 0

var engine_cam
# camera being controlled in test mode
var current_cam

# camera following the player
var test_time = 0
var test_time2 = 0
var got_change = false


# positions
var mouse_current_position
# button press position on the screen
var mouse_start_position
var cam_start_transform
var cam_start_rotation = Vector3(0.0, 0.0, 0.0)
var cam_offset_rotation = Vector3(0.0, 0.0, 0.0)
var cam_rotation = Vector3(0.0, 0.0, 0.0)
var cam_offset_position = Vector3(0.0, 0.0, 0.0)
var cam_distance = Vector3(0, -200, 50)

# buttons
var mouse_button = false
var shift_down = false
var ctrl_down = false
var key_pressed = false

var MOUSE_TO_RADS = library.toRad(45) / 200
var MOUSE_TO_XY = 1.0 / 20
var MOUSE_TO_Z = 1.0 / 20
# test mode velocities
var KEYBOARD_TO_XYZ = 100
var KEYBOARD_TO_XYZ2 = 1
var KEYBOARD_TO_RADS = library.toRad(90)

var players = Array()
var player_names = [
    "bfr",
    "bfr2",
    "bfr3",
    "bfr4",
    "bfr5",
    "bfr6",
    "bfr7",
    "bfr8",
]

var launchpads = Array()
var launchpad_names = [
    "launchpad",
    "launchpad2",
    "launchpad3",
    "launchpad4",
    "launchpad5",
    "launchpad6",
    "launchpad7",
    "launchpad8",
]

var player_cam_position = Vector3(-18.302166, 106.792023, 116.125572)
var player_cam_quat = Quat(-0.126943, -0.048440, -0.006207, 0.990707)
var player_cam_quat1
var player_cam_position1

# interpolation positions for the starting cams
var camera_positions = [
# start
    Vector3(144.594910, 106.792023, -71.566864),
    Vector3(144.594910, 106.792023, -71.566864),
#    Vector3(-141.139526, 75.179024, -103.472992),
#    Vector3(-136.663818, 75.179024, -98.978104),

# 3
    Vector3(-273.107666, 116.130394, -427.929657),
    Vector3(-273.107666, 116.130394, -427.929657),
#    Vector3(-899.228394, 64.485626, -1047.237305),
#    Vector3(-900.933777, 64.485626, -1046.512085),

# 2
    Vector3(-497.324768, 77.330460, -773.149170),
    Vector3(-497.324768, 77.330460, -773.149170), 
#    Vector3(-1356.199829, 227.085648, 590.068298),
#    Vector3(-1356.199829, 227.085648, 590.068298),

# 1
    Vector3(-752.561157, -1.119545, -1096.885620), 
    Vector3(-753.881348, -1.119545, -1100.054077), 
#    Vector3(-144.823227, 117.835617, 86.016701),
#    Vector3(-144.526749, 117.835617, 86.795509)
]

var camera_quats = [
    Quat(-0.109848, 0.493807, 0.063052, 0.860298),
    Quat(-0.109848, 0.493807, 0.063052, 0.860298),
#    Quat(-0.069653, -0.382571, -0.028938, 0.920842),
#    Quat(-0.069653, -0.382571, -0.028938, 0.920842),

# 3
    Quat(-0.095328, -0.461029, -0.049894, 0.880838),
    Quat(-0.095328, -0.461029, -0.049894, 0.880838),
#    Quat(0.025486, 0.971845, 0.125053, -0.198065),
#    Quat(0.025486, 0.971845, 0.125053, -0.198065),

# 2
    Quat(-0.023210, 0.608658, 0.017817, 0.792893),
    Quat(-0.023210, 0.608658, 0.017817, 0.792893),
#    Quat(-0.220921, -0.280185, -0.066428, 0.931814),
#    Quat(-0.201215, -0.475987, -0.112856, 0.848653),

# 1
#    Quat(-0.157762, -0.465868, -0.084816, 0.866536),
#    Quat(-0.157762, -0.465868, -0.084816, 0.866536),
    Quat(0.384351, 0.179652, -0.076526, 0.902299),
    Quat(0.384351, 0.179652, -0.076526, 0.902299),
]

var camera_counter = 1
var liftoff_time1 = library.camera_times[library.camera_times.size() - 1]
var liftoff_time2 = liftoff_time1 + 3
var liftoff_time3 = liftoff_time2 + 5;

func _ready():
    print("mane._ready")
    
    var number = 0
    for i in player_names:
        var node = find_node(i).get_children()[0]
        node.number = number
        players.append(node)
        number += 1

    for i in launchpad_names:
        launchpads.append(find_node(i))
    
    for i in range(0, players.size()):
        players[i].show()
        launchpads[i].show()
# disable physics while stationary.  Has to be disabled at object creation
        players[i].rigid.sleeping = true
    
    Globals.arrow = find_node('arrow')
    overlay = find_node('overlay')
    overlay.hide()
    Globals.player = find_node('bfr').get_children()[0]
    launchpad = find_node('launchpad')
    starting_cam0 = find_node('starting_cam0')
    starting_cam1 = find_node('starting_cam1')
    starting_cam2 = find_node('starting_cam2')
    starting_cam3 = find_node('starting_cam3')
    count.append(find_node('1'))
    count.append(find_node('2'))
    count.append(find_node('3'))
    count[0].hide()
    count[1].hide()
    count[2].hide()
    blanker = find_node('blanker')
    library.player_cam = find_node('playerCam')
    engine_cam = find_node('engine_cam')

# set the camera particles should look_at
    ProjectSettings.set("camera", library.player_cam)

#    blanker.show()

# prerender this slow view
    starting_cam0.global_transform.origin = camera_positions[4]
    starting_cam0.global_transform.basis = Basis(camera_quats[4])

    #print("mane cam_rotation=%f %f %f" % [cam_rotation.x, cam_rotation.y, cam_rotation.z])

    if !library.TEST_MODE:
# initialize game stuff
        starting_cam0.make_current()
        library.player_cam.global_transform.origin = player_cam_position
        library.player_cam.global_transform.basis = Basis(player_cam_quat)
    else:
# initialize test stuff
        current_cam = library.player_cam
#        current_cam = engine_cam
        current_cam.make_current()

        library.player_cam.global_transform.origin = player_cam_position
        library.player_cam.global_transform.basis = Basis(player_cam_quat)

        #player_cam.global_transform.origin = camera_positions[0]
        #player_cam.global_transform.basis = Basis(camera_quats[0])
        #player.liftoff()
        state = STATE_TEST
        cam_start_transform = current_cam.transform
        cam_rotation = current_cam.transform.basis.get_euler()
        #find_node('launchpad').hide()

        #player.rotate_y(library.toRad(-135))





func _process(delta):
    handle_input(delta)

    update_time(delta)


    match state:
        STATE_TEST:     
            pass

# some kind of extra splash screen
#        STATE_INIT1:
#            starting_time += delta
#            if(starting_time >= 3):
#                starting_cam0.global_transform.origin = camera_positions[0]
#                starting_cam0.global_transform.basis = Basis(camera_quats[0])
#                blanker.hide()
#                state = STATE_INIT2
#                starting_time = 0


        STATE_INIT2:
            starting_time += delta
            var fraction = (starting_time - library.camera_times[camera_counter - 1]) / \
                (library.camera_times[camera_counter] - library.camera_times[camera_counter - 1])
            var index = (camera_counter - 1) * 2
            starting_cam0.global_transform.origin = \
                camera_positions[index].linear_interpolate(camera_positions[index + 1], fraction)
            starting_cam0.global_transform.basis = \
                Basis(camera_quats[index].slerp(camera_quats[index + 1], fraction))

 
            if starting_time >= library.camera_times[camera_counter]:
                print("mane._process camera_counter=%d" % [camera_counter])
# show the right number
                if camera_counter > 1:
                    count[camera_counter - 2].hide()
                if camera_counter < 4:
                    count[camera_counter - 1].show()

                camera_counter += 1
                if(camera_counter >= library.camera_times.size()):
                    state = STATE_LIFTOFF0


        STATE_LIFTOFF0:
            state = STATE_LIFTOFF1

            overlay.show()

# launch the computer players
#                    for p in players:
#                        p.liftoff()
#                    for l in launchpads:
#                        l.liftoff()

# just launch the human player for testing
            Globals.player.liftoff()
# cue the smoke
            launchpad.liftoff()


# change camera
            library.player_cam.make_current()
            library.player_cam.look_at(Globals.player.rigid.global_transform.origin + 
                    Vector3(0, -25, 0), 
                Vector3(0, 1, 0))
# get the starting position
            player_cam_quat1 = Quat(library.player_cam.global_transform.basis)
            player_cam_position1 = library.player_cam.global_transform.origin
        
        
        STATE_LIFTOFF1:
            starting_time += delta


# cue more smoke
            if Globals.player.rigid.global_transform.origin.y > 65:
                launchpad.smoke2.find_node('particles').emitting = true
            
            if starting_time > liftoff_time2:
                state = STATE_LIFTOFF2



        STATE_LIFTOFF2:
            starting_time += delta
# interpolate the camera
            #print("mane.process y=%f" % [Globals.player.rigid.global_transform.origin.y])

# future position following the player
            follow_player()

# interpolate between starting & future
            var player_cam_position2 = library.player_cam.global_transform.origin
            var player_cam_quat2 = Quat(library.player_cam.global_transform.basis)
            var fraction = (starting_time - liftoff_time2) / \
                (liftoff_time3 - liftoff_time2)
#            library.player_cam.global_transform.origin = player_cam_position1
#            library.player_cam.global_transform.basis = Basis(player_cam_quat1)

            library.player_cam.global_transform.origin = player_cam_position1.linear_interpolate( \
                player_cam_position2, \
                fraction)
            library.player_cam.global_transform.basis = Basis(player_cam_quat1.slerp( \
                player_cam_quat2, fraction))


            if starting_time > liftoff_time3:
                state = STATE_PLAYBACK




        STATE_PLAYBACK:
# move the camera
            follow_player()
            #pass




func update_time(delta):
    Globals.absolute_time += delta
    #print("mane.update_time %f" % [Globals.absolute_time])
    overlay.update()





func handle_input(delta):
# joystick input
    if !library.USE_KEYBOARD:
        var joy_x = Input.get_joy_axis(0, JOY_ANALOG_LX)
        var joy_y = Input.get_joy_axis(0, JOY_ANALOG_LY)
        var joy_throttle = Input.get_joy_axis(0, JOY_AXIS_6)
        var joy_rocker = Input.get_joy_axis(0, JOY_AXIS_7)
        var joy_rudder = Input.get_joy_axis(0, JOY_AXIS_8)
        var joy_l2 = Input.is_joy_button_pressed(0, JOY_L2)
        var joy_r2 = Input.is_joy_button_pressed(0, JOY_R2)
        # share
        var joy_l3 = Input.is_joy_button_pressed(0, JOY_L3)
        # options
        var joy_r3 = Input.is_joy_button_pressed(0, JOY_R3)
        # marked L3 on joystick
        var joy_select = Input.is_joy_button_pressed(0, JOY_SELECT)
        # nothing
        var joy_start = Input.is_joy_button_pressed(0, JOY_START)
        # marked X on throttle
        var joy_circle = Input.is_joy_button_pressed(0, JOY_SONY_CIRCLE)
        # marked square on throttle
        var joy_x_button = Input.is_joy_button_pressed(0, JOY_SONY_X)
        # marked circle on throttle
        var joy_square = Input.is_joy_button_pressed(0, JOY_SONY_SQUARE)
        # L1 on joystick
        var joy_l = Input.is_joy_button_pressed(0, JOY_L)
        # trigger on joystick
        var joy_r = Input.is_joy_button_pressed(0, JOY_R)

# deploy grid fins
        if joy_r && !prev_trigger:
            prev_trigger = joy_r
            Globals.player.toggleGrids()
        elif !joy_r && prev_trigger:
            prev_trigger = joy_r


# change camera
#        if joy_l2:
#            starting_cam0.make_current()
#        elif joy_r2:
#            engine_cam.make_current()
#        elif joy_square:
#            library.player_cam.make_current()

# combine the rocker & rudder
        if abs(joy_rocker) > abs(joy_rudder):
            joy_rudder = joy_rocker

        Globals.player.commanded_throttle = joy_throttle
        Globals.player.commanded_thrust_vector.x = -joy_x * library.MAX_VECTOR
        Globals.player.commanded_thrust_vector.y = -joy_y * library.MAX_VECTOR
        Globals.player.commanded_thrust_vector.z = joy_rudder * library.MAX_VECTOR

#        print("joy=%f, %f, %f, %f, %f" % [joy_x, joy_y, joy_throttle, joy_rocker, joy_rudder])


# input optionally taken from the keyboard
    else:

        var angle_step = library.KEYBOARD_RATE * delta
        var throttle_step = library.THROTTLE_RATE * delta




        if !library.TEST_MODE:
            # thrust vectoring
            if Input.is_action_pressed("ui_up"):
                Globals.player.commanded_thrust_vector.y += angle_step
            if Input.is_action_pressed("ui_down"):
                Globals.player.commanded_thrust_vector.y -= angle_step
            if Input.is_action_pressed("ui_left"):
                Globals.player.commanded_thrust_vector.z += angle_step
            if Input.is_action_pressed("ui_right"):
                Globals.player.commanded_thrust_vector.z -= angle_step
            if Input.is_action_pressed("ui_yaw_left"):
                Globals.player.commanded_thrust_vector.x += angle_step
            if Input.is_action_pressed("ui_yaw_right"):
                Globals.player.commanded_thrust_vector.x -= angle_step

            if Input.is_action_pressed("ui_center"):
                Globals.player.commanded_thrust_vector.x = 0
                Globals.player.commanded_thrust_vector.y = 0
                Globals.player.commanded_thrust_vector.z = 0

        if Input.is_action_pressed("ui_throttle_up"):
            Globals.player.commanded_throttle += throttle_step
        if Input.is_action_pressed("ui_throttle_down"):
            Globals.player.commanded_throttle -= throttle_step

        Globals.player.commanded_throttle = clamp(Globals.player.commanded_throttle, 0, 1)

        # roll
        Globals.player.commanded_thrust_vector.x = clamp(Globals.player.commanded_thrust_vector.x, -library.MAX_ROLL, library.MAX_ROLL)
        # pitch
        Globals.player.commanded_thrust_vector.y = clamp(Globals.player.commanded_thrust_vector.y, -library.MAX_VECTOR, library.MAX_VECTOR)
        # yaw
        Globals.player.commanded_thrust_vector.z = clamp(Globals.player.commanded_thrust_vector.z, -library.MAX_VECTOR, library.MAX_VECTOR)


# input always taken from the keyboard
    if Input.is_action_pressed("ui_cancel"):
        get_tree().quit()
#    if Input.is_action_pressed("ui_select"):
#        Globals.player.rud()
    if Input.is_action_pressed("ui_select"):
        library.screenshot(self)
 

# test mode
    if library.TEST_MODE:
        do_test_mode(delta)



# move the camera to the player
func follow_player():
    library.player_cam.translation = \
        Globals.player.rigid.global_transform.origin + \
        cam_distance
    library.player_cam.look_at(Globals.player.rigid.global_transform.origin + Vector3(0, -25, 0), \
        Vector3(0, 1, 0))

# move the test arrow to the camera
    var rotationMatrix = library.player_cam.transform.basis.orthonormalized()
    Globals.arrow.translation = library.player_cam.translation + \
        rotationMatrix * Vector3(40.0, -20.0, -50.0)




# used during test mode
func apply_cam_offset():
    current_cam.transform = cam_start_transform
    # translate the global position
    var xyz = current_cam.global_transform.origin
    xyz.y += cam_offset_position.y
    xyz.x += cam_offset_position.x * sin(cam_rotation.y + PI / 2) + \
        cam_offset_position.z * sin(cam_rotation.y)
    xyz.z += cam_offset_position.x * cos(cam_rotation.y + PI / 2) + \
        cam_offset_position.z * cos(cam_rotation.y)
    current_cam.global_transform.origin = xyz
    
    # rotate the global rotation by looking at a point on a sphere
    var test_look_at = current_cam.global_transform.origin
    var r = cos(cam_rotation.x)
    test_look_at.x -= r * sin(cam_rotation.y)
    test_look_at.z -= r * cos(cam_rotation.y)
    test_look_at.y += sin(cam_rotation.x)
    current_cam.look_at(test_look_at, Vector3(0, 1, 0))
    
    


func bake_cam_offset():
    cam_start_transform = current_cam.transform
    mouse_start_position = mouse_current_position
    cam_start_rotation = cam_rotation
    cam_offset_position = Vector3(0.0, 0.0, 0.0)
    cam_offset_rotation = Vector3(0.0, 0.0, 0.0)




func do_test_mode(delta):
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


# mouse input
    if Input.is_mouse_button_pressed(BUTTON_LEFT):
        mouse_current_position = get_viewport().get_mouse_position()  
        if !mouse_button:
            mouse_button = true
            bake_cam_offset()




# in XY mode
        if Input.is_action_pressed("ui_shift"):
            if !shift_down:
                shift_down = true
                got_change = true

            var x_offset = (mouse_current_position.x - mouse_start_position.x) * MOUSE_TO_XY
            var y_offset = (mouse_current_position.y - mouse_start_position.y) * MOUSE_TO_XY
            cam_offset_position = Vector3(x_offset,
                    y_offset,
                    0)
            got_change = true

        else:
# exited XY mode
            if shift_down:
                shift_down = false
                got_change = true

# in Z mode
            if Input.is_action_pressed("ui_alt"):
                if !ctrl_down:
                    ctrl_down = true
                    got_change = true


                var x_offset = (mouse_current_position.x - mouse_start_position.x) * MOUSE_TO_XY
                var z_offset = -(mouse_current_position.y - mouse_start_position.y) * MOUSE_TO_XY
                cam_offset_position = Vector3(x_offset, 
                        0.0,
                        z_offset)
                got_change = true

            else:
# exited Z mode
                if ctrl_down:
                    ctrl_down = false
                    got_change = true

# in rotate mode
                current_cam.transform = cam_start_transform
                cam_rotation = cam_start_rotation + \
                    Vector3(-(mouse_current_position.y - mouse_start_position.y) * MOUSE_TO_RADS,
                    -(mouse_current_position.x - mouse_start_position.x) * MOUSE_TO_RADS,
                    0.0)
                got_change = true



    else:
        if mouse_button:
            mouse_button = false
            got_change = true


    if got_change:
        apply_cam_offset()

    if test_time - test_time2 > 1:
        test_time2 = test_time
#        print("do_test_mode test_time=%f" % [test_time])
        
        if got_change:
            got_change = false
            var xyz = current_cam.global_transform.origin
            var quat = Quat(current_cam.global_transform.basis)
            print("do_test_mode position=%f, %f, %f quat=%f, %f, %f, %f" % \
                [xyz.x, xyz.y, xyz.z, quat.x, quat.y, quat.z, quat.w ])








