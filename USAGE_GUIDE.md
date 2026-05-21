# jn-idgun — Anleitung

## Was macht das Script?

Du richtest eine Waffe auf irgendetwas und siehst sofort alle technischen Infos: Koordinaten, Model-Name, Hash, Heading, Entfernung. Bei Spielern auch Server-ID, Name, Job, Wanted-Level, Health, Armor und Ping. Bei Fahrzeugen: Kennzeichen, Tankstand, Fahrer.

Das Panel erscheint links unten als Dark+Cyan-Overlay — kein Menü, kein Mausfokus, einfach drauf und scannen.

---

## Aktivierung

### Option 1 — Keybind (Standard)

Standardmäßig ist **F6** der Toggle-Key. Drücken → Panel erscheint. Nochmal drücken → Panel verschwindet.

Der Key ist rebindable: GTA V Einstellungen → Tastatur → "jn-idgun: Toggle Scanner"

### Option 2 — Command

```
/idgun
```

### Option 3 — Item

Wenn dem Spieler das Item `idgun` gegeben wurde, einfach im Inventar benutzen. Funktioniert wie ein Toggle.

```lua
-- Admin: Item via Konsole geben
/giveitem [playerid] idgun 1
```

---

## Controls

| Taste | Aktion |
|---|---|
| **F6** | Scanner ein/ausschalten |
| **C** | Letzte Koordinaten in F8-Console drucken |
| **H** | History-Panel ein/ausblenden (letzte 10 Scans) |

Alle Keys sind rebindable unter GTA V → Einstellungen → Tastatur & Maus.

---

## Was wird angezeigt?

### Ped (NPC)
- Model-Name
- Hash
- Koordinaten
- Heading
- Entfernung
- Health, Armor

### Spieler
Alles was beim Ped steht, plus:
- Server-ID
- Spielername
- Job (aus dem Framework)
- Wanted-Level (★★☆☆☆)
- Ping

### Fahrzeug
- Model-Name
- Kennzeichen
- Tankstand
- Fahrer (Name + Server-ID)
- Koordinaten, Heading, Entfernung

### Objekt / Prop
- Model-Name
- Hash
- Koordinaten
- Heading
- Entfernung

---

## Koordinaten kopieren

**C** drücken während der Scanner aktiv ist und eine Entität angezielt wird. Die Koordinaten werden in die F8-Konsole gedruckt:

```
[jn-idgun] Coords: 123.4567, -456.7890, 30.1234 | Model: a_m_y_hipster_01 | Type: ped
```

---

## History

**H** drücken → ein kleines Panel zeigt die letzten 10 Scans mit Typ, Model und Uhrzeit. Nützlich wenn du mehrere Entities schnell hintereinander gecheckt hast.

---

## Berechtigungen (server.cfg)

```cfg
# Gruppen, die den Scanner nutzen dürfen
add_ace group.admin      command.idgun allow
add_ace group.moderator  command.idgun allow
add_ace group.police     command.idgun allow

# Einzelner Spieler per Identifier
add_principal identifier.steam:110000112345678 group.admin
```

Alternativ: `Config.UseJobWhitelist = true` in `config.lua` — dann können nur bestimmte Jobs den Scanner nutzen, ohne Ace-Permission.

---

## config.lua — die wichtigsten Settings

```lua
-- Jeder darf den Scanner nutzen (gut zum Testen, nicht für Prod!)
Config.RequirePermission = false

-- Nur bestimmte Jobs können den Scanner nutzen
Config.UseJobWhitelist = true
Config.AllowedJobs = { 'police', 'sheriff', 'admin' }

-- Consent Mode: Zielspieler bekommt Notification wenn er gescannt wird
Config.ConsentMode = true

-- Audit Log in der Server-Console ausschalten
Config.AuditLog = false

-- Maximale Scan-Reichweite in Metern
Config.MaxScanDistance = 100.0

-- Deutsche Sprache
Config.Locale = 'de'
```

---

## Item vergeben (QBCore / QBox)

```lua
-- Via Server-Konsole oder Admin-Script:
/giveitem 1 idgun 1

-- Via Lua (z.B. in einem anderen Script):
exports['ox_inventory']:AddItem(source, 'idgun', 1)         -- QBox
Player.Functions.AddItem('idgun', 1)                         -- QBCore
xPlayer.addInventoryItem('idgun', 1)                         -- ESX
```

Das Item ist als `unique = true` konfiguriert — ein Spieler kann es nur einmal im Inventar haben.

---

## Audit Log

Wenn `Config.AuditLog = true` (Standard), wird jeder Scan in der Server-Console geloggt:

```
[jn-idgun] AUDIT | Janni (ID: 1) scanned player [John_Doe]
[jn-idgun]         → Target: John_Doe (ID: 5)
```

---

## Fehlerbehebung

**Scanner lässt sich nicht togglen:** Prüfe ob die Ace-Permission gesetzt ist oder `Config.RequirePermission = false` in config.lua.

**Job wird nicht angezeigt:** Das Script holt den Job via Server-Callback. Kurz warten nach dem ersten Scan — er erscheint nach ~0.5s.

**Item funktioniert nicht:** Stelle sicher dass `qb-core` neugestartet wurde nachdem das Item zu items.lua hinzugefügt wurde, oder nutze einfach den Keybind/Command.

**NUI sichtbar aber kein Panel:** F6 nochmal drücken (Toggle).
