# jn-idgun

**Modern Entity Inspector for FiveM** — aim at any ped, player, vehicle or object and get instant data in a sleek Dark+Cyan overlay.

> Made by **ByJanni** | Free & open-source — [License](LICENSE)

---

## Features

| Feature | Details |
|---|---|
| **Framework support** | QBox, QBCore, ESX, Standalone — auto-detected |
| **Entity types** | Ped, Player, Vehicle, Object |
| **Player info** | Server ID, Name, Job, Wanted stars, Health, Armor, Ping |
| **Vehicle info** | Plate, Fuel level, Driver name + ID |
| **Audit log** | Every scan is logged to the server console |
| **Job whitelist** | Only allow specific jobs to use the scanner |
| **Consent mode** | Optionally notify the target player when scanned |
| **History panel** | Press H to view your last 10 scans |
| **Locales** | English & German included, add your own |
| **Keybinds** | Fully rebindable in GTA V key settings |
| **NUI overlay** | Clean Dark+Cyan panel, no mouse focus needed |

---

## Installation

1. Download and extract into your `resources` folder
2. Add to `server.cfg`:
   ```
   ensure jn-idgun
   ```
3. Give ace permission to the groups that should use the scanner:
   ```
   add_ace group.admin    command.idgun allow
   add_ace group.moderator command.idgun allow
   add_ace group.police   command.idgun allow
   ```
4. Restart the server

---

## Configuration

All settings are in **`config.lua`**. Key options:

```lua
-- Who can use the scanner
Config.RequirePermission = true          -- false = everyone
Config.AcePermission     = 'command.idgun'

-- Alternatively, whitelist by framework job
Config.UseJobWhitelist = false
Config.AllowedJobs     = { 'police', 'sheriff', 'fbi' }

-- RP features
Config.ConsentMode      = false  -- notify target when scanned
Config.AuditLog         = true   -- log to server console

-- Display
Config.MaxScanDistance  = 50.0   -- meters
Config.ShowWantedLevel  = true
Config.ShowHealth       = true
Config.ShowArmor        = true
Config.ShowPing         = true

-- Locale: 'en' or 'de'
Config.Locale = 'en'

-- Framework: 'auto', 'qbox', 'qbcore', 'esx', 'standalone'
Config.Framework = 'auto'
```

---

## Keybinds

| Action | Default | Rebindable |
|---|---|---|
| Toggle scanner on/off | `F6` | Yes (GTA settings) |
| Copy coords to F8 console | `C` | Yes |
| Toggle history panel | `H` | Yes |

---

## Adding Locales

Create a new file in `locales/`, e.g. `locales/fr.json`. Copy `en.json` as a template and translate the values. Then set `Config.Locale = 'fr'` in `config.lua`.

---

## Server.cfg Example

```
ensure jn-idgun

# Allow admins and police to use the scanner
add_ace group.admin     command.idgun allow
add_ace group.police    command.idgun allow
add_ace group.moderator command.idgun allow
```

---

## Dependencies

**Required:** None — works with vanilla FiveM

**Optional:**
- `ox_lib` — used for nicer notifications if present
- `qbx_core` / `qb-core` / `es_extended` — for job info and framework notifications

---

## Credits

- Hash lookup data: [PhilippRedel](https://github.com/PhilippRedel) via [pun_idgun](https://github.com/Puntherline/pun_idgun)
- Inspired by: [pun_idgun](https://github.com/Puntherline/pun_idgun) by Puntherline

---

## License

Free to use and modify. **Not allowed to sell.** See [LICENSE](LICENSE).
