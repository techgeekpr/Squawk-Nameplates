-- The addon used to be called BigPvP.  Park anything saved under the old name
-- so its settings can be carried over once.
if type(BigPvPDB) == "table" then
	SquawkNamePlates_Legacy = SquawkNamePlates_Legacy or {}
	SquawkNamePlates_Legacy[#SquawkNamePlates_Legacy + 1] = BigPvPDB
	BigPvPDB = nil
end
