local tick = Material("icon16/tick.png")
local cross = Material("icon16/cross.png")

-- Magic numbers because loading order is wack
SBMG.FlagMaterials = {
    [101] = Material("icon16/flag_red.png"),
    [102] = Material("icon16/flag_blue.png"),
    [103] = Material("icon16/flag_green.png"),
    [104] = Material("icon16/flag_yellow.png"),
}

local options = {}

local function valid_lang(str)
    return language.GetPhrase(str) ~= str
end

local function populate_options(layout, name)
    for k, v in pairs(options) do
        if IsValid(v) and IsValid(v:GetParent()) then
            v:GetParent():Remove()
        end
    end
    options = {}

    -- Attempt to find last saved option set
    local last_options = {}
    if SBMG:GetActiveGame() == name then
        last_options = table.Copy(SBMG.ActiveGame.Options)
    elseif file.Exists("sbmg/" .. name .. ".txt", "DATA") then
        last_options = util.JSONToTable(file.Read("sbmg/" .. name .. ".txt", "DATA"))
    end

    local tbl = SBMG.Minigames[name]
    for k, v in pairs(tbl.Options) do
        local parent = vgui.Create("DPanel", layout)
        parent:SetSize(layout:GetWide() * 0.5, 24)
        if valid_lang("sbmg.options." .. k .. ".desc") then
            parent:SetTooltip(language.GetPhrase("sbmg.options." .. k .. ".desc"))
        end
        parent.Paint = function(pnl, w, h)
            draw.SimpleText(language.GetPhrase("sbmg.options." .. k), "Futura_13", 4, h / 2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        if v.type == "i" then
            options[k] = vgui.Create("DNumberWang", parent)
            options[k]:SetPos(layout:GetWide() * 0.5 - 64 - 8, (24 - 15) / 2)
            options[k]:SetFraction(0)
            options[k]:SetMinMax(v.min, v.max)
            options[k]:SetValue(last_options[k] or v.default)
        elseif v.type == "b" then
            options[k] = vgui.Create("DCheckBox", parent)
            options[k]:SetPos(layout:GetWide() * 0.5 - 15 - 8, (24 - 15) / 2)
            options[k]:SetChecked(last_options[k] or v.default)
        end
    end
end

list.Set( "DesktopWindows", "SBMG", {
    title = "SBMG",
    icon = "icon64/sbmg.png",
    width		= 640,
    height		= 480,
    onewindow	= true,
    init		= function( icon, window )
        window:SetTitle( "#sbmg.title" )
        window:SetSize( math.min( ScrW() - 16, window:GetWide() ), math.min( ScrH() - 16, window:GetTall() ) )
        window:SetMinWidth( window:GetWide() )
        window:SetMinHeight( window:GetTall() )
        window:Center()

        local left = vgui.Create("DPanel", window)
        left:SetSize(window:GetWide() * 0.3, window:GetTall())
        left:Dock(LEFT)
        left:DockMargin(2, 2, 2, 2)

        local title = vgui.Create("DLabel", left)
        title:SetSize(left:GetWide(), left:GetTall() * 0.08)
        title:SetText("")
        title:Dock(TOP)
        title:DockMargin(4, 12, 4, 4)
        title.Paint = function(self, w, h)
            draw.SimpleTextOutlined(language.GetPhrase("sbmg.gamecontrol"), "Futura_24", w * 0.5, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0))
        end

        local gamechoice = nil
        local gamebox = vgui.Create("DComboBox", left)
        gamebox:SetSize(left:GetWide(), left:GetTall() * 0.05)
        gamebox:SetPos(left:GetWide() * 0.1, left:GetTall() * 0.1)
        gamebox:SetValue(language.GetPhrase("sbmg.selectgame"))
        gamebox:Dock(TOP)
        gamebox:DockMargin(12, 8, 12, 8)
        gamebox:SetSortItems(false)
        for k, v in SortedPairsByMemberValue(SBMG.Minigames, "SortOrder") do
            local i = gamebox:AddChoice(v.PrintName, k, false, v.Icon)
            if k == SBMG:GetActiveGame() then
                gamechoice = i
            end
        end
        gamebox:SetDisabled(LocalPlayer():IsAdmin() and SBMG:GetActiveGame() ~= nil)

        local desc = vgui.Create("DLabel", left)
        desc:SetSize(left:GetWide(), left:GetTall() * 0.25)
        desc:SetText("")
        desc:Dock(TOP)
        desc:DockMargin(4, 12, 4, 4)
        desc:SetTextColor(Color(0, 0, 0))
        desc.Paint = function(self, w, h)
            local _, data = gamebox:GetSelected()
            if data then
                local words = string.Explode(" ", language.GetPhrase(SBMG.Minigames[data].Description))
                local i = 0
                local s = ""
                local y = 0
                for _, v in pairs(words) do
                    if i + string.len(v) >= 22 then
                        draw.SimpleText(s, "Futura_18", w * 0.5, y, Color(0, 0, 0), TEXT_ALIGN_CENTER)
                        s = v .. " "
                        i = string.len(v)
                        y = y + 12
                    else
                        s = s .. v .. " "
                        i = i + string.len(v)
                    end
                end
                if s ~= "" then
                    draw.SimpleText(s, "Futura_18", w * 0.5, y, Color(0, 0, 0), TEXT_ALIGN_CENTER)
                end
            end
        end

        local start = vgui.Create("DButton", left)
        start:SetSize(left:GetWide() * 0.2, left:GetTall() * 0.1)
        start:Dock(TOP)
        start:DockMargin(24, 4, 24, 4)
        start:SetText(SBMG:GetActiveGame() ~= nil and language.GetPhrase("sbmg.restart") or language.GetPhrase("sbmg.start"))
        start:SetDisabled(LocalPlayer():IsAdmin() and SBMG:GetActiveGame() == nil)
        start.DoClick = function(pnl)
            local _, data = gamebox:GetSelected()
            if data then
                local output = {}
                for k, v in pairs(options) do
                    print(v:GetClassName())
                    if v.GetChecked then
                        output[k] = v:GetChecked()
                    else
                        output[k] = v:GetValue()
                    end
                end

                -- Save this to a file of the local player so we can auto-load it next time
                PrintTable(output)
                if not file.IsDir("sbmg", "DATA") then file.CreateDir("sbmg") end
                local json = util.TableToJSON(output, true)
                file.Write("sbmg/" .. data .. ".txt", json)

                net.Start("SBMG_Admin")
                    net.WriteUInt(SBMG_NET_MODE_START, SBMG_NET_MODE_BITS)
                    net.WriteString(data)
                    net.WriteTable(output)
                net.SendToServer()
                window:Close()
            end
        end
        start:SetFont("Futura_24")

        local stop = vgui.Create("DButton", left)
        stop:SetSize(left:GetWide() * 0.2, left:GetTall() * 0.1)
        stop:Dock(TOP)
        stop:DockMargin(24, 4, 24, 4)
        stop:SetText(language.GetPhrase("sbmg.stop"))
        stop:SetDisabled(LocalPlayer():IsAdmin() and SBMG:GetActiveGame() == nil)
        stop.DoClick = function(pnl)
            net.Start("SBMG_Admin")
                net.WriteUInt(SBMG_NET_MODE_END, SBMG_NET_MODE_BITS)
            net.SendToServer()
        end
        stop:SetFont("Futura_24")

        local interrupt = vgui.Create("DButton", left)
        interrupt:SetSize(left:GetWide() * 0.2, left:GetTall() * 0.1)
        interrupt:Dock(TOP)
        interrupt:DockMargin(24, 4, 24, 4)
        interrupt:SetText(language.GetPhrase("sbmg.interrupt"))
        interrupt:SetDisabled(LocalPlayer():IsAdmin() and SBMG:GetActiveGame() == nil)
        interrupt.DoClick = function(pnl)
            net.Start("SBMG_Admin")
                net.WriteUInt(SBMG_NET_MODE_INTERRUPT, SBMG_NET_MODE_BITS)
            net.SendToServer()
        end
        interrupt:SetFont("Futura_24")

        local top = vgui.Create("DPanel", window)
        top:SetSize(window:GetWide() * 7, window:GetTall() * 0.3)
        top:Dock(TOP)
        top:DockMargin(2, 2, 2, 2)

        local plys, teams

        local check_ply = vgui.Create("DLabel", top)
        check_ply:SetSize(top:GetWide() * 0.3, top:GetTall() * 0.2)
        check_ply:SetPos(4, top:GetTall() * 0.1)
        check_ply:SetText("")
        check_ply.Paint = function(pnl, w, h)
            local _, data = gamebox:GetSelected()
            if data and plys then
                local text = string.format(language.GetPhrase("sbmg.min.players"), table.Count(plys), SBMG.Minigames[data].MinPlayers or 0)
                draw.SimpleText(text, "Futura_24", 20, 0, Color(0, 0, 0), TEXT_ALIGN_LEFT)
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial((SBMG.Minigames[data].MinPlayers or 0) > table.Count(plys) and cross or tick)
                surface.DrawTexturedRect( 0, 4, 16, 16 )
            end
        end

        local check_team = vgui.Create("DLabel", top)
        check_team:SetSize(top:GetWide() * 0.3, top:GetTall() * 0.2)
        check_team:SetPos(4, top:GetTall() * 0.3 + 8)
        check_team:SetText("")
        check_team.Paint = function(pnl, w, h)
            local _, data = gamebox:GetSelected()
            if data and teams then
                local text = string.format(language.GetPhrase("sbmg.min.teams"), table.Count(teams), SBMG.Minigames[data].MinTeams or 0)
                draw.SimpleText(text, "Futura_24", 20, 0, Color(0, 0, 0), TEXT_ALIGN_LEFT)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial((SBMG.Minigames[data].MinTeams or 0) > table.Count(teams) and cross or tick)
                surface.DrawTexturedRect( 0, 4, 16, 16 )
            end
        end

        local active_teams = vgui.Create("DPanel", top)
        active_teams:SetSize(top:GetWide() * 0.3, top:GetTall() * 0.2)
        active_teams:SetPos(8, top:GetTall() * 0.6 + 8)
        active_teams.Paint = function(pnl, w, h)
            local _, data = gamebox:GetSelected()
            if data and teams then
                local x = 0
                for i = SBTM_RED, SBTM_YEL do
                    local clr = team.GetColor(i)
                    if table.HasValue(teams, i) then
                        surface.SetDrawColor(255, 255, 255, 255)
                    else
                        surface.SetDrawColor(255, 255, 255, 150)
                        clr.a = 150
                    end
                    surface.SetMaterial(SBMG.FlagMaterials[i])
                    surface.DrawTexturedRect( x, 0, 16, 16 )
                    local c = 0
                    for _, v in pairs(plys) do if v:Team() == i then c = c + 1 end end
                    draw.SimpleTextOutlined(c, "Futura_18", x + 16, 0, clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 150))
                    x = x + 36
                end
            end
        end

        local optionpanel = vgui.Create("DPanel", window)
        optionpanel:Dock(FILL)
        optionpanel:DockMargin(2, 2, 2, 2)

        local optionlayout = vgui.Create("DIconLayout", optionpanel)
        optionlayout:Dock(FILL)
        optionlayout:SetLayoutDir(LEFT)


        gamebox.OnSelect = function(pnl, index, value, data)
            if data then
                -- TODO refresh options
                local tbl = SBMG.Minigames[data]

                populate_options(optionlayout, data)

                local okay = true

                plys, teams = SBMG.Minigames[data]:GetParticipants()

                if tbl.MinPlayers and table.Count(plys) < tbl.MinPlayers then
                    okay = false
                end

                if tbl.MinTeams and table.Count(teams) < tbl.MinTeams then
                    okay = false
                end

                start:SetDisabled(not okay and not SBMG:GetActiveGame())
            end
        end
        if gamechoice then timer.Simple(0, function() gamebox:ChooseOptionID(gamechoice) end) end
    end
})