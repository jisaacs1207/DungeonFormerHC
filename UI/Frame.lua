--[[
    DungeonFormer - Main window. Clean, flat style (TSM/ElvUI-like).
    No Blizzard dialog chrome; solid dark background, thin border, custom tabs.
]]

local DF = DungeonFormer
DF.UI = DF.UI or {}
local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local frame
local tabButtons = {}
local tabContent = {}
local currentTab = 1

local TAB_NAMES = { "Find Players", "Players", "Contacted" }
local FRAME_WIDTH = 440
local FRAME_HEIGHT = 520
local TITLE_HEIGHT = 32
local TAB_HEIGHT = 28
local STATUS_HEIGHT = 22
local PADDING = 16
local BORDER = 1

-- Colors (flat dark theme)
local COLORS = {
    bg = { 0.06, 0.06, 0.08, 1 },
    bgTitle = { 0.09, 0.09, 0.11, 1 },
    bgTab = { 0.07, 0.07, 0.09, 1 },
    bgTabActive = { 0.06, 0.06, 0.08, 1 },
    border = { 0.2, 0.2, 0.22, 1 },
    text = { 0.9, 0.88, 0.82, 1 },
    textDim = { 0.55, 0.52, 0.48, 1 },
    accent = { 0.4, 0.65, 0.95, 1 },
}

local function CreateBackdrop(f, bg, useBorder)
    local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints(f)
    if tex.SetColorTexture then
        tex:SetColorTexture(bg[1], bg[2], bg[3], bg[4] or 1)
    else
        tex:SetTexture("Interface\\Buttons\\WHITE8x8")
        if tex.SetVertexColor then
            tex:SetVertexColor(bg[1], bg[2], bg[3])
        end
    end
    if useBorder and f.SetBackdrop then
        f:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        f:SetBackdropBorderColor(COLORS.border[1], COLORS.border[2], COLORS.border[3], 1)
    end
end

local function CreateMainFrame()
    local f = CreateFrame("Frame", "DungeonFormerFrame", UIParent, BackdropTemplate)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    if f.SetClampedToScreen then f:SetClampedToScreen(true) end
    f:SetMovable(true)
    f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    f:SetPoint("CENTER")
    CreateBackdrop(f, COLORS.bg, true)

    -- Title bar (flat bar)
    local titleBar = CreateFrame("Frame", nil, f)
    titleBar:SetPoint("TOPLEFT", BORDER, -BORDER)
    titleBar:SetPoint("TOPRIGHT", -BORDER, -BORDER)
    titleBar:SetHeight(TITLE_HEIGHT)
    CreateBackdrop(titleBar, COLORS.bgTitle, false)
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleBar, "LEFT", PADDING, 0)
    title:SetPoint("RIGHT", titleBar, "RIGHT", -36, 0)
    title:SetJustifyH("LEFT")
    title:SetText("Dungeon Former")
    title:SetTextColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], 1)
    f.title = title

    -- Close (minimal X)
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("TOPRIGHT", 0, 0)
    local closeTex = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeTex:SetAllPoints(closeBtn)
    if closeTex.SetColorTexture then
        closeTex:SetColorTexture(0.2, 0.2, 0.22, 0.6)
    end
    local closeLabel = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    closeLabel:SetPoint("CENTER", 0, 0)
    closeLabel:SetText("×")
    closeLabel:SetTextColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], 1)
    closeBtn:SetScript("OnClick", function() f:Hide() end)
    closeBtn:SetScript("OnEnter", function()
        if closeTex.SetColorTexture then closeTex:SetColorTexture(0.4, 0.22, 0.22, 0.9) end
    end)
    closeBtn:SetScript("OnLeave", function()
        if closeTex.SetColorTexture then closeTex:SetColorTexture(0.2, 0.2, 0.22, 0.6) end
    end)

    -- Drag region
    local drag = CreateFrame("Frame", nil, titleBar)
    drag:SetPoint("TOPLEFT", 0, 0)
    drag:SetPoint("BOTTOMRIGHT", closeBtn, "BOTTOMLEFT", 0, 0)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() if f.StartMoving then f:StartMoving() end end)
    drag:SetScript("OnDragStop", function() if f.StopMovingOrSizing then f:StopMovingOrSizing() end end)

    -- Tab bar (flat, no Blizzard template)
    local tabBar = CreateFrame("Frame", nil, f)
    tabBar:SetPoint("TOPLEFT", BORDER, -(TITLE_HEIGHT + BORDER))
    tabBar:SetPoint("TOPRIGHT", -BORDER, -(TITLE_HEIGHT + BORDER))
    tabBar:SetHeight(TAB_HEIGHT)
    CreateBackdrop(tabBar, COLORS.bgTab, false)
    f.tabContainer = tabBar

    local tabWidth = (FRAME_WIDTH - 2 * BORDER - (PADDING * 2)) / #TAB_NAMES
    for i, name in ipairs(TAB_NAMES) do
        local btn = CreateFrame("Button", "DungeonFormerTab" .. i, tabBar)
        btn:SetSize(tabWidth - 4, TAB_HEIGHT - 4)
        btn:SetPoint("LEFT", tabBar, "LEFT", PADDING + (i - 1) * tabWidth + 2, 0)
        btn:SetID(i)
        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints(btn)
        if btn.bg.SetColorTexture then
            btn.bg:SetColorTexture(0, 0, 0, 0)
        end
        btn.line = btn:CreateTexture(nil, "OVERLAY")
        btn.line:SetPoint("BOTTOMLEFT", 0, 0)
        btn.line:SetPoint("BOTTOMRIGHT", 0, 0)
        btn.line:SetHeight(2)
        if btn.line.SetColorTexture then
            btn.line:SetColorTexture(COLORS.accent[1], COLORS.accent[2], COLORS.accent[3], 0)
        end
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        btn.text:SetAllPoints(btn)
        btn.text:SetJustifyH("CENTER")
        btn.text:SetText(name)
        btn.text:SetTextColor(COLORS.textDim[1], COLORS.textDim[2], COLORS.textDim[3], 1)
        btn:SetScript("OnClick", function()
            DF.UI.SelectTab(i)
        end)
        btn:SetScript("OnEnter", function(self)
            if not (currentTab == i) then
                self.text:SetTextColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], 1)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not (currentTab == i) then
                self.text:SetTextColor(COLORS.textDim[1], COLORS.textDim[2], COLORS.textDim[3], 1)
            end
        end)
        tabButtons[i] = btn
    end

    -- Content area
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", BORDER + 2, -(TITLE_HEIGHT + TAB_HEIGHT + BORDER + 2))
    content:SetPoint("BOTTOMRIGHT", -(BORDER + 2), STATUS_HEIGHT + BORDER + 2)
    CreateBackdrop(content, COLORS.bg, false)
    f.content = content

    -- Status bar
    local statusBar = CreateFrame("Frame", nil, f)
    statusBar:SetPoint("BOTTOMLEFT", BORDER, BORDER)
    statusBar:SetPoint("BOTTOMRIGHT", -BORDER, BORDER)
    statusBar:SetHeight(STATUS_HEIGHT)
    CreateBackdrop(statusBar, COLORS.bgTitle, false)
    local status = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("LEFT", statusBar, "LEFT", PADDING, 0)
    status:SetPoint("RIGHT", statusBar, "RIGHT", -PADDING, 0)
    status:SetJustifyH("LEFT")
    status:SetText("/df to open  •  Click a name to whisper")
    status:SetTextColor(COLORS.textDim[1], COLORS.textDim[2], COLORS.textDim[3], 1)
    f.statusText = status

    f:SetScript("OnHide", function() end)
    f:Hide()
    return f
end

function DF.UI.SelectTab(index)
    currentTab = index
    for i, btn in ipairs(tabButtons) do
        local active = (i == index)
        if btn.bg and btn.bg.SetColorTexture then
            btn.bg:SetColorTexture(active and COLORS.bgTabActive[1] or 0, COLORS.bgTabActive[2] or 0, COLORS.bgTabActive[3] or 0, active and 0.5 or 0)
        end
        if btn.line and btn.line.SetColorTexture then
            btn.line:SetColorTexture(COLORS.accent[1], COLORS.accent[2], COLORS.accent[3], active and 1 or 0)
        end
        if btn.text then
            btn.text:SetTextColor(active and COLORS.text[1] or COLORS.textDim[1], active and COLORS.text[2] or COLORS.textDim[2], active and COLORS.text[3] or COLORS.textDim[3], 1)
        end
    end
    local content = frame.content
    local children = { content:GetChildren() }
    for _, child in pairs(children) do
        child:SetParent(nil)
        child:Hide()
    end
    if tabContent[index] then
        tabContent[index](content)
    end
    DF.State.currentTab = index
end

function DF.UI.SetStatusText(text)
    if frame and frame.statusText then
        frame.statusText:SetText(text or "")
    end
end

function DF.UI.GetFrame()
    return frame
end

function DF.UI.Show()
    if not frame then
        frame = CreateMainFrame()
    end
    frame:Show()
    DF.UI.SelectTab(DF.State.currentTab or 1)
end

function DF.UI.Hide()
    if frame then frame:Hide() end
end

function DF.UI.Toggle()
    if frame and frame:IsShown() then DF.UI.Hide() else DF.UI.Show() end
end

function DF.UI.RegisterTab(index, builder)
    tabContent[index] = builder
end

function DF.UI.GetCurrentTab()
    return currentTab
end
