MINIGAME.PrintName = "#sbmg.ctf.name"
MINIGAME.Description = "#sbmg.ctf.desc"
MINIGAME.ShortName = "CTF"
MINIGAME.Icon = "icon16/flag_red.png"
MINIGAME.SortOrder = 8

function MINIGAME:GetBannerText()
    return string.format(language.GetPhrase("sbmg.banner"), SBMG.ActiveGame.Options["score_to_win"])
end

MINIGAME.TeamScores = true
MINIGAME.MinTeams = 2
MINIGAME.MinPlayers = 2
MINIGAME.MinEnts = {
    ["sbmg_flagpole"] = -1, -- Negative means X per team
}

MINIGAME.Options = {
    ["time"] = {type = "i", min = 60, default = 600},
    ["score_to_win"] = {type = "i", min = 1, default = 3},
    ["tp_on_start"] = {type = "b", default = true},
    ["flag_return_touch"] = {type = "b", default = true},
    ["flag_return_time"] = {type = "i", min = 1, default = 60},
    ["flag_cap_need"] = {type = "b", default = false},
    ["flag_hold"] = {type = "b", default = true},
    ["flag_slowdown"] = {type = "f", min = 0, max = 1, default = 0.75},
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

function MINIGAME:CanStart()
    if GetConVar("sv_manualweaponpickup") then -- if the convar exists, it is installed
        return false, "sbmg.manual_weapon_pickup"
    end
end

function MINIGAME:GameStart()
    if SERVER then
        for _, ent in pairs(ents.FindByClass("sbmg_flagpole")) do
            ent:ForceReturnFlag()
        end
    end
end

--[[]
function MINIGAME:Think()
end
]]

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
MINIGAME.Hooks.SBMG_FlagCaptured = function(ply, stand, flag_team)
    SBMG:AddScore(ply, 1)
    SBMG:AddScore(ply:Team(), 1)
    if SBMG.TeamScore[ply:Team()] >= SBMG:GetGameOption("score_to_win") then
        SBMG:MinigameEnd(ply:Team())
    else
        SBMG:SendTeamAnnouncer(ply:Team(), "TheirFlagCaptured")
        SBMG:SendTeamAnnouncer(flag_team, "OurFlagCaptured")
    end
end
--[[]
MINIGAME.Hooks.PreDrawOutlines = function()
    SBMG:Hook_Outlines_All("sbmg_flag")
    SBMG:Hook_Outlines_All("sbmg_flagpole")
end
]]