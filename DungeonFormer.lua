--[[
    DungeonFormer - Main entry point.
    Slash command, state, search/pull-who logic, and whisper event handling.
    No Ace dependencies.
]]

local DF = DungeonFormer
if not DF then return end

-- ---------------------------------------------------------------------------
-- State (saved and runtime)
-- ---------------------------------------------------------------------------
DF.State = DF.State or {
    currentTab = 1,
    DungeonDropdown = "Choose A Dungeon",
    ZoneDropdown = "All Zones",
    LowLevel = 1,
    HighLevel = 10,
    MessageBox = "Hey, wanna watch Zool Babies with me?",
    ReplyText = "Group's filled, sorry!",
    ReplyingButton = "Off",
    list = {},
    carelessWhispered = {},
    -- Class filter toggles (not saved by original; we keep in state)
    DruidCheck = false,
    HunterCheck = false,
    MageCheck = false,
    PaladinCheck = false,
    PriestCheck = false,
    RogueCheck = false,
    ShamanCheck = false,
    WarlockCheck = false,
    WarriorCheck = false,
}

-- Load saved variables into State
function DF.LoadSavedVariables()
    if not DungeonFormerDB then
        DungeonFormerDB = {}
    end
    local db = DungeonFormerDB
    if db.carelessWhispered then
        DF.State.carelessWhispered = db.carelessWhispered
    end
    -- Migrate from legacy global
    if carelessWhispered and type(carelessWhispered) == "table" and #carelessWhispered > 0 and #(DF.State.carelessWhispered or {}) == 0 then
        DF.State.carelessWhispered = carelessWhispered
    end
end

function DF.SaveSavedVariables()
    DungeonFormerDB = DungeonFormerDB or {}
    DungeonFormerDB.carelessWhispered = DF.State.carelessWhispered
end

-- ---------------------------------------------------------------------------
-- Search and Who
-- ---------------------------------------------------------------------------
function DF.SearchPlayers()
    local State = DF.State
    State.list = {}

    local classChecked = State.DruidCheck or State.HunterCheck or State.MageCheck or
        State.PaladinCheck or State.PriestCheck or State.RogueCheck or
        State.ShamanCheck or State.WarlockCheck or State.WarriorCheck

    local msg = "/who "
    local low = tostring(State.LowLevel or 1)
    local high = tostring(State.HighLevel or 10)

    if State.ZoneDropdown and State.ZoneDropdown ~= "All Zones" then
        msg = msg .. "z-\"" .. State.ZoneDropdown .. "\" "
    end

    if classChecked then
        if State.DruidCheck then msg = msg .. "c-druid " end
        if State.HunterCheck then msg = msg .. "c-hunter " end
        if State.MageCheck then msg = msg .. "c-mage " end
        if State.PaladinCheck then msg = msg .. "c-paladin " end
        if State.PriestCheck then msg = msg .. "c-priest " end
        if State.RogueCheck then msg = msg .. "c-rogue " end
        if State.ShamanCheck then msg = msg .. "c-shaman " end
        if State.WarlockCheck then msg = msg .. "c-warlock " end
        if State.WarriorCheck then msg = msg .. "c-warrior " end
    end

    msg = msg .. low .. "-" .. high

    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox then
        local edit = DEFAULT_CHAT_FRAME.editBox
        edit:SetText(msg)
        if ChatEdit_SendText then
            ChatEdit_SendText(edit, 0)
        end
    end

    -- Wait for who results: use WHO_LIST_UPDATE when available, else fallback timer
    DF._waitingForWho = true
    if C_Timer and C_Timer.After then
        C_Timer.After(2, function()
            if DF._waitingForWho then
                DF._waitingForWho = nil
                DF.PullWho()
            end
        end)
    else
        local delay = 0
        local timerFrame = CreateFrame("Frame")
        timerFrame:SetScript("OnUpdate", function(self, elapsed)
            delay = delay + elapsed
            if delay >= 2 and DF._waitingForWho then
                DF._waitingForWho = nil
                self:SetScript("OnUpdate", nil)
                DF.PullWho()
            end
        end)
    end
end

function DF.PullWho()
    local State = DF.State
    if not State.carelessWhispered then
        State.carelessWhispered = {}
    end

    local numResults = DF.GetNumWhoResults()
    for i = 1, numResults do
        local info = DF.GetWhoInfo(i)
        if info then
            local addToTable = true
            for j = 1, #State.carelessWhispered do
                if State.carelessWhispered[j].fullName == info.fullName then
                    addToTable = false
                    break
                end
            end
            if addToTable then
                table.insert(State.list, info)
            end
        end
    end

    if ToggleFriendsFrame then
        ToggleFriendsFrame(2)
    end
    DF.UI.SelectTab(2)
end

-- ---------------------------------------------------------------------------
-- Slash command
-- ---------------------------------------------------------------------------
SLASH_DUNGEONFORMER1 = "/df"
if SlashCmdList then
    SlashCmdList["DUNGEONFORMER"] = function()
        DF.UI.Toggle()
    end
end

-- ---------------------------------------------------------------------------
-- Whisper event (auto-reply, track recentChat)
-- ---------------------------------------------------------------------------
local function OnWhisper(_, event, message, author)
    local State = DF.State
    if not State.carelessWhispered then return end
    author = author:gsub("%-[^%-]+$", "") -- strip realm
    for i = 1, #State.carelessWhispered do
        local name = State.carelessWhispered[i].fullName
        if name and (name == author or name:find(author) or author:find(name)) then
            State.carelessWhispered[i].recentChat = string.sub(message or "", 1, 20)
            if DF.UI.GetCurrentTab() == 3 then
                DF.UI.SelectTab(1)
                DF.UI.SelectTab(3)
            end
            if State.ReplyingButton == "On" then
                if not State.carelessWhispered[i].autoreplied then
                    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox and ChatEdit_SendText then
                        local edit = DEFAULT_CHAT_FRAME.editBox
                        edit:SetText("/tell " .. author .. " " .. (State.ReplyText or ""))
                        ChatEdit_SendText(edit, 0)
                    end
                    State.carelessWhispered[i].autoreplied = true
                end
            end
            break
        end
    end
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "DungeonFormer" then
        DF.LoadSavedVariables()
        DF.UI = DF.UI or {}
        DF.UI.RegisterTab(1, DF.UI.BuildTabSearch)
        DF.UI.RegisterTab(2, DF.UI.BuildTabResults)
        DF.UI.RegisterTab(3, DF.UI.BuildTabWhispered)
    end
end)

-- Who list: when results arrive, pull them and show Results tab (if event exists in this client)
local whoFrame = CreateFrame("Frame")
if whoFrame.RegisterEvent then
    whoFrame:RegisterEvent("WHO_LIST_UPDATE")
    whoFrame:SetScript("OnEvent", function(_, event)
        if event == "WHO_LIST_UPDATE" and DF._waitingForWho then
            DF._waitingForWho = nil
            DF.PullWho()
        end
    end)
end

-- Whisper listener
local whisperFrame = CreateFrame("Frame")
whisperFrame:RegisterEvent("CHAT_MSG_WHISPER")
whisperFrame:SetScript("OnEvent", OnWhisper)

-- Save on logout
local logoutFrame = CreateFrame("Frame")
logoutFrame:RegisterEvent("PLAYER_LOGOUT")
logoutFrame:SetScript("OnEvent", DF.SaveSavedVariables)
