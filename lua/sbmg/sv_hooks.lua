hook.Add("PlayerInitialSpawn", "SBMG_CompatibilityCheck", function(ply)
    if hook.GetTable().PlayerCanPickupWeapon.ManualWeaponPickup_CanPickup ~= nil then
        ply:PrintMessage(HUD_PRINTTALK, "[SBMG] You have Manual Weapon Pickup installed. SBMG Flag entities WILL NOT WORK!")
    end
end)