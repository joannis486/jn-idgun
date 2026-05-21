Config = {}

-- ─────────────────────────────────────────────
--  Permission
-- ─────────────────────────────────────────────

-- false = everyone can toggle the scanner (dev/testing mode)
Config.RequirePermission = true

-- Ace permission required when RequirePermission = true
Config.AcePermission = 'command.idgun'

-- Enable job whitelist (only certain jobs can use the scanner)
-- Works in addition to or instead of ace permission
Config.UseJobWhitelist = false
Config.AllowedJobs = { 'police', 'sheriff', 'fbi', 'sasp', 'admin' }

-- ─────────────────────────────────────────────
--  Features
-- ─────────────────────────────────────────────

-- Log every scan to the server console
Config.AuditLog = true

-- Notify the target player when they are being scanned (RP consent mode)
Config.ConsentMode = false

-- Show wanted level stars when scanning a player
Config.ShowWantedLevel = true

-- Show health and armor bars
Config.ShowHealth = true
Config.ShowArmor  = true

-- Show target player ping
Config.ShowPing = true

-- Max distance (meters) to scan an entity — entities farther away are ignored
Config.MaxScanDistance = 50.0

-- How many scans to keep in the history panel
Config.HistorySize = 10

-- ─────────────────────────────────────────────
--  Keybinds  (rebindable in GTA key settings)
-- ─────────────────────────────────────────────
Config.DefaultKeybind     = 'F6'  -- Toggle scanner on/off
Config.CopyKeybind        = 'c'   -- Copy last scanned coords to console
Config.HistoryKeybind     = 'h'   -- Toggle history panel

-- ─────────────────────────────────────────────
--  Admin Notifications
-- ─────────────────────────────────────────────

-- Broadcast a server chat message to admins when scanner is used
Config.NotifyAdminsOnScan = false
Config.AdminAce           = 'group.admin'

-- ─────────────────────────────────────────────
--  Locale
-- ─────────────────────────────────────────────
-- Available: 'en', 'de'
Config.Locale = 'en'

-- ─────────────────────────────────────────────
--  Framework
-- ─────────────────────────────────────────────
-- 'auto'       → auto-detects qbx_core > qb-core > es_extended > standalone
-- 'qbox'       → force QBox
-- 'qbcore'     → force QBCore
-- 'esx'        → force ESX
-- 'standalone' → no framework, ace permissions only
Config.Framework = 'auto'
