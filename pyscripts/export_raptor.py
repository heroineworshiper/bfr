# blender script to export the raptor



import os
import bpy
import bmesh
import sys
import importlib
import math

libpath = os.path.dirname(bpy.data.filepath) + "/../pyscripts"
sys.path.append(libpath)

print("libpath=%s" % (libpath))

import bfs
importlib.reload(bfs)


objects = [
    'charcoal.01',
    'charcoal.02',
    'stainless.01',
    'stainless.02',
    'stainless.03',
    'stainless.04',
    'sea_nozzle',
    'vacuum_nozzle',
    'sea_flame',
    'flame2'
]



bfs.selectList(objects, showThem=True)


path = os.path.dirname(bpy.data.filepath) + "/../exports/raptor.dae"


bpy.ops.export_scene.dae(filepath=path, 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)





