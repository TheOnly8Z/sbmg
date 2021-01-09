hook.Add("PlayerInitialSpawn", "SBMG_CompatibilityCheck", function(ply)
    if hook.GetTable().PlayerCanPickupWeapon.ManualWeaponPickup_CanPickup ~= nil then
        ply:PrintMessage(HUD_PRINTTALK, "[SBMG] You have Manual Weapon Pickup installed. SBMG Flag entities and CTF WILL NOT WORK!")
    end
end)

hook.Add("JMod_CanDestroyProp", "SBMG", function(prop, blaster, pos, power, range, ignore)
    print(prop)
    if string.Left(prop:GetClass(), 5) == "sbmg_" then return false end
end)