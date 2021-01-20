local function add_announcers(cb)
    for k, v in pairs(SBMG.Announcers) do
        cb:AddChoice(v.PrintName or k, k)
    end
end

hook.Add("PopulateToolMenu", "SBMG", function()
    spawnmenu.AddToolMenuOption("Utilities", "Admin", "SBMG_Server", "#sbmg.title.short", "", "", function(pnl)
        pnl:Help("#sbmg.menuhelp")
        pnl:Help("")
        pnl:Help("#sbtm.authorhelp")
        pnl:Help("")
    end)

    spawnmenu.AddToolMenuOption("Utilities", "User", "SBMG_Client", "#sbmg.title.short", "", "", function(pnl)
        pnl:Help("#sbmg.menuhelp")

        local combobox = pnl:ComboBox("#sbmg.cvar.cl.obj_outline", "cl_sbmg_obj_outline")
        combobox:AddChoice("#sbmg.cvar.cl.obj_outline.0", 0)
        combobox:AddChoice("#sbmg.cvar.cl.obj_outline.1", 1)
        combobox:AddChoice("#sbmg.cvar.cl.obj_outline.2", 2)

        local combobox2 = pnl:ComboBox("#sbmg.cvar.cl.obj_outline_mode", "cl_sbmg_obj_outline_mode")
        combobox2:AddChoice("#sbmg.cvar.cl.obj_outline_mode.0", 0)
        combobox2:AddChoice("#sbmg.cvar.cl.obj_outline_mode.1", 1)
        combobox2:AddChoice("#sbmg.cvar.cl.obj_outline_mode.2", 2)
        combobox2:AddChoice("#sbmg.cvar.cl.obj_outline_mode.3", 3)

        pnl:Help("")
        pnl:CheckBox("#sbmg.cvar.cl.ann_disabled", "cl_sbmg_ann_disabled")

        local combobox3 = pnl:ComboBox("#sbmg.cvar.cl.ann_name", "cl_sbmg_ann_name")
        cb:AddChoice("#sbmg.announcers.no_pref", "")
        add_announcers(combobox3)
        pnl:ControlHelp("#sbmg.cvar.cl.ann_name.desc")

        pnl:NumSlider("#sbmg.cvar.cl.ann_volume", "cl_sbmg_ann_volume", 0, 1, 2)

        pnl:Help("")
        pnl:Help("#sbtm.authorhelp")
        pnl:Help("")
    end)
end)