# blender script to export the grid

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
    'grid',
    'grid_piston',
    'grid_shaft'
]

bfs.selectList(objects, showThem=True)

path = os.path.dirname(bpy.data.filepath) + "/../exports/grid.dae"

bpy.ops.export_scene.dae(filepath=path, 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)









