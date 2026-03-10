--[[
    DungeonFormer - Main window and tab container.
    Native WoW frames only; no Ace dependencies.
]]

local DF = DungeonFormer
DF.UI = DF.UI or {}
local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local frame
local tabButtons = {}
local tabContent = {}
local currentTab = 1

local TAB_NAMES = { "Search", "Results", "Whispered" }

local function CreateMainFrame()
    local f = CreateFrame("Frame", "DungeonFormerFrame", UIParent, BackdropTemplate)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    if f.SetClampedToScreen then
        f:SetClampedToScreen(true)
    end
    f:SetMovable(true)
    f:SetWidth(320)
    f:SetHeight(420)
    f:SetPoint("CENTER")
    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 26,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
    end

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetPoint("TOPRIGHT", -14, -12)
    title:SetJustifyH("CENTER")
    title:SetText("Dungeon Former")
    f.title = title

    -- Close button (template name can vary by client)
    local closeTemplate = "UIPanelCloseButton"
    local closeBtn = CreateFrame("Button", nil, f, closeTemplate)
    if closeBtn then
        closeBtn:SetPoint("TOPRIGHT", -4, -4)
        closeBtn:SetScript("OnClick", function()
            f:Hide()
        end)
    end

    -- Title bar drag
    local drag = CreateFrame("Frame", nil, f)
    drag:SetPoint("TOPLEFT", 14, -8)
    drag:SetPoint("TOPRIGHT", -40, -8)
    drag:SetHeight(24)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function()
        if f.StartMoving then f:StartMoving() end
    end)
    drag:SetScript("OnDragStop", function()
        if f.StopMovingOrSizing then f:StopMovingOrSizing() end
    end)

    -- Status bar
    local status = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("BOTTOMLEFT", 14, 10)
    status:SetPoint("BOTTOMRIGHT", -14, 10)
    status:SetJustifyH("LEFT")
    status:SetText("")
    f.statusText = status

    -- Tab container (buttons row)
    local tabContainer = CreateFrame("Frame", nil, f)
    tabContainer:SetPoint("TOPLEFT", 14, -36)
    tabContainer:SetPoint("TOPRIGHT", -14, -36)
    tabContainer:SetHeight(24)
    f.tabContainer = tabContainer

    -- Content area (below tabs, above status); top inset so tab content never overlaps tab bar
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", 14, -68)
    content:SetPoint("BOTTOMRIGHT", -14, 28)
    -- Opaque background matching the dialog; use same inset as frame border so it lines up
    local bg = content:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(content)
    if bg.SetColorTexture then
        bg:SetColorTexture(0.12, 0.12, 0.12, 1)
    else
        bg:SetTexture("Interface\\Buttons\\WHITE8x8")
        if bg.SetVertexColor then
            bg:SetVertexColor(0.12, 0.12, 0.12)
        end
    end
    f.content = content

    -- Tab buttons
    for i, name in ipairs(TAB_NAMES) do
        local btn = CreateFrame("Button", "DungeonFormerTab" .. i, tabContainer, "OptionsFrameTabButtonTemplate")
        btn:SetText(name)
        btn:SetID(i)
        btn:SetScript("OnClick", function()
            DF.UI.SelectTab(i)
        end)
        tabButtons[i] = btn
        if i == 1 then
            btn:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, 6)
        else
            btn:SetPoint("LEFT", tabButtons[i - 1], "RIGHT", -2, 0)
        end
    end

    f:SetScript("OnHide", function() end)
    f:Hide()
    return f
end

function DF.UI.SelectTab(index)
    currentTab = index
    for i, btn in ipairs(tabButtons) do
        if i == index then
            if PanelTemplates_SelectTab then
                PanelTemplates_SelectTab(btn)
            end
        else
            if PanelTemplates_DeselectTab then
                PanelTemplates_DeselectTab(btn)
            end
        end
    end
    -- Remove old tab content and rebuild
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
    if frame then
        frame:Hide()
    end
end

function DF.UI.Toggle()
    if frame and frame:IsShown() then
        DF.UI.Hide()
    else
        DF.UI.Show()
    end
end

function DF.UI.RegisterTab(index, builder)
    tabContent[index] = builder
end

function DF.UI.GetCurrentTab()
    return currentTab
end
