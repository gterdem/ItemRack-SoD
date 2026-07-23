# ItemRack - Season of Discovery

ItemRack for **World of Warcraft Classic: Season of Discovery** (patch 1.15.9, Interface `11509`). Manage your gear with sets, automated cooldown queues, event-based swaps, and dual-spec integration — driven from on-screen slot buttons and your character sheet.

> **Season of Discovery only.** This is a fork that targets **only** WoW Classic: Season of Discovery. I maintain it for SoD simply because that's what I play. Support for The Burning Crusade / Wrath / Cataclysm Classic from the upstream Anniversary port has been **removed**. If you need those clients, use the original Anniversary version.

## Credits

ItemRack has passed through many hands, and this fork stands on all of their work:

- **Original Author:** Gello
- **Classic Port:** Rottenbeer & Roadblock — [ItemRack Classic on CurseForge](https://www.curseforge.com/wow/addons/itemrack-classic)
- **Anniversary (TBC) Port:** Bl4ut0
- **Season of Discovery Fork:** gterdem
- **Contributors:** UDrew, physixtential, and others (see [CHANGELOG.md](CHANGELOG.md))

## Installation

1. Download the latest release from the [Releases page](https://github.com/gterdem/ItemRack-SoD/releases).
2. Extract into your WoW addons folder:
   ```
   World of Warcraft\_classic_era_\Interface\AddOns\
   ```
   You should end up with two folders: `ItemRack/` and `ItemRackOptions/`.
3. *(Recommended)* Install [LibSoundIndex](https://www.curseforge.com/wow/addons/libsoundindex) so ItemRack can mute individual gear-swap sounds without silencing combat or UI audio. Without it, ItemRack briefly mutes the Master SFX channel during a swap as a fallback.
4. Restart WoW or `/reload`. ItemRack appears as equipment-slot buttons on your character panel.

**[📖 Complete Control Reference →](CONTROLS.md)** — every mouse click, keybind, and slash command.

## Features

### 🚀 Quick Access & Slot Buttons
- **Open options:** `/itemrack opt` or right-click the minimap button.
- **Create a slot button:** Alt-click any slot on your character sheet.
- **Use item:** left-click a slot button (trinkets, on-use effects).
- **Cycle queue:** right-click a slot button to swap to the next queued item.
- **Slot menu:** hover a slot button for the item flyout.
- **Auto-Queue toggle:** Alt+left-click a slot button.

### ⚔️ Dual-Spec Integration (Season of Discovery)
SoD adds dual talent specialization at level 40, and ItemRack ties your gear to it:

1. In **Options → Sets**, select a set and check **Primary Talent** or **Secondary Talent** to link it to a talent group.
2. When you switch specs, ItemRack automatically equips the linked set.
3. **Optional reverse direction:** enable **"Switch spec on set equip"** (Config tab) to also switch talents when you equip a spec-linked set. This is **off by default**, so equipping a set normally changes only your gear. Talents are never switched in combat — the swap is skipped with a message.

### 🔮 Rune Integration (Season of Discovery)
Dual-spec (and gear swaps) don't move your engraved **runes** — ItemRack helps close that gap:

1. Sets automatically **remember the runes** on their engravable pieces when saved. In **Options → Sets**, each item cell shows a small **rune icon** (top-right), and its rune name in the tooltip.
2. Enable **"Rune reminders on set equip"** (Config tab, **off by default**). When you equip a set whose runes differ from what's engraved, a popup lists each slot's `current → target` rune with a **click-to-apply** button.
3. Runes engrave **one at a time** and **not in combat** (a game restriction), so the button applies the next rune per click. Type **`/itemrack runes`** to reopen the reminder for your current set.

### 📋 Gear Sets
- Save the items you want, pick an icon and a name, then **Save**.
- Show/hide helm and cloak per set.
- **Hide** a set to keep it out of the quick set menu (hold Alt to reveal hidden entries).

### 🔄 Auto-Queue
Keeps a "ready" item equipped:

1. Open the **Queue** (lightning bolt) config for a slot and rank items by priority.
2. When the equipped item goes on cooldown, ItemRack swaps to the highest-priority ready item.
3. **Pause Queue** on specific items to keep them from being swapped out mid-use.
4. Per-set queues are saved and recalled when you equip a set.

### ⚡ Events & Automation
Link sets to game-state triggers (**Config → Enable Events**, then the **Events** tab):

- Drinking/eating → spirit gear; mounting → riding gear; zone changes → per-zone gear; combat state → weapon or gear swaps.
- Manually picking a set overrides background events until conditions change.
- `/itemrack debug` shows which triggers fire in real time.

**Script events** have a stack-aware helper API — `EquipEventSet("Set Name")` / `UnequipEventSet()`. Existing bare `EquipSet(...)` / `UnequipSet(...)` scripts keep working (they're shimmed onto the stack-aware path); prefer the new helpers going forward.

### 🛠️ Diagnostics
A built-in diagnostic export — no digging through `WTF` folders:

1. `/itemrack debug` to enable logging.
2. Reproduce the issue in-game.
3. `/itemrack dump` opens a window with the last 500 actions, queue states, and any stuck API locks. `CTRL+C` copies an anonymized report to paste into a bug report.

> **Privacy:** the dump includes your set names, queue configs, and recently equipped items. It does **not** collect passwords or account data. Review it before sharing if any set names are sensitive.

## Support

For issues with this Season of Discovery fork, open an issue on the [GitHub repository](https://github.com/gterdem/ItemRack-SoD). For general ItemRack usage, the [original CurseForge page](https://www.curseforge.com/wow/addons/itemrack-classic) is a good reference.

## License

**Public Domain.** This addon is dedicated to the public domain via [The Unlicense](LICENSE) — the same public-domain status as the original ItemRack Classic by Gello. Do whatever you like with it.

Bundled libraries under `Libs/` (LibStub, CallbackHandler, LibDataBroker, LibDBIcon) retain their own respective licenses.
