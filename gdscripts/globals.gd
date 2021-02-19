extends Node

# a singleton instantiated by the project settings

var absolute_time = 0.0
var speed_lowpass = 0.0
var player
var current_iteration = 0
# debugging arrow
var arrow

# limits of the dials.  depends on the map
var DIAL_ALTITUDE = 200
var DIAL_SPEED = 30000

# physics altitude in km at which top speed & altitude of the BFR
# iteration are displayed
var TOP_PHYSICS_ALTITUDE = 10

# settings for various BFR iterations.  It would be boring to need 8 minutes
# to reach max speed & max altitude, so we fake the display
# as physics altitude increases, displayed speed increases until top speed while
# physics speed is limited
# displayed altitude also a scaled version of physics altitude

# displayed top speed km/h, 
# physics top speed km/h, 
# acceleration,    arbitary unit used by the game engine
# handling,    arbitary unit used by the game engine
# displayed nitro km/h
# physics nitro km/h
var BFR_PARAMS =  [[25000, 500, 0, 0, 2000, 50],
               [27000, 600, 0, 0, 4000, 60],
               [29000, 700, 0, 0, 6000, 70]]



