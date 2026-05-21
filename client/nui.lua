-- jn-idgun | NUI callbacks (NUI → Lua)
-- The overlay never takes focus, so all NUI callbacks are informational only

RegisterNUICallback('ready', function(_, cb)
    -- NUI signals it's loaded; nothing to do
    cb('ok')
end)
