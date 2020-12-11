MINIGAME.PrintName = "#sbmg.elim.name"
MINIGAME.Description = "#sbmg.elim.desc"
MINIGAME.ShortName = "ELIM"
MINIGAME.Icon = "icon16/group_delete.png"
MINIGAME.SortOrder = 4

function MINIGAME:GetBannerText()
    return nil
end

MINIGAME.TeamScores = true
MINIGAME.MinTeams = 2
MINIGAME.MinPlayers = 2

MINIGAME.Options = {
    ["time"] = {type = "i", min = 10, default = 300},
    ["tp_on_start"] = {type = "b", default = true},
}

MINIGAME.Tags = SBMG_TAG_UNASSIGN_ON_DEATH

function MINIGAME:GetParticipants()
    local plys = {}
    local teams = {}
    for _, p in pairs(player.GetAll()) do
        if p:Team() >= SBTM_RED and p:Team() <= SBTM_YEL then
            table.insert(plys, p)
            if not table.HasValue(teams, p:Team()) then
                table.insert(teams, p:Team())
            end
        end
    end
    return plys, teams
end

function MINIGAME:GameStart()
    for t, _ in pairs(SBMG.TeamScore) do
        SBMG.TeamScore[t] = team.NumPlayers(t)
    end
    for p, s in pairs(SBMG.ActivePlayers) do
        p.OrigTeam = p:Team()
    end
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
    local winner = nil
    local tie = false
    for t, s in pairs(SBMG.TeamScore) do
        if not winner then
            winner = t
            max = team.NumPlayers(t)
        elseif team.NumPlayers(t) > team.NumPlayers(winner) then
            winner = t
            tie = false
        elseif team.NumPlayers(t) == team.NumPlayers(winner) then
            tie = true
        end
    end
    return tie and false or winner
end

function MINIGAME:GameEnd(winner)
    if SERVER then
        if winner then
            PrintMessage(HUD_PRINTTALK, "The winner is: " .. team.GetName(winner) .. "!")
        else
            PrintMessage(HUD_PRINTTALK, "It's a tie!")
        end
        for _, p in pairs(player.GetAll()) do
            if p.OrigTeam then p:SetTeam(p.OrigTeam) end
        end
    end
    for _, p in pairs(player.GetAll()) do
        p.OrigTeam = nil
    end
end

function MINIGAME:PlayerLeave(ply, oldTeam)
    SBMG:AddScore(oldTeam, -1)
end

function MINIGAME:PlayerJoin(ply, oldTeam)
    SBMG:AddScore(ply:Team(), 1)
end

MINIGAME.Hooks = {}
MINIGAME.Hooks.PlayerDeath = function(ply, inflictor, attacker)
    if SBMG.ActivePlayers[ply] and SBMG.ActivePlayers[attacker] and ply:Team() ~= TEAM_UNASSIGNED then
        SBMG:AddScore(attacker, ply:Team() == attacker:Team() and -1 or 1)
        SBMG:AddScore(ply:Team(), -1)
    end
end