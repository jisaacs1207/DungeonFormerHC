--[[
    DungeonFormer - Contacted tab. Clean wide layout.
]]

local DF = DungeonFormer
local Colors = DF.ClassColors

local PAD = 14
local ROW_H = 20
local TOP = 12

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

    local y = TOP
    local replyLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    replyLabel:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    replyLabel:SetText("When someone you whispered replies, send this:")
    replyLabel:SetTextColor(0.75, 0.72, 0.65, 1)
    y = y + 18
    local replyEdit = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    replyEdit:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    replyEdit:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PAD, -y)
    replyEdit:SetHeight(22)
    replyEdit:SetAutoFocus(false)
    replyEdit:SetText(State.ReplyText or "")
    replyEdit:SetScript("OnTextChanged", function(self) State.ReplyText = self:GetText() end)
    replyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    y = y + 28

    local toggleLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    toggleLabel:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    toggleLabel:SetText("Auto-reply")
    toggleLabel:SetTextColor(0.7, 0.67, 0.6, 1)
    local replyBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    replyBtn:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 72, -y - 2)
    replyBtn:SetSize(56, 22)
    replyBtn:SetText(State.ReplyingButton == "On" and "On" or "Off")
    replyBtn:SetScript("OnClick", function()
        if State.ReplyingButton == "On" then
            State.ReplyingButton = "Off"
            DF.UI.SetStatusText("  Auto-reply off")
        else
            State.ReplyingButton = "On"
            DF.UI.SetStatusText("  Auto-reply on — will reply when they message")
        end
        replyBtn:SetText(State.ReplyingButton)
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
    end)
    y = y + 30

    local clearNRBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearNRBtn:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    clearNRBtn:SetSize(180, 24)
    clearNRBtn:SetText("Remove who didn't reply")
    clearNRBtn:SetScript("OnClick", function()
        local toremove = {}
        for i = 1, #(State.carelessWhispered or {}) do
            if not State.carelessWhispered[i].recentChat then table.insert(toremove, i) end
        end
        table.sort(toremove, function(a, b) return a > b end)
        for _, idx in ipairs(toremove) do table.remove(State.carelessWhispered, idx) end
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
        DF.UI.SetStatusText("  Removed players who didn't reply")
    end)
    local clearBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearBtn:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 186, -y)
    clearBtn:SetSize(90, 24)
    clearBtn:SetText("Clear all")
    clearBtn:SetScript("OnClick", function()
        State.carelessWhispered = {}
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
        DF.UI.SetStatusText("  Contacted list cleared")
    end)
    y = y + 30

    local list = State.carelessWhispered or {}

    if #list == 0 then
        local empty = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        empty:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        empty:SetPoint("RIGHT", content, "RIGHT", -PAD, 0)
        empty:SetWordWrap(true)
        empty:SetNonSpaceWrap(true)
        empty:SetText("No one contacted yet.\n\nWhen you whisper someone from the Players tab, they appear here. Click a name to move them back to Players.")
        empty:SetTextColor(0.55, 0.52, 0.48, 1)
    else
        local hint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        hint:SetText("Click a name to move back to Players")
        hint:SetTextColor(0.55, 0.52, 0.48, 1)
        y = y + 18

        local scrollFrame = CreateFrame("ScrollFrame", "DFWhisperedScroll", content, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -PAD - 20, 0)
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
        scrollChild:SetPoint("LEFT", scrollFrame, "LEFT", 0, 0)
        scrollChild:SetPoint("RIGHT", scrollFrame, "RIGHT", 0, 0)
        scrollChild:SetHeight(1)
        scrollFrame:SetScrollChild(scrollChild)
        scrollChild:SetWidth(380)

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
            row:SetHeight(ROW_H)
            row:SetScript("OnClick", function()
                table.insert(State.list, player)
                table.remove(State.carelessWhispered, i)
                DF.UI.SelectTab(1)
                DF.UI.SelectTab(3)
            end)
            row:SetScript("OnEnter", function(self) self.hl:Show() end)
            row:SetScript("OnLeave", function(self) self.hl:Hide() end)
            local r, g, b = GetClassColor(classStr)
            local line = message
                and ("|cff%02x%02x%02x[%s]|r %s  — %s"):format(r * 255, g * 255, b * 255, level, name, string.sub(message, 1, 24))
                or ("|cff%02x%02x%02x[%s]|r %s"):format(r * 255, g * 255, b * 255, level, name)
            local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", row, "LEFT", 6, 0)
            label:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            label:SetJustifyH("LEFT")
            label:SetText(line)
            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            hl:SetBlendMode("ADD")
            row.hl = hl
            hl:Hide()
            totalHeight = totalHeight + ROW_H
        end
        scrollChild:SetHeight(math.max(totalHeight, 1))
        scrollFrame:SetScript("OnShow", function(self)
            local w = self:GetWidth()
            if w and w > 0 then scrollChild:SetWidth(w) end
        end)
    end

    DF.UI.SetStatusText(#list > 0 and ("  " .. #list .. " contacted") or "  No one contacted yet")
    content:SetParent(container)
end
