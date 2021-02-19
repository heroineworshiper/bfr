# blender functions for creating big fucking rockets
# project must be saved in the same directory as this file or you'll get 
# No module named 'bfs'

import os
import bpy, bmesh
import math
from mathutils import *

from bpy_extras.image_utils import load_image


# enter edit mode for the object & get the mesh
def edit(obj):
    bpy.context.scene.objects.active = obj
    bpy.ops.object.mode_set(mode = 'EDIT')
    bpy.ops.mesh.select_all(action='DESELECT')
    bm = bmesh.new()
    bm = bmesh.from_edit_mesh(obj.data)
    return bm



# enters edit mode, selects all, flips the normals, exits edit mode
def flip_normals(obj):
    mesh = edit(obj)
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.flip_normals()
    bpy.ops.object.mode_set(mode = 'OBJECT')




# deselect all objects
def deselect():
    #bpy.ops.object.select_all(action='DESELECT')
    for i in bpy.data.objects:
        i.select = False

def selectList(list, showThem=False):
    for i in list:
        obj = findObject(i)
        if obj == None:
            print("selectList " + i + " not found")
        else:
            obj.select = True
            if showThem:
                obj.hide = False

# deselect all, select the obj & make it the active obj
def selectActivate(obj):
    deselect()
    obj.select = True
    bpy.context.scene.objects.active = obj
    return obj


# select & activate the object
def selectByName(name):
    deselect()
    for i in bpy.context.scene.objects:
        #print(i.name)
        if i.name == name:
            i.select = True
            bpy.context.scene.objects.active = i
            return i
    print("selectByName didn't find %s" % (name))


# the 1 export routine that works.  Filename is relative & must end in .dae
# exports the selected objects
def exportWrapper(filename):
    dirname = os.path.dirname(bpy.data.filepath)
    bpy.ops.export_scene.dae(filepath=dirname + "/../exports/" + filename, 
        use_mesh_modifiers=True,
        use_export_selected=True,
        use_triangles=True,
        anim_optimize_precision=1)
    



# get all selected objects in an array
def getSelected():
    result = []
    for i in bpy.context.scene.objects:
        if i.select:
            result.append(i)
    return result


def findObject(name):
    for i in bpy.context.scene.objects:
        if i.name == name:
            return i
    return None

def duplicateByName(name2, name1):
    obj = selectByName(name1)
    bpy.ops.object.duplicate()
    result = getSelected()[0]
    bpy.context.scene.objects.active = result
    result.name = name2
    return result




def deleteObject(obj):
    deselect()
    obj.select = True
    obj.hide = False
    bpy.context.scene.objects.active = obj
    bpy.ops.object.delete()
    
def deleteObjectNamed(name):
    deselect()
    obj = findObject(name)
    if obj != None:
        obj.select = True
        obj.hide = False
        bpy.context.scene.objects.active = obj
        bpy.ops.object.delete()
    else:
        print("deleteObjectNamed: %s not found" % (name))
    
def deleteObjectsNamed(objs):
    for i in objs:
        deleteObjectNamed(i)

def showObjects(objNames):
    for i in objNames:
        obj = findObject(i)
        if obj == None:
            print("showObjects: " + i + " not found")
        else:
            obj.hide = False

# create an empty object.  Must be in object mode.
def createObject(name):
    deleteObjectNamed(name)
    mesh = bpy.data.meshes.new("mesh")
    obj = bpy.data.objects.new(name, mesh)
    scene = bpy.context.scene
    scene.objects.link(obj)  # put the object into the scene (link)
    scene.objects.active = obj  # set as the active object in the scene
    obj.select = True  # select object
    mesh = obj.data
    bm = bmesh.new()
    return (obj, bm, mesh)
    
    
    


# join polygons
def joinList(list, name):
    deselect()
    select(list)

    dst = bpy.data.objects[list[0]]
    bpy.context.scene.objects.active = dst
    bpy.ops.object.join()
    dst.name = name

# convert list to meshes
def toMeshes(list):
    for i in list:
        object = bpy.data.objects[i]
        object.select = True
        bpy.context.scene.objects.active = object
        bpy.ops.object.convert(target='MESH')


def toRad(angle):
    return angle * math.pi * 2.0 / 360.0

def fromRad(angle):
    return angle * 360.0 / math.pi / 2.0

def polarToXY(angle, radius):
    x = radius * math.cos(angle)
    y = radius * math.sin(angle)
    return [x, y]

def XYToPolar(x, y):
    angle = math.atan2(y, x)
    radius = math.hypot(x, y)
    return [angle, radius]

# 3D hypotenuse
def hypot3(vert1, vert2):
    distance = math.hypot(vert1[0] - vert2[0], \
            vert1[1] - vert2[1])
    distance = math.hypot(distance, vert1[2] - vert2[2])
    return distance

# magnitude of 3D vector
def mag(vec):
    return math.sqrt(vec[0] ** 2 + vec[1] ** 2 + vec[2] ** 2)


# normal to a plane given by 3 points
def normal(coord1, center, coord3):
    result = Vector(coord1 - center).cross(coord3 - center)
    return result.normalized()



def thickness(obj, value):
    selectActivate(obj)
    mod = obj.modifiers.new(type="SOLIDIFY", name="mod")
    mod.thickness = value
    bpy.ops.object.modifier_apply(modifier="mod")
    

class VertObj:
    def __init__(self, coord, vert):
        self.coord = coord
        self.vert = vert


# extract sorted vertices from the object
def objToVerts(obj):
    resultVerts = []
    for vert in obj.data.vertices:
        resultVerts.append(VertObj(obj.matrix_world * vert.co, vert))
    resultVerts = sorted(resultVerts, key=lambda x: (x.coord[2]))
    return resultVerts


# delete all vertices in keepObj which are in deleteObj
# optionally, provide sorted vertices in deleteVerts to speed it up
def deleteOverlap(keepObj, deleteObj=None, deleteVerts=None):
    mesh = edit(keepObj)
    
    # create arrays of the vertices in the 2 objects
    keepVerts = []
    for vert in mesh.verts:
        keepVerts.append(VertObj(keepObj.matrix_world * vert.co, vert))
    # sort the vertices into the scanning order
    keepVerts = sorted(keepVerts, key=lambda x: (x.coord[2]))

    if deleteVerts == None:
        print("deleteOverlap: sorting vertices from %s" % deleteObj.name)
        deleteVerts = objToVerts(deleteObj)


    THRESHOLD = 0.001
    # localized british museum algorithm
    if True:
        #for i in range(0, len(keepVerts)):
        #    if keepVerts[i].coord.z < -32 and keepVerts[i].coord.z > -46:
        #        print("keepVert=%d %s" % (i, keepVerts[i].coord))

        #for i in range(0, len(deleteVerts)):
        #    if deleteVerts[i].coord.z < -32 and deleteVerts[i].coord.z > -46:
        #        print("deleteVert=%d %s" % (i, deleteVerts[i].coord))
        
        i = 0
        j = 0
        # search for the fuse verts in the window verts
        for j in range(0, len(keepVerts)):
            keepVert = keepVerts[j]
            fuseCoord = keepVert.coord

            # because of rounding errors, we have to rewind & search a cube
            if i >= len(deleteVerts):
                i = len(deleteVerts) - 1
            while i > 0 and \
                i < len(deleteVerts) and \
                deleteVerts[i].coord[2] > fuseCoord[2] - THRESHOLD:
                i -= 1
            
            # search a range of Z
            while i < len(deleteVerts) and \
                deleteVerts[i].coord[2] < fuseCoord[2] - THRESHOLD:
                i += 1

            while i < len(deleteVerts) and \
                deleteVerts[i].coord[2] < fuseCoord[2] + THRESHOLD:
                
                # search a range of Y & X
                if deleteVerts[i].coord[1] >= fuseCoord[1] - THRESHOLD and \
                    deleteVerts[i].coord[1] < fuseCoord[1] + THRESHOLD and \
                    deleteVerts[i].coord[0] >= fuseCoord[0] - THRESHOLD and \
                    deleteVerts[i].coord[0] < fuseCoord[0] + THRESHOLD:
                    keepVert.vert.select = True
                    #print("keepVert=%d %s deleteVert=%d %s" % (j, fuseCoord, i, deleteVerts[i].coord))
                    break
                i += 1
            j += 1

    # british museum algorithm
    if False:
        for i in range(0, len(keepVerts)):
            keepVert = keepVerts[i]
            for j in range(0, len(deleteVerts)):
                deleteVert = deleteVerts[j]
                dist = mag(deleteVert.coord - keepVert.coord)
                if dist < THRESHOLD:
                    keepVert.vert.select = True
                    #print("keepVert=%d %s deleteVert=%d %s" % (i, keepVert.coord, j, deleteVert.coord))
                    break

    bpy.ops.mesh.delete(type='VERT')
    
    mesh.free()
    bpy.ops.object.mode_set(mode = 'OBJECT')





# cut cookie out of the target with a cutter
# both objects must be subdivided
# obj.location doesn't alter the matrix_world, so have to use bpy.ops.transform.translate
# returns the cookie
def cookieCut(target, cutter, cookieName, solver='CARVE'):
    result = None
    cutterVerts = objToVerts(cutter)

    selectActivate(target)
    bpy.ops.object.duplicate()
    
    # this object becomes the cookie
    result = getSelected()[0]
    result.name = cookieName
    
    # this object becomes the outline
    selectActivate(target)

    # create the outline
    bool = target.modifiers.new(type="BOOLEAN", name="bool")
    bool.operation = 'DIFFERENCE'
    bool.solver = solver
    bool.object = cutter
    bpy.ops.object.modifier_apply(modifier="bool")

    # boolean artifacts
    # delete all vertices which coincide between the windows & the plug
    deleteOverlap(target, cutter, cutterVerts)

    # create the cookie
    selectActivate(result)

    bool = result.modifiers.new(type="BOOLEAN", name="bool")
    bool.operation = 'INTERSECT'
    bool.solver = solver
    bool.object = cutter
    bpy.ops.object.modifier_apply(modifier="bool")

    # boolean artifacts
    # delete all vertices which coincide between the windows & the plug
    deleteOverlap(result, cutter, cutterVerts)

    # hide the cutter
    cutter.hide = True

    return result


# get the average coordinate for all the vertices in a face
def avgCoord(obj, faceNum):
    face = obj.data.polygons[faceNum]
    matrix = obj.matrix_world
    total_coord = [ 0, 0, 0 ]
    for k in range(face.loop_start, face.loop_start + face.loop_total):
        vertex_idx = obj.data.loops[k].vertex_index
        vertex = obj.data.vertices[vertex_idx]
        coord = matrix * vertex.co
        total_coord[0] += coord[0]
        total_coord[1] += coord[1]
        total_coord[2] += coord[2]
    total_coord[0] /= face.loop_total
    total_coord[1] /= face.loop_total
    total_coord[2] /= face.loop_total
    return total_coord













def view3d_find( return_area = False ):
    # returns first 3d view, normally we get from context
    for area in bpy.context.window.screen.areas:
        if area.type == 'VIEW_3D':
            v3d = area.spaces[0]
            region_3d = v3d.region_3d
            for region in area.regions:
                if region.type == 'WINDOW':
                    if return_area: return region, region_3d, v3d, area
                    return region, region_3d, v3d
    return None, None


# cut shapes srcNames on the XY axis out of srcPlane & 
# create a new object dstPlane
def cutPlane(dstPlane, srcNames, srcPlane):
    deleteObjectNamed(dstPlane)
    dst_cutout = duplicateByName(dstPlane, srcPlane)
    dst_cutout.hide = False
    selectList(srcNames)
    showObjects(srcNames)
    bpy.ops.object.mode_set(mode = 'EDIT')
    region, region_3d, v3d, area = view3d_find(True)
    # View the object from the top
    region_3d.view_rotation = Euler( (0,0,0) ).to_quaternion()
    # Zoom in to increase the resolution of the knife
    region_3d.view_distance = 0.1
    region_3d.view_location = [ -0.662180,1.048937,0.000042 ]
    # Force redraw the scene - this is considered unsavory but is necessary here
    bpy.ops.wm.redraw_timer(type='DRAW_WIN_SWAP', iterations=1)

    override = {
        'scene'            : bpy.context.scene,
        'region'           : region,
        'area'             : area,
        'space'            : v3d,
        'active_object'    : bpy.context.object,
        'window'           : bpy.context.window,
        'screen'           : bpy.context.screen,
        'selected_objects' : bpy.context.selected_objects,
        'edit_object'      : bpy.context.object
    }
    bpy.ops.mesh.knife_project(override)
    bpy.ops.wm.redraw_timer(type='DRAW_WIN_SWAP', iterations=1)
    bpy.ops.mesh.delete(type="FACE")
    bpy.ops.object.mode_set(mode = 'OBJECT')
    findObject(srcPlane).hide = True

    
    
    
    


#def cutPlane(plane_name, cutout_names):
# rasterize all the shapes
#    w = 1000
#    h = 1000
#    buffer = range(0, w * h)
#    plane = findObject(plane_name)
#    plane_verts = plane.data.vertices
#    plane_matrix = plane.matrix_world
#    min_x = 0x7fffffff
#    min_y = 0x7fffffff
#    max_x = -0x7fffffff
#    max_y = -0x7fffffff
#    for i in range(0, len(plane_verts)):
#        coord = plane_matrix * plane_verts[i].co
#        x = coord[0]
#        y = coord[1]
#        if x < min_x:
#            min_x = x
#        if y < min_y:
#            min_y = y
#        if x > max_x:
#            max_x = x
#        if y > max_y:
#            max_y = y
#    #print("min_x=%f max_x=%f min_y=%f max_y=%f" % (min_x, max_x, min_y, max_y))
#
#    for i in range(0, len(cutout_names)):
#        cutout = findObject(cutout_names[i])
#        cutout_matrix = cutout.matrix_world
#        print("cutout %s polygons=%d" % (cutout_names[i], len(cutout.data.polygons)))
#        for j in range(0, len(cutout.data.polygons)):
#            face = cutout.data.polygons[j]
#            for k in range(face.loop_start, face.loop_start + face.loop_total):
# vertices go clockwise around the face
#                vertex_idx = cutout.data.loops[k].vertex_index
#                vertex = cutout.data.vertices[vertex_idx]
#                coord = cutout_matrix * vertex.co
#                print("    vertex=%f %f" % (coord[0], coord[1]))
    
    




def dumpUVs(obj):
    data = obj.data
    uvs = data.uv_layers[-1].data
    for i in range(0, len(uvs)):
        coord = uvs[i].uv
        print("uv %f %f" % (coord[0], coord[1]))


# map UV coords on a cylindrical object
# assume the cylinder rotates around the Z axis in world frame
def cylinderUV(obj, flipZ=False, flipX=False):
    #deselect()
    #mesh = edit(obj)
    #bpy.ops.mesh.select_all(action='SELECT')
    #bpy.ops.uv.smart_project()
    #bpy.ops.mesh.select_all(action='DESELECT')
    #bpy.ops.uv.select_all(action='SELECT')
    #bpy.ops.transform.rotate(value=angle)

    data = obj.data
    if len(data.uv_layers) < 1:
        data.uv_textures.new("big fucking UV map")
    
    uvs = data.uv_layers[-1].data
    verts = data.vertices
    
    #print("total polys=%d" % len(data.polygons))
    #print("total uvs=%d %s" % (len(uvs), uvs[0]))
    #print("total verts=%d %s" % (len(verts), verts[0]))
    
    #for poly in data.polygons:
    #    print("verts=%s uvs=%s" % (poly.vertices, poly.loop_indices))

    # discover the used quadrants
    quadrants = [ False, False, False, False ]
    for vert in verts:
        worldCoord = obj.matrix_world * vert.co
        if worldCoord.x >= 0 and worldCoord.y >= 0:
            quadrants[0] = True
        elif worldCoord.x >= 0 and worldCoord.y < 0:
            quadrants[1] = True
        elif worldCoord.x < 0 and worldCoord.y < 0:
            quadrants[2] = True
        else:
            quadrants[3] = True

    flipSign = False
    if quadrants[2] and quadrants[3]:
        flipSign = True

    #print("quadrants=%s" % quadrants)
    #for i in range(0, len(uvs)):
    #    coord = uvs[i].uv
    #    print("uv %f %f" % (coord[0], coord[1]))

    minAngle = math.pi * 2
    maxAngle = -math.pi * 2
    minZ = 10000
    maxZ = -10000
    for vert in verts:
        worldCoord = obj.matrix_world * vert.co
        if worldCoord.z > maxZ:
            maxZ = worldCoord.z
        if worldCoord.z < minZ:
            minZ = worldCoord.z
        polar = XYToPolar(worldCoord.x, worldCoord.y)
        if flipSign and polar[0] < 0:
            polar[0] += math.pi * 2
        if polar[0] > maxAngle:
            maxAngle = polar[0]
        if polar[0] < minAngle:
            minAngle= polar[0]

    #print("minAngle=%f maxAngle=%f minZ=%f maxZ=%f" % 
    #    (minAngle, maxAngle, minZ, maxZ))

    for poly in data.polygons:
        uvIndexes = poly.loop_indices
        #print("vertices=%d uvs=%d" % (len(poly.vertices), len(uvIndexes)))
        for vertIndex, uvIndex in zip(poly.vertices, uvIndexes):
            vert = verts[vertIndex]
            worldCoord = obj.matrix_world * vert.co
            polar = XYToPolar(worldCoord.x, worldCoord.y)
            if flipSign and polar[0] < 0:
                polar[0] += math.pi * 2

            uvX = (polar[0] - minAngle) / (maxAngle - minAngle)
            uvY = (worldCoord.z - minZ) / (maxZ - minZ)
            if flipZ:
                uvY = 1.0 - uvY
            if flipX:
                uvX = 1.0 - uvX
                
            uvs[uvIndex].uv[0] = uvX
            uvs[uvIndex].uv[1] = uvY
    #dumpUVs(obj)







def create_image_textures(image):
    fn_full = os.path.normpath(bpy.path.abspath(image.filepath))

    # look for texture referencing this file
    for texture in bpy.data.textures:
        if texture.type == 'IMAGE':
            tex_img = texture.image
            if (tex_img is not None) and (tex_img.library is None):
                fn_tex_full = os.path.normpath(bpy.path.abspath(tex_img.filepath))
                if fn_full == fn_tex_full:
                    return texture

    # if no texture is found: create one
    name_compat = bpy.path.display_name_from_filepath(image.filepath)
    texture = bpy.data.textures.new(name=name_compat, type='IMAGE')
    texture.image = image
    texture.extension = 'CLIP'  # Default of "Repeat" can cause artifacts
    return texture



def apply_material_options(material, slot):
    material.alpha = 0.0
    material.specular_alpha = 0.0
    slot.use_map_alpha = True

    material.specular_intensity = 0
    material.diffuse_intensity = 1.0
    material.use_transparency = True
    material.transparency_method = 'Z_TRANSPARENCY'
    material.use_shadeless = True
    material.use_transparent_shadows = False
    material.emit = 0.0


def create_material_for_texture(texture):
    # look for material with the needed texture
    for material in bpy.data.materials:
        slot = material.texture_slots[0]
        if slot and slot.texture == texture:
            return material

    # if no material found: create one
    name_compat = bpy.path.display_name_from_filepath(texture.image.filepath)
    material = bpy.data.materials.new(name=name_compat)
    slot = material.texture_slots.add()
    slot.texture = texture
    slot.texture_coords = 'UV'
    apply_material_options(material, slot)
    return material



# assign a texture to an object
def assign_texture(dst, path):
    # create the material
    image = load_image("bfs.godot/assets/ramp.png", 
        os.path.dirname(bpy.data.filepath), 
        check_existing=True, 
        force_reload=False)
    #print("extrudeTrack 2 %s" % (image.filepath))
    tex = create_image_textures(image)
    material = create_material_for_texture(tex)


# assign the material
    if dst.data.materials:
        dst.data.materials[0] = material
        material_id = 0
    else:
        dst.data.materials.append(material)
        material_id = len(dst.data.materials) - 1
    print("uv_textures=%d data=%d" % (len(dst.data.uv_textures), len(dst.data.uv_textures[0].data)))
    for tex in dst.data.uv_textures[0].data:
        tex.image = image













