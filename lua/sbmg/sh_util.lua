
function SBMG:GetActiveGame()
    return SBMG.ActiveGame.Name
end

function SBMG:GetCurrentGameTable()
    return SBMG.ActiveGame.Name and SBMG.Minigames[SBMG.ActiveGame.Name]
end

function SBMG:GetGameOption(opt)
    return SBMG.ActiveGame.Name and SBMG.ActiveGame.Options[opt]
end

function SBMG:GameHasTag(tag)
    local tbl = SBMG:GetCurrentGameTable()
    if not tbl then return false end
    return bit.band(tbl.Tags or 0, tag) == tag
end

function SBMG:GetEntCount(class, c, teams)
    local perTeam = (c < 0)
    c = math.abs(c)
    local enttbl = ents.FindByClass(class)
    if perTeam then
        local team_count = {}
        for _, t in pairs(teams) do
            team_count[t] = 0
        end
        for _, e in pairs(enttbl) do
            if team_count[e:GetTeam()] then
                team_count[e:GetTeam()] = team_count[e:GetTeam()] + 1
            end
        end
        local not_enough = nil
        for t, tc in pairs(team_count) do
            if tc < c then
                not_enough = t
                break
            end
        end
        if not_enough then
            return false, team_count, not_enough
        else
            return true, team_count
        end
    else
        return table.Count(enttbl) >= c, table.Count(enttbl)
    end
end

local function get_sound(def)
    if istable(def) then
        return def[math.random(1, #def)]
    elseif isstring(def) then
        return def
    end
end

function SBMG:GetAnnouncer()
    if SERVER or GetConVar("sbmg_ann_enforce"):GetBool() then
        return GetConVar("sbmg_ann_name"):GetString()
    elseif CLIENT then
        local ann = GetConVar("cl_sbmg_ann_name"):GetString()
        if ann == "" then ann = GetConVar("sbmg_ann_name"):GetString() end
        return ann
    end
end

function SBMG:GetAnnouncerSound(name, subname, force_generic)
    local ann = SBMG:GetAnnouncer()
    if not ann or ann == "" then return false end
    local tbl = SBMG.Announcers[ann]
    if not tbl then return false end
    local snd = nil

    -- Attempt to find a minigame-specific sound first
    local cur_mg_tbl = tbl.MinigameLines and tbl.MinigameLines[SBMG:GetActiveGame()]
    if not force_generic and cur_mg_tbl and cur_mg_tbl[name] ~= nil then
        if cur_mg_tbl[name] == false then
            -- Explicitly do not play any sound. This allows gamemode lines to stop generic lines from playing
            return nil
        elseif isstring(subname) and subname ~= nil and
                istable(cur_mg_tbl[name]) and cur_mg_tbl[name][subname] then
            snd = get_sound(cur_mg_tbl[name][subname])
        else
            snd = get_sound(cur_mg_tbl[name])
        end
    end

    -- If not, resort to finding a generic sound
    if not snd and tbl.GenericLines then
        if isstring(subname) and subname ~= nil and
                istable(tbl.GenericLines[name]) and tbl.GenericLines[name][subname] then
            snd = get_sound(tbl.GenericLines[name][subname])
        else
            snd = get_sound(tbl.GenericLines[name])
        end
    end

    return snd
end

-- Minigame default functions
function SBMG:Timeout_TeamScore()
    local winner = nil
    local tie = false
    for t, s in pairs(SBMG.TeamScore) do
        if not winner then
            winner = t
        elseif SBMG.TeamScore[t] > SBMG.TeamScore[winner] then
            winner = t
            tie = false
        elseif SBMG.TeamScore[t] == SBMG.TeamScore[winner] then
            tie = true
        end
    end
    if tie then
        return false
    else
        return winner
    end
end