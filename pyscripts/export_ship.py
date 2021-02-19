# export the big fucking ship



import os
import bpy
import bmesh
import sys
import importlib
import math


sys.path.append(os.path.dirname(bpy.data.filepath))

import bfs
importlib.reload(bfs)

objects = [
    "bottom_fuse",
    "bottom_heatshield",
    "canard flange1",
    "canard flange2",
    "canard1",
    "canard2",
    "flag",
    "hatch1",
    "hatch1_outline",
    "hatch2",
    "hatch2_outline",
    "pipes",
    "spacex",
    "tank rear",
    "top dome",
    "top_fuse",
    "top_heatshield",
    "wing base3",
    "wing base4",
    "wing cylinder3",
    "wing cylinder4",
    "wing2",
    "wing3",
    "wing4",
    "wing_heatshield"
    ]




bfs.selectList(objects)
for i in range(0, 101):
    bfs.findObject("window_" + str(i)).select = True
    
path = os.path.dirname(bpy.data.filepath) + "/bfs.godot/assets/bfs5.dae"

#bpy.ops.wm.collada_export(filepath=bfs.PATH + "assets/bfs5.dae", 
#    apply_modifiers=True,
#    selected=True,
#    triangulate=False)

bpy.ops.export_scene.dae(filepath=path, 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)

print("wrote %s" % path)
    
    
    
    
    
    
    
    
    
    
