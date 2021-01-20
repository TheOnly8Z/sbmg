MINIGAME.PrintName = "#sbmg.raid.name"
MINIGAME.Description = "#sbmg.raid.desc"
MINIGAME.ShortName = "Raid"
MINIGAME.Icon = "icon16/transmit_delete.png"
MINIGAME.SortOrder = 7

function MINIGAME:GetBannerText()
    return string.format(language.GetPhrase("sbmg.banner." .. (LocalPlayer():Team() == SBMG_BLU and "defx" or "capx")), SBMG.ActiveGame.Options["score_to_win"])
end

MINIGAME.TeamScores = true
MINIGAME.MinTeams = 2
MINIGAME.MinPlayers = 2
MINIGAME.MinEnts = {
    ["sbmg_point"] = 1, -- Negative means X per team
}

MINIGAME.Tags = SBMG_TAG_DIRECT_CAPTURE_POINT + SBMG_TAG_UNASSIGN_ON_DEATH

MINIGAME.Options = {
    ["time"] = {type = "i", min = 60, default = 120},
    ["score_to_win"] = {type = "i", min = 1, default = 1},
    ["tp_on_start"] = {type = "b", default = true},
    ["show_radius"] = {type = "b", default = true},
    ["auto_cap"] = {type = "b", default = false},
}

function MINIGAME:GetParticipants()
    local plys = {}
    table.Add(plys, team.GetPlayers(SBTM_RED))
    table.Add(plys, team.GetPlayers(SBTM_BLU))
    return plys, {SBTM_RED, SBTM_BLU}
end

function MINIGAME:GameStart()
    local points = ents.FindByClass("sbmg_point")
    if SERVER then
        for _, ent in pairs(points) do
            ent:SetTeam(SBTM_BLU)
            ent:SetCapTeam(0)
            ent:SetCapProgress(0)
        end
        SBMG:SendTeamAnnouncer(SBTM_RED, "StartAttack")
        SBMG:SendTeamAnnouncer(SBTM_BLU, "StartDefend")
    end
    for p, s in pairs(SBMG.ActivePlayers) do
        p.OrigTeam = p:Team()
    end
    SBMG.TeamScore[SBTM_BLU] = #points
end

function MINIGAME:Think()
    local winner = nil
    for t, s in pairs(SBMG.TeamScore) do
        if team.NumPlayers(t) > 0 then
            if not winner then
                winner = t
            else
                return
            end
        end
    end
    if winner then
        SBMG:MinigameEnd(winner)
    end
end

function MINIGAME:Timeout()
    return SBTM_BLU
end

function MINIGAME:GameEnd(winner)
    if SERVER then
        if winner then
            PrintMessage(HUD_PRINTTALK, "The winner is: " .. team.GetName(winner) .. "!")
        else
            PrintMessage(HUD_PRINTTALK, "It's a tie!")
        end
    end
end

MINIGAME.Hooks = {}
MINIGAME.Hooks.PlayerDeath = function(ply, inflictor, attacker)
    if SBMG.ActivePlayers[ply] and SBMG.ActivePlayers[attacker] and ply:Team() ~= attacker:Team() then
        if ply == attacker or ply:Team() == attacker:Team() then
            SBMG:AddScore(attacker, -1)
        elseif ply ~= attacker and ply:Team() ~= attacker:Team() then
            SBMG:AddScore(attacker, 1)
        end
    end
end
MINIGAME.Hooks.SBMG_CanCapturePoint = function(ent, t, ply)
    if t == SBTM_BLU then return false end
end
MINIGAME.Hooks.SBMG_PointCaptured = function(ent, oldTeam)
    SBMG:AddScore(ent:GetTeam(), 1)
    SBMG:AddScore(oldTeam, -1)
    if SBMG.TeamScore[ent:GetTeam()] >= SBMG:GetGameOption("score_to_win") then
        SBMG:MinigameEnd(ent:GetTeam())
    end
end
--MINIGAME.Hooks.PreDrawOutlines = function() SBMG:Hook_Outlines_All("sbmg_point") end