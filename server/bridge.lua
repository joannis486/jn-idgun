-- jn-idgun | Server-side framework bridge
-- Global: Bridge (used by server/main.lua)

Bridge = {
    Type = 'standalone',
    Core = nil
}

local function detectFramework()
    local fw = Config.Framework

    if (fw == 'auto' or fw == 'qbox') and GetResourceState('qbx_core') ~= 'missing' then
        return 'qbox', exports.qbx_core:GetCoreObject()
    end
    if (fw == 'auto' or fw == 'qbcore') and GetResourceState('qb-core') ~= 'missing' then
        return 'qbcore', exports['qb-core']:GetCoreObject()
    end
    if (fw == 'auto' or fw == 'esx') and GetResourceState('es_extended') ~= 'missing' then
        return 'esx', exports.es_extended:getSharedObject()
    end
    return 'standalone', nil
end

CreateThread(function()
    Wait(100)
    Bridge.Type, Bridge.Core = detectFramework()
    print(('[jn-idgun] Framework: %s'):format(Bridge.Type))
end)

function Bridge.GetPlayerJob(source)
    if not Bridge.Core then return nil end

    if Bridge.Type == 'qbox' or Bridge.Type == 'qbcore' then
        local player = Bridge.Core.Functions.GetPlayer(source)
        return player and player.PlayerData.job or nil
    end

    if Bridge.Type == 'esx' then
        local player = Bridge.Core.GetPlayerFromId(source)
        return player and player.getJob() or nil
    end

    return nil
end

function Bridge.GetPlayerIdentifier(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id and id:find('license:') then
            return id
        end
    end
    return 'unknown'
end

function Bridge.HasJobPermission(source)
    if not Config.UseJobWhitelist then return false end

    local job = Bridge.GetPlayerJob(source)
    if not job then return false end

    local jobName = (type(job) == 'table') and (job.name or '') or tostring(job)
    for _, allowed in ipairs(Config.AllowedJobs) do
        if jobName == allowed then return true end
    end
    return false
end
