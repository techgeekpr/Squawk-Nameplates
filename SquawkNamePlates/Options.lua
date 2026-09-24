--[[ Options: what to watch, where to show it, and how big. ]]

local BD = SquawkNamePlates
local Options = {}
BD.Options = Options

local controls = {}
local COLUMN_WIDTH = 300
local COLUMNS = { 20, 350 }
local ROW = 24
local WIDE_ROW = 28
local SECTION = 36

local function apply()
	BD.Display:UpdateAll()
end

local function checkbox(parent, x, y, label, get, set, tooltip)
	local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	check:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	check:SetSize(22, 22)

	local text = check.Text or _G[(check:GetName() or "") .. "Text"]
	if not text then
		text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		text:SetPoint("LEFT", check, "RIGHT", 2, 0)
	end
	text:SetFontObject("GameFontHighlightSmall")
	text:SetText(label)
	text:SetWidth(COLUMN_WIDTH - 26)
	text:SetJustifyH("LEFT")

	check:SetScript("OnClick", function(self)
		set(self:GetChecked() and true or false)
		apply()
	end)
	if tooltip then
		check:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(label, 1, 0.82, 0, 1)
			GameTooltip:AddLine(tooltip, 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		check:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end

	check.Refresh = function(self) self:SetChecked(get() and true or false) end
	controls[#controls + 1] = check
	return check
end

local function stepper(parent, x, y, label, get, set, step, minimum, maximum, width)
	width = width or COLUMN_WIDTH
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	holder:SetSize(width, 20)

	local text = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	text:SetPoint("LEFT", holder, "LEFT", 2, 0)
	text:SetJustifyH("LEFT")
	text:SetWidth(math.max(width - 96, 1))
	text:SetText(label)

	local plus = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
	plus:SetSize(20, 18)
	plus:SetPoint("RIGHT", holder, "RIGHT", 0, 0)
	plus:SetText("+")

	local value = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	value:SetPoint("RIGHT", plus, "LEFT", -3, 0)
	value:SetWidth(42)
	value:SetJustifyH("CENTER")

	local minus = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
	minus:SetSize(20, 18)
	minus:SetPoint("RIGHT", value, "LEFT", -3, 0)
	minus:SetText("-")

	local function refresh() value:SetText(tostring(get())) end
	local function nudge(direction)
		set(math.max(minimum, math.min(maximum, get() + direction * step)))
		refresh()
		apply()
	end
	minus:SetScript("OnClick", function() nudge(-1) end)
	plus:SetScript("OnClick", function() nudge(1) end)

	holder.Refresh = refresh
	controls[#controls + 1] = holder
	return holder
end

local function header(parent, x, y, label)
	local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	text:SetText(label)
	return text
end

function Options:Initialize()
	local panel = CreateFrame("Frame", "SquawkNamePlates_Options", UIParent, "BackdropTemplate")
	Options.Panel = panel
	panel.name = "Squawk NamePlates"
	panel:SetSize(700, 540)
	panel:Hide()

	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -14)
	title:SetText("Squawk NamePlates " .. BD.Version)

	local credit = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	credit:SetPoint("LEFT", title, "RIGHT", 10, 0)
	credit:SetText("|cffffd100Made by: Avoid Me|r |cff82c5ff<Squawk>|r")

	local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
	subtitle:SetWidth(660)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetText("One big icon per enemy nameplate, showing the most important thing on them right now: crowd control first, then immunities, defensives, offensives, potions and racials.")

	local scroll = CreateFrame("ScrollFrame", nil, panel)
	scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -60)
	scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -6, 44)
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self, delta)
		local range = self:GetVerticalScrollRange() or 0
		self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * 40)))
	end)

	local content = CreateFrame("Frame", nil, scroll)
	content:SetSize(690, 560)
	scroll:SetScrollChild(content)

	local db = function() return BD.db end
	local c1, c2 = COLUMNS[1], COLUMNS[2]
	local y = -10

	header(content, c1, y, "What to watch")
	y = y - ROW
	for _, key in ipairs(BD.CategoryOrder) do
		checkbox(content, c1, y, BD.CategoryNames[key],
			function() return db().categories[key] end,
			function(v) db().categories[key] = v end)
		y = y - ROW
	end

	y = y - (SECTION - ROW)
	header(content, c1, y, "Icon contents")
	y = y - ROW
	checkbox(content, c1, y, "Cooldown spiral",
		function() return db().showCooldown end,
		function(v) db().showCooldown = v end,
		"Needs a readable duration; when the client hides it the icon still shows, just without the sweep.")
	y = y - ROW
	checkbox(content, c1, y, "Countdown text",
		function() return db().showTimer end,
		function(v) db().showTimer = v end)
	y = y - ROW
	checkbox(content, c1, y, "Stack count",
		function() return db().showStacks end,
		function(v) db().showStacks = v end)
	y = y - ROW
	checkbox(content, c1, y, "Colour the border by category",
		function() return db().colouredBorder end,
		function(v) db().colouredBorder = v end,
		"Red crowd control, gold immunity, blue defensive, orange offensive, green potion, purple racial.")

	y = -10
	header(content, c2, y, "Nameplates")
	y = y - ROW
	checkbox(content, c2, y, "Icons on nameplates",
		function() return db().nameplates.enabled end,
		function(v) db().nameplates.enabled = v end)
	y = y - ROW
	checkbox(content, c2, y, "Enemies only",
		function() return db().nameplates.onlyEnemies end,
		function(v) db().nameplates.onlyEnemies = v end)
	y = y - ROW
	checkbox(content, c2, y, "Players only",
		function() return db().nameplates.onlyPlayers end,
		function(v) db().nameplates.onlyPlayers = v end)
	y = y - WIDE_ROW
	stepper(content, c2, y, "Nameplate icon size",
		function() return db().nameplates.size end,
		function(v) db().nameplates.size = v end, 2, 16, 96)
	y = y - ROW
	stepper(content, c2, y, "Height above the plate",
		function() return db().nameplates.offsetY end,
		function(v) db().nameplates.offsetY = v end, 2, -40, 120)

	y = y - ROW
	stepper(content, c2, y, "Nudge left / right",
		function() return db().nameplates.offsetX end,
		function(v) db().nameplates.offsetX = v end, 2, -200, 200)

	y = y - SECTION
	local note = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	note:SetPoint("TOPLEFT", content, "TOPLEFT", c2, y)
	note:SetWidth(COLUMN_WIDTH)
	note:SetJustifyH("LEFT")
	note:SetText("Icons are drawn on enemy nameplates only.|n|n"
		.. "Enemy nameplates must be switched on for any of this to appear: "
		.. "press V, or run |cffffd100/snp plates|r.|n|n"
		.. "|cffffd100/snp diag|r reports what the client is handing over, and "
		.. "|cffffd100/snp test|r puts a marker on every visible plate.")

	panel:SetScript("OnShow", function() Options:Refresh() end)

	if type(Settings) == "table" and Settings.RegisterCanvasLayoutCategory then
		local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel, "Squawk NamePlates")
		if ok and category then
			Options.Category = category
			pcall(Settings.RegisterAddOnCategory, category)
			return
		end
	end
	if type(InterfaceOptions_AddCategory) == "function" then
		pcall(InterfaceOptions_AddCategory, panel)
		return
	end

	Options.Standalone = true
	panel:SetPoint("CENTER")
	panel:SetFrameStrata("DIALOG")
	panel:EnableMouse(true)
	panel:SetMovable(true)
	panel:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	panel:SetBackdropColor(0, 0, 0, 0.92)
	panel:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	panel:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

	local close = CreateFrame("Button", nil, panel)
	close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	close:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	close:SetSize(20, 20)
	close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -6, -6)
	close:SetScript("OnClick", function() panel:Hide() end)
end

function Options:Refresh()
	for _, control in ipairs(controls) do
		if control.Refresh then control:Refresh() end
	end
end

function Options:Open()
	if not Options.Panel then
		BD:Print("the options panel did not start; use the slash commands instead")
		return
	end
	if Options.Category and Settings and Settings.OpenToCategory then
		Settings.OpenToCategory(Options.Category:GetID())
	elseif Options.Standalone then
		Options.Panel:Show()
		Options:Refresh()
	else
		Options.Panel:Show()
	end
end
