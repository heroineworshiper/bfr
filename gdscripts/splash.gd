# the starting point in final mode

extends Node2D

var library = preload("library.gd").new()
var title
var i = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    var viewport_size = get_viewport().size
    title = find_node('title')
    var sprite_size = title.get_texture().get_size()
    #print("viewport w=%f h=%f sprite w=%f h=%f x=%f y=%f" % \
    #    [viewport_size.x, viewport_size.y, sprite_size.x, sprite_size.y, title.position.x, title.position.y])
    var scale = viewport_size.y / sprite_size.y
    title.set_scale(Vector2(scale, scale))
    title.position.x = viewport_size.x / 2
    title.position.y = viewport_size.y / 2
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    i = i + 1
    # 1 frame to draw the spash screen
    if(i == 2):
        get_tree().change_scene("res://hangar.tscn")
        #library.goto_scene(self, "res://hangar.tscn")
