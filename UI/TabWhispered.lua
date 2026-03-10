--[[
    DungeonFormer - Whispered tab: auto-reply settings and list of whispered players.
    Click a name to move back to Results. Clear / Clear No-Reply buttons.
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

function DF.UI.BuildTabWhispered(container)
    local State = DF.State or {}
    local content = CreateFrame("Frame", nil, container)
    content:SetAllPoints(container)
    content:Show()

    local y = CONTENT_TOP_PADDING
    -- Auto-reply edit
    local replyLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    replyLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
    replyLabel:SetText("Auto-reply")
    local replyEdit = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    replyEdit:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y - 20)
    replyEdit:SetWidth(170)
    replyEdit:SetHeight(20)
    replyEdit:SetAutoFocus(false)
    replyEdit:SetText(State.ReplyText or "")
    replyEdit:SetScript("OnTextChanged", function(self)
        State.ReplyText = self:GetText()
    end)
    replyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    y = y + 28

    -- On/Off toggle button
    local replyBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    replyBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 180, -y + 6)
    replyBtn:SetSize(65, 22)
    replyBtn:SetText(State.ReplyingButton or "Off")
    replyBtn:SetScript("OnClick", function()
        if State.ReplyingButton == "On" then
            State.ReplyingButton = "Off"
            DF.UI.SetStatusText("Stopped Auto-Replying")
        else
            State.ReplyingButton = "On"
            DF.UI.SetStatusText("Auto-Replying.")
        end
        replyBtn:SetText(State.ReplyingButton)
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
    end)
    y = y + 32

    -- Clear No-Reply and Clear List buttons
    local clearNRBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearNRBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
    clearNRBtn:SetSize(120, 22)
    clearNRBtn:SetText("Clear No-Reply")
    clearNRBtn:SetScript("OnClick", function()
        local toremove = {}
        for i = 1, #(State.carelessWhispered or {}) do
            if not State.carelessWhispered[i].recentChat then
                table.insert(toremove, i)
            end
        end
        table.sort(toremove, function(a, b) return a > b end)
        for _, idx in ipairs(toremove) do
            table.remove(State.carelessWhispered, idx)
        end
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
        DF.UI.SetStatusText("No-Replies Cleared")
    end)
    local clearBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 126, -y)
    clearBtn:SetSize(120, 22)
    clearBtn:SetText("Clear List")
    clearBtn:SetScript("OnClick", function()
        State.carelessWhispered = {}
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
        DF.UI.SetStatusText("Whispers cleared.")
    end)
    y = y + 30

    -- Scroll area for whispered list
    local scrollFrame = CreateFrame("ScrollFrame", "DFWhisperedScroll", content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
    scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -24, 0)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollChild:SetPoint("LEFT", scrollFrame, "LEFT", 0, 0)
    scrollChild:SetPoint("RIGHT", scrollFrame, "RIGHT", 0, 0)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(270)

    local list = State.carelessWhispered or {}
    local totalHeight = 0
    for i, player in ipairs(list) do
        local name = player.fullName or "?"
        local level = player.level or "?"
        local classStr = player.classStr
        local message = player.recentChat
        local row = CreateFrame("Button", nil, scrollChild)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -totalHeight)
        row:SetPoint("LEFT", scrollChild, "LEFT", 0, -totalHeight)
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, -totalHeight)
        row:SetHeight(ROW_HEIGHT)
        row:SetScript("OnClick", function()
            table.insert(State.list, player)
            table.remove(State.carelessWhispered, i)
            DF.UI.SelectTab(1)
            DF.UI.SelectTab(3)
        end)
        row:SetScript("OnEnter", function(self) self.highlight:Show() end)
        row:SetScript("OnLeave", function(self) self.highlight:Hide() end)
        local playerString
        if not message then
            playerString = level .. " " .. name
        else
            playerString = level .. " " .. name .. ": " .. message
        end
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", row, "LEFT", 4, 0)
        label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        label:SetJustifyH("LEFT")
        label:SetText(playerString)
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
    scrollFrame:SetScript("OnShow", function(self)
        local w = self:GetWidth()
        if w and w > 0 then scrollChild:SetWidth(w) end
    end)

    DF.UI.SetStatusText("      " .. #(State.list or {}) .. " names collected.")
    content:SetParent(container)
end
