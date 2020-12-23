
function SBMG:MinigameStart(name, options)
    if not SBMG.Minigames[name] then return end
    local plys, teams = SBMG.Minigames[name]:GetParticipants()
    if SBMG.Minigames[name].MinPlayers and table.Count(plys) < SBMG.Minigames[name].MinPlayers then print("[SBMG] Can't start minigame, not enough players") return end
    if SBMG.Minigames[name].MinTeams and table.Count(teams) < SBMG.Minigames[name].MinTeams then print("[SBMG] Can't start minigame, not enough teams") return end
    if SBMG.Minigames[name].MinEnts then
        for v, c in pairs(SBMG.Minigames[name].MinEnts) do
            local can, t, ne = SBMG:GetEntCount(class, c, teams)
            if not can and t and ne then
                print("[SBMG] Can't start minigame, not enough of entity " .. v .. " for " .. team.GetName(ne))
                return
            elseif not can then
                print("[SBMG] Can't start minigame, not enough of entity " .. v)
                return
            end
        end
    end

    SBMG:ValidateOptions(options, name)
    if GetConVar("developer"):GetBool() then PrintTable(options) end

    if SBMG.Minigames[name].CanStart then
        local result = SBMG.Minigames[name]:CanStart(options)
        if result == false then return end
    end

    SBMG.ActiveGame.Name = name
    SBMG.ActiveGame.Options = options
    SBMG.ActiveGame.StartTime = CurTime()
    for _, p in pairs(plys) do SBMG.ActivePlayers[p] = 0 end
    if SBMG.Minigames[name].TeamScores then
        for _, t in pairs(teams) do SBMG.TeamScore[t] = 0 end
    end

    for k, v in pairs(SBMG.Minigames[name].Hooks or {}) do
        hook.Add(k, "SBMG_Minigame", v)
    end

    SBMG.Minigames[name]:GameStart()

    if table.Count(SBTM.Spawns or {}) > 0 and SBMG.ActiveGame.Options["tp_on_start"] then
        local spawns = {}
        for _, e in pairs(SBTM.Spawns) do
                local tr = util.TraceHull({
                    start = e:GetPos(),
                    endpos = e:GetPos(),
                    maxs = Vector(16, 16, 72),
                    mins = Vector(-16, -16, 0),
                    filter = e
                })
                if not tr.Hit then
                    spawns[e:GetTeam()] = spawns[e:GetTeam()] or {}
                    table.insert(spawns[e:GetTeam()], e)
                end
        end
        for ply, _ in pairs(SBMG.ActivePlayers) do
            local teamSpawns = spawns[ply:Team()]
            if teamSpawns and #teamSpawns > 0 then
                local i = math.random(1, #teamSpawns)
                ply:SetPos(teamSpawns[i]:GetPos())
                ply:SetAngles(Angle(0, teamSpawns[i]:GetAngles().y, 0))
                table.remove(teamSpawns, i)
            end
        end
    end

    net.Start("SBMG_Game")
        net.WriteUInt(SBMG_NET_MODE_START, SBMG_NET_MODE_BITS)
        net.WriteString(name)
        net.WriteTable(options)
    net.Broadcast()
end

function SBMG:MinigameEnd(winner)
    local name = SBMG.ActiveGame.Name

    for k, v in pairs(SBMG.Minigames[name].Hooks or {}) do
        hook.Remove(k, "SBMG_Minigame")
    end

    SBMG.Minigames[name]:GameEnd(winner)

    SBMG.ActiveGame.Name = nil
    SBMG.ActiveGame.Options = nil
    SBMG.ActiveGame.StartTime = nil
    SBMG.ActivePlayers = {}
    SBMG.TeamScore = {}

    net.Start("SBMG_Game")
        if winner == false then
            net.WriteUInt(SBMG_NET_MODE_INTERRUPT, SBMG_NET_MODE_BITS)
        elseif winner == nil then
            net.WriteUInt(SBMG_NET_MODE_TIMEOUT, SBMG_NET_MODE_BITS)
        else
            net.WriteUInt(SBMG_NET_MODE_END, SBMG_NET_MODE_BITS)
            local isTeam = not isentity(winner)
            net.WriteBool(isTeam)
            if isTeam then
                net.WriteUInt(winner, 12)
            else
                net.WriteEntity(winner)
            end
        end
    net.Broadcast()
end

function SBMG:Think()
    local tbl = SBMG:GetCurrentGameTable()
    if tbl then
        local t = SBMG:GetGameOption("time")
        if t and SBMG.ActiveGame.StartTime + t <= CurTime() then
            SBMG:MinigameEnd(tbl.Timeout and tbl:Timeout() or nil)
        elseif tbl.Think then
            tbl:Think()
        end
    end
end
hook.Add("Think", "SBMG", SBMG.Think)

function SBMG:AddScore(tgt, amt)
    if isentity(tgt) then
        SBMG.ActivePlayers[tgt] = (SBMG.ActivePlayers[tgt] or 0) + amt
        net.Start("SBMG_Score")
            net.WriteBool(false)
            net.WriteEntity(tgt)
            net.WriteInt(amt, 8)
        net.Broadcast()
    else
        SBMG.TeamScore[tgt] = (SBMG.TeamScore[tgt] or 0) + amt
        net.Start("SBMG_Score")
            net.WriteBool(true)
            net.WriteUInt(tgt, 12)
            net.WriteInt(amt, 8)
        net.Broadcast()
    end
end

function SBMG:ValidateOptions(options, name)
    local orig = SBMG.Minigames[name].Options
    for i, v in pairs(orig) do
        if options[i] == nil then options[i] = v.default end
        if v.type == "i" then
            -- Integer
            options[i] = math.Clamp(math.Round(tonumber(options[i])), orig.min or -math.huge, orig.max or math.huge)
        elseif v.type == "f" then
            -- Float
            options[i] = math.Clamp(tonumber(options[i]), orig.min or -math.huge, orig.max or math.huge)
        elseif v.type == "b" and not isbool(options[i]) then
            -- Bool
            options[i] = tobool(options[i])
        elseif v.type == "s" and not isstring(options[i])  then
            -- String
            options[i] = tostring(options[i])
        end
    end
    return options
end