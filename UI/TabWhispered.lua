--[[
    DungeonFormer - Contacted tab. Flat skin, custom scrollbar.
]]

local DF = DungeonFormer
local Colors = DF.ClassColors
local Skin = DF.UI.Skin

local PAD = Skin.PAD or 14
local ROW_H = 20
local TOP = 14

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
    replyLabel:SetTextColor(0.72, 0.7, 0.65, 1)
    y = y + 18
    local replyEdit = Skin.FlatEditBox(content, nil, 24)
    replyEdit:ClearAllPoints()
    replyEdit:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    replyEdit:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PAD, -y)
    replyEdit:SetText(State.ReplyText or "")
    replyEdit:SetScript("OnTextChanged", function(self) State.ReplyText = self:GetText() end)
    y = y + 30

    local toggleLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    toggleLabel:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    toggleLabel:SetText("Auto-reply")
    toggleLabel:SetTextColor(0.68, 0.66, 0.6, 1)
    local replyBtn = Skin.FlatButton(content, 56, 24, State.ReplyingButton == "On" and "On" or "Off", function(btn)
        if State.ReplyingButton == "On" then
            State.ReplyingButton = "Off"
            DF.UI.SetStatusText("  Auto-reply off")
        else
            State.ReplyingButton = "On"
            DF.UI.SetStatusText("  Auto-reply on — will reply when they message")
        end
        if btn and btn.SetText then btn:SetText(State.ReplyingButton) end
    end, false)
    replyBtn:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 72, -y - 2)
    y = y + 32

    local clearNRBtn = Skin.FlatButton(content, 180, 26, "Remove who didn't reply", function()
        local toremove = {}
        for i = 1, #(State.carelessWhispered or {}) do
            if not State.carelessWhispered[i].recentChat then table.insert(toremove, i) end
        end
        table.sort(toremove, function(a, b) return a > b end)
        for _, idx in ipairs(toremove) do table.remove(State.carelessWhispered, idx) end
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
        DF.UI.SetStatusText("  Removed players who didn't reply")
    end, false)
    clearNRBtn:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    local clearBtn = Skin.FlatButton(content, 90, 26, "Clear all", function()
        State.carelessWhispered = {}
        DF.UI.SelectTab(1)
        DF.UI.SelectTab(3)
        DF.UI.SetStatusText("  Contacted list cleared")
    end, false)
    clearBtn:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 186, -y)
    y = y + 32

    local list = State.carelessWhispered or {}

    if #list == 0 then
        local empty = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        empty:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        empty:SetPoint("RIGHT", content, "RIGHT", -PAD, 0)
        empty:SetWordWrap(true)
        empty:SetNonSpaceWrap(true)
        empty:SetText("No one contacted yet.\n\nWhen you whisper someone from the Players tab, they appear here. Click a name to move them back to Players.")
        empty:SetTextColor(0.52, 0.5, 0.46, 1)
    else
        local hint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        hint:SetText("Click a name to move back to Players")
        hint:SetTextColor(0.52, 0.5, 0.46, 1)
        y = y + 20

        local scrollFrame, scrollChild = Skin.ScrollFrame(content, 10)
        scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -PAD, 0)
        local function updateScrollChildWidth()
            local w = scrollFrame:GetWidth()
            if w and w > 0 then scrollChild:SetWidth(math.max(1, w - 14)) end
        end
        updateScrollChildWidth()
        scrollFrame:SetScript("OnSizeChanged", function()
            updateScrollChildWidth()
            if scrollFrame.UpdateScroll then scrollFrame:UpdateScroll() end
        end)

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
            label:SetPoint("LEFT", row, "LEFT", 8, 0)
            label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            label:SetJustifyH("LEFT")
            label:SetText(line)
            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetTexture("Interface\\Buttons\\WHITE8x8")
            if hl.SetColorTexture then hl:SetColorTexture(1, 1, 1, 0.08) end
            row.hl = hl
            hl:Hide()
            totalHeight = totalHeight + ROW_H
        end
        scrollChild:SetHeight(math.max(totalHeight, 1))
        if scrollFrame.bar and scrollFrame.bar.SetValue then
            scrollFrame.bar:SetValue(0)
        end
        scrollFrame:Refresh()
    end

    DF.UI.SetStatusText(#list > 0 and ("  " .. #list .. " contacted") or "  No one contacted yet")
    content:SetParent(container)
end
