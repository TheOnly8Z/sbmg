AddCSLuaFile()

SWEP.PrintName = "SBMG Bomb"
SWEP.Spawnable = false
SWEP.Author = "8Z"
SWEP.Instructions = "Hold ATTACK1 near bombsite"

SWEP.Slot = 5

SWEP.ViewModel = "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = ""
SWEP.UseHands = true

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "Planting")
    self:NetworkVar("Entity", 0, "Bombsite")
end

function SWEP:Initialize()
end

function SWEP:Deploy()
    self:SetHoldType("slam")
    local seq, dur = self:LookupSequence("draw")
    self:GetOwner():GetViewModel():SendViewModelMatchingSequence(seq)
    self:SetNextPrimaryFire(CurTime() + dur)
    self:SetPlanting(0)
end

function SWEP:Holster()
    return true
end

function SWEP:CanPrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return false end
    if not SBTM:IsTeamed(self:GetOwner()) then return false end
    if self:GetPlanting() > 0 then return false end
    return true
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    local bombsite, d = nil, 0
    for _, ent in ipairs(ents.FindByClass("sbmg_bombsite")) do
        if IsValid(ent:GetBomb()) or ent:GetTeam() == self:GetOwner():Team() then continue end
        local dist = ent:GetPos():Distance(self:GetOwner():GetPos())
        if dist > ent:GetRadius() then continue end
        if not bombsite or d > dist then
            bombsite = ent
            d = dist
        end
    end
    if not bombsite then return end

    self:SetHoldType("camera")
    self:GetOwner():GetViewModel():SendViewModelMatchingSequence(self:LookupSequence("pressbutton"))
    self:SetPlanting(CurTime() + 2.9)
    self:SetBombsite(bombsite)
end

function SWEP:Think()
    if self:GetPlanting() > 0 then
        if not self:GetOwner():KeyDown(IN_ATTACK) or not IsValid(self:GetBombsite())
                or IsValid(self:GetBombsite():GetBomb())
                or self:GetBombsite():GetPos():Distance(self:GetPos()) > self:GetBombsite():GetRadius() then
            self:SetHoldType("slam")
            self:SetPlanting(0)
            self:GetOwner():GetViewModel():SendViewModelMatchingSequence(self:LookupSequence("idle"))
        elseif self:GetPlanting() < CurTime() then
            if SERVER then
                self:EmitSound("weapons/c4/c4_plant.wav", 100)
                local bomb = ents.Create("sbmg_bomb")
                bomb:SetPos(self:GetOwner():GetPos())
                bomb:SetAngles(Angle(0, self:GetOwner():GetAngles().y, 0))
                bomb:SetOwner(self:GetOwner())
                bomb:SetTeam(self:GetOwner():Team())
                bomb:SetBombsite(self:GetBombsite())
                bomb:SetTimer(CurTime() + 45) -- TODO change
                bomb:Spawn()
                self:GetBombsite():SetBomb(bomb)
                self:Remove()
            end
            self:SetPlanting(0)
        end
    end
end

function SWEP:SecondaryAttack()
end

if SERVER then

elseif CLIENT then

end