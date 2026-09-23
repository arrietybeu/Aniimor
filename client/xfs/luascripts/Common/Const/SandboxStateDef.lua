-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\SandboxStateDef.lua

local SandboxStateDef = {}

SandboxStateDef.Switch = {
	Off = 1,
	Default = 0,
	On = 2
}
SandboxStateDef.ChestShield = {
	UNLOCKED = 1,
	LOCK = 0,
	OPENED = 2
}
SandboxStateDef.ChestContainer = {
	UNLOCKED = 1,
	LOCK = 0
}
SandboxStateDef.DialoguePlayer = {
	IDLE = 0,
	FINISHED = 2,
	PLAYING = 1
}
SandboxStateDef.TimelineContainer = {
	IDLE = 0,
	FINISHED = 2,
	PLAYING = 1
}
SandboxStateDef.CondenseWaterStone = {
	Wet = 1,
	Dry = 0
}
SandboxStateDef.CondenseWaterBoundItem = {
	Phantom = 0,
	Active = 1
}

return SandboxStateDef
