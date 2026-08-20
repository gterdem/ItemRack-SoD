# ItemRack - Season of Discovery - Release v1.2.0

The set tooltip now tells you which piece of your set changed, plus a fix for the rune reminder popping up with the wrong list after a set swap.

---

### ✨ Added
* **See which slot changed at a glance.** Swap one piece out of the set you're wearing and the set button quietly drops back to its generic icon — but nothing told you *which* slot drifted. Now the tooltip of your current set counts them next to the name (`Shockadin (1 changed)`) and marks each one with an orange `»`.
* **Optionally see what you're wearing instead.** Turn on **"Show what's equipped instead"** and each highlighted slot also names the item actually in it (`now: Lawbringer Helm`), so you get *what* it changed to, not just *where*. Off by default — it makes the tooltip wider.

### 🔧 Fixed
* **Correctly-equipped slots are no longer flagged as changed.** The highlight compared gear by exact identity — item plus enchant, gems and suffix — while the set icon uses looser base-item matching and deliberately allows your two rings (or two trinkets) to sit in each other's slots, and allows whatever an active auto-queue put on. So a re-enchanted weapon, or a pair of swapped rings, showed up orange while ItemRack still considered the set fully equipped. Both now use one shared comparison, so the tooltip can't contradict the icon.
* **The highlight no longer lights up sets you aren't wearing.** It applied to every set in the quick menu, where nearly every slot differs by definition and the whole list turned orange. It's now limited to your current set.
* **Item tooltips no longer forget which sets an item belongs to after you enchant it.** Set membership was matched on exact identity — item *plus* enchant, gems and suffix — so putting a new enchant on a set piece made its tooltip stop listing the set, even though ItemRack still equips it as part of that set. It now matches on the base item, the same way the set tooltip does.
* **"ItemRack Set" lines in item tooltips no longer get clipped or overlap.** With **"Show set info in tooltips"** on, the set names added to an item's tooltip could be cut off at the bottom, or the set name could be drawn on top of its own label — seemingly at random. The lines were being appended after the tooltip had already been sized, so it never grew to fit them. Most noticeable with tooltip-skinning addons like ElvUI.
* **The rune reminder no longer invents mismatches after a set swap.** Equipping a set could pop a reminder claiming several runes differed — listing the runes of the gear you just took *off* — when re-checking a moment later showed the correct, much shorter list. The check ran before the new pieces had actually reached their slots, so it read the outgoing items. It now waits for your gear to settle, and an open reminder re-scans as each piece lands.

### ⚙️ Changed
* **"Highlight unequipped in tooltip" is now "Highlight changed slots in tooltip", and is on by default.** It shipped off and buried in the options list, so most people never knew it existed — and with the two bugs above fixed it's now worth having on. Existing installs get switched on once; untick it and your choice sticks.

_No action needed on upgrade. Rune reminders and the changed-slot highlight are both dormant unless they have something to report._
