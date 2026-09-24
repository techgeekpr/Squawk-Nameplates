if type(SquawkNamePlatesDB) == "table" then
	SquawkNamePlates_Restore = SquawkNamePlates_Restore or {}
	SquawkNamePlates_Restore[#SquawkNamePlates_Restore + 1] = SquawkNamePlatesDB
	SquawkNamePlatesDB = nil
end
