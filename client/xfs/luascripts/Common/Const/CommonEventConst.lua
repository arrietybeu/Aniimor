-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\CommonEventConst.lua

local CommonEventConst = {}

CommonEventConst.AutoReTriggerEventTag = {
	dialogueGraphTeleport = "dialogueGraphTeleport",
	teleportScenePosition = "teleportScenePosition",
	appearHelp = "appearHelp",
	startGuide = "startGuide",
	playDialogueGraph = "playDialogueGraph"
}
CommonEventConst.MaxReTriggerCount = 10
CommonEventConst.ReTriggerCountLimit = 500
CommonEventConst.TeleportMaxDeltaRadius = 10
CommonEventConst.ReTriggerEventOp = {
	MAX_COUNT_EVENT_REMOVE = 5,
	SUCCESS_EVENT_REMOVE = 4,
	HEAD_EVENT_ADD_TRIGGER_COUNT = 3,
	HEAD_EVENT_TRIGGER = 2,
	NEW_EVENT_INSERT_TAIL = 1
}

return CommonEventConst
