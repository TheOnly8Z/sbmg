
hook.Add("SetupMove", "SBMG", function(ply, mv, cmd)

    local pregame_time = SBMG:GetGameOption("pregame_time")
    if (pregame_time or 0) > 0 and SBMG.ActiveGame.StartTime > CurTime() then
        mv:SetMaxSpeed(0.01)
        mv:SetMaxClientSpeed(0.01)
        cmd:SetForwardMove(0)
        cmd:SetUpMove(0)
        cmd:SetSideMove(0)
        local banned_keys = {IN_ATTACK, IN_ATTACK2, IN_SPEED, IN_WALK, IN_USE, IN_JUMP}
        for _, k in pairs(banned_keys) do
            if mv:KeyDown(k) then mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(k))) end
        end
    end

    local s = SBMG:GetGameOption("flag_slowdown")
    if ply:HasWeapon("sbmg_flagwep") and s then
        local basespd = (Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length()
        basespd = math.min(basespd, mv:GetMaxClientSpeed())
        mv:SetMaxSpeed(basespd * s)
        mv:SetMaxClientSpeed(basespd * s)
    end

    local bomb = ply:GetWeapon("sbmg_bombwep")
    if IsValid(bomb) and bomb:GetPlanting() > 0 then
        mv:SetMaxSpeed(0.00001)
        mv:SetMaxClientSpeed(0.00001)
    end
end)