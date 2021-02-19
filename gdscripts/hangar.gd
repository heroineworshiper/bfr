extends Spatial

var library = preload("library.gd").new()
var booster
var ship
var camera_move = 0
var camera_time = 0
var camera_duration = 10
# angle1, y1, angle2, y2
var camera_table = [
    -83, 15, -95, 10,
    85, 10, 105, 8,
    138, 15, 119, 8
]


# material to object mapping
var materials = [
    "crane2", "res://materials/crane.tres",
    "crane", "res://materials/crane.tres",
    "crane track", "res://materials/crane_track.tres",
    "crane track2", "res://materials/crane_track.tres",
    "floor", "res://materials/floor.tres",
    "roof", "res://materials/roof.tres",
    "stand bottom2", "res://materials/stand2.tres",
    "stand bottom3", "res://materials/stand3.tres",
    "stand bottom4", "res://materials/stand4.tres",
    "stand bottom", "res://materials/stand.tres",
    "stand top2", "res://materials/stand2.tres",
    "stand top3", "res://materials/stand3.tres",
    "stand top4", "res://materials/stand4.tres",
    "stand top", "res://materials/stand.tres",
    "vent2", "res://materials/vent.tres",
    "vent3", "res://materials/vent.tres",
    "vent4", "res://materials/vent.tres",
    "vent", "res://materials/vent.tres",
    "walls2", "res://materials/wall2.tres",
    "walls3", "res://materials/wall3.tres",
    "walls", "res://materials/wall.tres",
]



const LOOK_AT_REAR = Vector3(0, 10, -25)
const LOOK_AT_FRONT = Vector3(0, 10, -65)
const CENTER = Vector3(0, 10, -43)


# Called when the node enters the scene tree for the first time.
func _ready():
    print("hangar._ready")
    library.setMaterials(self, materials)

    var material1 = load('res://materials/light_leg.tres')
    var material2 = load('res://materials/light.material')
    for i in range(0, 90):
        var name = 'light_leg_' + str(i)
        var node = find_node(name)
        node.set_surface_material(0, material1)
        name = 'light_' + str(i)
        node = find_node(name)
        node.set_surface_material(0, material2)

    material1 = load('res://materials/vrib.tres')
    for i in range(0, 18):
        var name = 'vrib_' + str(i)
        var node = find_node(name)
        node.set_surface_material(0, material1)

    material1 = load('res://materials/vrib.tres')
    for i in range(0, 36):
        var name = 'crane_rib_' + str(i)
        var node = find_node(name)
        node.set_surface_material(0, material1)

    ship = find_node('ship')
    booster = find_node('booster')
    library.player_cam = find_node('Camera_')

    # attach the cam to the wall
    var xyz1 = library.player_cam.global_transform.origin
    var polar = library.XYZToPolar(
        xyz1, 
        CENTER)
    var xyz2 = get_wall_point(polar.x, xyz1.y)
    library.player_cam.global_transform.origin = xyz2
    library.player_cam.look_at(get_lookat(), Vector3(0, 1, 0))




# turn off physics
    booster.find_node('rigid').sleeping = true
    ship.find_node('rigid').sleeping = true



func get_lookat():
    var coord = library.player_cam.global_transform.origin
    if coord.z > CENTER.z:
        return LOOK_AT_REAR
    else:
        return LOOK_AT_FRONT



var KEYBOARD_TO_XYZ = 10
var KEYBOARD_TO_ANGLE = library.toRad(45)
const MAX_Y = 15
const MIN_Y = 2


const FRONT_Z = 0
const BACK_Z = -84
const LEFT_X = -16
const RIGHT_X = 16
func get_wall_point(angle, y):
    #print("get_wall_point angle=%f y=%f" % [library.fromRad(angle), y])

    var front = Plane(Vector3(0, 0, FRONT_Z), Vector3(10, 0, FRONT_Z), Vector3(0, 10, FRONT_Z))
    var back = Plane(Vector3(0, 0, BACK_Z), Vector3(10, 0, BACK_Z), Vector3(0, 10, BACK_Z))
    var left = Plane(Vector3(LEFT_X, 0, 0), Vector3(LEFT_X, 0, 10), Vector3(LEFT_X, 10, 10))
    var right = Plane(Vector3(RIGHT_X, 0, 0), Vector3(RIGHT_X, 0, 10), Vector3(RIGHT_X, 10, 10))

    var walls = [ front, back, left, right ]
    var closest = Vector3(0, 0, 0)
    var haveClosest = false
    var closestHypot = 0

    var dir = library.polarToXYZ2(angle, 1, CENTER.y, CENTER) - \
        CENTER
    #print("get_wall_point 1 dir=%f,%f,%f walls=%d" % [dir.x, dir.y, dir.z, walls.size()])
    
    for wall in walls:
        var point = wall.intersects_ray(CENTER, Vector3(dir.x, dir.y, dir.z))
        if point != null:
            #print("get_wall_point 3 xyz=%f,%f,%f" % [point.x, point.y, point.z])
            var currentHypot3 = library.hypot3(point, CENTER)
            if currentHypot3 < closestHypot || \
                haveClosest == false:
                closestHypot = currentHypot3
                closest = point
                haveClosest = true


    #print("get_wall_point 2 %f,%f,%f" % [point.x, y, point.z])
    return Vector3(closest.x, y, closest.z)




func handle_input(delta):
    if !library.TEST_MODE:
        if Input.is_action_pressed("ui_cancel"):
            get_tree().quit()

        if Input.is_action_pressed("ui_left"):
            var xyz1 = library.player_cam.global_transform.origin
            var polar = library.XYZToPolar(
                xyz1, 
                CENTER)
            polar.x -= KEYBOARD_TO_ANGLE * delta
            var xyz2 = get_wall_point(polar.x, xyz1.y)
            library.player_cam.global_transform.origin = xyz2
            #print("hangar.handle_input 1 %f,%f,%f" % [xyz2.x, xyz2.y, xyz2.z])
            library.player_cam.look_at(get_lookat(), Vector3(0, 1, 0))

        if Input.is_action_pressed("ui_right"):
            var xyz1 = library.player_cam.global_transform.origin
            var polar = library.XYZToPolar(
                xyz1, 
                CENTER)
            polar.x += KEYBOARD_TO_ANGLE * delta
            var xyz2 = get_wall_point(polar.x, xyz1.y)
            library.player_cam.global_transform.origin = xyz2
            library.player_cam.look_at(get_lookat(), Vector3(0, 1, 0))

        if Input.is_action_pressed("ui_up"):
            var y = library.player_cam.global_transform.origin.y
            y += delta * KEYBOARD_TO_XYZ
            if(y > MAX_Y):
                y = MAX_Y
            if(y < MIN_Y):
                y = MIN_Y
            library.player_cam.global_transform.origin.y = y
            library.player_cam.look_at(get_lookat(), Vector3(0, 1, 0))

        if Input.is_action_pressed("ui_down"):
            var y = library.player_cam.global_transform.origin.y
            y -= delta * KEYBOARD_TO_XYZ
            if(y > MAX_Y):
                y = MAX_Y
            if(y < MIN_Y):
                y = MIN_Y
            library.player_cam.global_transform.origin.y = y
            library.player_cam.look_at(get_lookat(), Vector3(0, 1, 0))
    else:
        library.do_test_mode(self, delta)



func auto_camera(delta):
    camera_time += delta
    if camera_time >= camera_duration:
        camera_time = 0
        camera_move += 1
        if camera_move >= camera_table.size() / 4:
            camera_move = 0
    var angle1 = camera_table[camera_move * 4 + 0]
    var y1 = camera_table[camera_move * 4 + 1]
    var angle2 = camera_table[camera_move * 4 + 2]
    var y2 = camera_table[camera_move * 4 + 3]
    var fraction = camera_time / camera_duration
    var angle = fraction * (angle2 - angle1) + angle1
    var y = fraction * (y2 - y1) + y1
    var xyz2 = get_wall_point(library.toRad(angle), y)
    library.player_cam.global_transform.origin = xyz2
    library.player_cam.look_at(get_lookat(), Vector3(0, 1, 0))




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    #print("hangar._process")
    auto_camera(delta)
    handle_input(delta)
    pass








