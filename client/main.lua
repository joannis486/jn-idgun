-- jn-idgun | Client main
-- Core scanner logic: entity detection, data collection, thread management

local isActive     = false
local scanHistory  = {}
local lastScanData = nil
local historyOpen  = false

-- Weapon management
local SCANNER_WEAPON  = GetHashKey('WEAPON_FLASHLIGHT')
local prevWeapon      = nil
local hadScannerWeapon = false

local function equipScanner()
    local ped = cache.ped or PlayerPedId()
    prevWeapon        = GetSelectedPedWeapon(ped)
    hadScannerWeapon  = HasPedGotWeapon(ped, SCANNER_WEAPON, false)
    if not hadScannerWeapon then
        GiveWeaponToPed(ped, SCANNER_WEAPON, 0, false, true)
    end
    SetCurrentPedWeapon(ped, SCANNER_WEAPON, true)
end

local function unequipScanner()
    local ped = cache.ped or PlayerPedId()
    if not hadScannerWeapon then
        RemoveWeaponFromPed(ped, SCANNER_WEAPON)
    end
    if prevWeapon then
        SetCurrentPedWeapon(ped, prevWeapon, true)
        prevWeapon = nil
    end
end

-- Load hash lookup table
local Hashes = {}
do
    local raw = LoadResourceFile(GetCurrentResourceName(), 'data/hashes.json')
    if raw then Hashes = json.decode(raw) or {} end
end

local function resolveHash(hash)
    return Hashes[tostring(hash)] or tostring(hash)
end

local function formatCoords(c)
    return ('%.4f, %.4f, %.4f'):format(c.x, c.y, c.z)
end

local function getEntityTypeStr(entity)
    if IsEntityAPed(entity) then
        local idx = NetworkGetPlayerIndexFromPed(entity)
        if idx and idx >= 0 and GetPlayerServerId(idx) > 0 then
            return 'player'
        end
        return 'ped'
    end
    if IsEntityAVehicle(entity)  then return 'vehicle' end
    if IsEntityAnObject(entity)  then return 'object'  end
    return 'unknown'
end

local function getAimedEntity()
    local result, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if result and DoesEntityExist(entity) then
        return entity
    end
    return nil
end

-- ─────────────────────────────────────────────
--  Entity data collection
-- ─────────────────────────────────────────────
local function collectData(entity)
    local coords   = GetEntityCoords(entity)
    local myCoords = GetEntityCoords(cache.ped or PlayerPedId())
    local dist     = #(coords - myCoords)

    if dist > Config.MaxScanDistance then return nil, 'range' end

    local heading  = GetEntityHeading(entity)
    local model    = GetEntityModel(entity)
    local eType    = getEntityTypeStr(entity)

    local data = {
        type      = eType,
        model     = resolveHash(model),
        hash      = model,
        coords    = formatCoords(coords),
        rawCoords = { x = coords.x, y = coords.y, z = coords.z },
        heading   = ('%.2f°'):format(heading),
        distance  = ('%.1f m'):format(dist),
        timestamp = os.date('%H:%M:%S')
    }

    -- Ped / Player shared fields
    if eType == 'ped' or eType == 'player' then
        if Config.ShowHealth then
            local hp = GetEntityHealth(entity) - 100
            data.health = math.max(0, math.floor(hp)) .. ' / 100'
        end
        if Config.ShowArmor then
            data.armor = math.floor(GetPedArmour(entity)) .. ' / 100'
        end
    end

    -- Player-only fields (need server callback for job)
    if eType == 'player' then
        local idx = NetworkGetPlayerIndexFromPed(entity)
        data.serverid   = GetPlayerServerId(idx)
        data.playername = GetPlayerName(idx)

        if Config.ShowPing then
            data.ping = GetPlayerPing(idx) .. ' ms'
        end
        if Config.ShowWantedLevel then
            data.wanted = GetPlayerWantedLevel(idx)
        end
    end

    -- Vehicle fields
    if eType == 'vehicle' then
        data.plate = GetVehicleNumberPlateText(entity)
        data.fuel  = math.floor(GetVehicleFuelLevel(entity)) .. '%'
        data.color = { GetVehicleColours(entity) }

        local driverPed = GetPedInVehicleSeat(entity, -1)
        if DoesEntityExist(driverPed) then
            local driverIdx = NetworkGetPlayerIndexFromPed(driverPed)
            if driverIdx and driverIdx >= 0 and GetPlayerServerId(driverIdx) > 0 then
                data.driver   = GetPlayerName(driverIdx)
                data.driverid = GetPlayerServerId(driverIdx)
            end
        end
    end

    return data
end

-- ─────────────────────────────────────────────
--  History
-- ─────────────────────────────────────────────
local function pushHistory(data)
    if not data then return end
    table.insert(scanHistory, 1, {
        type      = data.type,
        model     = data.model,
        coords    = data.coords,
        timestamp = data.timestamp
    })
    while #scanHistory > Config.HistorySize do
        table.remove(scanHistory)
    end
end

-- ─────────────────────────────────────────────
--  Main scanner thread
-- ─────────────────────────────────────────────
local playerInfoPending = false
local lastPlayerTarget  = -1

CreateThread(function()
    while true do
        if not isActive then
            Wait(250)
        else
            Wait(50)

            local entity = getAimedEntity()

            if not entity or not DoesEntityExist(entity) then
                SendNUIMessage({ action = 'idle' })
                playerInfoPending = false
                lastPlayerTarget  = -1
            else
                local data, reason = collectData(entity)

                if not data then
                    SendNUIMessage({ action = reason == 'range' and 'outOfRange' or 'idle' })
                else
                    lastScanData = data

                    -- Async: fetch job info for player targets
                    if data.type == 'player' and data.serverid ~= lastPlayerTarget then
                        lastPlayerTarget  = data.serverid
                        playerInfoPending = true
                        TriggerServerEvent('jn-idgun:server:getPlayerInfo', data.serverid)
                        -- Also fire audit for player scan
                        TriggerServerEvent('jn-idgun:server:audit', {
                            entityType = 'player',
                            model      = data.playername
                        })
                    elseif data.type ~= 'player' then
                        lastPlayerTarget  = -1
                        playerInfoPending = false
                        -- Throttled audit (every 2s per entity)
                        TriggerServerEvent('jn-idgun:server:audit', {
                            entityType = data.type,
                            model      = data.model
                        })
                    end

                    SendNUIMessage({
                        action  = 'update',
                        data    = data,
                        history = historyOpen and scanHistory or nil
                    })
                end
            end
        end
    end
end)

-- ─────────────────────────────────────────────
--  Net Events from server
-- ─────────────────────────────────────────────
RegisterNetEvent('jn-idgun:client:toggleAllowed', function()
    isActive = not isActive

    if isActive then
        equipScanner()
        SendNUIMessage({ action = 'show' })
        Bridge.Notify(T('toggle_on'), 'success', 2000)
    else
        unequipScanner()
        SendNUIMessage({ action = 'hide' })
        Bridge.Notify(T('toggle_off'), 'inform', 2000)
        lastScanData      = nil
        playerInfoPending = false
        lastPlayerTarget  = -1
    end
end)

RegisterNetEvent('jn-idgun:client:denied', function()
    Bridge.Notify(T('no_permission'), 'error', 4000)
end)

RegisterNetEvent('jn-idgun:client:consentNotify', function()
    Bridge.Notify(T('consent_notify'), 'inform', 3000)
end)

RegisterNetEvent('jn-idgun:client:playerInfo', function(info)
    if not info or not isActive or not lastScanData then return end
    playerInfoPending     = false
    lastScanData.job      = info.job
    lastScanData.name_svr = info.name  -- server-side name confirmation

    SendNUIMessage({
        action  = 'updateExtra',
        job     = info.job,
        history = historyOpen and scanHistory or nil
    })
end)

RegisterNetEvent('jn-idgun:client:adminNotify', function(data)
    Bridge.Notify(
        ('Scanner: %s (#%d) → %s [%s]'):format(data.scanner, data.scannerId, data.entityType, data.model),
        'warning', 5000
    )
end)

-- ─────────────────────────────────────────────
--  Commands & Keybinds
-- ─────────────────────────────────────────────
RegisterCommand('idgun', function()
    TriggerServerEvent('jn-idgun:server:requestToggle')
end, false)

RegisterCommand('idgun_copy', function()
    if not isActive or not lastScanData then return end

    local c = lastScanData.rawCoords
    local str = ('%.4f, %.4f, %.4f'):format(c.x, c.y, c.z)

    print(('\n[jn-idgun] Coords: %s | Model: %s | Type: %s\n'):format(str, lastScanData.model, lastScanData.type))

    pushHistory(lastScanData)
    SendNUIMessage({ action = 'copyFeedback', coords = str, history = scanHistory })
    Bridge.Notify(T('copy_success'), 'success', 2000)
    TriggerServerEvent('jn-idgun:server:logCopy', { coords = str })
end, false)

RegisterCommand('idgun_history', function()
    if not isActive then return end
    historyOpen = not historyOpen
    SendNUIMessage({ action = 'toggleHistory', open = historyOpen, history = scanHistory })
end, false)

RegisterKeyMapping('idgun',         'jn-idgun: Toggle Scanner',        'keyboard', Config.DefaultKeybind)
RegisterKeyMapping('idgun_copy',    'jn-idgun: Copy Coords to Console', 'keyboard', Config.CopyKeybind)
RegisterKeyMapping('idgun_history', 'jn-idgun: Toggle History Panel',   'keyboard', Config.HistoryKeybind)
