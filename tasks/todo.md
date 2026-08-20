# Set tooltip: show which slot deviates from the set

Branch: `feature/tooltip-changed-slot-highlight`

## Problem

When one piece of a worn set is swapped out, the set button loses its set icon
(`ItemRack.UpdateCurrentSet` falls back to the generic icon) but nothing tells the player
*which* slot drifted. The set tooltip lists every slot in flat gray.

The orange "unequipped" highlight already exists (`ItemRackSettings.TooltipColorUnEquipped`,
`ItemRack.lua:3062`) but it is off by default and has two defects:

1. **False positives.** `SetTooltip` compares with `ItemRack.SameExactID` (itemID + enchant +
   gems + suffix). `ItemRack.IsSetEquipped` — the function that decides whether the button
   keeps the set icon — compares with the looser `ItemRack.SameID` (base itemID) *and*
   tolerates rings swapped between slots 11/12, trinkets between 13/14, and active auto-queue
   items. So the tooltip paints slots orange that ItemRack still considers correctly equipped.
2. **Noise on every other set.** `SetTooltip` serves both the current-set button
   (`ItemRack.lua:2766`) and every set in the quick menu (`ItemRack.lua:2782`). Hovering a set
   you are not wearing turns all 19 lines orange.

## Tasks

- [x] **Extract `ItemRack.SlotMatchesSet(setname,set,slot,exact)`** from the body of
      `ItemRack.IsSetEquipped` (`ItemRackEquip.lua:719`). Returns `match, equippedID`. Keep the
      logic byte-for-byte identical (loose match → ring/trinket cross-slot → auto-queue
      allowance) and have `IsSetEquipped` call it, so there is one source of truth and the
      tooltip can never disagree with the button icon.
- [x] **Rework `ItemRack.SetTooltip`** (`ItemRack.lua:3044`):
      - Build a deviation map in one pass via `SlotMatchesSet`, only when
        `TooltipColorUnEquipped=="ON"` **and** `setname==ItemRackUser.CurrentSet`
        (`CurrentSet` survives gear drift, so it is the right anchor).
      - Header line gains an orange `(N changed)` count — this also explains the missing icon.
      - Deviating slots get an orange `»` marker in addition to the orange item name, so the
        signal does not depend on hue alone.
      - Replace the `SameExactID` comparison with the deviation map.
- [x] **New sub-option `TooltipShowSwappedItem`** (default OFF, depends on
      `TooltipColorUnEquipped`): appends `now: <equipped item>` as a right column via
      `AddDoubleLine`, answering *what* it changed to. Opt-in because it widens the tooltip.
      - default in `ItemRackSettings` table (`ItemRack.lua:~298`)
      - migration line for existing installs (`ItemRack.lua:~1285`)
      - checkbox in `ItemRackOptions.lua:~227`
      - entry in `/itemrack dump` (`ItemRack.lua:~3871`)
- [x] **Flip `TooltipColorUnEquipped` default to `"ON"`.** Only affects fresh installs;
      existing users keep their saved value because SavedVariables replaces the whole table.
      Also refresh its option tooltip text to describe the current-set-only behavior.
- [x] Syntax-check changed files with `luaparse`.
- [x] Changelog `Development` section. No version bump — this is a test branch.

## Deliberately out of scope

- Slots the set records as `(empty)` where you are now wearing something: `SetTooltip` only
  iterates keys present in `set`, matching `IsSetEquipped`. Changing that would make the
  tooltip and the icon disagree again.
- Localization: this codebase hardcodes English tooltip strings (`"Queued: "` etc.).
- Unicode arrows (`→`) are avoided — glyph coverage in the client's default fonts is not
  verified. `»` is Latin-1 and safe.

## Review

All code changes are in. **Not yet verified in-game — that's the manual test pass.**

### What changed

| File | Change |
|---|---|
| `ItemRackEquip.lua` | New `ItemRack.SlotMatchesSet(setname,set,slot,exact)` extracted verbatim from `IsSetEquipped`, which now calls it. Returns `match, equippedID`. |
| `ItemRack.lua` | `SetTooltip` builds a deviation map through `SlotMatchesSet`, adds the `(N changed)` header count, the orange `»` marker, and the optional `now: <item>` right column. New setting default + migration + `/itemrack dump` entry. |
| `ItemRackOptions.lua` | Renamed the existing checkbox, added the `TooltipShowSwappedItem` sub-option under it. |
| `CHANGELOG.md` | `[Development]` section. No version bump — `ItemRack.BuildID` and both `.toc` files are untouched. |

`ItemRackOpt.ListScrollFrameUpdate()` already runs after every checkbox toggle, so the new
sub-option greys out on its own when the parent is unchecked — no extra handler needed.

### Verified

- `luaparse` clean on all three changed files.
- The extraction is a faithful move: `check11_12`/`check13_14` became inline `set[11] and set[12]`
  tests (identical truthiness), and every other line is unchanged apart from `i` → `slot`.
- `SlotMatchesSet` is safe to call from a mouseover: `GetQueues`/`GetQueuesEnabled` only read
  through an `__index` proxy (they mutate nothing), and `AutoQueueItemToEquip` is a pure query —
  its own comments note `IsSetEquipped` already calls it this way.
- The `»` is written as `"\194\187"` (UTF-8 for U+00BB). A bare `\187` byte would not have
  rendered — the client reads strings as UTF-8.

### Manual test checklist

1. Equip a set, then swap **one** piece. Hover the set button: expect `(1 changed)` and a single
   orange `»` line on that slot.
2. Swap the piece back. Expect the count and all orange to disappear, icon restored.
3. Hover a set you are **not** wearing in the quick menu — expect no orange at all.
4. Swap your two rings with each other, and separately your two trinkets. Expect **no** highlight
   (this is the false positive that the old code produced).
5. With an item missing from bags entirely, confirm red still wins over orange; with it in the
   bank, blue.
6. Turn on **Show what's equipped instead** and re-check step 1 for the `now: <item>` column.
7. Turn on **Tiny Tooltips** — the `(N changed)` count should still show, with no item lines.
8. `/itemrack dump` lists `TooltipShowSwappedItem`.

### Known minor

If an item's info is not yet cached by the client, `GetInfoByID` returns nil and that line is
skipped (pre-existing behavior) while the header still counts it — so the count can briefly
exceed the number of visible `»` marks. Self-corrects once the item caches.

### Not done (deliberate)

Version bump and the sync of `RELEASE_NOTES.md` / `ItemRack/Changelog.txt` — those belong to the
release step, once you've decided this ships.
