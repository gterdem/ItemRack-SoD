-- ItemRackRunes.lua
-- Season of Discovery rune (Engraving) integration.
--
-- When you equip a set whose saved runes differ from what's currently engraved, this shows
-- a small reminder popup listing each slot + rune name, with a click-to-apply button. Runes
-- CANNOT be applied silently: C_Engraving.CastRune must run from a user click (hardware event)
-- and engraves one rune at a time over a ~3s cast, so applying is click-driven (one per click).
--
-- Detection data comes for free: every saved set slot already carries a ":runeid:<id>" suffix
-- (see ItemRack.AppendRuneID / ItemRack.GetID). Parsing + comparison helpers live in
-- ItemRack.lua (GetSetRuneID / GetRuneMismatches); this file is the UI + apply side.

local runeFrame -- created lazily on first reminder (never on non-engraving clients)

local MAX_RUNE_NAME_ROW = 16 -- per-name truncation in the "current -> target" list rows
local MAX_RUNE_NAME_BTN = 16 -- truncation for the Apply button's target rune

-- [[ Rune lookup: map a saved skillLineAbilityID -> { name, icon } ]]
local runeCache
local function BuildRuneCache()
	runeCache = {}
	if not (C_Engraving and C_Engraving.GetRuneCategories and C_Engraving.GetRunesForCategory) then return end
	local ok, cats = pcall(C_Engraving.GetRuneCategories, true, false)
	if not ok or type(cats) ~= "table" then
		ok, cats = pcall(C_Engraving.GetRuneCategories)
	end
	if type(cats) ~= "table" then return end
	for _, cat in ipairs(cats) do
		local ok2, runes = pcall(C_Engraving.GetRunesForCategory, cat, false)
		if ok2 and type(runes) == "table" then
			for _, rune in ipairs(runes) do
				if rune.skillLineAbilityID then
					runeCache[rune.skillLineAbilityID] = { name = rune.name, icon = rune.iconTexture }
				end
			end
		end
	end
end

local function GetRuneEntry(id)
	if not id or id == 0 then return nil end
	if not runeCache then BuildRuneCache() end
	local entry = runeCache[id]
	if not entry then
		BuildRuneCache() -- one rebuild in case a rune was learned since the last scan
		entry = runeCache[id]
	end
	return entry
end

function ItemRack.GetRuneName(id)
	local entry = GetRuneEntry(id)
	return entry and entry.name
end

function ItemRack.GetRuneIcon(id)
	local entry = GetRuneEntry(id)
	return entry and entry.icon
end

-- [[ Display helpers ]]
local function SlotName(slot)
	local info = ItemRack.SlotInfo and ItemRack.SlotInfo[slot]
	return (info and info.real) or ("Slot "..tostring(slot))
end

local function Truncate(s, n)
	if not s then return "?" end
	if #s > n then return s:sub(1, n - 2)..".." end -- ASCII truncation marker (WoW font has no ellipsis glyph)
	return s
end

local function RuneNameOrNone(id)
	if not id or id == 0 then return "none" end
	return ItemRack.GetRuneName(id) or "?"
end

-- Apply-button label: "Head - Taste for Blood" (target rune only, truncated)
local function RuneLabel(m, maxlen)
	return SlotName(m.slot).." - "..Truncate(RuneNameOrNone(m.expected), maxlen)
end

-- List row: "Head: Endless Rage -> Taste for Blood" (current -> target)
local function MismatchRow(m)
	local cur = Truncate(RuneNameOrNone(m.current), MAX_RUNE_NAME_ROW)
	local exp = Truncate(RuneNameOrNone(m.expected), MAX_RUNE_NAME_ROW)
	return SlotName(m.slot)..": "..cur.." -> "..exp
end

local function BuildText(setname, mismatches)
	local rows = {}
	for _, m in ipairs(mismatches) do
		table.insert(rows, MismatchRow(m))
	end
	local noun = (#mismatches == 1) and "rune" or "runes"
	return string.format("Set '%s': %d %s differ\n\n%s", setname, #mismatches, noun, table.concat(rows, "\n"))
end

local function EnsureFrame()
	if runeFrame then return runeFrame end

	local f = CreateFrame("Frame", "ItemRackRuneFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f:SetSize(360, 140)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 160)
	f:SetFrameStrata("DIALOG")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	if f.SetBackdrop then
		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 },
		})
	end

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	f.title:SetText("ItemRack Runes")

	f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.text:SetPoint("TOP", 0, -34)
	f.text:SetWidth(330)
	f.text:SetJustifyH("CENTER")

	f.apply = CreateFrame("Button", "ItemRackRuneApplyButton", f, "UIPanelButtonTemplate")
	f.apply:SetSize(230, 22)
	f.apply:SetPoint("BOTTOMLEFT", 16, 14)
	f.apply:SetText("Apply Runes")
	f.apply:SetScript("OnClick", function() ItemRack.ApplyNextRune() end)

	f.close = CreateFrame("Button", "ItemRackRuneCloseButton", f, "UIPanelButtonTemplate")
	f.close:SetSize(90, 22)
	f.close:SetPoint("BOTTOMRIGHT", -16, 14)
	f.close:SetText("Close")
	f.close:SetScript("OnClick", function() f:Hide() end)

	-- RUNE_UPDATED fires when an engrave completes -> refresh instantly (no guessed delay).
	-- PLAYER_REGEN_* keep the Apply button's combat state in sync.
	f:RegisterEvent("RUNE_UPDATED")
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:SetScript("OnEvent", function() ItemRack.RefreshRuneReminder() end)

	f:Hide()
	runeFrame = f
	return f
end

-- Refresh the popup's text/apply-state from the set stored on the frame; hide if nothing differs.
function ItemRack.RefreshRuneReminder()
	local f = runeFrame
	if not f or not f:IsShown() or not f.setname then return end
	local mismatches = ItemRack.GetRuneMismatches(f.setname)
	if #mismatches == 0 then
		f:Hide()
		return
	end
	local body = BuildText(f.setname, mismatches)
	local extraRows = 0
	if InCombatLockdown() then
		body = body.."\n|cffff8080Runes can't be engraved in combat.|r"
		extraRows = 1
		f.apply:SetText("Apply (in combat)")
		f.apply:Disable()
	else
		f.apply:SetText("Apply: "..RuneLabel(mismatches[1], MAX_RUNE_NAME_BTN))
		f.apply:Enable()
	end
	f.text:SetText(body)
	f:SetHeight(100 + (#mismatches + extraRows) * 15)
end

-- Show the reminder for a freshly-equipped set. mismatches comes from ItemRack.GetRuneMismatches.
function ItemRack.ShowRuneReminder(setname, mismatches)
	if not mismatches or #mismatches == 0 then return end
	local f = EnsureFrame()
	f.setname = setname
	f:Show()
	ItemRack.RefreshRuneReminder()
end

-- Engrave the next differing rune (one per click, to satisfy the hardware-event requirement).
function ItemRack.ApplyNextRune()
	local f = runeFrame
	if not f or not f.setname then return end
	if InCombatLockdown() then
		ItemRack.Print("Runes can't be engraved in combat.")
		return
	end
	local mismatches = ItemRack.GetRuneMismatches(f.setname)
	if #mismatches == 0 then
		f:Hide()
		return
	end
	local m = mismatches[1]
	f.apply:Disable()
	f.apply:SetText("Engraving...")
	ClearCursor()
	C_Engraving.CastRune(m.expected)
	-- RUNE_UPDATED refreshes on completion; this is a fallback if the cast is interrupted.
	C_Timer.After(4, ItemRack.RefreshRuneReminder)
end

-- Re-open the reminder for the current set on demand (e.g. /itemrack runes) if any runes differ.
function ItemRack.OpenRuneReminder()
	if not ItemRack.IsEngravingActive() then
		ItemRack.Print("Rune reminders are only available in Season of Discovery.")
		return
	end
	local setname = ItemRackUser and ItemRackUser.CurrentSet
	if not setname or not (ItemRackUser.Sets and ItemRackUser.Sets[setname]) then
		ItemRack.Print("No current set to check runes for.")
		return
	end
	local mismatches = ItemRack.GetRuneMismatches(setname)
	if #mismatches == 0 then
		ItemRack.Print("Runes already match your current set ('"..setname.."').")
		return
	end
	ItemRack.ShowRuneReminder(setname, mismatches)
end
