-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\GamePad\\GamePadConst.lua

local GamePadConst = {}

GamePadConst.LEFT_STICK_MOVE_THRESHOLD = 0.6
GamePadConst.LONG_PRESS_THRESHOLD = 0.55
GamePadConst.FUNCTION_INDEX = {
	Y = 2,
	X = 1,
	RIGHT_STICK = 18,
	LEFT_STICK = 17,
	START = 16,
	SELECT = 15,
	RIGHT = 14,
	LEFT = 13,
	DOWN = 12,
	UP = 11,
	RSD = 10,
	LSD = 9,
	RT = 8,
	LT = 7,
	RS = 6,
	LS = 5,
	A = 4,
	B = 3
}
GamePadConst.INPUT_STATE = {
	PERFORMED = "Performed",
	CANCELED = "Canceled"
}
GamePadConst.INDEX_TO_PATH = {
	[GamePadConst.FUNCTION_INDEX.X] = "Raw/GamepadButtonWest",
	[GamePadConst.FUNCTION_INDEX.Y] = "Raw/GamepadButtonNorth",
	[GamePadConst.FUNCTION_INDEX.B] = "Raw/GamepadButtonEast",
	[GamePadConst.FUNCTION_INDEX.A] = "Raw/GamepadButtonSouth",
	[GamePadConst.FUNCTION_INDEX.LS] = "Raw/GamepadRightStickPress",
	[GamePadConst.FUNCTION_INDEX.RS] = "Raw/GamepadLeftStickPress",
	[GamePadConst.FUNCTION_INDEX.LT] = "Raw/GamepadLeftTrigger",
	[GamePadConst.FUNCTION_INDEX.RT] = "Raw/GamepadRightTrigger",
	[GamePadConst.FUNCTION_INDEX.LSD] = "Raw/GamepadLeftShoulder",
	[GamePadConst.FUNCTION_INDEX.RSD] = "Raw/GamepadRightShoulder",
	[GamePadConst.FUNCTION_INDEX.UP] = "Raw/GamepadDPadUp",
	[GamePadConst.FUNCTION_INDEX.DOWN] = "Raw/GamepadDPadDown",
	[GamePadConst.FUNCTION_INDEX.LEFT] = "Raw/GamepadDPadLeft",
	[GamePadConst.FUNCTION_INDEX.RIGHT] = "Raw/GamepadDPadRight",
	[GamePadConst.FUNCTION_INDEX.SELECT] = "Raw/GamepadSelect",
	[GamePadConst.FUNCTION_INDEX.START] = "Raw/GamepadStart",
	[GamePadConst.FUNCTION_INDEX.LEFT_STICK] = "Raw/GamepadLeftStickMove",
	[GamePadConst.FUNCTION_INDEX.RIGHT_STICK] = "Raw/GamepadRightStickMove"
}
GamePadConst.MOVE_DIRECTION = {
	NONE = 0,
	RIGHT = -4,
	LEFT = -3,
	DOWN = -2,
	UP = -1
}
GamePadConst.DIRECTION_MOVE_VALUE = {
	[GamePadConst.MOVE_DIRECTION.UP] = -1,
	[GamePadConst.MOVE_DIRECTION.DOWN] = 1,
	[GamePadConst.MOVE_DIRECTION.LEFT] = -1,
	[GamePadConst.MOVE_DIRECTION.RIGHT] = 1
}
GamePadConst.MATCH_MODE = {
	MATCH_DISTANCE = 4,
	MATCH_OLD_CACHE = 3,
	MATCH_FIRST = 2,
	MATCH_DIRECTION = 1
}
GamePadConst.LEFT_STICK_MOVE_DELAY_SLOW = 0.25
GamePadConst.LEFT_STICK_MOVE_DELAY_FAST = 0.15
GamePadConst.EMPTY_AREA_TABLE = {}

return GamePadConst
