-- This is an annotated example minigame.

-- Name as displayed on screen and in menus.
-- Recommended to use GMod's localization system: https://wiki.facepunch.com/gmod/Addon_Localization
MINIGAME.PrintName = "#sbmg.ffa.name"

-- Description shown in menu. Keep it short!
MINIGAME.Description = "#sbmg.ffa.desc"

-- An abbreviated name for the minigame. Not used for now.
MINIGAME.ShortName = "FFA"

-- A 16x16 icon for the dropdown menu.
MINIGAME.Icon = "icon16/user.png"

-- How high this game is on the minigame list. Lower number = higher on list
MINIGAME.SortOrder = 1

-- Set to false to enable this minigame.
MINIGAME.Ignore = true

-- Return the subtitle for the HUD element. This usually shows the objective of the minigame, like "100 Kills to win".
-- Remember to call SBMG.ActiveGame.Options to get the configured game value!
function MINIGAME:GetBannerText()
    return string.format(language.GetPhrase("sbmg.banner"), SBMG.ActiveGame.Options["kills_to_win"])
end

-- If set to true, scores will be per team, not per person. If a team wins together, this should be true.
MINIGAME.TeamScores = false

-- Minimum amount of teams (with players in it) to start a game.
MINIGAME.MinTeams = 1

-- Minimum amount of total players to start a game.
MINIGAME.MinPlayers = 2

-- Minimum amount of certain entities to start a game.
-- If using per team counts, the entity MUST have GetTeam() (such as the default SBMG entities).
MINIGAME.MinEnts = {
    ["sbmg_point"] = 1, -- At least one point in the game
    ["sbmg_flagpole"] = -1, -- At least one flagpole *per team* in the game
}

-- A list of options for this minigame.
-- Some options like time and tp on start are in every minigame, and are not listed here.
MINIGAME.Options = {
    ["kills_to_win"] = {type = "i", min = 1, default = 10},
    ["suicide_penalty"] = {type = "b", default = false},
}

-- A list of tags this minigame has, which influences certain behavior.
-- sbmg_init.lua has all available tags as well as what they do.
-- For multiple tags, simply add them together.
MINIGAME.Tags = SBMG_TAG_FORCE_FRIENDLY_FIRE

-- Check which players count as participants.
-- The first value is a table of all players, and the second is a table of all teams.
function MINIGAME:GetParticipants()
    return team.GetPlayers(SBTM_RED), {SBTM_RED}
end

-- Called on game start. SHARED.
function MINIGAME:GameStart()
end

-- Called every tick. SHARED.
function MINIGAME:Think()
end

-- Called when a minigame's time is up.
-- Return false to declare a tie, or a team number to declare a winner.
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

-- Called on game end. SHARED.
-- Winner can be a team number, false (timeout) and nil (cancelled)
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

-- A list of hooks for this minigame.
-- Hooks defined here will be automatically created when the minigame starts and removed when it ends.
-- The list is shared, though adding server hooks on client (and vice versa) obviously does nothing.
-- You probably want to call SBMG:AddScore() here for certain events, like killing someone or capturing a flag.
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
