if game.SinglePlayer() then return end

AddCSLuaFile()

SBMG = SBMG or {}

SBMG_NET_MODE_START = 0
SBMG_NET_MODE_END = 1
SBMG_NET_MODE_INTERRUPT = 2
SBMG_NET_MODE_TIMEOUT = 3
SBMG_NET_MODE_BITS = 2

-- Override SBTM's no friendly fire option
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

function SBMG:Load()
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

    for _, v in pairs(file.Find("sbmg/minigames/*", "LUA")) do
        MINIGAME = {}
        AddCSLuaFile("sbmg/minigames/" .. v)
        include("sbmg/minigames/" .. v)
        local name = string.Explode(".", v)[1]
        SBMG.Minigames[name] = MINIGAME
        SBMG.Minigames[name].SortOrder = SBMG.Minigames[name].SortOrder or 0
        print("[SBMG] Loaded minigame '" .. name .. "'.")
    end
end
SBMG:Load()

concommand.Add("sbmg_reload", function(ply)
    if not IsValid(ply) or ply:IsAdmin() then
        SBMG:Load()
    end
end)