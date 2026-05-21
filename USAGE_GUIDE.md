# jn-idgun — Usage Guide

## What does it do?

Aim any weapon at an entity and instantly see all technical info: coordinates, model name, hash, heading, and distance. For players you also get server ID, name, job, wanted level, health, armor, and ping. For vehicles: plate, fuel level, and driver.

The panel slides in from the bottom-left as a Dark+Cyan overlay — no menu, no mouse focus required, just aim and scan.

---

## Activation

### Option 1 — Keybind (default)

**F6** toggles the scanner. Press once to open, press again to close.

Rebindable in GTA V settings → Key Bindings → search "jn-idgun: Toggle Scanner".

### Option 2 — Command

```
/idgun
```

### Option 3 — Item

If the player has been given the `idgun` item, simply use it from the inventory. Works as a toggle.

```
/giveitem [playerid] idgun 1
```

---

## Controls

| Key | Action |
|---|---|
| **F6** | Toggle scanner on / off |
| **C** | Print last scanned coords to F8 console |
| **H** | Toggle history panel (last 10 scans) |

All keys are rebindable via GTA V → Settings → Key Bindings.

---

## What gets displayed?

### Ped (NPC)
- Model name
- Hash
- Coordinates
- Heading
- Distance
- Health, Armor

### Player
Everything from Ped, plus:
- Server ID
- Player name
- Job (pulled from the framework)
- Wanted level (★★☆☆☆)
- Ping

### Vehicle
- Model name
- Plate
- Fuel level
- Driver (name + server ID)
- Coordinates, heading, distance

### Object / Prop
- Model name
- Hash
- Coordinates
- Heading
- Distance

---

## Copying Coords

Press **C** while the scanner is active and an entity is in sight. The coords get printed to the F8 console:

```
[jn-idgun] Coords: 123.4567, -456.7890, 30.1234 | Model: a_m_y_hipster_01 | Type: ped
```

---

## History Panel

Press **H** to open a small list of your last 10 scans, showing type, model name and timestamp. Useful when you've quickly scanned multiple entities and want to go back.

---

## Permissions (server.cfg)

```cfg
# Groups allowed to use the scanner
add_ace group.admin      command.idgun allow
add_ace group.moderator  command.idgun allow
add_ace group.police     command.idgun allow

# Single player by identifier
add_principal identifier.steam:110000112345678 group.admin
```

Alternatively, enable `Config.UseJobWhitelist = true` in `config.lua` — then only specific jobs can use the scanner, without needing an ace permission.

---

## config.lua — Key Settings

```lua
-- Everyone can use the scanner (good for testing, not for production)
Config.RequirePermission = false

-- Only allow specific jobs
Config.UseJobWhitelist = true
Config.AllowedJobs = { 'police', 'sheriff', 'admin' }

-- Consent mode: notify the target player when they are being scanned
Config.ConsentMode = true

-- Disable audit logging to server console
Config.AuditLog = false

-- Maximum scan distance in meters
Config.MaxScanDistance = 100.0

-- Language
Config.Locale = 'en'  -- or 'de'
```

---

## Giving the Item (QBCore / QBox / ESX)

```lua
-- Via server console or admin script:
/giveitem 1 idgun 1

-- Via Lua in another script:
exports['ox_inventory']:AddItem(source, 'idgun', 1)  -- QBox
Player.Functions.AddItem('idgun', 1)                  -- QBCore
xPlayer.addInventoryItem('idgun', 1)                  -- ESX
```

The item is configured as `unique = true` — a player can only carry one at a time.

---

## Audit Log

When `Config.AuditLog = true` (default), every scan is logged to the server console:

```
[jn-idgun] AUDIT | Janni (ID: 1) scanned player [John_Doe]
[jn-idgun]         → Target: John_Doe (ID: 5)
```

---

## Troubleshooting

**Scanner won't toggle:** Check that the ace permission is set, or set `Config.RequirePermission = false` in config.lua.

**Job not showing up:** The job is fetched via a server callback. Wait ~0.5s after the first scan on a player — it will appear shortly after.

**Item doesn't work:** Make sure `qb-core` was restarted after adding the item to items.lua. Alternatively just use the keybind or command.

**Panel not visible:** Press F6 again to toggle it back on.
