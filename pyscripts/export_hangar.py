# blender script to export hangar
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



objects = [
    "crane",
    "crane_rib_0",
    "crane_rib_1",
    "crane_rib_2",
    "crane_rib_3",
    "crane_rib_4",
    "crane_rib_5",
    "crane_rib_6",
    "crane_rib_7",
    "crane_rib_8",
    "crane_rib_9",
    "crane_rib_10",
    "crane_rib_11",
    "crane_rib_12",
    "crane_rib_13",
    "crane_rib_14",
    "crane_rib_15",
    "crane_rib_16",
    "crane_rib_17",
    "crane_rib_18",
    "crane_rib_19",
    "crane_rib_20",
    "crane_rib_21",
    "crane_rib_22",
    "crane_rib_23",
    "crane_rib_24",
    "crane_rib_25",
    "crane_rib_26",
    "crane_rib_27",
    "crane_rib_28",
    "crane_rib_29",
    "crane_rib_30",
    "crane_rib_31",
    "crane_rib_32",
    "crane_rib_33",
    "crane_rib_34",
    "crane_rib_35",
    "crane track",
    "crane track2",
    "crane2",
    "duct",
    "floor",
    "light_0",
    "light_1",
    "light_10",
    "light_11",
    "light_12",
    "light_13",
    "light_14",
    "light_15",
    "light_16",
    "light_17",
    "light_18",
    "light_19",
    "light_2",
    "light_20",
    "light_21",
    "light_22",
    "light_23",
    "light_24",
    "light_25",
    "light_26",
    "light_27",
    "light_28",
    "light_29",
    "light_3",
    "light_30",
    "light_31",
    "light_32",
    "light_33",
    "light_34",
    "light_35",
    "light_36",
    "light_37",
    "light_38",
    "light_39",
    "light_4",
    "light_40",
    "light_41",
    "light_42",
    "light_43",
    "light_44",
    "light_45",
    "light_46",
    "light_47",
    "light_48",
    "light_49",
    "light_5",
    "light_50",
    "light_51",
    "light_52",
    "light_53",
    "light_54",
    "light_55",
    "light_56",
    "light_57",
    "light_58",
    "light_59",
    "light_6",
    "light_60",
    "light_61",
    "light_62",
    "light_63",
    "light_64",
    "light_65",
    "light_66",
    "light_67",
    "light_68",
    "light_69",
    "light_7",
    "light_70",
    "light_71",
    "light_72",
    "light_73",
    "light_74",
    "light_75",
    "light_76",
    "light_77",
    "light_78",
    "light_79",
    "light_8",
    "light_80",
    "light_81",
    "light_82",
    "light_83",
    "light_84",
    "light_85",
    "light_86",
    "light_87",
    "light_88",
    "light_89",
    "light_9",
    "light_leg",
    "light_leg_0",
    "light_leg_1",
    "light_leg_10",
    "light_leg_11",
    "light_leg_12",
    "light_leg_13",
    "light_leg_14",
    "light_leg_15",
    "light_leg_16",
    "light_leg_17",
    "light_leg_18",
    "light_leg_19",
    "light_leg_2",
    "light_leg_20",
    "light_leg_21",
    "light_leg_22",
    "light_leg_23",
    "light_leg_24",
    "light_leg_25",
    "light_leg_26",
    "light_leg_27",
    "light_leg_28",
    "light_leg_29",
    "light_leg_3",
    "light_leg_30",
    "light_leg_31",
    "light_leg_32",
    "light_leg_33",
    "light_leg_34",
    "light_leg_35",
    "light_leg_36",
    "light_leg_37",
    "light_leg_38",
    "light_leg_39",
    "light_leg_4",
    "light_leg_40",
    "light_leg_41",
    "light_leg_42",
    "light_leg_43",
    "light_leg_44",
    "light_leg_45",
    "light_leg_46",
    "light_leg_47",
    "light_leg_48",
    "light_leg_49",
    "light_leg_5",
    "light_leg_50",
    "light_leg_51",
    "light_leg_52",
    "light_leg_53",
    "light_leg_54",
    "light_leg_55",
    "light_leg_56",
    "light_leg_57",
    "light_leg_58",
    "light_leg_59",
    "light_leg_6",
    "light_leg_60",
    "light_leg_61",
    "light_leg_62",
    "light_leg_63",
    "light_leg_64",
    "light_leg_65",
    "light_leg_66",
    "light_leg_67",
    "light_leg_68",
    "light_leg_69",
    "light_leg_7",
    "light_leg_70",
    "light_leg_71",
    "light_leg_72",
    "light_leg_73",
    "light_leg_74",
    "light_leg_75",
    "light_leg_76",
    "light_leg_77",
    "light_leg_78",
    "light_leg_79",
    "light_leg_8",
    "light_leg_80",
    "light_leg_81",
    "light_leg_82",
    "light_leg_83",
    "light_leg_84",
    "light_leg_85",
    "light_leg_86",
    "light_leg_87",
    "light_leg_88",
    "light_leg_89",
    "light_leg_9",
    "roof",
    "stand bottom",
    "stand bottom2",
    "stand bottom3",
    "stand bottom4",
    "stand top",
    "stand top2",
    "stand top3",
    "stand top4",
    "vent",
    "vent2",
    "vent3",
    "vent4",
    "vrib_0",
    "vrib_1",
    "vrib_10",
    "vrib_11",
    "vrib_12",
    "vrib_13",
    "vrib_14",
    "vrib_15",
    "vrib_16",
    "vrib_17",
    "vrib_2",
    "vrib_3",
    "vrib_4",
    "vrib_5",
    "vrib_6",
    "vrib_7",
    "vrib_8",
    "vrib_9",
    "walls",
    "walls2",
    "walls3"
]



bfs.selectList(objects)


path = os.path.dirname(bpy.data.filepath) + "/bfs.godot/assets/hangar.dae"


bpy.ops.export_scene.dae(filepath=path, 
    use_mesh_modifiers=True,
    use_export_selected=True,
    use_triangles=True,
    anim_optimize_precision=1)







