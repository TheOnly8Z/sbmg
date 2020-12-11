AddCSLuaFile()

ENT.PrintName = "SBMG Point"
ENT.Type = "anim"
ENT.Category = "Fun + Games"
ENT.Spawnable = not game.SinglePlayer()
ENT.AdminOnly = true
ENT.SBTM_TeamEntity = true
ENT.Editable = true
ENT.ThinkDelay = 0.1
ENT.PresetNames = {
    "Alpha",
    "Bravo",
    "Charlie",
    "Delta",
    "Echo",
    "Foxtrot",
    "Golf",
    "Hotel"
}

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Team")
    self:NetworkVar("Int", 1, "CapTeam")
    self:NetworkVar("Float", 0, "Radius",          {KeyName = "radius", Edit = {type = "Float", order = 1, min = 64, max = 1024}})
    self:NetworkVar("Float", 1, "CaptureDuration", {KeyName = "captureduration", Edit = {type = "Float", order = 2, min = 1, max = 30}})
    self:NetworkVar("Float", 2, "CapProgress")
    self:NetworkVar("String", 0, "PointName",           {KeyName = "name", Edit = {type = "String", order = 3}})
    self:NetworkVar("Bool", 0, "Enabled")
end

if SERVER then

    function ENT:SpawnFunction(ply, tr)
        if not tr.Hit then return end
        local ent = ents.Create( ClassName )
        ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
        ent:Spawn()
        ent:Activate()
        return ent
    end

    function ENT:Initialize()
        self:SetModel("models/props_interiors/Furniture_Lamp01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetUseType(SIMPLE_USE)
        if self:GetTeam() == 0 then self:SetTeam(TEAM_UNASSIGNED) end
        if self:GetRadius() <= 0 then self:SetRadius(256) end
        if self:GetCaptureDuration() <= 0 then self:SetCaptureDuration(10) end
        if self:GetPointName() == "" then self:SetPointName(self.PresetNames[#ents.FindByClass("sbmg_point")] or "Point " .. #ents.FindByClass("sbmg_point")) end
        self:SetEnabled(true)
    end

    function ENT:Use(activator, caller)
        self:StartCapture(activator:Team(), activator)
    end

    function ENT:StartCapture(t, ply)
        if self:GetCapTeam() == 0 and (t >= SBTM_RED and t <= SBTM_YEL) and hook.Run("SBMG_CanCapturePoint", self, t, ply) ~= false then
            self:SetCapTeam(t)
            self:SetCapProgress(0)
        end
    end

    function ENT:CheckCapture()
        if self:GetCapTeam() ~= 0 and self:GetCapProgress() >= self:GetCaptureDuration() then
            local oldTeam = self:GetTeam()
            self:SetTeam((self:GetTeam() == TEAM_UNASSIGNED or SBMG:GameHasTag(SBMG_TAG_DIRECT_CAPTURE_POINT)) and self:GetCapTeam() or TEAM_UNASSIGNED)
            if self:GetTeam() == self:GetCapTeam() then self:SetCapTeam(0) end
            self:SetCapProgress(0)
            hook.Run("SBMG_PointCaptured", self, oldTeam)
        elseif self:GetCapTeam() ~= 0 and self:GetCapProgress() <= 0 then
            self:SetCapTeam(0)
            self:SetCapProgress(0)
        end
    end

    function ENT:Think()
        local cappers = 0 -- Need at least 1 to continue capping
        local defenders = 0 -- Need to be 0 to continue capping
        local distSqr = math.pow(self:GetRadius(), 2)
        if self:GetCapTeam() > 0 then
            for _, p in pairs(player.GetAll()) do
                if p:GetPos():DistToSqr(self:GetPos()) <= distSqr then
                    if p:Team() == self:GetCapTeam() then
                        cappers = cappers + 1
                    elseif p:Team() ~= TEAM_UNASSIGNED then
                        defenders = defenders + 1
                    end
                end
            end
            local progress = 0
            if cappers > 0 and defenders == 0 then
                progress = 1 + math.Clamp((cappers - 1) * 0.34, 0, 1)
            elseif cappers == 0 then
                progress = -0.5 - math.Clamp(defenders * 0.67, 0, 2)
            end

            self:SetCapProgress(self:GetCapProgress() + progress * self.ThinkDelay)
            self:CheckCapture()

            self:NextThink(CurTime() + self.ThinkDelay)
            return true
        elseif SBMG:GetGameOption("auto_cap") then
            local capteam = nil
            local p1 = nil
            for _, p in pairs(player.GetAll()) do
                if p:GetPos():DistToSqr(self:GetPos()) <= distSqr then
                    if not capteam and p:Team() ~= self:GetTeam() then
                        cappers = cappers + 1
                        capteam = p:Team()
                        p1 = p
                    elseif p:Team() ~= capteam and p:Team() ~= TEAM_UNASSIGNED then
                        defenders = defenders + 1
                    end
                end
            end
            if capteam and cappers > 0 and defenders == 0 then
                self:StartCapture(capteam, p1)
            end

            self:NextThink(CurTime() + 0.5)
            return true
        end
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
        hook.Add("PostDrawOpaqueRenderables", "SBMG_Point", function()
            if SBMG:GetActiveGame() and not SBMG:GetGameOption("show_radius") then return end
            for k, ent in pairs(ents.FindByClass("sbmg_point")) do
                if not ent:GetEnabled() then continue end
                local angle = ent:GetAngles()
                local mins, maxs = ent:WorldSpaceAABB()
                local flipteam = ent:GetTeam() == TEAM_UNASSIGNED or SBMG:GameHasTag(SBMG_TAG_DIRECT_CAPTURE_POINT)
                local pos = ent:GetPos() - Vector(0, 0, (maxs.z - mins.z) / 2 - math.sin(CurTime() * 2) * 4 - 8)
                local clr = (ent:GetTeam() == TEAM_UNASSIGNED and Color(255, 255, 255) or team.GetColor(ent:GetTeam()))
                local prog = ent:GetCapProgress() / ent:GetCaptureDuration()

                local r, g, b = clr:Unpack()
                r = Lerp(prog, r, (flipteam and team.GetColor(ent:GetCapTeam()).r or 255) * 0.5)
                g = Lerp(prog, g, (flipteam and team.GetColor(ent:GetCapTeam()).g or 255) * 0.5)
                b = Lerp(prog, b, (flipteam and team.GetColor(ent:GetCapTeam()).b or 255) * 0.5)

                local r2, g2, b2 = (flipteam and team.GetColor(ent:GetCapTeam()) or Color(255, 255, 255)):Unpack()

                local s = ent:GetRadius() * 2
                cam.Start3D2D(pos, angle, 1)
                    circle(s, r, g, b)
                    if prog > 0 then
                        circle(s * prog, r2, g2, b2)
                    end
                cam.End3D2D()
                angle:RotateAroundAxis(angle:Forward(), 180)
                cam.Start3D2D(pos, angle, 1)
                    circle(s, r, g, b)
                    if prog > 0 then
                        circle(s * prog, r2, g2, b2)
                    end
                cam.End3D2D()
                ent:SetColor(Color(r, g, b))
            end
        end)
    end
end