if game.SinglePlayer() then return end

AddCSLuaFile()

SBMG = SBMG or {}

SBMG_NET_MODE_START = 0
SBMG_NET_MODE_END = 1
SBMG_NET_MODE_INTERRUPT = 2
SBMG_NET_MODE_TIE = 3
SBMG_NET_MODE_BITS = 2

-- Override SBTM's no friendly fire option (for FFA games where everyone is on one team but isn't allied)
-- This also disables team outlines
SBMG_TAG_FORCE_FRIENDLY_FIRE = 1
-- Override SBTM's unassign on death option
SBMG_TAG_UNASSIGN_ON_DEATH = 2
-- Skip neutral when capturing points (for Attack/Defend etc.)
SBMG_TAG_DIRECT_CAPTURE_POINT = 4

-- Stores all minigames
SBMG.Minigames = SBMG.Minigames or {}

SBMG.ActiveGame = SBMG.ActiveGame or {
    -- Internal name of the game
    Name = nil,
    -- CurTime() of when the game started
    StartTime = 0,
    -- Options used to activate the game
    Options = {},
    -- Other stuff can be stored here
}

SBMG.ActivePlayers = SBMG.ActivePlayers or {
    --[Player] = Score
}

SBMG.TeamScore = {}

SBMG.Announcers = SBMG.Announcers or {}
SBMG.ActiveAnnouncer = nil

SBMG.BaseMinigameOptions = {
    ["time"] = {type = "i", min = 60, default = 120},
    ["pregame_time"] = {type = "i", min = 0, default = 10},
    ["tp_on_start"] = {type = "b", default = true},
}

function SBMG:Load()
    -- Lua Files
    for _, v in pairs(file.Find("sbmg/*", "LUA")) do
        if string.Left(v, 3) == "cl_" then
            AddCSLuaFile("sbmg/" .. v)
            if CLIENT then
                include("sbmg/" .. v)
            end
        elseif string.Left(v, 3) == "sv_" and (SERVER or game.SinglePlayer()) then
            include("sbmg/" .. v)
        elseif string.Left(v, 3) == "sh_" then
            include("sbmg/" .. v)
            AddCSLuaFile("sbmg/" .. v)
        end
    end

    -- Minigame definitions
    for _, v in pairs(file.Find("sbmg/minigames/*", "LUA")) do
        MINIGAME = {}
        AddCSLuaFile("sbmg/minigames/" .. v)
        include("sbmg/minigames/" .. v)
        local name = string.Explode(".", v)[1]
        if MINIGAME.Ignore then continue end
        if not MINIGAME.DoNotInherit then
            --MINIGAME.Options = table.Inherit(MINIGAME.Options, SBMG.BaseMinigameOptions)
            for k, l in pairs(SBMG.BaseMinigameOptions) do -- table.Inherit is evil and we must steer clear
                if not MINIGAME.Options[k] then
                    MINIGAME.Options[k] = l
                end
            end
        end
        MINIGAME.SortOrder = MINIGAME.SortOrder or 0
        SBMG.Minigames[name] = MINIGAME
        print("[SBMG] Loaded minigame '" .. name .. "'.")
    end

    -- Announcer definitions
    for _, v in pairs(file.Find("sbmg/announcers/*", "LUA")) do
        ANNOUNCER = {}
        AddCSLuaFile("sbmg/announcers/" .. v)
        include("sbmg/announcers/" .. v)
        local name = string.Explode(".", v)[1]
        SBMG.Announcers[name] = ANNOUNCER
        SBMG.Announcers[name].SortOrder = SBMG.Announcers[name].SortOrder or 0
        print("[SBMG] Loaded announcer '" .. name .. "'.")
    end
end
SBMG:Load()

concommand.Add("sbmg_reload", function(ply)
    if not IsValid(ply) or ply:IsAdmin() then
        SBMG:Load()
        if IsValid(ply) and ply:IsListenServerHost() then
            ply:SendLua("SBMG:Load()")
        end
    end
end)