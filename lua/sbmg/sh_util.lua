
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