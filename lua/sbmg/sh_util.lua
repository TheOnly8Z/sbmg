
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