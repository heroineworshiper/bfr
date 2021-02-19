# blender script to export the raptor



import os
import bpy
import bmesh
import sys
import importlib
import math

sys.path.append("/amazon/root/bfr/pyscripts")

OUTPATH="/amazon/root/bfr/exports/raptor.dae"

import bfs
importlib.reload(bfs)


objects = [
    'charcoal.01',
    'charcoal.02',
    'sea_nozzle',
    'vacuum_nozzle',
    'sea_flame',
    'flame2'
]



bfs.selectList(objects, showThem=True)




# better exporter
bpy.ops.export_scene.dae(filepath=OUTPATH, 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)





