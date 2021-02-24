surface.CreateFont("SBMG_HUD", {
    font = "Futura-Bold",
    size = 64,
    shadow = false
})

surface.CreateFont("SBMG_HUD_48", {
    font = "Futura-Bold",
    size = 48,
    shadow = false
})

surface.CreateFont("SBMG_HUD2", {
    font = "Futura-Bold",
    size = 36,
    shadow = false
})

local showonhud = GetConVar("cl_sbmg_obj_showonhud")
local mat_point = Material("sprites/sbmg_pointui.png", "mips smooth")

local function DrawScore(tgt, rank, y)
    local clr
    if not IsValid(tgt) then
        clr = Color(100, 100, 100)
    elseif SBMG:GetCurrentGameTable().TeamScores then
        clr = team.GetColor(tgt.OrigTeam or tgt:Team())
    else
        local pclr = tgt:GetPlayerColor()
        clr = Color(pclr.x * 255, pclr.y * 255, pclr.z * 255)
    end
    local str = "[" .. rank .. "] " .. (IsValid(tgt) and tgt:GetName() or language.GetPhrase("sbmg.disconnected")) .. ": " .. SBMG.ActivePlayers[tgt]
    surface.SetFont("SBMG_HUD2")
    local w, s = surface.GetTextSize(str)
    draw.SimpleTextOutlined(str, "SBMG_HUD2", ScreenScale(4), y, clr,  TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 50))
    if IsValid(tgt) and tgt:Team() == TEAM_UNASSIGNED then
        surface.SetDrawColor(clr.r, clr.g, clr.b)
        surface.DrawRect(ScreenScale(4), y + s * 0.5, w, ScreenScale(2))
    end
end

local function DrawObjectives()
    local points = {}
    local disttbl = {}

    cam.Start3D()
    for _, v in pairs(ents.FindByClass("sbmg_point")) do
        if not v:GetEnabled() then continue end
        points[v] = (v:WorldSpaceCenter() + Vector(0, 0, 96)):ToScreen()
    end
    cam.End3D()

    -- *Someone* is going to be dumb enough to overlap their points
    local bcount = 0
    for ent, info in pairs(points) do
        disttbl[ent] = ent:GetPos():Distance(EyePos())
        if disttbl[ent] <= ent:GetRadius() * 1.5 then
            bcount = bcount + 1
        end
    end
    local bottomx = ScrW() * 0.5 - math.max(bcount - 1, 0) * 64

    for ent, info in pairs(points) do
        local dist = disttbl[ent]
        local a = math.Clamp(math.Distance(info.x, info.y, ScrW() * 0.5, ScrH() * 0.5) / 96 + 0.1, 0, 1)
        local x, y = info.x, info.y
        local siz = 48
        local font = "SBMG_HUD2"
        local clr = ent:GetColor()

        if dist <= ent:GetRadius() * 1.5 then
            a = math.Clamp((ent:GetRadius() * 1.5 - dist) / ent:GetRadius() + 0.25, 0, 1)
            x = bottomx
            y = ScrH() * 0.9
            siz = 96
            font = "SBMG_HUD"
            bottomx = bottomx + 128
        elseif not info.visible then
            continue
        end

        clr.a = 255 * a
        surface.SetDrawColor(clr.r, clr.g, clr.b, 100 * a)
        surface.SetMaterial(mat_point)
        surface.DrawTexturedRect(x - siz / 2, y - siz / 2, siz, siz)

        local point_text = string.upper(string.Left(ent:GetPointName(), 1))
        surface.SetFont(font)
        local textw, texth = surface.GetTextSize(point_text)
        draw.SimpleTextOutlined(point_text, font, x - textw * 0.5 - 1, y - texth * 0.5 - 1, clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, 150 * a))

        if ent:GetCapTeam() ~= 0 then
            draw.SimpleTextOutlined(math.Round(ent:GetCapProgress() / ent:GetCaptureDuration() * 100) .. "%", "SBMG_HUD2", x, y + (font == "SBMG_HUD" and 48 or 24), Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, 150 * a))
        end

        --[[]
        surface.SetTextColor(0, 0, 0, 100 * math.min(dist_m, aim_m))
        surface.SetTextPos(info.x - textw * 0.5 + 1, info.y - texth * 0.5 + 1)
        surface.DrawText(point_text)

        surface.SetTextColor(r, g, b, 255 * math.min(dist_m, aim_m))
        surface.SetTextPos(info.x - textw * 0.5 - 1, info.y - texth * 0.5 - 1)
        surface.DrawText(point_text)
        ]]
    end
end

hook.Add("HUDPaint", "SBMG", function()
    local tbl = SBMG:GetCurrentGameTable()

    if showonhud:GetInt() == 2 or (showonhud:GetInt() == 1 and tbl) then
        DrawObjectives()
    end

    if not tbl then
        if (SBMG.LastWinTime or 0) + 5 >= CurTime() then
            local str
            if SBMG.LastWinner == false then
                str = language.GetPhrase("sbmg.nocontest")
            elseif SBMG.LastWinner == nil then
                str = language.GetPhrase("sbmg.tie")
            elseif isentity(SBMG.LastWinner) then
                if SBMG.LastWinner == LocalPlayer() then
                    str = language.GetPhrase("sbmg.win.ply")
                else
                    str = string.format(language.GetPhrase("sbmg.winner"), SBMG.LastWinner:GetName())
                end
            else
                if SBMG.LastWinner == LocalPlayer():Team() then
                    str = language.GetPhrase("sbmg.win.team")
                else
                    str = string.format(language.GetPhrase("sbmg.winner"), team.GetName(SBMG.LastWinner))
                end
            end
            draw.SimpleTextOutlined(str, "SBMG_HUD", ScrW() * 0.5, ScrH() * 0.35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 50))
        end
        return
    end

    local clr
    if SBMG:GetCurrentGameTable().TeamScores then
        clr = team.GetColor(LocalPlayer():Team())
    else
        local pclr = LocalPlayer():GetPlayerColor()
        clr = Color(pclr.x * 255, pclr.y * 255, pclr.z * 255)
    end

    -- Name and banner
    draw.SimpleTextOutlined(language.GetPhrase(tbl.PrintName), "SBMG_HUD", ScrW() * 0.5, ScreenScale(4), clr,  TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 50))
    local y = ScreenScale(24)
    local text = tbl.GetBannerText and tbl:GetBannerText()
    if text then
        draw.SimpleTextOutlined(text, "SBMG_HUD2", ScrW() * 0.5, y, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 50))
        y = y + ScreenScale(12)
    end


    -- Draw team scores if applicable
    if tbl.TeamScores then
        local sc = 36
        local x = ScrW() * 0.5 - (table.Count(SBMG.TeamScore) - 1) * ScreenScale(sc / 2)
        local c = 0
        for t, s in SortedPairs(SBMG.TeamScore) do
            draw.SimpleTextOutlined(s, string.len(s) > 2 and "SBMG_HUD_48" or "SBMG_HUD", x, y + ScreenScale(10), team.GetColor(t),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 50))
            if c < table.Count(SBMG.TeamScore) - 1 then
                draw.SimpleTextOutlined(":", "SBMG_HUD", x + ScreenScale(sc / 2), y + ScreenScale(10), Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 50))
            end
            c = c + 1
            x = x + ScreenScale(sc)
        end
        y = y + ScreenScale(20)
    end

    -- Draw time if applicable
    local t = SBMG:GetGameOption("time")
    local t_tbl
    if (t or 0) > 0 then
        t_tbl = string.FormattedTime(math.ceil(SBMG.ActiveGame.StartTime + t - CurTime()))
    else
        t_tbl = string.FormattedTime(math.ceil(CurTime() - SBMG.ActiveGame.StartTime))
    end
    local str = string.format("%02i", t_tbl.s)
    if t_tbl.h > 0 then str = t_tbl.h .. ":" .. string.format("%02i", t_tbl.m) .. ":" .. str
    else str = t_tbl.m .. ":" .. str end
    draw.SimpleTextOutlined(str, "SBMG_HUD2", ScrW() * 0.5, y, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 50))

    -- Draw top left individual scores
    local ranked = table.GetKeys(SBMG.ActivePlayers)
    table.sort(ranked, function(a, b) return SBMG.ActivePlayers[a] > SBMG.ActivePlayers[b] end)
    local y2 = ScreenScale(2)
    if SBMG.ActivePlayers[LocalPlayer()] then
        DrawScore(LocalPlayer(), table.KeyFromValue(ranked, LocalPlayer()), y2)
        y2 = y2 + ScreenScale(12)
    end
    for i, v in pairs(ranked) do
        if v == LocalPlayer() then continue end
        DrawScore(v, i, y2)
        y2 = y2 + ScreenScale(8)
    end
end)

local function outline_class(class, mode)
    for _, e in pairs(ents.FindByClass(class)) do
        if mode == 3 or mode == 1 then
            outline.Add(e, e:GetTeam() == TEAM_UNASSIGNED and Color(255,255,255) or team.GetColor(e:GetTeam()), OUTLINE_MODE_NOTVISIBLE)
        elseif mode == 3 or mode == 2 then
            -- Technically, PreDrawOutlines is right during PreDrawHalos so this should work
            halo.Add(e, e:GetTeam() == TEAM_UNASSIGNED and Color(255,255,255) or team.GetColor(e:GetTeam()), 4, 4, true, true)
        end
    end
end

hook.Add("PreDrawHalos", "SBMG", function()
    local cvar = GetConVar("cl_sbmg_obj_outline"):GetInt()
    local mode = GetConVar("cl_sbmg_obj_outline_mode"):GetInt()
    if cvar > 0 and SBTM:IsTeamed(LocalPlayer()) and mode > 0 and
            (cvar == 2 or SBMG:GetActiveGame()) then
        outline_class("sbmg_point", mode)
        outline_class("sbmg_flag", mode)
        outline_class("sbmg_flagpole", mode)
    end
end)

-- TODO remove debug
--[[]
local bomb = Material("icon16/bomb.png")
hook.Add("HUDDrawTargetID", "SBMG", function()
    local tr = util.GetPlayerTrace( LocalPlayer() )
    local trace = util.TraceLine( tr )
    if not trace.Hit or not trace.HitNonWorld or not trace.Entity:IsPlayer() then return end

    local MouseX, MouseY = gui.MousePos()
    if ( MouseX == 0 and MouseY == 0 ) then
        MouseX = ScrW() / 2
        MouseY = ScrH() / 2
    end
    local x = MouseX
    local y = MouseY
    x = x - 8
    y = y + 78

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(bomb)
    surface.DrawTexturedRect( x, y, 16, 16 )

    local text = "BOMB CARRIER"
    local font = "TargetIDSmall"
    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )
    x = MouseX - w / 2
    y = y + 16

    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, team.GetColor(trace.Entity:Team()))
end)
]]