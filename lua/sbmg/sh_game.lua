SBMG.LastThink = 0
function SBMG:Think()
    local tbl = SBMG:GetCurrentGameTable()
    if tbl then
        local t = SBMG:GetGameOption("time")
        local te = CurTime() - SBMG.ActiveGame.StartTime -- time elapsed
        if (t or 0) > 0 and te > t then
            -- SBMG:MinigameEnd() will broadcast to client, so we don't call it clientside here
            if SERVER then SBMG:MinigameEnd(tbl.Timeout and tbl:Timeout() or nil) end
        else
            if tbl.Think then
                tbl:Think()
            end
            -- Handle announcer countdown entirely clientside
            if CLIENT then
                local tr = t - te -- time remaining
                local ta = math.ceil(tr) -- time of announcer
                local et = SBMG.ActiveGame.StartTime + t -- end time
                if ta <= et - SBMG.LastThink and ta > et - CurTime() then
                    -- Play the voiceline *once*, only when the whole second happened on or during the tick
                    SBMG:PlayAnnouncerCountdown(ta)
                end
            end
        end
    end
    SBMG.LastThink = CurTime()
end
hook.Add("Think", "SBMG", SBMG.Think)