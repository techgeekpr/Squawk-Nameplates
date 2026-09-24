--[[ One big icon per enemy nameplate.

	Nameplates only: the icon is parented to the plate itself and follows it
	around the screen.  Icons come from a pool keyed by unit token, handed out
	on NAME_PLATE_UNIT_ADDED and returned on NAME_PLATE_UNIT_REMOVED, because
	the token for a given plate changes as units come and go.

	Nothing here enables mouse input.  An icon sitting over a nameplate that
	accepted clicks would swallow the click meant for the plate underneath.
]]

local BD = SquawkNamePlates
local Display = {}
BD.Display = Display

Display.icons = {}     -- unit token -> icon
Display.pool = {}
Display.stats = { plates = 0, shown = 0 }

-- ---------------------------------------------------------------------------
-- the icon
-- ---------------------------------------------------------------------------

local function createIcon()
	local icon = CreateFrame("Frame", nil, UIParent)
	icon:SetSize(BD.db.nameplates.size, BD.db.nameplates.size)
	icon:SetFrameStrata("HIGH")
	icon:Hide()

	icon.Backdrop = icon:CreateTexture(nil, "BACKGROUND")
	icon.Backdrop:SetPoint("TOPLEFT", -2, 2)
	icon.Backdrop:SetPoint("BOTTOMRIGHT", 2, -2)
	icon.Backdrop:SetColorTexture(0, 0, 0, 1)

	icon.Texture = icon:CreateTexture(nil, "ARTWORK")
	icon.Texture:SetAllPoints(icon)
	icon.Texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	-- The spiral needs a readable duration, which this client may hide.
	local ok, cooldown = pcall(CreateFrame, "Cooldown", nil, icon, "CooldownFrameTemplate")
	if ok and cooldown then
		cooldown:SetAllPoints(icon)
		cooldown:SetDrawEdge(false)
		if cooldown.SetHideCountdownNumbers then
			pcall(cooldown.SetHideCountdownNumbers, cooldown, true)
		end
		icon.Cooldown = cooldown
	end

	icon.Overlay = CreateFrame("Frame", nil, icon)
	icon.Overlay:SetAllPoints(icon)
	icon.Overlay:SetFrameLevel(icon:GetFrameLevel() + 8)

	icon.Timer = icon.Overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	icon.Timer:SetPoint("BOTTOM", icon, "BOTTOM", 0, -2)
	icon.Timer:SetShadowColor(0, 0, 0, 1)
	icon.Timer:SetShadowOffset(1, -1)

	icon.Count = icon.Overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
	icon.Count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
	icon.Count:SetShadowColor(0, 0, 0, 1)
	icon.Count:SetShadowOffset(1, -1)

	return icon
end

local function applyAura(icon, aura)
	if not aura then
		icon.expires = nil
		icon:Hide()
		return
	end

	icon.Texture:SetTexture(aura.icon)

	if BD.db.colouredBorder then
		local colour = BD.CategoryColors[aura.category]
		if colour then
			icon.Backdrop:SetColorTexture(colour[1], colour[2], colour[3], 1)
		else
			icon.Backdrop:SetColorTexture(0, 0, 0, 1)
		end
	else
		icon.Backdrop:SetColorTexture(0, 0, 0, 1)
	end

	if icon.Cooldown then
		if BD.db.showCooldown and aura.duration and aura.duration > 0 and aura.expires then
			pcall(icon.Cooldown.SetCooldown, icon.Cooldown,
				aura.expires - aura.duration, aura.duration)
			icon.Cooldown:Show()
		else
			pcall(icon.Cooldown.Clear, icon.Cooldown)
			icon.Cooldown:Hide()
		end
	end

	icon.Count:SetText((BD.db.showStacks and aura.count and aura.count > 1) and aura.count or "")
	icon.expires = (BD.db.showTimer and aura.expires) or nil
	icon.auraName = aura.name
	icon:Show()
end

-- ---------------------------------------------------------------------------
-- plates
-- ---------------------------------------------------------------------------

function Display:PlateFor(unit)
	if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
		local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
		if ok and plate then return plate, "C_NamePlate" end
	end
	if C_NamePlateManager and C_NamePlateManager.GetNamePlateForUnit then
		local ok, plate = pcall(C_NamePlateManager.GetNamePlateForUnit, unit)
		if ok and plate then return plate, "C_NamePlateManager" end
	end
	return nil
end

-- UnitIsPlayer and UnitCanAttack can hand back secret booleans on this client,
-- and testing one throws.  Every check is wrapped: an unreadable answer means
-- "show it" rather than an error or a silently missing icon.
local function passesFilter(test)
	local ok, value = pcall(test)
	if not ok then return true end
	local readable, result = pcall(function() return value and true or false end)
	if not readable then return true end
	return result
end

local function wanted(unit)
	local settings = BD.db.nameplates
	if not settings.enabled then return false end

	if settings.onlyPlayers and not passesFilter(function() return UnitIsPlayer(unit) end) then
		return false
	end
	if settings.onlyEnemies and not passesFilter(function() return UnitCanAttack("player", unit) end) then
		return false
	end
	return true
end

function Display:Release(unit)
	local icon = Display.icons[unit]
	if not icon then return end
	Display.icons[unit] = nil
	icon:Hide()
	icon:ClearAllPoints()
	icon:SetParent(UIParent)
	icon.expires = nil
	Display.pool[#Display.pool + 1] = icon
end

function Display:Update(unit)
	if not UnitExists(unit) or not wanted(unit) then
		Display:Release(unit)
		return
	end

	local plate = Display:PlateFor(unit)
	if not plate then
		Display:Release(unit)
		return
	end

	local aura = BD:FindBest(unit)
	local icon = Display.icons[unit]

	if not aura then
		if icon then icon:Hide() end
		return
	end

	if not icon then
		icon = table.remove(Display.pool) or createIcon()
		Display.icons[unit] = icon
	end

	local settings = BD.db.nameplates
	icon:SetParent(plate)
	icon:SetSize(settings.size, settings.size)
	icon:ClearAllPoints()
	icon:SetPoint("BOTTOM", plate, "TOP", settings.offsetX or 0, settings.offsetY)
	applyAura(icon, aura)
end

function Display:UpdateAll()
	local plates, shown = 0, 0
	for index = 1, 40 do
		local unit = "nameplate" .. index
		if UnitExists(unit) then
			plates = plates + 1
			Display:Update(unit)
			local icon = Display.icons[unit]
			if icon and icon:IsShown() then shown = shown + 1 end
		else
			Display:Release(unit)
		end
	end
	Display.stats.plates, Display.stats.shown = plates, shown
end

-- ---------------------------------------------------------------------------
-- countdown text
-- ---------------------------------------------------------------------------

local function refreshTimers()
	local now = GetTime()
	for _, icon in pairs(Display.icons) do
		if icon:IsShown() then
			if not icon.expires then
				icon.Timer:SetText("")
			else
				local remaining = icon.expires - now
				if remaining <= 0 then
					icon.Timer:SetText("")
				elseif remaining >= 60 then
					icon.Timer:SetText(("%dm"):format(math.ceil(remaining / 60)))
				else
					icon.Timer:SetText(("%d"):format(math.ceil(remaining)))
				end
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- diagnostics and test
-- ---------------------------------------------------------------------------

function Display:Diagnostics()
	BD:Print("---- nameplates ----")
	BD:Print(("nameplate API: %s"):format(
		(C_NamePlate and C_NamePlate.GetNamePlateForUnit) and "|cff00ff00C_NamePlate|r"
			or ((C_NamePlateManager and C_NamePlateManager.GetNamePlateForUnit)
				and "|cff00ff00C_NamePlateManager|r" or "|cffff0000neither|r")))

	local showEnemies
	if C_CVar and C_CVar.GetCVar then
		showEnemies = C_CVar.GetCVar("nameplateShowEnemies")
	elseif type(GetCVar) == "function" then
		showEnemies = GetCVar("nameplateShowEnemies")
	end
	BD:Print(("enemy nameplates: %s"):format(
		(showEnemies == "1") and "|cff00ff00on|r"
			or "|cffff0000OFF - press V, or /snp plates|r"))

	local exists, withPlate = 0, 0
	for index = 1, 40 do
		local unit = "nameplate" .. index
		if UnitExists(unit) then
			exists = exists + 1
			if Display:PlateFor(unit) then withPlate = withPlate + 1 end
		end
	end
	BD:Print(("nameplate units: %d, with a frame to attach to: %d"):format(exists, withPlate))
	BD:Print(("icons showing: %d of %d plates"):format(Display.stats.shown, Display.stats.plates))
end

function Display:Test()
	local shown = 0
	for index = 1, 40 do
		local unit = "nameplate" .. index
		if UnitExists(unit) then
			local plate = Display:PlateFor(unit)
			if plate then
				local icon = Display.icons[unit] or table.remove(Display.pool) or createIcon()
				Display.icons[unit] = icon
				icon:SetParent(plate)
				icon:SetSize(BD.db.nameplates.size, BD.db.nameplates.size)
				icon:ClearAllPoints()
				icon:SetPoint("BOTTOM", plate, "TOP",
					BD.db.nameplates.offsetX or 0, BD.db.nameplates.offsetY)
				applyAura(icon, {
					category = "cc", name = "Test",
					icon = "Interface\\Icons\\Spell_Nature_Polymorph",
				})
				shown = shown + 1
			end
		end
	end
	BD:Print(("test icon on %d nameplate(s) for 5 seconds"):format(shown))
	if shown == 0 then
		BD:Print("no nameplates to attach to - |cffffd100/snp diag|r says why")
	end
	C_Timer.After(5, function() Display:UpdateAll() end)
end

-- ---------------------------------------------------------------------------
-- setup
-- ---------------------------------------------------------------------------

function Display:Initialize()
	local events = CreateFrame("Frame")
	events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	events:RegisterEvent("UNIT_AURA")
	events:RegisterEvent("PLAYER_ENTERING_WORLD")

	events:SetScript("OnEvent", function(_, event, unit)
		if event == "NAME_PLATE_UNIT_ADDED" then
			Display:Update(unit)
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			Display:Release(unit)
		elseif event == "UNIT_AURA" then
			if unit and unit:match("^nameplate") then Display:Update(unit) end
		else
			Display:UpdateAll()
		end
	end)

	C_Timer.NewTicker(0.2, refreshTimers)
	-- A sweep catches plates that were already up and auras whose event never
	-- reached us; forty UnitExists calls twice a second is cheap.
	C_Timer.NewTicker(0.5, function() Display:UpdateAll() end)
end
