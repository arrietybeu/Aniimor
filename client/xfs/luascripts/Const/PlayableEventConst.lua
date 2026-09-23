-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\PlayableEventConst.lua

local enum_dummy = {
	is_enum_dummy = true
}
local PlayableEventConst = {
	showBall = enum_dummy,
	fireBall = enum_dummy,
	holdBall = enum_dummy,
	magnesisBegin = enum_dummy,
	magnesisLoop = enum_dummy,
	magnesisThrow = enum_dummy,
	magnesisCancel = enum_dummy,
	unliftItem = enum_dummy,
	addCollideMinRadius = enum_dummy,
	carryEgg = enum_dummy,
	putDownEgg = enum_dummy
}

for attr, v in pairs(PlayableEventConst) do
	if type(v) ~= "table" or v.is_enum_dummy ~= true then
		error("%s: type(v) ~= enum_dummy: " .. attr)
	end

	PlayableEventConst[attr] = attr
end

return PlayableEventConst
