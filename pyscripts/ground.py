# extract objects for the ground

import os
import bpy
import bmesh
import sys
import importlib
import math
from mathutils import *

libpath = os.path.dirname(bpy.data.filepath) + "/../pyscripts"
sys.path.append(libpath)
print("libpath=%s" % (libpath))

import bfs
importlib.reload(bfs)

dirname = os.path.dirname(bpy.data.filepath)
filepath = dirname + "/../exports/"

print("filepath=%s" % (filepath))


objsToCut = [
    "shuttle_landing", 
    "road", 
    "beach", 
    "water1"
]

objsToExport = [
    "ground_cutout",
    "ocean_cutout",
    "road_cutout", 
    "shuttle_landing", 
    "beach", 
    "water1",
    "vab"
]




bfs.deselect()


bfs.cutPlane("ground_cutout", objsToCut, "ground")
bfs.cutPlane("road_cutout", [ "vab_cutter" ], "road")



# split the ground into ocean & ground
bfs.deleteObjectNamed("ocean_cutout")
ocean_cutout = bfs.duplicateByName("ocean_cutout", "ground_cutout")
# delete leftmost faces
print("faces=%d" % (len(ocean_cutout.data.polygons)))
rightmost = 0
rightmost_x = 0
for i, face in enumerate(ocean_cutout.data.polygons):
    coord = bfs.avgCoord(ocean_cutout, i)
    if i == 0 or coord[0] > rightmost_x:
        rightmost = i
        rightmost_x = coord[0]
    print("i=%d coord=%f, %f, %f" % (i, coord[0], coord[1], coord[2]))
# select the leftmost faces
for i in range(0, len(ocean_cutout.data.polygons)):
    if i != rightmost:
        ocean_cutout.data.polygons[i].select = True
# edit mode
bpy.ops.object.mode_set(mode = 'EDIT')
# delete them
bpy.ops.mesh.delete(type = 'FACE')
bpy.ops.object.mode_set(mode = 'OBJECT')


# delete rightmost face in ground_cutout
ground_cutout = bfs.selectByName("ground_cutout")
ground_cutout.data.polygons[rightmost].select = True
# edit mode
bpy.ops.object.mode_set(mode = 'EDIT')
# delete them
bpy.ops.mesh.delete(type = 'FACE')
bpy.ops.object.mode_set(mode = 'OBJECT')


bfs.deselect()
bfs.selectList(objsToExport)

bpy.ops.export_scene.dae(filepath=filepath + "ground.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)








