AddCSLuaFile()

ENT.PrintName = "SBMG Flag"
ENT.Type = "anim"
ENT.Category = "Fun + Games"
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.SBTM_NoPickup = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
    self:NetworkVar("Entity", 0, "Stand")
    self:NetworkVar("Float", 0, "DropTime")
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
        if IsValid(self:GetStand()) then
            self:GetStand().FlagEnt = self
        end
        self:SetTrigger(true)
        self:UseTriggerBounds(true, 12)
    end

    function ENT:FlagPickup(ply)
        if ply:IsPlayer() and ply:Alive() and not ply:InVehicle() and ply ~= self:GetOwner() and
                ply:Team() ~= TEAM_UNASSIGNED and self:GetTeam() ~= TEAM_UNASSIGNED then
            if ply:Team() ~= self:GetTeam() then
                local swep = ply:Give("sbmg_flagwep")
                -- Manual Weapon Pickup waits a tick and causes this check to fail. Can't be arsed to fix it
                if IsValid(swep) then
                    swep:SetTeam(self:GetTeam())
                    swep:SetStand(self:GetStand())
                    if SBMG:GetGameOption("flag_hold") then
                        ply:SelectWeapon(ply:GetWeapon("sbmg_flagwep"))
                    end
                    SBMG:SendTeamAnnouncer(ply:Team(), "TheirFlagTaken")
                    SBMG:SendTeamAnnouncer(self:GetTeam(), "OurFlagTaken")
                    self:GetStand().FlagEnt = swep
                    self:Remove()
                else
                    error("Flag generated for " .. tostring(ply) .. " is not valid!")
                end
            elseif not SBMG:GetActiveGame() or SBMG:GetGameOption("flag_return_touch") then
                self:ReturnFlag(false)
            end
        end
    end

    function ENT:StartTouch(ply)
        self:FlagPickup(ply)
    end

    function ENT:Use(ply)
        self:FlagPickup(ply)
    end

    function ENT:Think()
        if not IsValid(self:GetParent()) and self:GetDropTime() > 0 then
            local endtime = SBMG:GetGameOption("flag_return_time") or 60
            if endtime > 0 and self:GetDropTime() + endtime < CurTime() then
                self:ReturnFlag(false)
            end
        end
    end

    function ENT:ReturnFlag(no_announcer)
        if IsValid(self:GetParent()) then return end
        local eff = EffectData()
        eff:SetEntity(self)
        util.Effect("entity_remove", eff)
        -- Return to its rightful owner
        local stand = self:GetStand()
        if IsValid(stand) and self:GetTeam() == stand:GetTeam() then
            if GetConVar("sbmg_obj_simple"):GetBool() then
                self:SetPos(stand:GetPos() + stand:GetRight() * -2.32 + stand:GetUp() * 30)
            else
                self:SetPos(stand:GetPos())
            end
            self:SetAngles(stand:GetAngles())
            self:SetParent(self:GetStand())
            if not no_announcer then
                SBMG:SeparateTeamAnnouncer(self:GetTeam(), "OurFlagReturned", "TheirFlagReturned")
            end
        else
            self:Remove()
        end
    end

    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end
elseif CLIENT then
    function ENT:Draw()
        self:SetColor(self:GetTeam() == TEAM_UNASSIGNED and Color(255,255,255) or team.GetColor(self:GetTeam()))
        self:DrawModel()
    end
end