local announcer_sound
local annsound_end = 0
function SBMG:PlayAnnouncerSound(snd, no_override)
    if not GetConVar("cl_sbmg_ann_disabled"):GetBool() and snd then
        if GetConVar("developer"):GetBool() then print("[SBMG] Playing announcer line '" .. snd .. "'") end
        if announcer_sound and no_override and annsound_end > CurTime() then print(announcer_sound) return end
        if announcer_sound then announcer_sound:Stop() end
        announcer_sound = CreateSound(LocalPlayer(), snd)
        announcer_sound:SetSoundLevel(0)
        announcer_sound:PlayEx(GetConVar("cl_sbmg_ann_volume"):GetFloat(), 100)
        annsound_end = CurTime() + SoundDuration(snd)
    end
end

function SBMG:PlayAnnouncerCountdown(time, pregame)
    local ann
    if GetConVar("sbmg_ann_enforce"):GetBool() or GetConVar("cl_sbmg_ann_name"):GetString() == "" then
        ann = GetConVar("sbmg_ann_name"):GetString()
    elseif CLIENT then
        ann = GetConVar("cl_sbmg_ann_name"):GetString()
    end

    local tbl = SBMG.Announcers[ann].GenericLines -- TODO make minigame-specific countdown a thing?
    if not pregame and (not tbl or not tbl.EndCountdown or not tbl.EndCountdown[time]) then return false end
    if pregame and (not tbl or not tbl.PregameCountdown or not tbl.PregameCountdown[time]) then return false end

    local t2 = pregame and tbl.PregameCountdown or tbl.EndCountdown

    local snd = istable(t2[time]) and t2[time][math.random(1, #t2[time])] or t2[time]
    if snd then
        SBMG:PlayAnnouncerSound(snd, true)
        return true
    end
end

net.Receive("SBMG_Announce", function()
    local snd
    if GetConVar("sbmg_ann_enforce"):GetBool() then
        snd = net.ReadString()
        SBMG:PlayAnnouncerSound(snd)
    else
        local name = net.ReadString()
        local subname = net.ReadString()
        local force_generic = net.ReadBool()
        SBMG:PlayAnnouncerSound(SBMG:GetAnnouncerSound(name, subname, force_generic))
    end
end)
