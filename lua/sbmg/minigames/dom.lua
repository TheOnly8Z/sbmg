MINIGAME.PrintName = "#sbmg.dom.name"
MINIGAME.Description = "#sbmg.dom.desc"
MINIGAME.ShortName = "DOM"
MINIGAME.Icon = "icon16/transmit.png"
MINIGAME.SortOrder = 5

function MINIGAME:GetBannerText()
    return string.format(language.GetPhrase("sbmg.banner"), SBMG.ActiveGame.Options["score_to_win"])
end

MINIGAME.TeamScores = true
MINIGAME.MinTeams = 2
MINIGAME.MinPlayers = 2
MINIGAME.MinEnts = {
    ["sbmg_point"] = 1, -- Negative means X per team
}

MINIGAME.Options = {
    ["time"] = {type = "i", min = 60, default = 600},
    ["score_to_win"] = {type = "i", min = 1, default = 300},
    ["tp_on_start"] = {type = "b", default = true},
    ["auto_cap"] = {type = "b", default = false},
    ["clear_cap"] = {type = "b", default = true},
    ["show_radius"] = {type = "b", default = true},
}

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
    if SBMG:GetGameOption("clear_cap") then
        for _, ent in pairs(ents.FindByClass("sbmg_point")) do
            ent:SetTeam(TEAM_UNASSIGNED)
            ent:SetCapTeam(0)
            ent:SetCapProgress(0)
        end
    end
end

function MINIGAME:Think()
    if (SBMG.NextThink or 0) < CurTime() then
        SBMG.NextThink = CurTime() + 1
        local add = {}
        for _, ent in pairs(ents.FindByClass("sbmg_point")) do
            if ent:GetTeam() ~= TEAM_UNASSIGNED and SBMG.TeamScore[ent:GetTeam()] then
                add[ent:GetTeam()] = (add[ent:GetTeam()] or 0) + 1
            end
        end
        for k, v in pairs(add) do SBMG:AddScore(k, v)
            if SBMG.TeamScore[k] >= SBMG:GetGameOption("score_to_win") then
                SBMG:MinigameEnd(k)
            end
        end
    end
end

function MINIGAME:Timeout()
    return SBMG:Timeout_TeamScore()
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
        if ply == attacker then
            SBMG:AddScore(attacker, -1)
        elseif ply:Team() == attacker:Team() then
            SBMG:AddScore(attacker, -1)
        elseif ply ~= attacker and ply:Team() ~= attacker:Team() then
            SBMG:AddScore(attacker, 1)
        end
    end
end
--MINIGAME.Hooks.PreDrawOutlines = function() SBMG:Hook_Outlines_All("sbmg_point") end