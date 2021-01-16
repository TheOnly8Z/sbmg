local announcer_sound

net.Receive("SBMG_Announce", function()
    local snd
    if GetConVar("sbmg_ann_enforce"):GetBool() then
        snd = net.ReadString()
    else
        local ann = GetConVar("cl_sbmg_ann_name"):GetString()
        if ann == "" then ann = GetConVar("sbmg_ann_name"):GetString() end
        local name = net.ReadString()
        local subname = net.ReadString()
        local force_generic = net.ReadBool()
        snd = SBMG:GetAnnouncerSound(ann, name, subname, force_generic)
    end

    if not GetConVar("cl_sbmg_ann_disabled"):GetBool() and snd then
        if GetConVar("developer"):GetBool() then print("[SBMG] Playing announcer line '" .. snd .. "'") end
        if announcer_sound then
            announcer_sound:Stop()
        end
        announcer_sound = CreateSound(LocalPlayer(), snd)
        announcer_sound:SetSoundLevel(0)
        announcer_sound:PlayEx(GetConVar("cl_sbmg_ann_volume"):GetFloat(), 100)
    end
end)