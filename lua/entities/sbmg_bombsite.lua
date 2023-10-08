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
    local mat = Material("sprites/sbmg_aura.png")

    local function circle(s, r, g, b, a)
        surface.SetDrawColor(r, g, b, a or 50)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(-s / 2, -s / 2, s, s)
    end

    function ENT:Draw()
        self:DrawModel()
    end

    if SBMG then
        hook.Add("PostDrawOpaqueRenderables", "SBMG_Bombsite", function()
            if SBMG:GetActiveGame() and not SBMG:GetGameOption("show_radius") then return end
            for k, ent in pairs(ents.FindByClass("sbmg_bombsite")) do
                if not ent:GetEnabled() then continue end
                local mins, maxs = ent:WorldSpaceAABB()
                local pos = ent:WorldSpaceCenter() - Vector(0, 0, (maxs.z - mins.z) / 2 + math.sin(CurTime() * 2) * 4 - 8)
                local angle = ent:GetAngles()
                local clr = (ent:GetTeam() == TEAM_UNASSIGNED and Color(255, 255, 255) or team.GetColor(ent:GetTeam()))
                local r, g, b = clr:Unpack()
                local s = ent:GetRadius() * 2
                cam.Start3D2D(pos, angle, 1)
                    circle(s, r, g, b)
                cam.End3D2D()
                angle:RotateAroundAxis(angle:Forward(), 180)
                cam.Start3D2D(pos, angle, 1)
                    circle(s, r, g, b)
                cam.End3D2D()
                ent:SetColor(Color(r, g, b))
            end
        end)
    end
end