# export the big fucking ship



import os
import bpy
import bmesh
import sys
import importlib
import math

sys.path.append("/amazon/root/bfr/pyscripts")


OUTPATH="/amazon/root/bfr/exports/bfs6.dae"

import bfs
importlib.reload(bfs)

fuseObjects = [
    "bottom dome",
    "bottom_fuse",
    "bottom_heatshield",
    "canard",
    "canard flange",
    "canard2",
    "canard flange2",
    "flag",
    "hatch1",
    "hatch1_outline",
    "hatch2",
    "hatch2_outline",
    "spacex",
    "top_fuse",
    "top_heatshield",
    "wing",
    "wing flange",
    "wing2",
    "wing flange2",
    ]

bfs.selectList(fuseObjects)
for i in range(0, 101):
    bfs.findObject("window_" + str(i)).select = True


# stock exporter
#bpy.ops.wm.collada_export(filepath=OUTPATH, 
#    apply_modifiers=True,
#    selected=True,
#    triangulate=False)

# better exporter
bpy.ops.export_scene.dae(filepath=OUTPATH, 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)

print("Wrote %s" % OUTPATH)
    
    
    
    
    
    
    
    
    
    
