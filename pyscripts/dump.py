# print all the object names to a dump.txt

import bpy
import os


path = os.path.dirname(bpy.data.filepath) + '/dump.txt'

print('path=' + path)

f = open(path, "w")

for i in bpy.data.objects:
    print(i.name)
    f.write('\"' + i.name + '\",\n')
    

f.close()


