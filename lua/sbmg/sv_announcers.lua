function SBMG:SendAnnouncer(players, name, subname, force_generic)
    if GetConVar("sbmg_ann_enforce"):GetBool() then
        local snd = SBMG:GetAnnouncerSound(GetConVar("sbmg_ann_name"):GetString(), name, subname, force_generic)
        if snd then
            net.Start("SBMG_Announce")
                net.WriteString(snd)
            net.Send(players)
        end
    else
        net.Start("SBMG_Announce")
            net.WriteString(name)
            net.WriteString(subname or "")
            net.WriteBool(force_generic)
        net.Send(players)
    end
end

function SBMG:BroadcastAnnouncer(name, subname, force_generic)
    SBMG:SendAnnouncer(player.GetAll(), name, subname, force_generic)
end

function SBMG:SendTeamAnnouncer(t, name, subname, force_generic)
    SBMG:SendAnnouncer(team.GetPlayers(t), name, subname, force_generic)
end

function SBMG:SeparateTeamAnnouncer(t, name, others_name)
    local others = {}
    local ours = {}
    for _, p in pairs(player.GetAll()) do
        if p:Team() ~= t then table.insert(others, p) else table.insert(ours, p) end
    end
    SBMG:SendAnnouncer(ours, name)
    SBMG:SendAnnouncer(others, others_name)
end