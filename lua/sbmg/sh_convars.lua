CreateConVar("sbmg_obj_simple", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If enabled, use simple, vanilla entity models with no collisions for objectives.", 0, 1)
CreateConVar("sbmg_obj_physics", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If enabled, objectives have physics enabled.", 0, 1)

CreateConVar("sbmg_ann_name", "", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Name of the serverside (default) announcer.")
CreateConVar("sbmg_ann_enforce", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If enabled, clients are forced to use the announcer on the server and will always hear the same lines.", 0, 1)
