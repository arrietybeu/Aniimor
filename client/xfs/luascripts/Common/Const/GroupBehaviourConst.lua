-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\GroupBehaviourConst.lua

local GroupBehaviourConst = {}

GroupBehaviourConst.BehaviourType = {
	CallFriends = 3,
	EcologyPerform = 2,
	Custom = 1,
	SheepGather = 5
}
GroupBehaviourConst.BehaviourClassPath = {
	[GroupBehaviourConst.BehaviourType.Custom] = "Custom.GB_Custom",
	[GroupBehaviourConst.BehaviourType.EcologyPerform] = "EcologyPerform.GB_EcologyPerform",
	[GroupBehaviourConst.BehaviourType.CallFriends] = "CallFriends.GB_CallFriends",
	[GroupBehaviourConst.BehaviourType.SheepGather] = "SheepGather.GB_SheepGather"
}
GroupBehaviourConst.TacheDefine = {
	QueueFollow = 200,
	CustomAnimation = 101,
	MoveToResPoint = 100,
	MakeGroup = 0,
	CoolDown = -1,
	SheepGather = 401,
	SheepAbility = 402,
	SearchSheep = 400,
	HelpSkill = 202,
	Formation = 201
}
GroupBehaviourConst.RunningState = {
	NormalFinish = 3,
	Running = 2,
	None = 0,
	MakeGroup = 1,
	AbnormalFinish = 4
}
GroupBehaviourConst.MakeGroupMaxSqrDistance = 2500
GroupBehaviourConst.TacheDefaultTimeout = 30
GroupBehaviourConst.DefaultWaitTime = 1000
GroupBehaviourConst.OpenLog = false
GroupBehaviourConst.SheepGatherMemberCount = 4
GroupBehaviourConst.SheepGatherBehaviourID = "BP_Wild_GroupBehav_SheepGather"
GroupBehaviourConst.SheepGatherBCEventGather = "Event_GB_SheepGather"
GroupBehaviourConst.SheepGatherBCEventAbility = "Event_GB_SheepAbility"
GroupBehaviourConst.SheepGatherEntValKeys = {
	"Thundercloud01",
	"Thundercloud02",
	"Thundercloud03"
}

return GroupBehaviourConst
