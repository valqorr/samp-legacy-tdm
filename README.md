# SA-MP Legacy TDM Mode (2015)

This repository contains the original 2015 Team Deathmatch gamemode, including:

- : Core gamemode logic written in Pawn
- : Custom menu system
- Additional filterscripts, plugins, and configuration

## ⚠️ License Note
This repo does **not** include SA-MP server binaries (e.g. , ) due to licensing restrictions.  
Download them from [sa-mp.com](https://www.sa-mp.com/download.php) to run the server.

## 💡 Legacy Snapshot
Preserving an old but gold SA-MP project from the raw Pawn scripting era.


## 🛠 Commands

| Command               | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `/setteam [id] [t]`    | Assigns a player (`id`) to a team (`1 = Alpha`, `2 = Bravo`). Admin only.   |
| `/spawn [id]`          | Forces the target player to respawn immediately. Admin only.                |
| `/music [url]`         | Plays an audio stream from a given URL for the admin who ran the command.   |
| `/startbase`           | Starts the round countdown (10 seconds). Admin only.                        |
| `/stopbase`            | Cancels the countdown and ends the round. Admin only.                       |
| `/gunmenu`             | Opens the weapon/equipment selection menu. Must be at team spawn point.     |

---

### ℹ Notes on Command Usage:

- All commands marked as **Admin only** check `IsPlayerAdmin(playerid)` internally.
- `/gunmenu` can only be used:
  - If the player is within **10 units** of their team's spawn zone.
  - If the team exists (checked via `AlphaExist` or `BravoExist` flags).
- `/music` is local: only the issuing player hears the stream.

---

### 🧰 Menu Contents via `/gunmenu`

Weapon/equipment categories:

- **Weapons-1:** Nightstick, Tear Gas, Pistol, Shotgun, MP5  
- **Weapons-2:** Bat, Molotov, Silenced Pistol, Sawnoff, Micro Uzi, Country Rifle  
- **Weapons-3:** Knife, Grenade, Desert Eagle, Combat Shotgun, Tec-9, Sniper Rifle  
- **Equipment:** Health, Armour, Night/Thermal Vision, Parachute