--[[
    DungeonFormer - Results tab: message box and scrollable list of /who results.
    Click a name to whisper and move to Whispered list.
]]

local DF = DungeonFormer
local Colors = DF.ClassColors

local ROW_HEIGHT = 18
local PADDING = 4
local CONTENT_TOP_PADDING = 10

local function GetClassColor(classStr)
    if not classStr then return 1, 1, 1 end
    local c = Colors[classStr]
    if c then return c.r, c.g, c.b end
    return 1, 1, 1
end

function DF.UI.BuildTabResults(container)
    local State = DF.State or {}
    local content = CreateFrame("Frame", nil, container)
    content:SetAllPoints(container)
    content:Show()

    local y = CONTENT_TOP_PADDING
    -- Message edit
    local msgLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    msgLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
    msgLabel:SetText("Message")
    local msgEdit = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    msgEdit:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y - 20)
    msgEdit:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y - 20)
    msgEdit:SetHeight(20)
    msgEdit:SetAutoFocus(false)
    msgEdit:SetText(State.MessageBox or "")
    msgEdit:SetScript("OnTextChanged", function(self)
        State.MessageBox = self:GetText()
    end)
    msgEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    y = y + 50

    -- Scroll area for player list
    local scrollFrame = CreateFrame("ScrollFrame", "DFResultsScroll", content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
    scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -24, 0)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollChild:SetPoint("LEFT", scrollFrame, "LEFT", 0, 0)
    scrollChild:SetPoint("RIGHT", scrollFrame, "RIGHT", 0, 0)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    local list = State.list or {}
    local totalHeight = 0
    for i, player in ipairs(list) do
        local name = player.fullName or "?"
        local level = player.level or "?"
        local classStr = player.classStr
        local area = player.area or ""
        local row = CreateFrame("Button", nil, scrollChild)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -totalHeight)
        row:SetPoint("LEFT", scrollChild, "LEFT", 0, -totalHeight)
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, -totalHeight)
        row:SetHeight(ROW_HEIGHT)
        row:SetScript("OnClick", function()
            local msg = State.MessageBox or ""
            if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox and ChatEdit_SendText then
                local edit = DEFAULT_CHAT_FRAME.editBox
                edit:SetText("/tell " .. name .. " " .. msg)
                ChatEdit_SendText(edit, 0)
            end
            table.insert(State.carelessWhispered, player)
            table.remove(State.list, i)
            DF.UI.SelectTab(1)
            DF.UI.SelectTab(2)
            DF.UI.SetStatusText("      " .. #(State.list or {}) .. " names collected.")
        end)
        row:SetScript("OnEnter", function(self) self.highlight:Show() end)
        row:SetScript("OnLeave", function(self) self.highlight:Hide() end)
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", row, "LEFT", 4, 0)
        label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        label:SetJustifyH("LEFT")
        label:SetText(name .. " " .. level .. " " .. area)
        local r, g, b = GetClassColor(classStr)
        label:SetTextColor(r, g, b, 1)
        local highlight = row:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        highlight:SetBlendMode("ADD")
        row.highlight = highlight
        highlight:Hide()
        totalHeight = totalHeight + ROW_HEIGHT
    end
    scrollChild:SetHeight(math.max(totalHeight, 1))
    -- Classic: ensure scroll child has width so rows are visible (template may not set it)
    local listWidth = 270
    scrollChild:SetWidth(listWidth)
    scrollFrame:SetScript("OnShow", function(self)
        local w = self:GetWidth()
        if w and w > 0 then scrollChild:SetWidth(w) end
    end)

    DF.UI.SetStatusText("      " .. #list .. " names collected.")
    content:SetParent(container)
end
