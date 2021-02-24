local announcer_sound

function SBMG:PlayAnnouncerSound(snd)
    if not GetConVar("cl_sbmg_ann_disabled"):GetBool() and snd then
        if GetConVar("developer"):GetBool() then print("[SBMG] Playing announcer line '" .. snd .. "'") end
        if announcer_sound then
            announcer_sound:Stop()
        end
        announcer_sound = CreateSound(LocalPlayer(), snd)
        announcer_sound:SetSoundLevel(0)
        announcer_sound:PlayEx(GetConVar("cl_sbmg_ann_volume"):GetFloat(), 100)
    end
end

function SBMG:PlayAnnouncerCountdown(time)
    local ann
    if GetConVar("sbmg_ann_enforce"):GetBool() or GetConVar("cl_sbmg_ann_name"):GetString() == "" then
        ann = GetConVar("sbmg_ann_name"):GetString()
    elseif CLIENT then
        ann = GetConVar("cl_sbmg_ann_name"):GetString()
    end
    local tbl = SBMG.Announcers[ann].GenericLines -- TODO make minigame-specific countdown a thing?
    if not tbl or not tbl.EndCountdown or not tbl.EndCountdown[time] then return false end

    local snd = istable(tbl.EndCountdown[time]) and tbl.EndCountdown[time][math.random(1, #tbl.EndCountdown[time])] or tbl.EndCountdown[time]
    if snd then
        SBMG:PlayAnnouncerSound(snd)
        return true
    end
end

net.Receive("SBMG_Announce", function()
    local snd
    if GetConVar("sbmg_ann_enforce"):GetBool() then
        snd = net.ReadString()
        SBMG:PlayAnnouncerSound(snd)
    else
        local ann = GetConVar("cl_sbmg_ann_name"):GetString()
        if ann == "" then ann = GetConVar("sbmg_ann_name"):GetString() end
        local name = net.ReadString()
        local subname = net.ReadString()
        local force_generic = net.ReadBool()
        snd = SBMG:GetAnnouncerSound(ann, name, subname, force_generic)
        SBMG:PlayAnnouncerSound(snd)
    end
end)
