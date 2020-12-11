surface.CreateFont("SBMG_HUD", {
    font = "Futura-Bold",
    size = 64,
    shadow = true
})

surface.CreateFont("SBMG_HUD_48", {
    font = "Futura-Bold",
    size = 48,
    shadow = true
})

surface.CreateFont("SBMG_HUD2", {
    font = "Futura-Bold",
    size = 36,
    shadow = true
})

local function DrawScore(tgt, rank, y)
    local clr
    if SBMG:GetCurrentGameTable().TeamScores then
        clr = team.GetColor(tgt.OrigTeam or tgt:Team())
    else
        local pclr = tgt:GetPlayerColor()
        clr = Color(pclr.x * 255, pclr.y * 255, pclr.z * 255)
    end
    local str = "[" .. rank .. "] " .. tgt:GetName() .. ": " .. SBMG.ActivePlayers[tgt]
    surface.SetFont("SBMG_HUD2")
    local w, s = surface.GetTextSize(str)
    draw.SimpleTextOutlined(str, "SBMG_HUD2", ScreenScale(4), y, clr,  TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 50))
    if tgt:Team() == TEAM_UNASSIGNED then
        surface.SetDrawColor(clr.r, clr.g, clr.b)
        surface.DrawRect(ScreenScale(4), y + s * 0.5, w, ScreenScale(2))
    end
end

hook.Add("HUDPaint", "SBMG", function()
    local tbl = SBMG:GetCurrentGameTable()
    if not tbl then
        if (SBMG.LastWinTime or 0) + 10 >= CurTime() then
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
    if t then
        draw.SimpleTextOutlined(math.ceil(SBMG.ActiveGame.StartTime + t - CurTime()) .. "s", "SBMG_HUD2", ScrW() * 0.5, y, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 50))
    end

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