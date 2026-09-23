-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRConst.lua

local _M = {}

_M.ExecutionTiming = {
	Disposed = 5,
	Finished = 4,
	DoMainTrigger = 2,
	DoStartTrigger = 1,
	Waiting = 0
}
_M.NodeType = {
	SendMsg = 5,
	Graph = 4,
	Trigger = 3,
	EventFuc = 2,
	BehaviorTree = 1
}
_M.NodeBaseType = {
	TickLodTrigger = 8,
	CacheNode = 7,
	BridgeTrigger = 6,
	MessageTrigger = 5,
	EndTrigger = 4,
	EventTrigger = 3,
	TickTrigger = 2,
	StartTrigger = 1,
	NormalNode = 0
}
_M.ParamType = {
	MessageTriggerParams = 3,
	TickTriggerParams = 2,
	TickLodTriggerParams = 1,
	EventTriggerParams = 4
}
_M.ForeachKV = {
	MAP_VALUE = 2,
	MAP_KEY = 1
}
_M.FlowFinishType = {
	Break = 3,
	Interrupt = 2,
	Finish = 1
}
_M.DefaultNullTable = {}
_M.FiltKey = "filtKey"

return _M
