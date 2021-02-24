MINIGAME.PrintName = "#sbmg.ffa.name"
MINIGAME.Description = "#sbmg.ffa.desc"
MINIGAME.ShortName = "FFA"
MINIGAME.Icon = "icon16/user.png"
MINIGAME.SortOrder = 1

function MINIGAME:GetBannerText()
    return string.format(language.GetPhrase("sbmg.banner"), SBMG.ActiveGame.Options["kills_to_win"])
end

MINIGAME.TeamScores = false
MINIGAME.MinTeams = 1
MINIGAME.MinPlayers = 2

MINIGAME.Options = {
    ["time"] = {type = "i", min = 10, default = 180},
    ["kills_to_win"] = {type = "i", min = 1, default = 10},
    ["suicide_penalty"] = {type = "b", default = false},
}

MINIGAME.Tags = SBMG_TAG_FORCE_FRIENDLY_FIRE

function MINIGAME:GetParticipants()
    return team.GetPlayers(SBTM_RED), {SBTM_RED}
end

function MINIGAME:GameStart()
end

function MINIGAME:Think()

end

function MINIGAME:Timeout()
    local winner = nil
    local tie = false
    for p, s in pairs(SBMG.ActivePlayers) do
        if not winner then
            winner = p
        elseif s > SBMG.ActivePlayers[winner] then
            winner = p
            tie = false
        elseif s == SBMG.ActivePlayers[winner] then
            tie = true
        end
    end
    return tie and false or winner
end

function MINIGAME:GameEnd(winner)
    if SERVER then
        if winner then
            PrintMessage(HUD_PRINTTALK, "The winner is: " .. winner:GetName() .. "!")
        else
            PrintMessage(HUD_PRINTTALK, "It's a tie!")
        end
    else
        print("winner is " .. tostring(winner))
    end
end

MINIGAME.Hooks = {}
MINIGAME.Hooks.PlayerDeath = function(ply, inflictor, attacker)
    if SBMG.ActivePlayers[ply] and SBMG.ActivePlayers[attacker] then
        if SBMG:GetGameOption("suicide_penalty") and ply == attacker then
            SBMG:AddScore(attacker, -1)
        elseif ply ~= attacker then
            SBMG:AddScore(attacker, 1)
        end
        if SBMG.ActivePlayers[attacker] >= SBMG:GetGameOption("kills_to_win") then
            SBMG:MinigameEnd(attacker)
        end
    end
end
