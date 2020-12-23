AddCSLuaFile()

SWEP.PrintName = "SBMG Flag"
SWEP.Spawnable = false
SWEP.Author = "8Z"

SWEP.ViewModel = "models/props_sbmg/flag.mdl"
SWEP.WorldModel = "models/props_sbmg/flag.mdl"

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = ""

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
    self:NetworkVar("Entity", 0, "Stand")
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
    function SWEP:SpawnFlagAndRemove()
        local flagent = ents.Create("sbmg_flag")
        if GetConVar("sbmg_obj_simple"):GetBool() then
            flagent:SetPos(self:GetOwner():GetPos() + self:GetOwner():GetRight() * -2.32 + self:GetOwner():GetUp() * 30)
        else
            flagent:SetPos(self:GetOwner():GetPos())
        end
        flagent:SetAngles(self:GetOwner():GetAngles())
        flagent:SetTeam(self:GetTeam())
        flagent:SetStand(self:GetStand())
        flagent:Spawn()
        flagent:DropToFloor()
        self:Remove()
    end
elseif CLIENT then

    function SWEP:Initialize()
        self.ClientWM = ClientsideModel(self.WorldModel)
        self.ClientWM:SetNoDraw(true)
    end

    function SWEP:ShouldDrawViewModel()
        return false
    end

    function SWEP:DrawWorldModel()
        if (IsValid(self:GetOwner())) then
            -- Specify a good position
            local offsetVec = Vector(2, -1.5, 24)
            local offsetAng = Angle(180, 90, 0)
            local boneid = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
            if !boneid then return end

            local matrix = self:GetOwner():GetBoneMatrix(boneid)
            if !matrix then return end

            local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

            self.ClientWM:SetPos(newPos)
            self.ClientWM:SetAngles(newAng)

            self.ClientWM:SetupBones()
        else
            self.ClientWM:SetPos(self:GetPos())
            self.ClientWM:SetAngles(self:GetAngles())
        end
        self.ClientWM:SetColor(team.GetColor(self:GetTeam()))
        self.ClientWM:DrawModel()
    end
end