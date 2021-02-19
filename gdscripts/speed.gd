extends Node2D


var dial
# the value
var number
# text area
var km
# text area
var speed

# Called when the node enters the scene tree for the first time.
func _ready():
    dial = find_node('dial')
    number = find_node('number')
    km = find_node('km')
    speed = find_node('speed')
    number.set_text('0')




