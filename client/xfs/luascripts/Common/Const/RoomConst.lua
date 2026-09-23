-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\RoomConst.lua

local RoomConst = {
	RoomTypePVP1V1_Fair = 1,
	ROOM_ALL_PLAYER_READY = 2,
	ROOM_OTHER_PLAYER_READY = 1,
	RoomTypePVP1V1_UnFair = 2
}

RoomConst.RoomPVP1V1 = {
	ST_SELECT_PET = 1,
	ST_CREATE_SUCCESS = 0,
	ST_ABNORMAL_EXIT = 4,
	ST_ENTER_DUNGEON = 3,
	ST_PLAYER_READY = 2
}
RoomConst.RoomPVP1V1_ST = {
	ST_ALLOCATE = 3,
	ST_AUTOFILL = 2,
	ST_READY = 1,
	ST_INIT = 0,
	ST_ENTER = 4
}

return RoomConst
