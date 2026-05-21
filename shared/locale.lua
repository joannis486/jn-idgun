-- Locale system — shared between client and server
-- Creates global T(key, ...) function

local _locale = {}

local function loadLocale(lang)
    local raw = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(lang))
    if raw and #raw > 0 then
        return json.decode(raw) or {}
    end
    -- Fallback to English
    if lang ~= 'en' then
        local fallback = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
        if fallback then return json.decode(fallback) or {} end
    end
    return {}
end

_locale = loadLocale(Config.Locale or 'en')

function T(key, ...)
    local str = _locale[key]
    if not str then return key end
    if select('#', ...) > 0 then
        return str:format(...)
    end
    return str
end
