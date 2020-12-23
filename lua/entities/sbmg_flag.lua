AddCSLuaFile()

ENT.PrintName = "SBMG Flag"
ENT.Type = "anim"
ENT.Category = "Fun + Games"
ENT.Spawnable = false
ENT.AdminOnly = true


function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
end

if SERVER then
    function ENT:Initialize()
        if GetConVar("sbmg_obj_simple"):GetBool() then
            self:SetModel("models/props_combine/breenbust.mdl")
        else
            self:SetModel("models/props_sbmg/flag.mdl")
        end
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetUseType(SIMPLE_USE)
        if not IsValid(self:GetParent()) and GetConVar("sbmg_obj_physics"):GetBool() then
            self:SetMoveType(MOVETYPE_NONE)
        end
        if IsValid(self:GetParent()) then self:SetTeam(self:GetParent():GetTeam()) end
    end
elseif CLIENT then
    function ENT:Draw()
        self:SetColor(self:GetTeam() == TEAM_UNASSIGNED and Color(255,255,255) or team.GetColor(self:GetTeam()))
        self:DrawModel()
    end
end