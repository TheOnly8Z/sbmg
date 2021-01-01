
hook.Add("SetupMove", "SBMG", function(ply, mv, cmd)
    local s = SBMG:GetGameOption("flag_slowdown")
    if ply:HasWeapon("sbmg_flagwep") and s then
        local basespd = (Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length()
        basespd = math.min(basespd, mv:GetMaxClientSpeed())
        mv:SetMaxSpeed(basespd * s)
        mv:SetMaxClientSpeed(basespd * s)
    end
end)