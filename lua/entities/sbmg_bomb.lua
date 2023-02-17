AddCSLuaFile()

ENT.PrintName = "SBMG Bomb"
ENT.ShortName = "Points"
ENT.Type = "anim"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
    self:NetworkVar("Entity", 0, "Bombsite")
    self:NetworkVar("Float", 0, "Timer")
end

if SERVER then

    function ENT:Initialize()
        self:SetModel("models/weapons/w_c4_planted.mdl")
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetMoveType(MOVETYPE_NONE)
    end

    function ENT:Use(activator, caller)
    end

    function ENT:Think()
    end

    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end
elseif CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end