MINIGAME.PrintName = "#sbmg.br.name"
MINIGAME.Description = "#sbmg.br.desc"
MINIGAME.ShortName = "BR"
MINIGAME.Icon = "icon16/user_delete.png"
MINIGAME.SortOrder = 3

function MINIGAME:GetBannerText()
    return nil
end

MINIGAME.TeamScores = false
MINIGAME.MinTeams = 1
MINIGAME.MaxTeams = 1
MINIGAME.MinPlayers = 2

MINIGAME.Options = {
    ["time"] = {type = "i", min = 10, default = 300},
}

MINIGAME.Tags = SBMG_TAG_FORCE_FRIENDLY_FIRE + SBMG_TAG_UNASSIGN_ON_DEATH

function MINIGAME:GetParticipants()
    return team.GetPlayers(SBTM_RED), {SBTM_RED}
end

function MINIGAME:GameStart()
end

function MINIGAME:Think()
    if SERVER then
        local plys = team.GetPlayers(SBTM_RED)
        if table.Count(plys) == 0 then
            SBMG:MinigameEnd(nil)
        elseif table.Count(plys) == 1 then
            SBMG:MinigameEnd(plys[1])
        end
    end
end

function MINIGAME:Timeout()
    return nil
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
        SBMG:AddScore(attacker, 1)
    end
end
