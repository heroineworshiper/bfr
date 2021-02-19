# construct a ramp

import os
import bpy
import bmesh
import sys
import importlib
import math
from mathutils import *


sys.path.append(os.path.dirname(bpy.data.filepath))
import bfs
importlib.reload(bfs)



WIDTH = 2
HEIGHT = 4
VDIVISIONS = 32
HDIVISIONS = 16
NAME = "ramp"
# amount the low side rises
LOW_RISE = 0.5
# amount the high side rises
HIGH_RISE = 3


def do_exp(x, max):
    power = 1.5
    x = pow(x, power)
    x = x / pow(max, power) * max
    return x

# create a new object
dst, bm, mesh = bfs.createObject('NAME')

# make vertices
verts = []
for i in range(0, VDIVISIONS + 1):
    y = -HEIGHT / 2 + i * HEIGHT / VDIVISIONS
    low_z = i * LOW_RISE / VDIVISIONS
    high_z = i * HIGH_RISE / VDIVISIONS
    low_z = do_exp(low_z, LOW_RISE)
    high_z = do_exp(high_z, HIGH_RISE)
    for j in range(0, HDIVISIONS + 1):
        x = -WIDTH / 2 + j * WIDTH / HDIVISIONS
        z = low_z + j * (high_z - low_z) / HDIVISIONS
        vert = bm.verts.new([x, y, z])
        verts.append(vert)



bm.verts.ensure_lookup_table()


# make faces
for i in range(0, VDIVISIONS):
    for j in range(0, HDIVISIONS):
        index1 = i * (HDIVISIONS + 1) + j
        vert1 = verts[index1]
        vert2 = verts[index1 + 1]
        vert3 = verts[index1 + HDIVISIONS + 1 + 1]
        vert4 = verts[index1 + HDIVISIONS + 1]
        bm.faces.new((vert1, vert2, vert3, vert4))
        
bm.faces.ensure_lookup_table()


# make UV's
uv_layer = bm.loops.layers.uv.verify()
bm.faces.layers.tex.verify()


for i in range(0, VDIVISIONS):
    for j in range(0, HDIVISIONS):
        uv_list = [
            j / HDIVISIONS,       i / VDIVISIONS,  # top left
            (j + 1) / HDIVISIONS, i / VDIVISIONS,  # top right
            (j + 1) / HDIVISIONS, (i + 1) / VDIVISIONS,  # bottom right
            j / HDIVISIONS,       (i + 1) / VDIVISIONS,  # bottom left
        ]
        face = bm.faces[i * HDIVISIONS + j]
        for k, loop in enumerate(face.loops):
            uv = loop[uv_layer].uv
            uv[0] = uv_list[k * 2]
            uv[1] = uv_list[k * 2 + 1]


# make the bmesh the object's mesh
bm.to_mesh(mesh)
bm.free()  # always do this when finished


bfs.assign_texture(dst, "bfs.godot/assets/ramp.png")


