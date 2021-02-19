import bpy, bmesh
import importlib
import bfs
importlib.reload(bfs)

bfs.cylinderUV(bfs.findObject("flag2"), flipZ=True, flipX=True)




