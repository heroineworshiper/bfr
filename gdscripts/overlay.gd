extends Node2D

var library = preload("library.gd").new()



var speed
var altitude
var time
var viewport_size
var telemetry
var speed_bg
var bottom
var BASELINE_W = 1920

func resize(node, scale):
    node.position = node.position * scale
    node.scale = node.scale * scale


func update():
# draw the time
    var display_time = Globals.absolute_time - library.camera_times[4]
    var minutes = int(display_time) / 60
    var seconds = int(display_time) % 60
    var fracs = display_time - int(display_time)
    var text = "T + %02d:%02d.%03d" % [minutes, seconds, int(fracs * 1000)]
    #print("overlay.update %s" % [text])
    time.set_text(text)
    
    var altitude_ = Globals.player.rigid.global_transform.origin.y / 1000
    var displayed_altitude = library.calculate_altitude(altitude_)
    var altitude_frac = displayed_altitude - int(displayed_altitude)
    if displayed_altitude < 100:
        text = "%d.%d" % [int(displayed_altitude), int(altitude_frac * 10)]
    else:
        text = "%d" % [int(displayed_altitude)]
    altitude.number.set_text(text)
    altitude.dial.set_angle(displayed_altitude * \
        altitude.dial.MAX_ANGLE / \
        Globals.DIAL_ALTITUDE)
    
    var speed_ = Globals.player.rigid.linear_velocity.length() * 3600 / 1000
    Globals.speed_lowpass = Globals.speed_lowpass * .99 + speed_ * .01
    var displayed_speed = library.calculate_speed(Globals.speed_lowpass, \
        altitude_, \
        Globals.BFR_PARAMS[Globals.current_iteration])
    speed.number.set_text("%d" % [int(displayed_speed)])
    speed.dial.set_angle(displayed_speed * \
        speed.dial.MAX_ANGLE / \
        Globals.DIAL_SPEED)
    #print("overlay.update speed_=%f displayed=%f" % [Globals.speed_lowpass, displayed_speed])
    
    
    
    

# Called when the node enters the scene tree for the first time.
func _ready():
    viewport_size = get_viewport().size
    var scale_ = viewport_size.x / BASELINE_W
    print("viewport w=%f h=%f" % [viewport_size.x, viewport_size.y])
    position = position * scale_
    scale = scale * scale_

    bottom = find_node('bottom')
    speed = find_node('speed')
    altitude = find_node('altitude')
    time = find_node('time')
    telemetry = find_node('telemetry')
    speed_bg = find_node('speed_bg')
    altitude.speed.set_text('ALTITUDE')
    altitude.km.set_text('KM')

#    var scale = viewport_size.x / BASELINE_W
#    resize(telemetry, scale)
#    resize(speed_bg, scale)
#    resize(altitude, scale)
#    resize(speed, scale)
#    resize(bottom, scale)
#    resize(time_, scale)










