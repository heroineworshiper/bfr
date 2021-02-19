# extract the VAB

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


objsToExport = [
    "vab",
]




bfs.deselect()

bfs.selectList(objsToExport)

bpy.ops.export_scene.dae(filepath=filepath + "vab.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)








