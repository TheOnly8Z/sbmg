util.AddNetworkString("SBMG_Admin")
util.AddNetworkString("SBMG_Game")
util.AddNetworkString("SBMG_Score")

net.Receive("SBMG_Admin", function(len, ply)
    if not ply:IsAdmin() then return end
    local mode = net.ReadUInt(SBMG_NET_MODE_BITS)

    if mode == SBMG_NET_MODE_START then
        local name = net.ReadString()
        local options = net.ReadTable()
        SBMG:MinigameStart(name, options)
    elseif mode == SBMG_NET_MODE_END then
        -- It's like ending but using timeout to check winner
        local tbl = SBMG:GetCurrentGameTable()
        SBMG:MinigameEnd(tbl.Timeout and tbl:Timeout() or nil)
    elseif mode == SBMG_NET_MODE_INTERRUPT then
        SBMG:MinigameEnd(false)
    end
end)