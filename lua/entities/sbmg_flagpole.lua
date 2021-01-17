AddCSLuaFile()

ENT.PrintName = "SBMG Flag Stand"
ENT.ShortName = "Flags"
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
        self:CreateFlag()
        self:SetTrigger(true)
        self:UseTriggerBounds(true, 24)
    end

    function ENT:OnSetTeam(id, ply)
        if IsValid(self.FlagEnt) then
            self.FlagEnt:SetTeam(id)
        end
    end

    function ENT:CreateFlag()
        self.FlagEnt = ents.Create("sbmg_flag")
        if GetConVar("sbmg_obj_simple"):GetBool() then
            self.FlagEnt:SetPos(self:GetPos() + self:GetRight() * -2.32 + self:GetUp() * 30)
        else
            self.FlagEnt:SetPos(self:GetPos())
        end
        self.FlagEnt:SetAngles(self:GetAngles())
        self.FlagEnt:SetParent(self)
        self.FlagEnt:SetStand(self)
        self.FlagEnt:Spawn()
    end

    function ENT:StartTouch(ply)
        if ply:IsPlayer() and ply:Alive() and ply:HasWeapon("sbmg_flagwep") and
                ply:Team() == self:GetTeam() and self:GetTeam() ~= TEAM_UNASSIGNED then
            if SBMG:GetGameOption("flag_cap_need") and (not IsValid(self.FlagEnt)
                    or self.FlagEnt:GetParent() ~= self) then
                return
            end
            -- Captured
            hook.Run("SBMG_FlagCaptured", ply, self, ply:GetWeapon("sbmg_flagwep"):GetTeam())
            ply:GetWeapon("sbmg_flagwep"):SpawnFlagAndRemove(true)
        end
    end

    function ENT:ForceReturnFlag()
        if not IsValid(self.FlagEnt) then
            -- What the fuck? well, might as well make a new one
            self:CreateFlag()
        elseif self.FlagEnt:GetParent() == self then
            return
        elseif self.FlagEnt:GetClass() == "sbmg_flagwep" then
            self.FlagEnt:SpawnFlagAndRemove(true)
        elseif self.FlagEnt:GetParent() ~= self then
            self.FlagEnt:ReturnFlag(true)
        end
    end

    function ENT:OnRemove()
        for _, ent in pairs(ents.FindByClass("sbmg_flag")) do
            if ent:GetStand() == self then
                ent:Remove()
                return
            end
        end
        for _, ply in pairs(player.GetAll()) do
            if ply:HasWeapon("sbmg_flagwep") and ply:GetWeapon("sbmg_flagwep"):GetStand() == self then
                ply:GetWeapon("sbmg_flagwep"):Remove()
                return
            end
        end
    end
elseif CLIENT then
    function ENT:Draw()
        self:SetColor(self:GetTeam() == TEAM_UNASSIGNED and Color(255,255,255) or team.GetColor(self:GetTeam()))
        self:DrawModel()
    end
end