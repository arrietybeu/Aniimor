-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\PlayerForbidConst.lua

local PlayerForbidConst = {}

PlayerForbidConst.PLAYER_SWITCH = {
	CHANGE_PLAYER_NAME = 1,
	PLAYER_MEDIA_MARK = 4,
	PLAYER_CHAT = 3,
	CHANGE_PLAYER_SIGNATURE = 2
}
PlayerForbidConst.FORBID_END_TS = {
	UNFORBID = 0,
	PERMANENT = -1
}

function PlayerForbidConst.isValidPlayerSwitch(forbidType)
	return type(forbidType) == "number" and forbidType >= 1 and forbidType <= table.getCount(PlayerForbidConst.PLAYER_SWITCH)
end

return PlayerForbidConst
