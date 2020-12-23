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
    self:SetHoldType("melee2")
end

function SWEP:Holster()
    if SERVER then
        self:SpawnFlagAndRemove()
    end
    return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
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
        flagent:SetAngles(ent:GetAngles() + Angle(0, 90, 0))
        flagent:SetTeam(self:GetTeam())
        flagent:SetStand(self:GetStand())
        if stand then
            flagent:SetParent(ent)
        else
            flagent:SetDropTime(CurTime())
        end
        flagent:Spawn()
        if not stand then flagent:DropToFloor() end
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
            self:SpawnFlagAndRemove()
        end
    end
elseif CLIENT then
    function SWEP:ShouldDrawViewModel()
        return false
    end

    function SWEP:DrawWorldModel(flags)
        if (IsValid(self:GetOwner())) then
            -- Specify a good position
            local offsetVec = Vector(2, -1.5, 24)
            local offsetAng = Angle(180, 90, 0)
            if self.ClientWM:GetModel() == "models/props_combine/breenbust.mdl" then
                offsetVec = Vector(2, -1.5, -12)
                offsetAng = Angle(180, 180, 0)
            end
            local boneid = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
            if not boneid then return end

            local matrix = self:GetOwner():GetBoneMatrix(boneid)
            if not matrix then return end

            local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

            self.ClientWM:SetPos(newPos)
            self.ClientWM:SetAngles(newAng)

            self.ClientWM:SetupBones()
        else
            self.ClientWM:SetPos(self:GetPos())
            self.ClientWM:SetAngles(self:GetAngles())
        end

        local r, g, b = render.GetColorModulation()
        local clr = team.GetColor(self:GetTeam())
        render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
        self.ClientWM:DrawModel()
        render.SetColorModulation(r, g, b)
    end
end