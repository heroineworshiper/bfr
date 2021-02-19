extends Spatial
var library = preload("library.gd").new()


var areas = []
# endpoints of the gravity vectors in local coordinates
var point1 = []
var point2 = []
# test arrows
var arrow1 = []
var arrow2 = []
var initialized = false
var gravity_arrows = false

var materials = [
    'left', "res://materials/white_red.tres",
    'right', "res://materials/white_red.tres"
]


# Called when the node enters the scene tree for the first time.
func _ready():
    print("track1.ready")
    library.setMaterials(self, materials)
# hide the collision objects
    find_node('floor').hide()
    find_node('left_boundary').hide()
    find_node('right_boundary').hide()

# create gravity areas from the areas.txt file
    var f = File.new()
    var err = f.open("res://gdscripts/areas.txt", File.READ)
    if err != OK:
        print("Couldn't open areas.txt")
        pass

    var i = 0
# colors for visualizing the gravity nodes  
    var colors = [Color(1, 0, 0, 0.3), \
        Color(0, 1, 0, 0.3), \
        Color(0, 0, 1, 0.3)]
    var current_color = 0
# arrows for visualizing gravity directions
    var arrow_scene = load("res://scenes/arrow.tscn")

    while not f.eof_reached():
        var line2 = f.get_line()
        #print("track1._ready line2=%s" % line2)
# start of an area
        if line2 == "AREA":
# load the verts
            var vertex_array = PoolVector3Array()
# triangles for a cube
            var index_array = PoolIntArray([ \
                7, 3, 1, \
                1, 7, 5, \
                0, 6, 2, \
                0, 4, 6, \
                3, 6, 7, \
                2, 3, 6, \
                0, 1, 4, \
                1, 4, 5, \
                0, 1, 2, \
                3, 1, 2, \
                4, 5, 6, \
                7, 5, 6, \
                ])
            for i in range(0, 8):
                var line = f.get_line()
                var a = line.split(" ")
                vertex_array.push_back(Vector3(a[0].to_float(), \
                    a[2].to_float(), \
                    -a[1].to_float()))
                #print("track1._ready verts=%s" % str(vertex_array[i]))

# create the gravity area
            var area = Area.new()
            areas.append(area)
            add_child(area)
            area.space_override = area.SPACE_OVERRIDE_REPLACE
            #area.gravity_vec = vertex_array[0] - vertex_array[2]

            # normal from cross product of 2 vectors
            #var vec1 = vertex_array[1] - vertex_array[5]
            #var vec2 = vertex_array[1] - vertex_array[0]
            # cross ordering determines sign 
            #var cross_product = vec1.cross(vec2)
            # gravity is in global frame
            #area.gravity_vec = global_transform * cross_product

            # vectors don't form a plane, so we have to subtract the centers of the 2 planes
            var point1_ = (vertex_array[0] + vertex_array[1] + vertex_array[4] + vertex_array[5]) / 4
            var point2_ = (vertex_array[2] + vertex_array[3] + vertex_array[6] + vertex_array[7]) / 4
            point1.append(point1_)
            point2.append(point2_)

            area.linear_damp = 0
            area.angular_damp = 0
            area.gravity = 40
            area.connect("body_entered", self, "body_entered_area", [i])
            var shape = CollisionShape.new()
            area.add_child(shape)
            shape.shape = ConvexPolygonShape.new()
            shape.shape.set_points(vertex_array)


# create the mesh for visualizing the gravity nodes
            if false:
                var arrays_out = []
                arrays_out.resize(Mesh.ARRAY_MAX)
                arrays_out[Mesh.ARRAY_VERTEX] = vertex_array
                arrays_out[Mesh.ARRAY_INDEX] = index_array
                var mesh = ArrayMesh.new()
                mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, \
                    arrays_out)

                var node = MeshInstance.new()
                node.material_override = SpatialMaterial.new()
                node.material_override.flags_transparent = true
                node.material_override.albedo_color = colors[current_color]
                current_color = current_color + 1
                if current_color >= len(colors):
                    current_color = 0
                node.material_override.params_cull_mode = node.material_override.CULL_DISABLED
                node.mesh = mesh
                add_child(node)

            if gravity_arrows:
                var arrow1_ = arrow_scene.instance()
                arrow1_.translation = point1_
                add_child(arrow1_)
                arrow1.append(arrow1_)
                
                var arrow2_ = arrow_scene.instance()
                arrow2_.translation = point2_
                add_child(arrow2_)
                arrow2.append(arrow2_)
                



            i = i + 1

# DEBUG
        #break



func body_entered_area(body, area_number):
    #print("track1.body_entered_area 1 body=%s area_number=%d gravity=%s" % \
    #    [body.name, area_number, str(areas[area_number].gravity_vec)]);
    var orig_scale = Globals.arrow.scale
    Globals.arrow.look_at(Globals.arrow.global_transform.origin + 
            areas[area_number].gravity_vec, 
        Vector3(0, 1, 0))
    Globals.arrow.scale = orig_scale



func _process(delta):
# global_transform is only available here
    if not initialized:
        initialized = true
        for i in len(areas):
            var area = areas[i]
            # gravity is in global frame
            # no distributive property when using the global_transform
            area.gravity_vec = global_transform * point1[i] - \
                global_transform * point2[i]
            area.gravity_vec = area.gravity_vec.normalized()

            if gravity_arrows:
                arrow1[i].look_at(global_transform * point1[i] + area.gravity_vec, 
                    Vector3(0, 1, 0))
                arrow1[i].scale = Vector3(10, 10, 10)

                arrow2[i].look_at(global_transform * point1[i], 
                    Vector3(0, 1, 0))
                arrow2[i].scale = Vector3(10, 10, 10)









