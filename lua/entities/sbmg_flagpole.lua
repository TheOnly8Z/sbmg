AddCSLuaFile()

ENT.PrintName = "SBMG Flag Stand"
ENT.Type = "anim"
ENT.Category = "Fun + Games"
ENT.Spawnable = not game.SinglePlayer()
ENT.AdminOnly = true
ENT.SBTM_TeamEntity = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
end

if SERVER then

    function ENT:SpawnFunction(ply, tr)
        if not tr.Hit then return end
        local ent = ents.Create( ClassName )
        ent:SetPos( tr.HitPos + tr.HitNormal * 32 )
        ent:SetAngles(Angle(0, ply:GetAngles().y - 180, 0))
        ent:Spawn()
        ent:Activate()
        return ent
    end

    function ENT:Initialize()
        if GetConVar("sbmg_obj_simple"):GetBool() then
            self:SetModel("models/props_combine/breenchair.mdl")
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self:PhysicsInit(SOLID_VPHYSICS)
        else
            self:SetModel("models/props_sbmg/flagpole.mdl")
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
            self:PhysicsInitBox(Vector(-12, -12, -5), Vector(14, 14, 4))
        end
        self:DropToFloor()
        self:SetUseType(SIMPLE_USE)
        if not GetConVar("sbmg_obj_physics"):GetBool() then
            self:SetMoveType(MOVETYPE_NONE)
        end
        if self:GetTeam() == 0 then self:SetTeam(TEAM_UNASSIGNED) end
        self.FlagEnt = ents.Create("sbmg_flag")
        if GetConVar("sbmg_obj_simple"):GetBool() then
            self.FlagEnt:SetPos(self:GetPos() + self:GetRight() * -2.32 + self:GetUp() * 30)
        else
            self.FlagEnt:SetPos(self:GetPos())
        end
        self.FlagEnt:SetAngles(self:GetAngles())
        self.FlagEnt:SetParent(self)
        self.FlagEnt:Spawn()
    end

    function ENT:OnSetTeam(id, ply)
        if IsValid(self.FlagEnt) then
            self.FlagEnt:SetTeam(id)
        end
    end
elseif CLIENT then
    function ENT:Draw()
        self:SetColor(self:GetTeam() == TEAM_UNASSIGNED and Color(255,255,255) or team.GetColor(self:GetTeam()))
        self:DrawModel()
    end
end