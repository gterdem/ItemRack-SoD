# ItemRack - Season of Discovery - Release v1.1.2

A compatibility bugfix for players using a bank addon (Bagnator, Bagnon, etc.).

---

### 🔧 Fixed
* **Works alongside bank addons like Bagnator / Bagnon.** With such an addon installed, opening the bank and hovering an equipment slot could throw a Lua error (`IsInventorySlotEngravable ... outside of expected range`) on Season of Discovery. The rune scan now skips the bank's negative container indices — which are never engravable — so the item flyout builds cleanly with the bank open.

_Season of Discovery engraving fix; no effect on non-engraving characters._
