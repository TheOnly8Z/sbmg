MINIGAME.PrintName = "#sbmg.tdm.name"
MINIGAME.Description = "#sbmg.tdm.desc"
MINIGAME.ShortName = "TDM"
MINIGAME.Icon = "icon16/group.png"
MINIGAME.SortOrder = 2

function MINIGAME:GetBannerText()
    return string.format(language.GetPhrase("sbmg.banner"), SBMG.ActiveGame.Options["kills_to_win"])
end

MINIGAME.TeamScores = true
MINIGAME.MinTeams = 2
MINIGAME.MinPlayers = 2

MINIGAME.Options = {
    ["kills_to_win"] = {type = "i", min = 1, default = 20},
    ["tk_penalty"] = {type = "b", default = false},
    ["suicide_penalty"] = {type = "b", default = false},
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
end

function MINIGAME:Think()
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
        if SBMG:GetGameOption("suicide_penalty") and ply == attacker then
            SBMG:AddScore(attacker, -1)
        elseif SBMG:GetGameOption("tk_penalty") and ply:Team() == attacker:Team() then
            SBMG:AddScore(attacker, -1)
        elseif ply ~= attacker and ply:Team() ~= attacker:Team() then
            SBMG:AddScore(attacker, 1)
            SBMG:AddScore(attacker:Team(), 1)
        end

        if SBMG.TeamScore[attacker:Team()] >= SBMG.ActiveGame.Options["kills_to_win"] then
            SBMG:MinigameEnd(attacker:Team())
        end
    end
end
