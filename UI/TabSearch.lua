--[[
    DungeonFormer - Find Players tab. Flat skin, class colors, centered dropdowns.
]]

local DF = DungeonFormer
local Dungeons = DF.Dungeons
local Zones = DF.Zones
local Colors = DF.ClassColors
local Skin = DF.UI.Skin

local PAD = Skin.PAD or 14
local ROW = 22
local DROP_H = 26
local GAP = 12
local TOP = 14

local function Label(parent, text, y, small)
    local L = parent:CreateFontString(nil, "OVERLAY", small and "GameFontHighlightSmall" or "GameFontHighlight")
    L:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
    L:SetText(text)
    L:SetTextColor(0.82, 0.8, 0.75, 1)
    return L
end

local function EditBox(parent, x, y, w, getVal, setVal)
    local eb = Skin.FlatEditBox(parent, w or 56, 22)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    eb:SetText(tostring(getVal and getVal() or ""))
    eb:SetScript("OnTextChanged", function(self) if setVal then setVal(self:GetText()) end end)
    return eb
end

local function indexOf(items, text)
    if not text then return 1 end
    for i, item in ipairs(items) do
        if item == text then return i end
    end
    return 1
end

function DF.UI.BuildTabSearch(container)
    local State = DF.State or {}
    local y = TOP
    local content = CreateFrame("Frame", nil, container)
    content:SetAllPoints(container)
    content:Show()

    Label(content, "Pick a dungeon or set level range. Up to 50 results.", y, true)
    y = y + 20 + GAP

    Label(content, "Dungeon", y, true)
    y = y + 18
    local dungeonNames = {}
    for i = 1, #Dungeons do dungeonNames[i] = Dungeons[i].name end
    local dungeonDrop = Skin.FlatDropdown(content, 0, DROP_H, dungeonNames, indexOf(dungeonNames, State.DungeonDropdown), function(idx, text)
        State.DungeonDropdown = text
        local d = Dungeons[idx]
        if d then
            State.LowLevel = d.low
            State.HighLevel = d.high
            State.MessageBox = "Hey, want to run " .. d.sname .. "?"
            DF.UI.SelectTab(1)
            DF.UI.SelectTab(1)
        end
    end)
    dungeonDrop:ClearAllPoints()
    dungeonDrop:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    dungeonDrop:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PAD, -y)
    y = y + DROP_H + GAP

    Label(content, "Level range", y, true)
    y = y + 18
    EditBox(content, PAD, y, 52, function() return State.LowLevel end, function(v) State.LowLevel = v end)
    local dash = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dash:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 58, -y)
    dash:SetText("–")
    dash:SetTextColor(0.6, 0.58, 0.54, 1)
    EditBox(content, PAD + 72, y, 52, function() return State.HighLevel end, function(v) State.HighLevel = v end)
    y = y + ROW + GAP

    local findBtn = Skin.FlatButton(content, 0, 30, "Find Players", function() DF.SearchPlayers() end, true)
    findBtn:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    findBtn:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PAD, -y)
    y = y + 36 + GAP

    Label(content, "Filters (optional)", y, true)
    y = y + 18
    Label(content, "Zone", y, true)
    y = y + 16
    local zoneDrop = Skin.FlatDropdown(content, 0, DROP_H, Zones, indexOf(Zones, State.ZoneDropdown), function(idx, text) State.ZoneDropdown = text end)
    zoneDrop:ClearAllPoints()
    zoneDrop:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    zoneDrop:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PAD, -y)
    y = y + DROP_H + GAP

    Label(content, "Classes", y, true)
    y = y + 16
    local classList = {
        { key = "DruidCheck", label = "Druid" }, { key = "HunterCheck", label = "Hunter" }, { key = "MageCheck", label = "Mage" },
        { key = "PaladinCheck", label = "Paladin" }, { key = "PriestCheck", label = "Priest" }, { key = "RogueCheck", label = "Rogue" },
        { key = "ShamanCheck", label = "Shaman" }, { key = "WarlockCheck", label = "Warlock" }, { key = "WarriorCheck", label = "Warrior" },
    }
    local cw, rh = 132, 20
    for i, c in ipairs(classList) do
        local row, col = math.floor((i - 1) / 3), (i - 1) % 3
        local cx = Colors[c.label]
        local cr, cg, cb = (cx and cx.r) or 0.8, (cx and cx.g) or 0.78, (cx and cx.b) or 0.75
        Skin.FlatCheckBox(content, c.label, PAD + col * cw, y + row * rh, cr, cg, cb, function() return State[c.key] end, function(v) State[c.key] = v end)
    end

    content:SetParent(container)
end
