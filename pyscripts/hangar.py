# blender script to create hangar
# apply to hangar.blend


import os
import bpy
import bmesh
import sys
import importlib
import math


sys.path.append(os.path.dirname(bpy.data.filepath))

import bfs
importlib.reload(bfs)

# total dimensions
LENGTH = 85
WIDTH = 38
HEIGHT = 16.5

TOTAL_VRIBS = 18
TOTAL_HRIBS = 20
TOTAL_CRANE_RIBS = TOTAL_VRIBS * 2
VRIB_PREFIX = "vrib_"
HRIB_PREFIX = "hrib_"
CRANE_RIB_PREFIX = "crane_rib_"

LIGHT_COLUMNS = 6
LIGHT_ROWS = 15
TOTAL_LIGHTS = LIGHT_COLUMNS * LIGHT_ROWS
LIGHT_PREFIX = "light_"
LIGHT_LEG_PREFIX = "light_leg_"

bfs.deselect()

#for i in range(0, TOTAL_HRIBS * 2):
#    bfs.deleteObjectNamed(HRIB_PREFIX + str(i))


#bpy.ops.object.duplicate()
#vrib2 = bfs.getSelected()[0]
#bpy.ops.object.duplicate()
#vrib3 = bfs.getSelected()[0]

#bfs.selectActivate(vrib3)
# flip around the object's origin.
#bpy.ops.transform.mirror(constraint_axis=(True, False, False), constraint_orientation='GLOBAL')

# join 2 objects into a single piece.  Reverses normals.
#vrib2.select = True
#vrib3.select = True
#bpy.ops.object.join()


if False:
# do the vents
    bfs.deleteObjectNamed('vent2')
    bfs.deleteObjectNamed('vent3')
    bfs.deleteObjectNamed('vent4')

    vent = bfs.selectByName('vent')
    bpy.ops.object.duplicate()
    vent2 = bfs.selectActivate(bfs.getSelected()[0])
    vent2.name = 'vent2'
    vent2.location.z = 10
    
    bpy.ops.object.duplicate()
    vent3 = bfs.selectActivate(bfs.getSelected()[0])
    vent3.name = 'vent3'
    vent3.location.x *= -1
    vent3.rotation_euler[2] = bfs.toRad(180)
    
    bfs.selectActivate(vent)
    bpy.ops.object.duplicate()
    vent4 = bfs.selectActivate(bfs.getSelected()[0])
    vent4.name = 'vent4'
    vent4.location.x *= -1
    vent4.rotation_euler[2] = bfs.toRad(180)

if False:
# do the crane track
    bfs.deleteObjectNamed('crane track2')
    t2 = bfs.selectByName('crane track')
    bpy.ops.object.duplicate()
    t2 = bfs.selectActivate(bfs.getSelected()[0])
    t2.name = 'crane track2'
    t2.location.x *= -1
    t2.rotation_euler[2] = bfs.toRad(180)

if False:
# replicate the crane
    bfs.deleteObjectNamed('crane2')
    o = bfs.selectByName('crane')
    bpy.ops.object.duplicate()
    o = bfs.selectActivate(bfs.getSelected()[0])
    o.name = 'crane2'
    o.location.y = 64
    o.rotation_euler[2] = bfs.toRad(180)
    

if False:
# replicate the stands.  Requires reassigning the textures.

# stand coordinates
    stand_coords = [ 
        8.91577,  70, # bottom
        8.91577,  70, # top
        -7.03628, 28.27019, # bottom
        -7.03628, 28.27019, # top
        -7.03628, 54, # bottom
        -7.03628, 54, # top
    ]
    
    stand_names = [
        "stand bottom2",
        "stand top2",
        "stand bottom3",
        "stand top3",
        "stand bottom4",
        "stand top4",
    ]
    
    
    for i in stand_names:
        bfs.deleteObjectNamed(i)
    
# the parent of all the stands
    stands = bfs.findObject('stands')
    
# The master stand
    t1 = bfs.selectByName('stand top')
    b1 = bfs.selectByName('stand bottom')
    
    
    for i in range(0, 3):
        bfs.selectActivate(t1)
        bpy.ops.object.duplicate()
        t2 = bfs.selectActivate(bfs.getSelected()[0])
        t2.name = stand_names[i * 2 + 1]
        t2.location.x = stand_coords[i * 4 + 2]
        t2.location.y = stand_coords[i * 4 + 3]
        # reparent
        stands.select = True
        bpy.context.scene.objects.active = stands
        bpy.ops.object.parent_set()

        bfs.selectActivate(b1)
        bpy.ops.object.duplicate()
        b2 = bfs.selectActivate(bfs.getSelected()[0])
        b2.name = stand_names[i * 2]
        b2.location.x = stand_coords[i * 4]
        b2.location.y = stand_coords[i * 4 + 1]
        # reparent
        stands.select = True
        bpy.context.scene.objects.active = stands
        bpy.ops.object.parent_set()


if False:
# do the VRIBS
    for i in range(0, TOTAL_VRIBS):
        bfs.deleteObjectNamed(VRIB_PREFIX + str(i))

# the parent of all the vribs
    vribs = bfs.findObject('vribs')

# The master vrib
    vrib = bfs.selectByName('vrib')
    vrib.hide = False

    for i in range(0, TOTAL_VRIBS):
# replicate
        bfs.selectActivate(vrib)
        bpy.ops.object.duplicate()
        vrib1 = bfs.selectActivate(bfs.getSelected()[0])
        vrib1.name = VRIB_PREFIX + str(i)
        vrib1.location.y = i * LENGTH / (TOTAL_VRIBS - 1)
        vribs.select = True
        bpy.context.scene.objects.active = vribs
        bpy.ops.object.parent_set()

    vrib.hide = True




if True:
# do the crane ribs
    for i in range(0, TOTAL_CRANE_RIBS):
        bfs.deleteObjectNamed(CRANE_RIB_PREFIX + str(i))

# the parent of all the vribs
    ribs = bfs.findObject('crane ribs')

# The master vrib
    rib = bfs.selectByName('crane_rib')
    rib.hide = False
    y0 = rib.location.y

    for i in range(0, TOTAL_VRIBS):
# compute new Y
        y = y0 + i * LENGTH / (TOTAL_VRIBS - 1)
        
        
# replicate
        bfs.selectActivate(rib)
        bpy.ops.object.duplicate()
        rib1 = bfs.selectActivate(bfs.getSelected()[0])
        rib1.name = CRANE_RIB_PREFIX + str(i * 2)
        rib1.location.y = y
        ribs.select = True
        bpy.context.scene.objects.active = ribs
        bpy.ops.object.parent_set()
        
        bfs.selectActivate(rib1)
        bpy.ops.object.duplicate()
        rib1 = bfs.selectActivate(bfs.getSelected()[0])
        rib1.name = CRANE_RIB_PREFIX + str(i * 2 + 1)
        rib1.location.x *= -1
        rib1.rotation_euler[2] = bfs.toRad(180)
        ribs.select = True
        bpy.context.scene.objects.active = ribs
        bpy.ops.object.parent_set()



    rib.hide = True



if False:
# do the lights
    for i in range(0, TOTAL_LIGHTS):
        bfs.deleteObjectNamed(LIGHT_PREFIX + str(i))
        bfs.deleteObjectNamed(LIGHT_LEG_PREFIX + str(i))



# the parent of all the lights
    lights = bfs.findObject('lights')
    light = bfs.selectByName('light')
# master light object to be copied
    light.hide = False
    light_leg = bfs.selectByName('light_leg')
    light_leg.hide = False
    

    for i in range(0, TOTAL_LIGHTS):
        x = (i % LIGHT_COLUMNS) * WIDTH / LIGHT_COLUMNS - WIDTH / 2 + 3.2
        y = int(i / LIGHT_COLUMNS) * LENGTH / LIGHT_ROWS + 3.2
        bfs.selectActivate(light)
        bpy.ops.object.duplicate()
        light2 = bfs.selectActivate(bfs.getSelected()[0])
        light2.name = LIGHT_PREFIX + str(i)
        light2.location.x = x
        light2.location.y = y
        lights.select = True
        bpy.context.scene.objects.active = lights
        bpy.ops.object.parent_set()

        bfs.selectActivate(light_leg)
        bpy.ops.object.duplicate()
        light_leg2 = bfs.selectActivate(bfs.getSelected()[0])
        light_leg2.name = LIGHT_LEG_PREFIX + str(i)
        light_leg2.location.x = x
        light_leg2.location.y = y
        lights.select = True
        bpy.context.scene.objects.active = lights
        bpy.ops.object.parent_set()

    light.hide = True
    light_leg.hide = True



# now the H ribs
#hrib = bfs.selectByName('hrib')
#bpy.ops.object.duplicate()

#left_hrib = bfs.selectActivate(bfs.getSelected()[0])
#bpy.ops.object.duplicate()

# mirror it
#right_hrib = bfs.selectActivate(bfs.getSelected()[0])
#right_hrib.location.x *= -1

#for i in range(1, TOTAL_HRIBS):
#    left_hrib.name = HRIB_PREFIX + str(i)
#    right_hrib.name = HRIB_PREFIX + str(TOTAL_HRIBS + i)

#    if i < TOTAL_HRIBS - 1:
#        bfs.selectActivate(left_hrib)
#        bpy.ops.object.duplicate()
#        left_hrib = bfs.selectActivate(bfs.getSelected()[0])
#        bpy.ops.transform.translate(value=(0, 0, HEIGHT / (TOTAL_HRIBS - 2)))
    
#        bfs.selectActivate(right_hrib)
#        bpy.ops.object.duplicate()
#        right_hrib = bfs.selectActivate(bfs.getSelected()[0])
#        bpy.ops.transform.translate(value=(0, 0, HEIGHT / (TOTAL_HRIBS - 2)))






