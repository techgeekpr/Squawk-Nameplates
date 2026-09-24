--[[ What to watch for.

	Every entry below was resolved against Wowhead's Forever spell database
	(wowhead.com/forever/spells), so the names are the client's own and the ids
	cover every rank.  Matching prefers the spell id, which is exact and
	rank-proof; the name is only a fallback for clients that will not hand the
	id over.

	Regenerated data, not hand-typed: if something is wrong here it is wrong in
	the source, not a typo.
]]

local BD = SquawkNamePlates

-- Lower number wins when a unit has several of these at once.
BD.Priority = {
	cc        = 1,
	immunity  = 2,
	defensive = 3,
	offensive = 4,
	potion    = 5,
	racial    = 6,
}

BD.CategoryColors = {
	cc        = { 0.85, 0.20, 0.20 },   -- red
	immunity  = { 1.00, 0.85, 0.20 },   -- gold
	defensive = { 0.20, 0.70, 1.00 },   -- blue
	offensive = { 1.00, 0.45, 0.10 },   -- orange
	potion    = { 0.40, 0.90, 0.40 },   -- green
	racial    = { 0.75, 0.45, 0.95 },   -- purple
}

BD.CategoryNames = {
	cc = "Crowd control",
	immunity = "Immunities",
	defensive = "Defensive cooldowns",
	offensive = "Offensive cooldowns",
	potion = "Potions and items",
	racial = "Racials",
}

BD.CategoryOrder = { "cc", "immunity", "defensive", "offensive", "potion", "racial" }

-- ---------------------------------------------------------------------------

BD.Spells = {
	-- Hard control: stuns, fears, incapacitates, roots, silences, disarms.
	cc = {
		{ name = "Arcane Bomb", ids = { 19821, 19831, 462664, 466283, 466357 } },
		{ name = "Banish", ids = { 710, 8994, 18647, 24466, 27565, 457569, 465352 } },
		{ name = "Bash", ids = { 5211, 6798, 8983, 8984, 25515, 440586, 447891, 1260650 } },
		{ name = "Blackout", ids = { 15268, 15269, 15323, 15324, 15325, 15326 } },
		{ name = "Blind", ids = { 2094, 21060, 447563, 1303286, 1305855 } },
		{ name = "Charge Stun", ids = { 7922, 411688 } },
		{ name = "Cheap Shot", ids = { 1833, 6409, 14902 } },
		{ name = "Concussion Blow", ids = { 12809 } },
		{ name = "Counterattack", ids = { 19306, 20909, 20910, 1242634 } },
		{ name = "Counterspell - Silenced", ids = { 18469 } },
		{ name = "Curse of Tongues", ids = { 1714, 11719, 12889, 13338, 15470, 25195, 402794, 444046 } },
		{ name = "Death Coil", ids = { 6789, 17925, 17926, 28412 } },
		{ name = "Disarm", ids = {
			676, 6713, 8379, 11879, 13534, 15752, 22691, 27581, 445282,
			458880, 1225423, 1225428, 1236176
		} },
		{ name = "Earthbind", ids = { 3600 } },
		{ name = "Entangling Roots", ids = {
			339, 1062, 5195, 5196, 9852, 9853, 11922, 12747, 19970, 19971,
			19972, 19973, 19974, 19975, 20654, 20699, 21331, 22127, 22415,
			22800, 24648, 26071, 28858, 435991, 460690, 1213253, 1263640,
			1281781, 1294112, 1303308, 1316480, 1320095
		} },
		{ name = "Fear", ids = {
			663, 5782, 6213, 6215, 12096, 12542, 22678, 26070, 26580,
			27641, 27990, 29168, 30002, 411959, 469521, 469793, 469879,
			1213452, 1222563, 1247087, 1271593
		} },
		{ name = "Feral Charge", ids = { 19675, 414920, 414921, 414923, 414925, 1238122, 1238124 } },
		{ name = "Freezing Trap", ids = {
			1499, 14310, 14311, 27753, 1285994, 1288849, 1288851, 1288852,
			1294351, 1294353, 1294444
		} },
		{ name = "Freezing Trap Effect", ids = { 3355, 14308, 14309 } },
		{ name = "Frost Nova", ids = {
			122, 865, 6131, 9915, 10230, 11831, 12674, 12748, 14907,
			15063, 15531, 15532, 22645, 29849, 30094, 463448, 1220855,
			1289447
		} },
		{ name = "Frost Shock", ids = {
			8056, 8058, 10472, 10473, 12548, 15089, 15499, 19133, 21030,
			21401, 22582, 23115, 1248001
		} },
		{ name = "Frostbite", ids = { 11071, 12494 } },
		{ name = "Gnomish Mind Control Cap", ids = { 12907, 13180, 13181, 26740 } },
		{ name = "Goblin Mortar", ids = { 12716, 12768, 13237, 13238, 451714 } },
		{ name = "Gouge", ids = { 1776, 1777, 8629, 11285, 11286, 12540, 13579, 24698, 28456 } },
		{ name = "Hammer of Justice", ids = { 853, 5588, 5589, 10308, 13005, 1213301 } },
		{ name = "Hamstring", ids = { 1715, 7372, 7373, 9080, 26141, 26211, 27584, 1236177 } },
		{ name = "Hibernate", ids = { 2637, 18657, 18658 } },
		{ name = "Howl of Terror", ids = { 5484, 17928 } },
		{ name = "Impact", ids = { 11103, 12355, 1239832 } },
		{ name = "Improved Hamstring", ids = { 12289, 23694, 24428 } },
		{ name = "Intercept Stun", ids = { 20253, 20614 } },
		{ name = "Intimidation", ids = { 7093, 19577, 24394 } },
		{ name = "Iron Grenade", ids = { 3962, 4068 } },
		{ name = "Kidney Shot", ids = { 408, 8643, 8644, 27615 } },
		{ name = "Mind Control", ids = { 605, 627, 10911, 10912, 11446, 15690, 1213332 } },
		{ name = "Mind Flay", ids = {
			15407, 16568, 17165, 17311, 17312, 17313, 17314, 18807, 22919,
			23953, 26044, 26143, 28310, 29407, 368292, 368315, 368320,
			412526, 474204, 474268, 1215740
		} },
		{ name = "Net-o-Matic", ids = { 13099, 13119, 13120, 13138, 13139, 16566 } },
		{ name = "Piercing Howl", ids = { 10576, 12323, 23600 } },
		{ name = "Polymorph", ids = {
			118, 12824, 12825, 12826, 13323, 14621, 15534, 27760, 28271,
			28272, 29124, 29848, 434754, 1236174, 1236290, 1320379
		} },
		{ name = "Pounce", ids = { 9005, 9823, 9827, 1229228, 1258520, 1264548 } },
		{ name = "Psychic Scream", ids = {
			8122, 8124, 10888, 10890, 13704, 15398, 22884, 26042, 27610,
			437928
		} },
		{ name = "Repentance", ids = { 20066 } },
		{ name = "Riposte", ids = { 5237, 6187, 6569, 14251 } },
		{ name = "Sap", ids = { 2070, 6770, 11297 } },
		{ name = "Scare Beast", ids = { 1513, 14326, 14327 } },
		{ name = "Scatter Shot", ids = { 1988, 19503, 23601, 462666 } },
		{ name = "Seduction", ids = { 6358, 6359, 20407 } },
		{ name = "Shackle Undead", ids = { 1425, 9484, 9485, 10955, 11444 } },
		{ name = "Silence", ids = {
			6726, 8988, 12528, 15487, 18278, 18327, 22666, 23207, 26069,
			27559, 29943, 30225, 1214273, 1224125, 1293654, 1304401
		} },
		{ name = "Silenced", ids = { 18498 } },
		{ name = "Silenced - Kick", ids = { 18425 } },
		{ name = "Spell Lock", ids = { 19244, 19647, 19648, 19650, 20433, 20434, 24259 } },
		{ name = "Thorium Grenade", ids = { 19769, 19790 } },
		{ name = "Turn Undead", ids = { 2878, 5627, 10326, 19725 } },
		{ name = "Wing Clip", ids = { 2974, 14267, 14268, 14340, 27633, 1310180 } },
		{ name = "Wyvern Sting", ids = { 24335, 24336, 26180, 26233, 1215753 } },
	},

	-- Flat immunity: the ones that mean do not bother.
	immunity = {
		{ name = "Banish", ids = { 710, 8994, 18647, 24466, 27565, 457569, 465352 } },
		{ name = "Blessing of Protection", ids = { 1022, 5599, 10278, 442948 } },
		{ name = "Divine Intervention", ids = { 19752, 19753 } },
		{ name = "Divine Protection", ids = { 498, 5573, 13007, 27778, 27779, 458312, 458371, 1213300 } },
		{ name = "Divine Shield", ids = { 642, 659, 1020, 13874 } },
		{ name = "Ice Block", ids = { 11958, 27619 } },
		{ name = "Invulnerability", ids = { 3169 } },
		{ name = "Spirit of Redemption", ids = { 20711, 27792, 27795, 27827 } },
	},

	-- Survival cooldowns that are not full immunities.
	defensive = {
		{ name = "Barkskin", ids = { 20655, 22812, 428713, 1289128 } },
		{ name = "Blessing of Freedom", ids = { 1044 } },
		{ name = "Blessing of Sacrifice", ids = { 6940, 20729 } },
		{ name = "Desperate Prayer", ids = { 13908, 19236, 19238, 19240, 19241, 19242, 19243, 19338, 459702 } },
		{ name = "Deterrence", ids = { 19263 } },
		{ name = "Evasion", ids = { 4086, 5277, 15087 } },
		{ name = "Fade", ids = { 586, 9578, 9579, 9592, 10941, 10942, 12685, 20672, 1292765 } },
		{ name = "Feign Death", ids = { 5384 } },
		{ name = "Fire Ward", ids = {
			543, 874, 8457, 8458, 10223, 10225, 15041, 412214, 412218,
			412230, 412231, 412232
		} },
		{ name = "Frenzied Regeneration", ids = { 22842, 22845, 428708 } },
		{ name = "Frost Ward", ids = {
			6143, 8461, 8462, 10177, 15044, 28609, 412202, 412205, 412207,
			412209, 412210
		} },
		{ name = "Grounding Totem Effect", ids = { 8178 } },
		{ name = "Holy Shield", ids = { 9800, 20925, 20927, 20928, 456544 } },
		{ name = "Ice Barrier", ids = { 11426, 13031, 13032, 13033, 1213278 } },
		{ name = "Inner Fire", ids = { 588, 602, 624, 1006, 1254, 7128, 10951, 10952 } },
		{ name = "Last Stand", ids = { 12975, 12976 } },
		{ name = "Mana Shield", ids = {
			1463, 8494, 8495, 10191, 10192, 10193, 17740, 17741, 412116,
			412118, 412120, 412121, 412122, 412123
		} },
		{ name = "Nature's Grasp", ids = { 16689, 16810, 16811, 16812, 16813, 17329 } },
		{ name = "Power Word: Shield", ids = {
			17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901,
			11647, 11835, 11974, 17139, 20697, 22187, 27607, 437930,
			1226566, 1236154
		} },
		{ name = "Retaliation", ids = { 20230, 20240, 22857, 22858 } },
		{ name = "Shield Block", ids = { 2565, 2570, 12169, 467891 } },
		{ name = "Shield Wall", ids = { 871, 15062, 29061, 1277424 } },
		{ name = "Stoneskin Totem", ids = { 8071, 8073, 8154, 8155, 8199, 10406, 10407, 10408 } },
		{ name = "Survival Instincts", ids = { 408024, 408025, 409809 } },
		{ name = "Tremor Totem", ids = { 8143, 78156 } },
		{ name = "Vanish", ids = {
			1856, 1857, 11327, 11329, 24223, 24228, 24229, 24230, 24231,
			24232, 24233, 24699, 24700, 27617, 457437, 1231389, 1234595,
			1285372
		} },
	},

	-- Damage cooldowns worth reacting to.
	offensive = {
		{ name = "Adrenaline Rush", ids = { 13750, 28752, 28753 } },
		{ name = "Amplify Magic", ids = { 1008, 8455, 10169, 10170 } },
		{ name = "Arcane Power", ids = { 12042, 430952 } },
		{ name = "Bestial Wrath", ids = { 19574, 1310831 } },
		{ name = "Blade Flurry", ids = { 13877, 1226883, 1230700 } },
		{ name = "Bloodrage", ids = { 2687, 29131 } },
		{ name = "Cold Blood", ids = { 14177 } },
		{ name = "Combustion", ids = { 11129, 28682 } },
		{ name = "Crusader Strike", ids = {
			2537, 8823, 8824, 10336, 10337, 14517, 14518, 17281, 409914,
			1234893, 1236182, 1319259
		} },
		{ name = "Death Wish", ids = { 12328 } },
		{ name = "Divine Favor", ids = { 20216 } },
		{ name = "Enrage", ids = {
			1640, 3019, 5229, 8269, 8599, 12317, 12686, 12795, 12880,
			15061, 15097, 15716, 18501, 19516, 19953, 23537, 24318, 25503,
			26527, 27897, 28131, 28468, 28747, 28798, 425415, 427066,
			440483, 446327, 460862, 461347, 461348, 461349, 462885,
			1223458, 1284435, 1288972, 1303979
		} },
		{ name = "Holy Shock", ids = {
			20473, 20929, 20930, 25902, 25903, 25911, 25912, 25913, 25914,
			444894, 1311604, 1311605, 1311606
		} },
		{ name = "Icy Veins", ids = { 425121, 425169, 429125 } },
		{ name = "Inner Focus", ids = { 14751 } },
		{ name = "Nature's Swiftness", ids = { 16188, 17116, 29274 } },
		{ name = "Power Infusion", ids = { 10060 } },
		{ name = "Presence of Mind", ids = { 12043 } },
		{ name = "Rapid Fire", ids = { 3045, 28755, 1227772 } },
		{ name = "Recklessness", ids = { 1719, 13847 } },
		{ name = "Shadow Trance", ids = { 17941 } },
		{ name = "Shadowform", ids = { 15473, 16592, 22917, 401980, 412527, 412569, 426223, 1213334 } },
		{ name = "Slice and Dice", ids = { 5171, 6434, 6774 } },
		{ name = "Sweeping Strikes", ids = {
			12292, 12723, 18765, 26654, 462890, 1228365, 1230702, 1230704,
			1230712
		} },
		{ name = "Trueshot Aura", ids = { 19506, 20905, 20906, 1299346, 1299348 } },
	},

	-- Consumables and trinkets, the PvP ones people forget to watch.
	potion = {
		{ name = "Arcane Protection", ids = { 17549 } },
		{ name = "Fire Protection", ids = { 7233, 17543 } },
		{ name = "Free Action", ids = { 6615 } },
		{ name = "Frost Protection", ids = { 7239, 17544 } },
		{ name = "Gnomish Rocket Boots", ids = { 12905, 13141 } },
		{ name = "Goblin Rocket Boots", ids = { 8892, 8895 } },
		{ name = "Greater Stoneshield", ids = { 17540 } },
		{ name = "Holy Protection", ids = { 7245, 17545 } },
		{ name = "Invisibility", ids = { 885, 11392, 23452, 440505, 1227700 } },
		{ name = "Invulnerability", ids = { 3169 } },
		{ name = "Juju Flurry", ids = { 16322 } },
		{ name = "Lesser Invisibility", ids = { 66, 3680, 7870, 7880, 12845, 20408 } },
		{ name = "Living Free Action", ids = { 24364 } },
		{ name = "Mighty Rage", ids = { 17528 } },
		{ name = "Nature Protection", ids = { 7254, 17546 } },
		{ name = "Restoration", ids = { 11359, 23396, 23493, 24379, 1232203, 1235473, 1286344 } },
		{ name = "Shadow Protection", ids = { 7242, 17548 } },
		{ name = "Stoneshield", ids = { 4941 } },
		{ name = "Swiftness Potion", ids = { 2335 } },
	},

	-- Racial abilities that break your plan.
	racial = {
		{ name = "Berserking", ids = { 20554, 23505, 24378, 1286304 } },
		{ name = "Blood Fury", ids = { 20572, 24571 } },
		{ name = "Escape Artist", ids = { 20589 } },
		{ name = "Perception", ids = { 20600 } },
		{ name = "Shadowmeld", ids = { 20580, 1289453, 1294462, 1307132, 1310023 } },
		{ name = "Stoneform", ids = { 7020, 20594 } },
		{ name = "War Stomp", ids = {
			45, 11876, 15593, 16727, 16740, 19482, 20549, 24375, 25188,
			27758, 28125, 28725, 448707, 470031, 1222567, 1223459
		} },
		{ name = "Will of the Forsaken", ids = { 7744 } },
	},

}

-- Two lookups, built once and rebuilt when the player edits the lists: one by
-- spell id (exact, every rank, language proof) and one by name (the fallback
-- when a client will not hand over the id).
function BD:BuildLookup()
	local byName, byID = {}, {}
	for category, entries in pairs(BD.Spells) do
		for _, entry in ipairs(entries) do
			if type(entry) == "table" then
				byName[entry.name] = category
				for _, id in ipairs(entry.ids or {}) do byID[id] = category end
			else
				byName[entry] = category
			end
		end
	end

	-- the player's own additions win over the defaults
	for name, category in pairs(SquawkNamePlatesDB.custom or {}) do
		if category == false then byName[name] = nil else byName[name] = category end
	end

	BD.Lookup, BD.LookupByID = byName, byID
	return byName
end

function BD:CategoryOf(name)
	if not name then return nil end
	return BD.Lookup and BD.Lookup[name] or nil
end

function BD:CategoryOfID(spellId)
	if not spellId or not BD.LookupByID then return nil end
	local ok, id = pcall(function() return spellId + 0 end)
	if not ok then return nil end
	return BD.LookupByID[id]
end
