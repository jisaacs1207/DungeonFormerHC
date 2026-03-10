--[[
    DungeonFormer - Flat ElvUI/TSM-style controls.
    No Blizzard button/checkbox templates; minimal scrollbar.
]]

local DF = DungeonFormer
DF.UI = DF.UI or {}
DF.UI.Skin = DF.UI.Skin or {}

local PAD = 14
local -- Colors
    bgBtn = { 0.18, 0.18, 0.2, 1 }
local bgBtnHover = { 0.24, 0.24, 0.27, 1 }
local bgBtnPrimary = { 0.25, 0.45, 0.75, 1 }
local bgBtnPrimaryHover = { 0.35, 0.52, 0.82, 1 }
local bgInput = { 0.1, 0.1, 0.12, 1 }
local border = { 0.25, 0.25, 0.28, 1 }
local scrollTrack = { 0.12, 0.12, 0.14, 1 }
local scrollThumb = { 0.35, 0.35, 0.4, 1 }
local scrollThumbHover = { 0.45, 0.45, 0.5, 1 }
local checkBorder = { 0.35, 0.35, 0.38, 1 }
local checkFill = { 0.4, 0.62, 0.95, 1 }
local textColor = { 0.9, 0.88, 0.82, 1 }

local function setBg(tex, t)
    if not tex then return end
    if tex.SetColorTexture then
        tex:SetColorTexture(t[1], t[2], t[3], t[4] or 1)
    else
        tex:SetTexture("Interface\\Buttons\\WHITE8x8")
        if tex.SetVertexColor then tex:SetVertexColor(t[1], t[2], t[3]) end
    end
end

-- Flat button (no template)
function DF.UI.Skin.FlatButton(parent, width, height, text, onClick, primary)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, height)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(btn)
    setBg(bg, primary and bgBtnPrimary or bgBtn)
    btn.bg = bg
    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("CENTER", 0, 0)
    label:SetText(text)
    label:SetTextColor(textColor[1], textColor[2], textColor[3], 1)
    btn.label = label
    btn.SetText = function(self, t) if self.label then self.label:SetText(t or "") end end
    btn:SetScript("OnClick", function(self) if onClick then onClick(self) end end)
    btn:SetScript("OnEnter", function()
        setBg(btn.bg, primary and bgBtnPrimaryHover or bgBtnHover)
    end)
    btn:SetScript("OnLeave", function()
        setBg(btn.bg, primary and bgBtnPrimary or bgBtn)
    end)
    return btn
end

-- Flat checkbox: small square + colored label
function DF.UI.Skin.FlatCheckBox(parent, labelText, x, y, r, g, b, getVal, setVal)
    local cb = CreateFrame("Button", nil, parent)
    cb:SetSize(18, 18)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    cb:EnableMouse(true)
    cb:RegisterForClicks("LeftButtonUp")
    cb:SetHitRectInsets(-6, -6, -6, -6)
    cb:SetFrameLevel(parent:GetFrameLevel() + 10)
    local box = cb:CreateTexture(nil, "BACKGROUND")
    box:SetAllPoints(cb)
    setBg(box, bgInput)
    local borderTex = cb:CreateTexture(nil, "OVERLAY")
    borderTex:SetAllPoints(cb)
    borderTex:SetColorTexture(border[1], border[2], border[3], 1)
    cb.check = cb:CreateTexture(nil, "OVERLAY")
    cb.check:SetPoint("CENTER", 0, 0)
    cb.check:SetSize(10, 10)
    setBg(cb.check, checkFill)
    cb.check:Hide()
    cb:SetScript("OnClick", function()
        local v = not (getVal and getVal())
        if setVal then setVal(v) end
        cb.check:SetShown(v)
    end)
    cb:SetScript("OnEnter", function()
        setBg(box, bgBtnHover)
    end)
    cb:SetScript("OnLeave", function()
        setBg(box, bgInput)
    end)
    if getVal and getVal() then cb.check:Show() end
    local L = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    L:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    L:SetNonSpaceWrap(false)
    L:EnableMouse(false)
    L:SetText(labelText)
    L:SetTextColor(r or 0.85, g or 0.82, b or 0.78, 1)
    cb.label = L
    cb.SetChecked = function(self, v)
        self.check:SetShown(v)
    end
    cb.GetChecked = function(self)
        return self.check:IsShown()
    end
    return cb
end

-- Flat dropdown: trigger button + panel list (ElvUI/TSM style)
local ROW_H = 22
local LIST_MAX_H = 220
function DF.UI.Skin.FlatDropdown(parent, width, height, items, selectedIndex, onSelect)
    selectedIndex = math.max(1, math.min(selectedIndex or 1, #items))
    local trigger = CreateFrame("Button", nil, parent)
    trigger:SetSize((width and width > 0) and width or 200, height or 26)
    local bg = trigger:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(trigger)
    setBg(bg, bgInput)
    trigger.bg = bg
    local label = trigger:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("LEFT", trigger, "LEFT", 10, 0)
    label:SetPoint("RIGHT", trigger, "RIGHT", -24, 0)
    label:SetJustifyH("LEFT")
    label:SetWordWrap(false)
    trigger.label = label
    local arrow = trigger:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    arrow:SetPoint("RIGHT", trigger, "RIGHT", -8, 0)
    arrow:SetText("▼")
    arrow:SetTextColor(textColor[1], textColor[2], textColor[3], 0.8)
    trigger:SetScript("OnEnter", function() setBg(bg, bgBtnHover) end)
    trigger:SetScript("OnLeave", function() setBg(bg, bgInput) end)
    trigger._items = items
    trigger._selectedIndex = selectedIndex
    trigger._onSelect = onSelect
    trigger.label:SetText(items[selectedIndex] or "")
    trigger.SetSelectedValue = function(self, idx)
        idx = math.max(1, math.min(idx, #self._items))
        self._selectedIndex = idx
        self.label:SetText(self._items[idx] or "")
    end
    trigger.GetSelectedValue = function(self) return self._selectedIndex end
    trigger.SetText = function(self, t) self.label:SetText(t or "") end
    trigger:SetScript("OnClick", function(self)
        if self._list and self._list:IsShown() then
            self._list:Hide()
            return
        end
        local list = self._list
        if not list then
            local backdrop = CreateFrame("Button", nil, UIParent)
            backdrop:SetFrameStrata("TOOLTIP")
            backdrop:SetFrameLevel(1)
            backdrop:SetAllPoints(UIParent)
            backdrop:EnableMouse(true)
            backdrop:SetScript("OnClick", function() list:Hide() end)
            list = CreateFrame("Frame", nil, UIParent)
            list:SetFrameStrata("TOOLTIP")
            list:SetFrameLevel(100)
            if list.SetClampedToScreen then list:SetClampedToScreen(true) end
            list:SetWidth(math.max(200, self:GetWidth()))
            list:SetHeight(math.min(LIST_MAX_H, ROW_H * #self._items + 8))
            list._backdrop = backdrop
            local listBg = list:CreateTexture(nil, "BACKGROUND")
            listBg:SetAllPoints(list)
            setBg(listBg, bgInput)
            local listBorder = list:CreateTexture(nil, "BORDER")
            listBorder:SetAllPoints(list)
            listBorder:SetColorTexture(border[1], border[2], border[3], 0.9)
            local scroll, scrollChild = DF.UI.Skin.ScrollFrame(list, 8)
            scroll:SetPoint("TOPLEFT", list, "TOPLEFT", 4, -4)
            scroll:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -4, 4)
            scrollChild:SetWidth(self:GetWidth() - 20)
            scrollChild:SetHeight(ROW_H * #self._items)
            for i = 1, #self._items do
                local row = CreateFrame("Button", nil, scrollChild)
                row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * ROW_H)
                row:SetPoint("LEFT", scrollChild, "LEFT", 0, -(i - 1) * ROW_H)
                row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, -(i - 1) * ROW_H)
                row:SetHeight(ROW_H - 2)
                row:SetFrameLevel(scrollChild:GetFrameLevel() + 1)
                local rowBg = row:CreateTexture(nil, "BACKGROUND")
                rowBg:SetAllPoints(row)
                setBg(rowBg, bgBtn)
                row.bg = rowBg
                local rowLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                rowLabel:SetPoint("LEFT", row, "LEFT", 8, 0)
                rowLabel:SetPoint("RIGHT", row, "RIGHT", -8, 0)
                rowLabel:SetJustifyH("LEFT")
                rowLabel:SetText(self._items[i])
                rowLabel:SetWordWrap(false)
                row:SetScript("OnClick", function()
                    self:SetSelectedValue(i)
                    if self._onSelect then self._onSelect(i, self._items[i]) end
                    list:Hide()
                end)
                row:SetScript("OnEnter", function() setBg(rowBg, bgBtnHover) end)
                row:SetScript("OnLeave", function() setBg(rowBg, bgBtn) end)
            end
            list:SetScript("OnHide", function()
                if scroll.bar and scroll.bar.SetValue then scroll.bar:SetValue(0) end
                if list._backdrop then list._backdrop:Hide() end
            end)
            list._scroll = scroll
            list._scrollChild = scrollChild
            self._list = list
        end
        list:ClearAllPoints()
        list:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
        list:SetWidth(self:GetWidth())
        local n = #self._items
        list:SetHeight(math.min(LIST_MAX_H, ROW_H * n + 8))
        if list._scrollChild then
            list._scrollChild:SetWidth(math.max(1, list:GetWidth() - 20))
            list._scrollChild:SetHeight(ROW_H * n)
            if list._scroll and list._scroll.bar and list._scroll.bar.SetValue then
                list._scroll.bar:SetValue(0)
            end
            if list._scroll and list._scroll.Refresh then list._scroll:Refresh() end
        end
        if list._backdrop then
            list._backdrop:SetFrameLevel(list:GetFrameLevel() - 1)
            list._backdrop:Show()
        end
        list:Show()
    end)
    return trigger
end

-- Flat editbox (dark bg, subtle border)
function DF.UI.Skin.FlatEditBox(parent, width, height)
    local eb = CreateFrame("EditBox", nil, parent)
    eb:SetSize(width or 120, height or 22)
    eb:SetAutoFocus(false)
    eb:SetFontObject("GameFontHighlight")
    local bg = eb:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(eb)
    setBg(bg, bgInput)
    eb:SetTextInsets(8, 8, 3, 3)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return eb
end

-- Custom scroll frame with flat scrollbar
function DF.UI.Skin.ScrollFrame(parent, barWidth)
    barWidth = barWidth or 10
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    child:SetPoint("LEFT", scroll, "LEFT", 0, 0)
    child:SetPoint("RIGHT", scroll, "RIGHT", -barWidth - 4, 0)
    child:SetHeight(1)
    scroll:SetScrollChild(child)
    scroll.scrollChild = child

    local bar = CreateFrame("Slider", nil, scroll)
    bar:SetWidth(barWidth)
    bar:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
    bar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
    bar:SetMinMaxValues(0, 1000)
    bar:SetValueStep(1)
    bar:SetValue(0)
    bar:SetOrientation("VERTICAL")
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(bar)
    setBg(track, scrollTrack)
    local thumb = bar:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(barWidth - 2, 40)
    thumb:SetPoint("CENTER", bar, "CENTER", 0, 0)
    setBg(thumb, scrollThumb)
    bar.thumb = thumb
    bar:SetScript("OnValueChanged", function(self, value)
        local viewH = scroll:GetHeight()
        local contentH = child:GetHeight()
        local range = math.max(0, contentH - viewH)
        local offset = range * (value / 1000)
        if scroll.SetVerticalScroll then
            scroll:SetVerticalScroll(offset)
        else
            child:ClearAllPoints()
            child:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, -offset)
            child:SetPoint("LEFT", scroll, "LEFT", 0, -offset)
            child:SetPoint("RIGHT", scroll, "RIGHT", -barWidth - 4, -offset)
        end
    end)
    bar:SetScript("OnEnter", function() setBg(bar.thumb, scrollThumbHover) end)
    bar:SetScript("OnLeave", function() setBg(bar.thumb, scrollThumb) end)
    scroll.bar = bar
    scroll.UpdateScroll = function()
        local viewH = scroll:GetHeight()
        local contentH = child:GetHeight()
        if contentH <= viewH then
            bar:Hide()
        else
            bar:Show()
            bar:SetMinMaxValues(0, 1000)
        end
    end
    scroll.Refresh = function()
        local viewH = scroll:GetHeight()
        local contentH = child:GetHeight()
        if contentH <= viewH then
            bar:Hide()
        else
            bar:Show()
        end
    end
    scroll:SetScript("OnSizeChanged", scroll.UpdateScroll)
    if scroll.EnableMouseWheel then
        scroll:EnableMouseWheel(true)
        scroll:SetScript("OnMouseWheel", function(_, delta)
            bar:SetValue(math.max(0, math.min(1000, bar:GetValue() - delta * 80)))
        end)
    end
    return scroll, child
end

DF.UI.Skin.PAD = PAD
DF.UI.Skin.textColor = textColor
