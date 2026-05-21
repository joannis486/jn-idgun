-- jn-idgun | Client-side framework bridge
-- Global: Bridge (used by client/main.lua)

Bridge = {
    Type    = 'standalone',
    Core    = nil,
    HasOxLib = false
}

CreateThread(function()
    Wait(500) -- allow all resources to start

    Bridge.HasOxLib = GetResourceState('ox_lib') ~= 'missing'

    local fw = Config.Framework

    if (fw == 'auto' or fw == 'qbox') and GetResourceState('qbx_core') ~= 'missing' then
        Bridge.Type = 'qbox'
        Bridge.Core = exports.qbx_core:GetCoreObject()
        return
    end
    if (fw == 'auto' or fw == 'qbcore') and GetResourceState('qb-core') ~= 'missing' then
        Bridge.Type = 'qbcore'
        Bridge.Core = exports['qb-core']:GetCoreObject()
        return
    end
    if (fw == 'auto' or fw == 'esx') and GetResourceState('es_extended') ~= 'missing' then
        Bridge.Type = 'esx'
        Bridge.Core = exports.es_extended:getSharedObject()
        return
    end

    Bridge.Type = 'standalone'
end)

function Bridge.Notify(msg, notifType, duration)
    notifType = notifType or 'inform'
    duration  = duration  or 3000

    if Bridge.HasOxLib then
        lib.notify({ description = msg, type = notifType, duration = duration })
        return
    end

    if Bridge.Type == 'qbox' or Bridge.Type == 'qbcore' then
        Bridge.Core.Functions.Notify(msg, notifType, duration)
        return
    end

    if Bridge.Type == 'esx' then
        Bridge.Core.ShowNotification(msg)
        return
    end

    -- Fallback: GTA notification
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, false)
end
