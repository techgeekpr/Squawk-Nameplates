--[[ Class colours on nameplate health bars, and the bridge to Squawk Spy.

	Finding the health bar is the whole problem.  Blizzard has moved it more
	than once -- UnitFrame.healthBar, UnitFrame.healthbar, and in later builds
	HealthBarsContainer.healthBar -- and this client is a Midnight UI running
	Classic content, so which one exists is not worth assuming.  Each known
	shape is tried in turn, and if none match the plate's children are
	searched for a StatusBar.  Whatever is found is cached on the plate.

	Blizzard recolours the bar whenever the unit updates, so the colour is
	re-applied on a sweep rather than set once.

	The Spy bridge is entirely optional in both directions: every call checks
	the other addon exists first and goes through pcall, so running either
	addon without the other produces no errors at all.
]]

local BD = SquawkNamePlates
local Colors = {}
BD.Colors = Colors

-- The standard class colours: druid orange, paladin pink, shaman blue,
-- mage light blue, and so on.
local CLASS_COLORS = {
	DEATHKNIGHT = { 0.77, 0.12, 0.23 },
	DRUID       = { 1.00, 0.49, 0.04 },
	HUNTER      = { 0.67, 0.83, 0.45 },
	MAGE        = { 0.41, 0.80, 0.94 },
	PALADIN     = { 0.96, 0.55, 0.73 },
	PRIEST      = { 1.00, 1.00, 1.00 },
	ROGUE       = { 1.00, 0.96, 0.41 },
	SHAMAN      = { 0.00, 0.44, 0.87 },
	WARLOCK     = { 0.58, 0.51, 0.79 },
	WARRIOR     = { 0.78, 0.61, 0.43 },
	MONK        = { 0.00, 1.00, 0.59 },
	DEMONHUNTER = { 0.64, 0.19, 0.79 },
	EVOKER      = { 0.20, 0.58, 0.50 },
}

-- Kill on Sight is shown as a marker beside the plate, not by recolouring
-- the bar: the bar's job is to say the class, and one signal per channel
-- reads far better than a colour that means two different things.
local SKULL_ATLAS = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"

-- Which icon file holds a chicken is not something that can be known without
-- asking the client, so several plausible paths are probed and the first that
-- resolves is used.  /snp colors reports the winner, and the path can be
-- overridden in the settings if none of these is the one you want.
local CHICKEN_CANDIDATES = {
	"Interface\\Icons\\Ability_Hunter_Pet_Chicken",
	"Interface\\Icons\\Ability_Mount_Chicken",
	"Interface\\Icons\\INV_Misc_Bird_Chicken_01",
	"Interface\\Icons\\Ability_Hunter_Pet_Bird",
	"Interface\\Icons\\INV_Feather_01",
	"Interface\\Icons\\INV_Misc_QuestionMark",
}

-- SetTexture never fails, so a missing file looks exactly like a working one
-- until you see the blank on screen.  GetTextureFileID resolves the path and
-- returns nil when there is nothing behind it.
local probe
local function textureExists(path)
	if not path or path == "" then return false end
	if not probe then
		probe = UIParent:CreateTexture(nil, "BACKGROUND")
		probe:Hide()
	end
	if not pcall(probe.SetTexture, probe, path) then return false end

	if probe.GetTextureFileID then
		local id = probe:GetTextureFileID()
		probe:SetTexture(nil)
		return id ~= nil
	end
	local set = probe:GetTexture()
	probe:SetTexture(nil)
	return set ~= nil
end

local resolvedChicken
function Colors:ChickenTexture()
	local override = BD.db.chickenIcon
	if override and override ~= "" and textureExists(override) then return override, "your setting" end

	if resolvedChicken then return resolvedChicken, "probed" end
	for _, candidate in ipairs(CHICKEN_CANDIDATES) do
		if textureExists(candidate) then
			resolvedChicken = candidate
			return candidate, "probed"
		end
	end
	return CHICKEN_CANDIDATES[#CHICKEN_CANDIDATES], "fallback"
end

Colors.stats = { plates = 0, coloured = 0, noBar = 0 }

-- ---------------------------------------------------------------------------
-- finding the bar
-- ---------------------------------------------------------------------------

local function isStatusBar(object)
	if type(object) ~= "table" or not object.IsObjectType then return false end
	local ok, result = pcall(object.IsObjectType, object, "StatusBar")
	return ok and result and true or false
end

-- Depth-limited: a nameplate is shallow, and an unbounded walk over frames
-- every sweep would be wasteful.
local function searchForBar(frame, depth)
	if depth > 3 or type(frame) ~= "table" or not frame.GetChildren then return nil end
	local ok, children = pcall(function() return { frame:GetChildren() } end)
	if not ok then return nil end

	for _, child in ipairs(children) do
		if isStatusBar(child) then return child end
	end
	for _, child in ipairs(children) do
		local found = searchForBar(child, depth + 1)
		if found then return found end
	end
	return nil
end

function Colors:HealthBar(plate)
	if not plate then return nil end
	if isStatusBar(plate.squawkHealthBar) then return plate.squawkHealthBar end

	local frame = plate.UnitFrame or plate

	-- The shapes Blizzard has used, newest first.
	local container = frame.HealthBarsContainer
	for _, candidate in ipairs({
		(container and container.healthBar) or false,
		frame.healthBar or false,
		frame.healthbar or false,
		frame.HealthBar or false,
	}) do
		if candidate and isStatusBar(candidate) then
			plate.squawkHealthBar = candidate
			return candidate
		end
	end

	local found = searchForBar(frame, 1)
	if found then
		plate.squawkHealthBar = found
		return found
	end
	return nil
end

-- ---------------------------------------------------------------------------
-- the Spy bridge, optional in both directions
-- ---------------------------------------------------------------------------

-- Spy already watches nameplates itself, so this is belt and braces rather
-- than the only route -- but it costs nothing and covers the case where its
-- own sweep has not come round yet.
function Colors:TellSpy(unit)
	if not BD.db.tellSpy then return false end

	local spy = _G.SquawkSpy
	if type(spy) ~= "table" then return false end

	local detect = spy.Detect
	if type(detect) ~= "table" or type(detect.ScanUnit) ~= "function" then return false end

	return pcall(detect.ScanUnit, detect, unit, "nameplate") and true or false
end

-- Returns "kos", "guild", or nil.  Personal Kill on Sight outranks the guild
-- list, because it is your own judgement about that player.
function Colors:SpyListing(unit)
	if not BD.db.kosHighlight then return nil end

	local spy = _G.SquawkSpy
	if type(spy) ~= "table" then return nil end

	local ok, name = pcall(UnitName, unit)
	if not ok or type(name) ~= "string" or name == "" then return nil end

	if type(spy.IsKoS) == "function" then
		local read, kos = pcall(spy.IsKoS, spy, name)
		if read and kos then return "kos" end
	end

	local guild = spy.Guild
	if type(guild) == "table" and type(guild.IsKoS) == "function" then
		local read, kos = pcall(guild.IsKoS, guild, name)
		if read and kos then return "guild" end
	end
	return nil
end

-- ---------------------------------------------------------------------------
-- the Kill on Sight marker
-- ---------------------------------------------------------------------------

-- Anchored to the LEFT of the plate: Display.lua already owns the space above
-- it for the big aura icon, and two icons stacked there would collide.
function Colors:Marker(plate)
	if plate.squawkKoSMarker then return plate.squawkKoSMarker end

	local holder = CreateFrame("Frame", nil, plate)
	holder:SetFrameStrata("HIGH")
	holder:SetSize(20, 20)
	holder:SetPoint("RIGHT", plate, "LEFT", -4, 0)

	holder.Backdrop = holder:CreateTexture(nil, "BACKGROUND")
	holder.Backdrop:SetPoint("TOPLEFT", -1, 1)
	holder.Backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
	holder.Backdrop:SetColorTexture(0, 0, 0, 0.9)

	holder.Icon = holder:CreateTexture(nil, "ARTWORK")
	holder.Icon:SetAllPoints(holder)

	holder:Hide()
	plate.squawkKoSMarker = holder
	return holder
end

function Colors:UpdateMarker(unit, plate)
	local marker = Colors:Marker(plate)
	if not BD.db.kosHighlight then
		marker:Hide()
		return false
	end

	local kind = Colors:SpyListing(unit)
	if not kind then
		marker:Hide()
		return false
	end

	local size = BD.db.kosIconSize or 20
	marker:SetSize(size, size)

	if kind == "guild" then
		-- The guild's own list gets the chicken.
		marker.Icon:SetTexture((Colors:ChickenTexture()))
		marker.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		marker.Backdrop:SetColorTexture(1, 0.5, 0, 0.9)
	else
		-- Personal Kill on Sight gets the skull, sliced out of the raid target
		-- atlas: four marks per row, the skull being the eighth.
		marker.Icon:SetTexture(SKULL_ATLAS)
		marker.Icon:SetTexCoord(0.75, 1.0, 0.25, 0.5)
		marker.Backdrop:SetColorTexture(1, 0.1, 0.1, 0.9)
	end

	marker:Show()
	return true
end

-- ---------------------------------------------------------------------------
-- colouring
-- ---------------------------------------------------------------------------

-- UnitIsPlayer can hand back a secret boolean on this client, and testing one
-- throws.  An unreadable answer is treated as "yes", matching how the rest of
-- the addon filters.
local function probablyPlayer(unit)
	local ok, value = pcall(UnitIsPlayer, unit)
	if not ok then return true end
	local readable, result = pcall(function() return value and true or false end)
	if not readable then return true end
	return result
end

function Colors:ClassColor(unit)
	local ok, _, class = pcall(UnitClass, unit)
	if not ok or type(class) ~= "string" then return nil end
	return CLASS_COLORS[class], class
end

function Colors:Apply(unit)
	if not BD.db.classColors and not BD.db.kosHighlight then return false end
	if not UnitExists(unit) then return false end

	local plate = BD.Display and BD.Display:PlateFor(unit)
	if not plate then return false end

	local bar = Colors:HealthBar(plate)
	if not bar then
		Colors.stats.noBar = Colors.stats.noBar + 1
		return false
	end

	-- The marker is independent of the bar: Kill on Sight no longer overrides
	-- the class colour, it sits beside it.
	Colors:UpdateMarker(unit, plate)

	if not BD.db.classColors or not probablyPlayer(unit) then return false end

	local colour = Colors:ClassColor(unit)
	if not colour then return false end

	pcall(bar.SetStatusBarColor, bar, colour[1], colour[2], colour[3])
	return true
end

function Colors:ApplyAll()
	local plates, coloured = 0, 0
	Colors.stats.noBar = 0

	for index = 1, 40 do
		local unit = "nameplate" .. index
		if UnitExists(unit) then
			plates = plates + 1
			if Colors:Apply(unit) then coloured = coloured + 1 end
		end
	end

	Colors.stats.plates, Colors.stats.coloured = plates, coloured
end

-- ---------------------------------------------------------------------------
-- diagnostics
-- ---------------------------------------------------------------------------

function Colors:Diagnostics()
	BD:Print("---- colours ----")
	BD:Print(("class colours: %s   KoS highlight: %s   tell Spy: %s"):format(
		BD.db.classColors and "|cff00ff00on|r" or "|cffff0000off|r",
		BD.db.kosHighlight and "|cff00ff00on|r" or "|cffff0000off|r",
		BD.db.tellSpy and "|cff00ff00on|r" or "|cffff0000off|r"))

	local spy = _G.SquawkSpy
	BD:Print(("Squawk Spy: %s"):format(
		type(spy) == "table" and "|cff00ff00installed|r" or "|cffffd100not installed - that is fine|r"))
	if type(spy) == "table" then
		BD:Print(("  ScanUnit: %s   IsKoS: %s   Guild list: %s"):format(
			(type(spy.Detect) == "table" and type(spy.Detect.ScanUnit) == "function") and "yes" or "no",
			type(spy.IsKoS) == "function" and "yes" or "no",
			(type(spy.Guild) == "table" and type(spy.Guild.IsKoS) == "function") and "yes" or "no"))
	end

	local chicken, how = Colors:ChickenTexture()
	BD:Print(("guild KoS icon (%s): %s"):format(how, tostring(chicken)))

	Colors:ApplyAll()
	BD:Print(("plates: %d, coloured: %d, no health bar found: %d"):format(
		Colors.stats.plates, Colors.stats.coloured, Colors.stats.noBar))

	-- Which shape the bar was actually found in, for the first plate that has
	-- one: the whole feature hangs on this and it is worth stating.
	for index = 1, 40 do
		local unit = "nameplate" .. index
		if UnitExists(unit) then
			local plate = BD.Display and BD.Display:PlateFor(unit)
			local bar = plate and Colors:HealthBar(plate)
			if bar then
				local name = (bar.GetName and bar:GetName()) or "unnamed"
				BD:Print(("first bar found: %s"):format(name))
			else
				BD:Print("|cffff0000no StatusBar found on the plate at all|r")
			end
			return
		end
	end
	BD:Print("no nameplates up to inspect - |cffffd100/snp plates|r turns them on")
end

-- ---------------------------------------------------------------------------
-- setup
-- ---------------------------------------------------------------------------

function Colors:Initialize()
	local events = CreateFrame("Frame")
	events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	events:RegisterEvent("UNIT_HEALTH")
	events:RegisterEvent("UNIT_FACTION")

	events:SetScript("OnEvent", function(_, event, unit)
		if event == "NAME_PLATE_UNIT_ADDED" then
			Colors:Apply(unit)
			Colors:TellSpy(unit)
		elseif unit and type(unit) == "string" and unit:match("^nameplate") then
			Colors:Apply(unit)
		end
	end)

	-- Blizzard repaints the bar on its own updates, so the colour has to be
	-- put back rather than set once.
	C_Timer.NewTicker(0.4, function() Colors:ApplyAll() end)
end
