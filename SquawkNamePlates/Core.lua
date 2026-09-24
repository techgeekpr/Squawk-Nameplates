--[[ Squawk NamePlates -- oversized icons for the auras that decide a fight.

	Made by Avoid Me of <Squawk>.

	Nameplates and unit frames get one large icon showing the most important
	thing currently on that unit: crowd control first, then immunities,
	defensive cooldowns, offensive cooldowns, potions and racials.

	On this client auras read cleanly -- name, icon, stacks and dispel type are
	all available -- but durations are not guaranteed, so the cooldown spiral
	and the countdown text are both optional at runtime and simply do not draw
	when the numbers are hidden.
]]

local ADDON = ...

SquawkNamePlates = {}
local BD = SquawkNamePlates

BD.Version = "1.0.0"

-- ---------------------------------------------------------------------------
-- database
-- ---------------------------------------------------------------------------

local function copy(t)
	local n = {}
	for k, v in pairs(t) do
		if type(v) == "table" then n[k] = copy(v) else n[k] = v end
	end
	return n
end

local function fill(target, source)
	for k, v in pairs(source) do
		if type(v) == "table" then
			if type(target[k]) ~= "table" then target[k] = {} end
			fill(target[k], v)
		elseif target[k] == nil then
			target[k] = v
		end
	end
	return target
end

BD.Defaults = {
	enabled = true,

	nameplates = {
		enabled = true,
		size = 42,
		offsetX = 0,
		offsetY = 12,
		onlyEnemies = true,
		onlyPlayers = true,
	},

	categories = {
		cc = true, immunity = true, defensive = true,
		offensive = true, potion = true, racial = true,
	},

	showCooldown = true,
	showTimer = true,
	showStacks = true,
	colouredBorder = true,
	announce = false,          -- print immunities and potions to chat
}

function BD:InitDatabase()
	local snapshots = SquawkNamePlates_Restore
	SquawkNamePlates_Restore = nil

	local live = (type(SquawkNamePlatesDB) == "table") and SquawkNamePlatesDB or nil
	SquawkNamePlatesDB = live or {}
	SquawkNamePlatesDB.profiles = SquawkNamePlatesDB.profiles or {}
	SquawkNamePlatesDB.custom = SquawkNamePlatesDB.custom or {}

	if not live and type(snapshots) == "table" then
		for _, snap in ipairs(snapshots) do
			if type(snap) == "table" then
				for key, profile in pairs(snap.profiles or {}) do
					if not SquawkNamePlatesDB.profiles[key] then SquawkNamePlatesDB.profiles[key] = profile end
				end
				for name, category in pairs(snap.custom or {}) do
					if SquawkNamePlatesDB.custom[name] == nil then SquawkNamePlatesDB.custom[name] = category end
				end
			end
		end
	end
	-- Carried over from the old Big PvP name so the rename costs nothing.
	local legacy = SquawkNamePlates_Legacy
	SquawkNamePlates_Legacy = nil
	if type(legacy) == "table" then
		for _, snap in ipairs(legacy) do
			if type(snap) == "table" then
				for key, profile in pairs(snap.profiles or {}) do
					if not SquawkNamePlatesDB.profiles[key] then
						SquawkNamePlatesDB.profiles[key] = profile
						BD.AdoptedProfiles = (BD.AdoptedProfiles or 0) + 1
					end
				end
				for name, category in pairs(snap.custom or {}) do
					if SquawkNamePlatesDB.custom[name] == nil then
						SquawkNamePlatesDB.custom[name] = category
					end
				end
			end
		end
	end

	BD.ClientRestoredSV = live ~= nil

	local key = (UnitName("player") or "?") .. " - " .. (GetRealmName() or "?")
	BD.ProfileKey = key
	SquawkNamePlatesDB.profiles[key] = SquawkNamePlatesDB.profiles[key] or {}
	BD.db = fill(SquawkNamePlatesDB.profiles[key], copy(BD.Defaults))
end

function BD:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cffff7d0aSquawk NamePlates:|r " .. tostring(msg))
end

-- ---------------------------------------------------------------------------
-- reading auras
--
-- The same guarded reader pattern used elsewhere on this client: any field
-- can be a secret, and touching one throws, so every read is wrapped and a
-- failure means "show nothing" rather than an error.
-- ---------------------------------------------------------------------------

local function readAuras(unit, filter, fn)
	local byIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
	if byIndex then
		for index = 1, 40 do
			local ok, data = pcall(byIndex, unit, index, filter)
			if not ok then return false end
			if not data then return true end

			local readOk, name, icon, count, duration, expires, spellId = pcall(function()
				return tostring(data.name), data.icon, data.applications,
					data.duration, data.expirationTime, data.spellId
			end)
			if not readOk then return false end
			if fn(name, icon, count, duration, expires, spellId) then return true end
		end
		return true
	end

	if type(UnitAura) == "function" then
		for index = 1, 40 do
			local ok, name, icon, count, _, duration, expires, _, _, _, spellId =
				pcall(UnitAura, unit, index, filter)
			if not ok then return false end
			if not name then return true end
			if fn(tostring(name), icon, count, duration, expires, spellId) then return true end
		end
		return true
	end

	return false
end

BD.ReadAuras = readAuras

-- Finds the single most important aura on a unit.
function BD:FindBest(unit)
	if not unit or not UnitExists(unit) then return nil end

	local best
	local function consider(name, icon, count, duration, expires, spellId)
		-- Spell id first: it is exact, covers every rank, and does not care
		-- how the aura is spelled.  Name is the fallback when the id is
		-- unreadable on this client.
		local category = BD:CategoryOfID(spellId) or BD:CategoryOf(name)
		if not category or not BD.db.categories[category] then return false end
		if not icon then return false end

		local priority = BD.Priority[category] or 99
		if not best or priority < best.priority then
			best = {
				priority = priority,
				category = category,
				name = name,
				icon = icon,
				count = tonumber(count),
				duration = tonumber(duration),
				expires = tonumber(expires),
			}
		end
		return false
	end

	readAuras(unit, "HARMFUL", consider)
	readAuras(unit, "HELPFUL", consider)
	return best
end

-- ---------------------------------------------------------------------------
-- slash commands
-- ---------------------------------------------------------------------------

-- Lists what is on your target and which category each aura maps to, so
-- anything missing from the lists can be spotted and added.
function BD:Scan(unit)
	unit = unit or "target"
	if not UnitExists(unit) then
		BD:Print("nothing to scan - target something first")
		return
	end

	BD:Print(("auras on %s:"):format(UnitName(unit) or unit))
	local found = 0
	local function report(filter)
		readAuras(unit, filter, function(name, icon, count, duration, expires, spellId)
			found = found + 1
			local category = BD:CategoryOfID(spellId) or BD:CategoryOf(name)
			local id = tonumber(spellId)
			BD:Print(("  %s%s|r %s %s"):format(
				category and "|cff00ff00" or "|cff888888",
				name,
				id and ("|cff888888(" .. id .. ")|r") or "",
				category and ("-> " .. category) or "not watched"))
			return false
		end)
	end
	report("HARMFUL")
	report("HELPFUL")

	if found == 0 then BD:Print("  nothing readable") end
	BD:Print("add one with |cffffd100/bd add <category> <name>|r")
end

local function handleSlash(msg)
	msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local cmd, rest = msg:match("^(%S*)%s*(.*)$")
	cmd = (cmd or ""):lower()

	if cmd == "" or cmd == "config" or cmd == "options" then
		BD.Options:Open()
	elseif cmd == "scan" then
		BD:Scan(rest ~= "" and rest or "target")
	elseif cmd == "add" then
		local category, name = rest:match("^(%S+)%s+(.+)$")
		category = category and category:lower()
		if not name or not BD.Priority[category] then
			BD:Print("usage: /bd add <cc|immunity|defensive|offensive|potion|racial> <aura name>")
			return
		end
		SquawkNamePlatesDB.custom[name] = category
		BD:BuildLookup()
		BD:Print(("watching |cffffd100%s|r as %s"):format(name, category))
	elseif cmd == "remove" then
		if rest == "" then BD:Print("usage: /bd remove <aura name>") return end
		SquawkNamePlatesDB.custom[rest] = false
		BD:BuildLookup()
		BD:Print(("ignoring |cffffd100%s|r"):format(rest))
	elseif cmd == "test" then
		BD.Display:Test()
	elseif cmd == "diag" then
		BD.Display:Diagnostics()
	elseif cmd == "plates" then
		local set = (C_CVar and C_CVar.SetCVar) or SetCVar
		if set then
			pcall(set, "nameplateShowEnemies", "1")
			pcall(set, "nameplateMaxDistance", "60")
			BD:Print("enemy nameplates on, draw distance 60 yards")
		end
	else
		BD:Print("/snp | diag | test | plates | scan | add <category> <name> | remove <name>")
	end
end

SLASH_SQUAWKNAMEPLATES1 = "/snp"
SLASH_SQUAWKNAMEPLATES2 = "/squawknameplates"
SLASH_SQUAWKNAMEPLATES3 = "/bd"
SlashCmdList["SQUAWKNAMEPLATES"] = handleSlash

-- ---------------------------------------------------------------------------
-- boot
-- ---------------------------------------------------------------------------

local boot = CreateFrame("Frame")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function()
	BD:InitDatabase()
	BD:BuildLookup()

	if not BD.db.enabled then
		BD:Print("disabled - /bd config to switch it back on")
		return
	end

	for _, module in ipairs({ "Display", "Options" }) do
		local ok, err = pcall(function() BD[module]:Initialize() end)
		if not ok then BD:Print(("|cffff0000%s failed:|r %s"):format(module, tostring(err))) end
	end

	if (BD.AdoptedProfiles or 0) > 0 then
		BD:Print(("carried over %d saved profile(s) from the previous version."):format(BD.AdoptedProfiles))
	end
	BD:Print("loaded. |cffffd100/snp|r for options, |cffffd100/snp diag|r if icons do not appear.")
end)
