net.Receive("SBMG_Game", function()
    local mode = net.ReadUInt(SBMG_NET_MODE_BITS)

    if mode == SBMG_NET_MODE_START then
        local name = net.ReadString()
        local options = net.ReadTable()

        SBMG.ActiveGame.Name = name
        SBMG.ActiveGame.Options = options
        SBMG.ActiveGame.StartTime = CurTime() + (options["pregame_time"] or 0)
        local plys, teams = SBMG.Minigames[name]:GetParticipants()
        for _, p in pairs(plys) do SBMG.ActivePlayers[p] = 0 end
        if SBMG.Minigames[name].TeamScores then
            for _, t in pairs(teams) do SBMG.TeamScore[t] = 0 end
        end

        for k, v in pairs(SBMG.Minigames[name].Hooks or {}) do
            hook.Add(k, "SBMG_Minigame", v)
        end

        SBMG.Minigames[name]:GameStart()
    else
        local winner
        if mode == SBMG_NET_MODE_END then
            if net.ReadBool() then
                winner = net.ReadUInt(12)
            else
                winner = net.ReadEntity()
            end
        elseif mode == SBMG_NET_MODE_INTERRUPT then
            winner = false
        elseif mode == SBMG_NET_MODE_TIE then
            winner = nil
        end

        for k, v in pairs(SBMG.Minigames[SBMG.ActiveGame.Name].Hooks or {}) do
            hook.Remove(k, "SBMG_Minigame")
        end

        SBMG.Minigames[SBMG.ActiveGame.Name]:GameEnd(winner)

        SBMG.LastWinTime = CurTime()
        SBMG.LastWinner = winner

        SBMG.ActiveGame.Name = nil
        SBMG.ActiveGame.Options = nil
        SBMG.ActiveGame.StartTime = nil
        SBMG.ActivePlayers = {}
        SBMG.TeamScore = {}
    end
end)

net.Receive("SBMG_Score", function()
    local isTeam = net.ReadBool()
    if isTeam then
        local t = net.ReadUInt(12)
        local amt = net.ReadInt(8)
        SBMG.TeamScore[t] = (SBMG.TeamScore[t] or 0) + amt
    else
        local ply = net.ReadEntity()
        local amt = net.ReadInt(8)
        SBMG.ActivePlayers[ply] = (SBMG.ActivePlayers[ply] or 0) + amt
    end
end)