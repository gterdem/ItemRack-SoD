# ItemRack - Season of Discovery - Release v1.0.0

Re-founded as a **Season of Discovery-only** addon, forked from the ItemRack Anniversary port. This release targets patch **1.15.9** (Interface `11509`).

---

### ✨ Added
* **Optional spec switch on set equip**: New "Switch spec on set equip" option (Config tab). When enabled, equipping a gear set linked to a talent spec also switches to that spec; when off (**the default**), equipping a spec-linked set changes only your gear. Talents are never switched in combat — the swap is skipped with a message.

### 🔄 Changed
* **Season of Discovery only**: Interface set to `11509` (patch 1.15.9). Removed The Burning Crusade Classic (`20505`/`20506`), Wrath, and Cataclysm support and their version branches (`IsBCC`/`IsWrath`/`IsCata`), including the Wrath-only Titan's Grip handling.
* **Fresh release lineage**: Version reset to `1.0.0`; rebranded from "Anniversary" to "Season of Discovery". Removed the old CurseForge project ID pending a new Season of Discovery project.

### 🐛 Fixed
* **Dual-spec now works on Season of Discovery**: The talent-group events `ACTIVE_TALENT_GROUP_CHANGED` and `PLAYER_TALENT_UPDATE` were previously registered only on Wrath, leaving ItemRack's dual-spec set-swapping inert on SoD. They are now registered unconditionally, so equipping a set on a spec change works once dual spec is purchased.
