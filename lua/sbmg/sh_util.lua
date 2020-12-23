
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