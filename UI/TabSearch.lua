--[[
    DungeonFormer - Search tab: dungeon/zone dropdowns, level range, class filters, Search button.
]]

local DF = DungeonFormer
local Colors = DF.ClassColors
local Dungeons = DF.Dungeons
local Zones = DF.Zones

local PADDING = 8
local ROW_HEIGHT = 24
local DROPDOWN_HEIGHT = 28
local SECTION_GAP = 10

local function CreateLabel(parent, text, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -y)
    label:SetText(text)
    return label
end

local function CreateEditBox(parent, width, y, labelText, getVal, setVal)
    local l = CreateLabel(parent, labelText, y)
    local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", 80, -y - 2)
    eb:SetWidth(width or 50)
    eb:SetHeight(20)
    eb:SetAutoFocus(false)
    eb:SetText(tostring(getVal and getVal() or ""))
    eb:SetScript("OnTextChanged", function(self)
        if setVal then setVal(self:GetText()) end
    end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return eb
end

local function CreateCheckBox(parent, labelText, y, getVal, setVal)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -y)
    cb.text:SetText(labelText)
    cb:SetChecked(getVal and getVal() or false)
    cb:SetScript("OnClick", function(self)
        if setVal then setVal(self:GetChecked()) end
    end)
    return cb
end

local function CreateButton(parent, text, width, y, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -y)
    btn:SetSize(width or 100, 22)
    btn:SetText(text)
    btn:SetScript("OnClick", function()
        if onClick then onClick() end
    end)
    return btn
end

-- Dropdown using UIDropDownMenu (Classic); guard APIs that may be missing in some builds
-- No extra label (dropdown shows selected text); positioned at y to avoid overlapping content above
local function CreateDropdown(parent, items, selectedText, y, onSelect)
    local name = "DFDropdown" .. tostring(y)
    local drop = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    drop:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -y)
    drop._selectedValue = 1
    if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(drop, 250) end
    if UIDropDownMenu_SetText then UIDropDownMenu_SetText(drop, selectedText or items[1]) end
    UIDropDownMenu_Initialize(drop, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local currentVal = (UIDropDownMenu_GetSelectedValue and UIDropDownMenu_GetSelectedValue(drop)) or drop._selectedValue
        for i, item in ipairs(items) do
            info.text = item
            info.value = i
            info.checked = (currentVal == i)
            info.func = function()
                drop._selectedValue = i
                if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(drop, i) end
                if UIDropDownMenu_SetText then UIDropDownMenu_SetText(drop, item) end
                if onSelect then onSelect(i, item) end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    drop.GetSelectedValue = function()
        return (UIDropDownMenu_GetSelectedValue and UIDropDownMenu_GetSelectedValue(drop)) or drop._selectedValue
    end
    drop.SetSelectedValue = function(_, val)
        drop._selectedValue = val
        if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(drop, val) end
        if UIDropDownMenu_SetText and items[val] then UIDropDownMenu_SetText(drop, items[val]) end
    end
    drop.SetText = function(_, t) if UIDropDownMenu_SetText then UIDropDownMenu_SetText(drop, t) end end
    return drop
end

local CONTENT_TOP_PADDING = 10

function DF.UI.BuildTabSearch(container)
    local State = DF.State or {}
    local y = CONTENT_TOP_PADDING
    local content = CreateFrame("Frame", nil, container)
    content:SetAllPoints(container)
    content:Show()

    -- Description: one line, then clear gap so dropdown doesn't overlap
    CreateLabel(content, "Limit your search. The result max is 50.", y)
    y = y + ROW_HEIGHT + SECTION_GAP

    -- Dungeon dropdown
    local dungeonNames = {}
    for i = 1, #Dungeons do
        dungeonNames[i] = Dungeons[i].name
    end
    local dungeonDropdown = CreateDropdown(content, dungeonNames, State.DungeonDropdown, y, function(idx, text)
        State.DungeonDropdown = text
        local d = Dungeons[idx]
        if d then
            State.LowLevel = d.low
            State.HighLevel = d.high
            State.MessageBox = "Hey, want to run " .. d.sname .. "?"
            -- Refresh tab so level boxes and message show updated State (don't reference lowLvl/highLvl; they're created later)
            DF.UI.SelectTab(1)
            DF.UI.SelectTab(1)
        end
    end)
    y = y + DROPDOWN_HEIGHT + SECTION_GAP

    -- Level range (label + edit on same row each)
    local lowLvl = CreateEditBox(content, 60, y, "Low Level", function() return State.LowLevel end, function(v) State.LowLevel = v end)
    y = y + ROW_HEIGHT + PADDING
    local highLvl = CreateEditBox(content, 60, y, "High Level", function() return State.HighLevel end, function(v) State.HighLevel = v end)
    y = y + ROW_HEIGHT + SECTION_GAP

    CreateButton(content, "Search", 100, y, function()
        DF.SearchPlayers()
    end)
    y = y + ROW_HEIGHT + SECTION_GAP

    -- Zone dropdown
    local zoneDropdown = CreateDropdown(content, Zones, State.ZoneDropdown, y, function(idx, text)
        State.ZoneDropdown = text
    end)
    y = y + DROPDOWN_HEIGHT + SECTION_GAP

    -- Class checkboxes (two columns)
    local classes = {
        { key = "DruidCheck", label = "Druid" },
        { key = "HunterCheck", label = "Hunter" },
        { key = "MageCheck", label = "Mage" },
        { key = "PaladinCheck", label = "Paladin" },
        { key = "PriestCheck", label = "Priest" },
        { key = "RogueCheck", label = "Rogue" },
        { key = "ShamanCheck", label = "Shaman" },
        { key = "WarlockCheck", label = "Warlock" },
        { key = "WarriorCheck", label = "Warrior" },
    }
    for i, c in ipairs(classes) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        local cy = y + row * (ROW_HEIGHT + 2)
        local cx = CreateCheckBox(content, c.label, cy, function() return State[c.key] end, function(v) State[c.key] = v end)
        cx:SetPoint("TOPLEFT", content, "TOPLEFT", col * 150, -cy)
    end

    content:SetParent(container)
end
