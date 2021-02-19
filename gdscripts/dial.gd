# draw the dial in a speed indicator

extends Sprite

var TICK_RADIUS = 110
var TICK_ANGLE = 1
var INNER_RADIUS = 124
var OUTER_RADIUS = 130
var ANGLE1 = -120
var ANGLE2 = 120
var MAX_ANGLE = (ANGLE2 - ANGLE1)
var RED_ANGLE = 200
var WHITE = Color(1, 1, 1)
var GREY = Color(.5, .5, .5)
var RED = Color(1.0, 0.0, 0.0)
var DKRED = Color(.5, 0.0, 0.0)
var CENTER = Vector2(0, 0)

# angle of value being displayed 0 ... MAX_ANGLE
var current_angle = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_angle(value):
    if value > MAX_ANGLE:
        value = MAX_ANGLE
    current_angle = value
    update()


func draw_arc_segment(center, radius1, radius2, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()
    #points_arc.push_back(center)
    var colors = PoolColorArray([color])
# outer arc
    for i in range(nb_points + 1):
        var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90
        points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), \
            sin( deg2rad(angle_point) ) ) * radius2)
# inner arc
    for i in range(nb_points + 1):
        var j = nb_points - i
        var angle_point = angle_from + j * (angle_to - angle_from) / nb_points - 90
        points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), \
            sin( deg2rad(angle_point) ) ) * radius1)
    draw_polygon(points_arc, 
        colors, 
        PoolVector2Array(), # uvs
        null, # texture
        null, # normal_map
        true) # antialiased



func _draw():
    #print("Dial.draw")
# background
    draw_arc_segment(CENTER, 
        TICK_RADIUS, 
        OUTER_RADIUS, 
        ANGLE1,
        ANGLE1 + TICK_ANGLE, 
        GREY)
# arc
    draw_arc_segment(CENTER, 
        INNER_RADIUS, 
        OUTER_RADIUS, 
        ANGLE1 + TICK_ANGLE,
        ANGLE1 + RED_ANGLE, 
        GREY)
# redline
    draw_arc_segment(CENTER, 
        INNER_RADIUS, 
        OUTER_RADIUS, 
        ANGLE1 + RED_ANGLE,
        ANGLE2, 
        DKRED)

# foreground
    if current_angle > 0:
        var end_angle = TICK_ANGLE
        if current_angle <= end_angle:
            end_angle = current_angle
        draw_arc_segment(CENTER, 
            TICK_RADIUS, 
            OUTER_RADIUS, 
            ANGLE1,
            ANGLE1 + end_angle, 
            WHITE)

        if current_angle > TICK_ANGLE:
            end_angle = RED_ANGLE
            if current_angle <= end_angle:
                end_angle = current_angle
            draw_arc_segment(CENTER, 
                INNER_RADIUS, 
                OUTER_RADIUS, 
                ANGLE1 + TICK_ANGLE,
                ANGLE1 + end_angle, 
                WHITE)

        if current_angle > RED_ANGLE:
            end_angle = ANGLE2 - ANGLE1
            if current_angle <= end_angle:
                end_angle = current_angle
            draw_arc_segment(CENTER, 
                INNER_RADIUS, 
                OUTER_RADIUS, 
                ANGLE1 + RED_ANGLE,
                ANGLE1 + end_angle, 
                RED)






