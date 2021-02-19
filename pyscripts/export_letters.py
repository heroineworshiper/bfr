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

bfs.selectByName("3")

bpy.ops.export_scene.dae(filepath=filepath + "3.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)


bfs.selectByName("2")

bpy.ops.export_scene.dae(filepath=filepath + "2.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)


bfs.selectByName("1")

bpy.ops.export_scene.dae(filepath=filepath + "1.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)

bfs.selectByName("rud.r")

bpy.ops.export_scene.dae(filepath=filepath + "rud_r.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)

bfs.selectByName("rud.d")

bpy.ops.export_scene.dae(filepath=filepath + "rud_d.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)

bfs.selectByName("rud.u")

bpy.ops.export_scene.dae(filepath=filepath + "rud_u.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)


bfs.selectByName("start")

bpy.ops.export_scene.dae(filepath=filepath + "start.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)


bfs.selectByName("finish")

bpy.ops.export_scene.dae(filepath=filepath + "finish.dae", 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)


