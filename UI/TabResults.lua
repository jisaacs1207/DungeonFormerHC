--[[
    DungeonFormer - Players tab. Flat skin, custom scrollbar.
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

function DF.UI.BuildTabResults(container)
    local State = DF.State or {}
    local content = CreateFrame("Frame", nil, container)
    content:SetAllPoints(container)
    content:Show()

    local y = TOP
    local msgLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    msgLabel:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    msgLabel:SetText("Message to send when you click a player")
    msgLabel:SetTextColor(0.72, 0.7, 0.65, 1)
    y = y + 18
    local msgEdit = Skin.FlatEditBox(content, nil, 24)
    msgEdit:ClearAllPoints()
    msgEdit:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
    msgEdit:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PAD, -y)
    msgEdit:SetText(State.MessageBox or "")
    msgEdit:SetScript("OnTextChanged", function(self) State.MessageBox = self:GetText() end)
    y = y + 32

    local list = State.list or {}

    if #list == 0 then
        local empty = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        empty:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        empty:SetPoint("RIGHT", content, "RIGHT", -PAD, 0)
        empty:SetWordWrap(true)
        empty:SetNonSpaceWrap(true)
        empty:SetText("No players yet.\n\nUse Find Players to search, then come back here. Click a name to whisper and move them to Contacted.")
        empty:SetTextColor(0.52, 0.5, 0.46, 1)
    else
        local hint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -y)
        hint:SetText("Click a player to whisper them")
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
            local area = player.area or ""
            local row = CreateFrame("Button", nil, scrollChild)
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -totalHeight)
            row:SetPoint("LEFT", scrollChild, "LEFT", 0, -totalHeight)
            row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, -totalHeight)
            row:SetHeight(ROW_H)
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
                DF.UI.SetStatusText("  " .. #(State.list or {}) .. " players — click to whisper")
            end)
            row:SetScript("OnEnter", function(self) self.hl:Show() end)
            row:SetScript("OnLeave", function(self) self.hl:Hide() end)
            local r, g, b = GetClassColor(classStr)
            local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", row, "LEFT", 8, 0)
            label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            label:SetJustifyH("LEFT")
            label:SetText(("|cff%02x%02x%02x[%s]|r %s  %s"):format(r * 255, g * 255, b * 255, level, name, area ~= "" and ("— " .. area) or ""))
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

    DF.UI.SetStatusText(#list > 0 and ("  " .. #list .. " players — click to whisper") or "  No players yet — search in Find Players")
    content:SetParent(container)
end
