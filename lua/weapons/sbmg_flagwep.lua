AddCSLuaFile()

SWEP.PrintName = "SBMG Flag"
SWEP.Spawnable = false
SWEP.Author = "8Z"
SWEP.Instructions = "Holster to drop"

SWEP.ViewModel = "models/props_sbmg/flag.mdl"
SWEP.WorldModel = "models/props_sbmg/flag.mdl"

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = ""

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
    self:NetworkVar("Entity", 0, "Stand")
end


function SWEP:Initialize()
    self:SetHoldType("melee2")

    if SERVER and IsValid(self:GetStand()) then
        self:GetStand().FlagEnt = self
    end

    if CLIENT then
        if GetConVar("sbmg_obj_simple"):GetBool() then
            self.ClientWM = ClientsideModel("models/props_combine/breenbust.mdl")
        else
            self.ClientWM = ClientsideModel(self.WorldModel)
        end
        self.ClientWM:SetNoDraw(true)
        self.ClientWM:SetColor(team.GetColor(self:GetTeam()))
    end
end

function SWEP:Deploy()
end

function SWEP:Holster()
    if SERVER and SBMG:GetGameOption("flag_hold") then
        self:SpawnFlagAndRemove(false)
    end
    return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
    if SERVER then self:SpawnFlagAndRemove(false) end
end

if SERVER then
    function SWEP:SpawnFlag(stand)
        local flagent = ents.Create("sbmg_flag")
        local ent = stand and self:GetStand() or self:GetOwner()
        if GetConVar("sbmg_obj_simple"):GetBool() then
            flagent:SetPos(ent:GetPos() + ent:GetRight() * -2.32 + ent:GetUp() * 30)
        else
            flagent:SetPos(ent:GetPos())
        end
        if stand then
            flagent:SetAngles(ent:GetAngles())
        else
            flagent:SetAngles(Angle(0, ent:GetAngles().y + 90, 0))
        end
        print(flagent:GetAngles())
        flagent:SetTeam(self:GetTeam())
        flagent:SetStand(self:GetStand())
        if stand then
            flagent:SetParent(ent)
        else
            flagent:SetDropTime(CurTime())
            -- Custom drop to floor solution
            local tr = util.TraceHull({
                start = flagent:GetPos() + Vector(0, 0, 4),
                endpos = flagent:GetPos() - Vector(0, 0, 100000),
                mins = Vector(-8, -16, -1),
                maxs = Vector(12, 24, 126),
                collisiongroup = COLLISION_GROUP_DEBRIS
            })
            flagent:SetPos(tr.HitPos)
        end
        flagent:SetOwner(self:GetOwner())
        flagent:Spawn()
        timer.Simple(3, function() if IsValid(flagent) then flagent:SetOwner(nil) end end)
        self:Remove()
        return flagent
    end

    function SWEP:SpawnFlagAndRemove(stand)
        self:SpawnFlag(stand)
        self.DONE = true
        self:Remove()
    end

    function SWEP:OnRemove()
        if not self.DONE then
            self:SpawnFlagAndRemove(false)
        end
    end
elseif CLIENT then
    function SWEP:ShouldDrawViewModel()
        return false
    end

    function SWEP:DrawWorldModel(flags)
    end
    if SBMG then
        hook.Add("PostPlayerDraw", "SBMG_FlagWep", function(ply)
            if not ply:Alive() or not ply:HasWeapon("sbmg_flagwep") then return end
            local wep = ply:GetWeapon("sbmg_flagwep")
            local mdl = wep.ClientWM
            local active = ply:GetActiveWeapon() == wep

            local pos, ang
            if active then
                if mdl:GetModel() == "models/props_combine/breenbust.mdl" then
                    pos = Vector(2, -1.5, -12)
                    ang = Angle(180, 180, 0)
                else
                    pos = Vector(2, -1.5, 24)
                    ang = Angle(180, 90, 0)
                end
            else
                if mdl:GetModel() == "models/props_combine/breenbust.mdl" then
                    pos = Vector(6, -8, -4)
                    ang = Angle(0, -90, -90)
                else
                    pos = Vector(-24, -2, -4)
                    ang = Angle(0, 90, 90)
                end
            end
            local boneid = ply:LookupBone(active and "ValveBiped.Bip01_R_Hand" or "ValveBiped.Bip01_Spine2")
            if not boneid then return end

            local matrix = ply:GetBoneMatrix(boneid)
            if not matrix then return end

            local newPos, newAng = LocalToWorld(pos, ang, matrix:GetTranslation(), matrix:GetAngles())

            mdl:SetPos(newPos)
            mdl:SetAngles(newAng)

            mdl:SetupBones()

            local r, g, b = render.GetColorModulation()
            local clr = team.GetColor(wep:GetTeam())
            render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
            mdl:DrawModel()
            render.SetColorModulation(r, g, b)
        end)
    end
end