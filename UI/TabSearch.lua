--[[
    DungeonFormer - Find Players tab. Clean layout for wide frame.
]]

local DF = DungeonFormer
local Dungeons = DF.Dungeons
local Zones = DF.Zones

local PAD = 14
local ROW = 22
local DROP_H = 26
local GAP = 10
local TOP = 12

local function Label(parent, text, y, small)
    local L = parent:CreateFontString(nil, "OVERLAY", small and "GameFontHighlightSmall" or "GameFontHighlight")
    L:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
    L:SetText(text)
    L:SetTextColor(0.88, 0.85, 0.78, 1)
    return L
end

local function EditBox(parent, x, y, w, getVal, setVal)
    local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    eb:SetSize(w or 56, 20)
    eb:SetAutoFocus(false)
    eb:SetText(tostring(getVal and getVal() or ""))
    eb:SetScript("OnTextChanged", function(self) if setVal then setVal(self:GetText()) end end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return eb
end

local function CheckBox(parent, label, x, y, getVal, setVal)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    cb.text:SetText(label)
    cb.text:SetFontObject("GameFontHighlightSmall")
    cb:SetChecked(getVal and getVal() or false)
    cb:SetScript("OnClick", function(self) if setVal then setVal(self:GetChecked()) end end)
    return cb
end

local function Button(parent, text, y, fullWidth, onClick, primary)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
    if fullWidth then
        btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PAD, -y)
    else
        btn:SetWidth(160)
    end
    btn:SetHeight(primary and 28 or 24)
    btn:SetText(text)
    btn:SetScript("OnClick", function() if onClick then onClick() end end)
    return btn
end

local function Dropdown(parent, items, selectedText, y, onSelect)
    local name = "DFDrop" .. tostring(y)
    local drop = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    drop:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
    drop:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PAD, -y)
    drop._selectedValue = 1
    if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(drop, 380) end
    if UIDropDownMenu_SetText then UIDropDownMenu_SetText(drop, selectedText or items[1]) end
    UIDropDownMenu_Initialize(drop, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local cur = (UIDropDownMenu_GetSelectedValue and UIDropDownMenu_GetSelectedValue(drop)) or drop._selectedValue
        for i, item in ipairs(items) do
            info.text = item
            info.value = i
            info.checked = (cur == i)
            info.func = function()
                drop._selectedValue = i
                if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(drop, i) end
                if UIDropDownMenu_SetText then UIDropDownMenu_SetText(drop, item) end
                if onSelect then onSelect(i, item) end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    drop.SetSelectedValue = function(_, val)
        drop._selectedValue = val
        if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(drop, val) end
        if UIDropDownMenu_SetText and items[val] then UIDropDownMenu_SetText(drop, items[val]) end
    end
    return drop
end

function DF.UI.BuildTabSearch(container)
    local State = DF.State or {}
    local y = TOP
    local content = CreateFrame("Frame", nil, container)
    content:SetAllPoints(container)
    content:Show()

    Label(content, "Pick a dungeon or set level range. Up to 50 results.", y, true)
    y = y + 18 + GAP

    Label(content, "Dungeon", y, true)
    y = y + 16
    local dungeonNames = {}
    for i = 1, #Dungeons do dungeonNames[i] = Dungeons[i].name end
    Dropdown(content, dungeonNames, State.DungeonDropdown, y, function(idx, text)
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
    y = y + DROP_H + GAP

    Label(content, "Level range", y, true)
    y = y + 16
    local lowLvl = EditBox(content, PAD, y, 52, function() return State.LowLevel end, function(v) State.LowLevel = v end)
    local dash = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dash:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 58, -y)
    dash:SetText("–")
    local highLvl = EditBox(content, PAD + 72, y, 52, function() return State.HighLevel end, function(v) State.HighLevel = v end)
    local highLvl = EditBox(content, PAD + 72, y, 52, function() return State.HighLevel end, function(v) State.HighLevel = v end)
    y = y + ROW + GAP

    Button(content, "Find Players", y, true, function() DF.SearchPlayers() end, true)
    y = y + 32 + GAP

    Label(content, "Filters (optional)", y, true)
    y = y + 16
    Label(content, "Zone", y, true)
    y = y + 14
    Dropdown(content, Zones, State.ZoneDropdown, y, function(idx, text) State.ZoneDropdown = text end)
    y = y + DROP_H + GAP

    Label(content, "Classes", y, true)
    y = y + 14
    local classes = {
        { key = "DruidCheck", label = "Druid" }, { key = "HunterCheck", label = "Hunter" }, { key = "MageCheck", label = "Mage" },
        { key = "PaladinCheck", label = "Paladin" }, { key = "PriestCheck", label = "Priest" }, { key = "RogueCheck", label = "Rogue" },
        { key = "ShamanCheck", label = "Shaman" }, { key = "WarlockCheck", label = "Warlock" }, { key = "WarriorCheck", label = "Warrior" },
    }
    local cw, rh = 132, 18
    for i, c in ipairs(classes) do
        local r, col = math.floor((i - 1) / 3), (i - 1) % 3
        CheckBox(content, c.label, PAD + col * cw, y + r * rh, function() return State[c.key] end, function(v) State[c.key] = v end)
    end

    content:SetParent(container)
end
