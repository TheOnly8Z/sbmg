AddCSLuaFile()

ENT.PrintName = "SBMG Bombsite"
ENT.ShortName = "Points"
ENT.Type = "anim"
ENT.Category = "Fun + Games"
ENT.Spawnable = not game.SinglePlayer()
ENT.AdminOnly = true
ENT.SBTM_TeamEntity = true
ENT.SBTM_NoPickup = true
ENT.Editable = true
ENT.ThinkDelay = 0.1

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
    self:NetworkVar("Float", 0, "Radius",          {KeyName = "radius", Edit = {type = "Float", order = 1, min = 64, max = 1024}})
    self:NetworkVar("String", 0, "PointName",           {KeyName = "name", Edit = {type = "String", order = 3}})
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Entity", 0, "Bomb")
end

if SERVER then

    function ENT:SpawnFunction(ply, tr)
        if not tr.Hit then return end
        local ent = ents.Create( ClassName )
        ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
        ent:SetAngles(Angle(0, ply:GetAngles().y - 180, 0))
        ent:Spawn()
        ent:Activate()
        return ent
    end

    function ENT:Initialize()
        if GetConVar("sbmg_obj_simple"):GetBool() then
            self:SetModel("models/props_c17/oildrum001.mdl")
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
        else
            self:SetModel("models/props_c17/oildrum001.mdl") -- TODO: Bombsite model
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
        self:DropToFloor()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        if not GetConVar("sbmg_obj_physics"):GetBool() then
            self:SetMoveType(MOVETYPE_NONE)
        end
        if self:GetTeam() == 0 then self:SetTeam(TEAM_UNASSIGNED) end
        if self:GetRadius() <= 0 then self:SetRadius(256) end
        if self:GetPointName() == "" then
            local count = #ents.FindByClass("sbmg_bombsite")
            if count > 26 then
                self:SetPointName(count)
            else
                self:SetPointName(string.char(64 + count))
            end
        end
        self:SetEnabled(true)
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