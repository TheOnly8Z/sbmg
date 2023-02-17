MINIGAME.PrintName = "#sbmg.de.name"
MINIGAME.Description = "#sbmg.de.desc"
MINIGAME.ShortName = "DE"
MINIGAME.Icon = "icon16/bomb.png"
MINIGAME.SortOrder = 10

function MINIGAME:GetBannerText()
    return string.format(language.GetPhrase("sbmg.banner." .. (LocalPlayer():Team() == SBMG_BLU and "defx" or "capx")), SBMG.ActiveGame.Options["score_to_win"])
end

MINIGAME.TeamScores = true
MINIGAME.MinTeams = 2
MINIGAME.MaxTeams = 2
MINIGAME.MinPlayers = 2
MINIGAME.MinEnts = {
    ["sbmg_bombsite"] = 1, -- Negative means X per team
}

MINIGAME.Tags = 0

MINIGAME.Options = {
    ["score_to_win"] = {type = "i", min = 1, default = 1},
}

function MINIGAME:GetParticipants()
    local plys = {}
    table.Add(plys, team.GetPlayers(SBTM_RED))
    table.Add(plys, team.GetPlayers(SBTM_BLU))
    return plys, {SBTM_RED, SBTM_BLU}
end

function MINIGAME:CanStart(options)
    if table.Count(ents.FindByClass("sbmg_bombsite")) < options["score_to_win"] then
        return false, "sbmg.score_over_points"
    end
end

function MINIGAME:GameStart()
    local points = ents.FindByClass("sbmg_bombsite")
    if SERVER then
        SBMG:SendTeamAnnouncer(SBTM_RED, "StartAttack")
        SBMG:SendTeamAnnouncer(SBTM_BLU, "StartDefend")
    end
    SBMG.TeamScore[SBTM_BLU] = #points
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

    for _, e in pairs(ents.FindByClass("sbmg_bomb")) do
        e:Remove()
    end
    for _, p in pairs(player.GetAll()) do
        p:StripWeapon("sbmg_bombwep")
    end
end