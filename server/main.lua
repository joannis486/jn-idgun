-- jn-idgun | Server main
-- Handles permission checks, audit log, player info, consent notifications

local activeScanners = {}  -- track who has scanner active

-- ─────────────────────────────────────────────
--  Toggle Request
-- ─────────────────────────────────────────────
RegisterNetEvent('jn-idgun:server:requestToggle', function()
    local src = source

    if Config.RequirePermission then
        local hasAce = IsPlayerAceAllowed(src, Config.AcePermission)
        local hasJob = Bridge.HasJobPermission(src)

        if not hasAce and not hasJob then
            TriggerClientEvent('jn-idgun:client:denied', src)
            return
        end
    end

    -- Toggle tracking
    if activeScanners[src] then
        activeScanners[src] = nil
    else
        activeScanners[src] = true
    end

    TriggerClientEvent('jn-idgun:client:toggleAllowed', src)
end)

-- ─────────────────────────────────────────────
--  Player Info (callback-style via net event)
-- ─────────────────────────────────────────────
RegisterNetEvent('jn-idgun:server:getPlayerInfo', function(targetId)
    local src = source
    if not activeScanners[src] then return end

    local targetSrc = tonumber(targetId)
    if not targetSrc or not GetPlayerName(targetSrc) then
        TriggerClientEvent('jn-idgun:client:playerInfo', src, nil)
        return
    end

    local info = {
        name       = GetPlayerName(targetSrc),
        identifier = Bridge.GetPlayerIdentifier(targetSrc)
    }

    local job = Bridge.GetPlayerJob(targetSrc)
    if job then
        if type(job) == 'table' then
            info.job = job.label or job.name or 'Unknown'
        else
            info.job = tostring(job)
        end
    end

    TriggerClientEvent('jn-idgun:client:playerInfo', src, info)

    -- Consent notification
    if Config.ConsentMode then
        TriggerClientEvent('jn-idgun:client:consentNotify', targetSrc)
    end

    -- Audit log — player scanned
    if Config.AuditLog then
        local scannerName = GetPlayerName(src)
        print(T('audit_player_target', GetPlayerName(targetSrc), targetSrc))
        _ = scannerName -- suppress unused warning; main audit printed client-side
    end
end)

-- ─────────────────────────────────────────────
--  Audit Log
-- ─────────────────────────────────────────────
RegisterNetEvent('jn-idgun:server:audit', function(data)
    if not Config.AuditLog then return end
    if not activeScanners[source] then return end

    local src        = source
    local name       = GetPlayerName(src)
    local entityType = data.entityType or 'unknown'
    local model      = data.model or '?'

    print(T('audit_scan', name, src, entityType, model))

    if Config.NotifyAdminsOnScan then
        for _, playerId in ipairs(GetPlayers()) do
            local pid = tonumber(playerId)
            if pid ~= src and IsPlayerAceAllowed(pid, Config.AdminAce) then
                TriggerClientEvent('jn-idgun:client:adminNotify', pid, {
                    scanner    = name,
                    scannerId  = src,
                    entityType = entityType,
                    model      = model
                })
            end
        end
    end
end)

-- ─────────────────────────────────────────────
--  Copy Coords Log
-- ─────────────────────────────────────────────
RegisterNetEvent('jn-idgun:server:logCopy', function(data)
    if not Config.AuditLog then return end
    if not activeScanners[source] then return end

    local src    = source
    local name   = GetPlayerName(src)
    local coords = data.coords or '?'

    print(T('audit_copy', name, src, coords))
end)

-- ─────────────────────────────────────────────
--  Cleanup on player drop
-- ─────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    activeScanners[source] = nil
end)
