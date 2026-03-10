--[[
    DungeonFormer - Who list API compatibility layer.
    WoW Classic uses GetNumWhoResults() and GetWhoInfo(index) (multiple returns).
    Retail uses C_FriendList.GetNumWhoResults() and C_FriendList.GetWhoInfo(index) (table).
    This module normalizes to a single table shape: { fullName, level, classStr, area }.
]]

local DF = DungeonFormer

-- Returns number of who results (after a /who has been run).
function DF.GetNumWhoResults()
    if C_FriendList and C_FriendList.GetNumWhoResults then
        return C_FriendList.GetNumWhoResults()
    end
    return GetNumWhoResults and GetNumWhoResults() or 0
end

-- Returns a table { fullName, level, classStr, area } for the who result at index.
function DF.GetWhoInfo(index)
    if C_FriendList and C_FriendList.GetWhoInfo then
        local info = C_FriendList.GetWhoInfo(index)
        if info then
            return {
                fullName = info.fullName or info.name,
                level = info.level,
                classStr = info.classStr or info.classFileName or "",
                area = info.area or info.zone or "",
            }
        end
        return nil
    end
    if GetWhoInfo then
        local fullName, guild, level, race, class, zone, classFileName = GetWhoInfo(index)
        if fullName then
            return {
                fullName = fullName,
                level = level or 0,
                classStr = class or classFileName or "",
                area = zone or "",
            }
        end
    end
    return nil
end
