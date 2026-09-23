-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\CaptureFsm.lua

local FsmState = {
	Empty = 0,
	S = 3,
	E = 2,
	T = 1
}
local FsmCommand = {
	SwitchItem = 3,
	EnterExit = 2,
	Throw = 1
}
local FsmRule = {
	[FsmState.Empty] = {
		[FsmCommand.Throw] = FsmState.T,
		[FsmCommand.EnterExit] = FsmState.E,
		[FsmCommand.SwitchItem] = FsmState.S
	},
	[FsmState.T] = {
		[FsmCommand.Throw] = FsmState.T
	},
	[FsmState.E] = {
		[FsmCommand.EnterExit] = FsmState.E,
		[FsmCommand.SwitchItem] = FsmState.E,
		[FsmCommand.Throw] = FsmState.E
	},
	[FsmState.S] = {
		[FsmCommand.SwitchItem] = FsmState.S,
		[FsmCommand.EnterExit] = FsmState.E
	}
}
local CaptureFsm = {
	start = FsmState.Empty,
	states = FsmState,
	rules = FsmRule,
	commands = FsmCommand
}

return CaptureFsm
