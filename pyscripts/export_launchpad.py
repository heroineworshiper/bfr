# blender script to export launchpad
# apply to launchpad.blend


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
    'hangar',
    'launchpad',
    'launchpad-col',
    'tower'
    'tower-col'
]

# create collision shapes
# colonly doesn't work
bfs.deleteObjectNamed('tower-col')
bfs.duplicateByName('tower-col', 'tower')


bfs.selectList(objects)


path = os.path.dirname(bpy.data.filepath) + "/bfs.godot/assets/launchpad_model.dae"


bpy.ops.export_scene.dae(filepath=path, 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)









