-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\ActivityConst.lua

local ActivityConst = {
	PET_BAND_POS_VOTE_NUM = 4,
	STAGE_REWARDS_IDX_REWARD = 2,
	STAGE_REWARDS_IDX_SCORE = 1,
	LUCKY_PET_TOTAL_RAND_COUNT = 4,
	LUCKY_PET_SPECIAL_COUNT = 2,
	SCORE_REWARDS_IDX_REWARD = 2,
	SCORE_REWARDS_IDX_SCORE = 1
}

ActivityConst.AppNamePrefix = {
	DailyActive = "dailyActive"
}
ActivityConst.EventType = {
	StarPlanGuidePage = 113,
	MysteriousMerchant = 112,
	SeasonPage = 110,
	TeaParty = 109,
	PetHatch = 108,
	Interlink = 106,
	WaterArea = 105,
	LeylineTreeGuide = 103,
	MockBattle = 101,
	CrossPlatform = 28,
	LongTermSign = 27,
	FishingCapture = 26,
	SeasonAchievements = 25,
	SeasonIntroduction = 24,
	SeasonActivity = 23,
	FirstTopup = 22,
	BindAccount = 21,
	LittleFirePerson = 20,
	GrowthGift = 19,
	LeylineTreeUp = 18,
	RechargeRebate = 17,
	BattlePass = 16,
	PetDispatch = 15,
	SignVersion = 14,
	SignNewbie = 13,
	JourneyTrial = 11,
	AreaActivity = 10,
	ArkCarn = 9,
	EcologyTrace = 8,
	EnergyMatch = 7,
	CatchRogue = 6,
	PetSave = 5,
	OfficialGroup = 4,
	WeekWish = 3,
	PuppetPhoto = 2,
	PuppetCatch = 1,
	MinType = 1,
	DailyActive = 12,
	MaxType = 200,
	LittleFirePersonGuide = 117,
	RedBook = 115,
	SteamBindEmail = 114
}
ActivityConst.NewFrameEventType = {
	NewActFrameBeg = 11,
	NewActFrameEnd = 200
}
ActivityConst.NewFrameEventTypeSet = {
	[8] = true
}
ActivityConst.NewFrameEventAttriName = {
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"activityEcoTrace",
	nil,
	nil,
	"activityJourneyTrail",
	"activityDailyActive",
	"activitySignNewbie",
	"activitySignVersion",
	"activityPetDispatch",
	"activityBattlePass",
	"activityRechargeRebate",
	"activityLeylineTreeUp",
	"activityGrowthGift",
	"activityLittleFirePerson",
	"activityBindAccount",
	"activityFirstCharge",
	nil,
	nil,
	"activitySeasonAchieve",
	"activityFishingCapture",
	"activityLongTermSign",
	"activityCrossPlatform",
	[108] = "activityPetHatch",
	[115] = "activityRedNote"
}
ActivityConst.TimeControlRuleType = {
	DailyCycle = 2,
	FixedSpan = 1,
	WeeklyCycle = 3
}
ActivityConst.TimeControlRule = {
	FixedSpan_OpenDays = 12,
	FixedSpan_Date = 11,
	WeeklyCycle_OpenDays = 32,
	WeeklyCycle_Date = 31,
	DailyCycle_OpenDays = 22,
	DailyCycle_Date = 21
}
ActivityConst.TimeFormat = {
	Date = 1,
	OpenDays = 2
}
ActivityConst.PuppetPhotoClueType = {
	Explore = 5,
	Career = 4,
	Stage = 3,
	Form = 2,
	Attr = 1
}
ActivityConst.PuppetPhotoClueTypeNum = 5
ActivityConst.PetSaveSubEventType = {
	WeekSumy = 1,
	PetSave = 2
}
ActivityConst.PetSaveWeekSumyPetType = {
	HomelandPutInTime = 3,
	ControlKillNum = 2,
	BattleTime = 1
}
ActivityConst.ArkCarnStageId = {
	Show = 3,
	Pre = 2,
	Vote = 1
}
ActivityConst.PET_BAND_POS_TYPE = {
	MainDancer = 5,
	Atmos = 4,
	Accompany = 3,
	Dancer = 2,
	Drummer = 1
}
ActivityConst.ActivityTaskType = {
	EcoTrace_Tongxing = 83,
	EcoTrace_Lilian = 82,
	EcoTrace_Capture = 81,
	Active_AchievementTask = 1003,
	Active_WeeklyTask = 1002,
	Active_DailyTask = 1001,
	LittleFire_GlobalReward = 202,
	LittleFire_PersonReward = 201,
	BattlePass_AwardPay = 165,
	BattlePass_AwardFree = 164,
	BattlePass_Newbie = 163,
	BattlePass_Season = 162,
	BattlePass_Weekly = 161,
	PetDispatch_StageScore = 152,
	PetDispatch_Dispatch = 151,
	DailyActive_ScoreReward = 122,
	DailyActive_GetScore = 121
}
ActivityConst.ActivityTaskSubType = {
	AchiTask_SeasonAchieve_Mileage = 305,
	AchiTask_SeasonAchieve_Home = 304,
	AchiTask_SeasonAchieve_Rogg = 303,
	AchiTask_SeasonAchieve_Battle = 302,
	AchiTask_SeasonAchieve_Emo = 301,
	LittleFire_Daily_NpcInt = 203
}
ActivityConst.TaskState = {
	Received_SendMail = 4,
	Received = 3,
	Finihed_CanRecv = 2,
	UnFinished = 1
}
ActivityConst.OperationTaskFlowState = {
	Failed = 3,
	Submitted = 2,
	Accepted = 1,
	ProgressChanged = 5,
	Finished = 4
}
ActivityConst.PetDispatchTaskSubState = {
	UnFinished_Disptaching = 11
}
ActivityConst.TaskSortPri = {
	[ActivityConst.TaskState.Received] = 0,
	[ActivityConst.TaskState.Received_SendMail] = 1,
	[ActivityConst.TaskState.UnFinished] = 9,
	[ActivityConst.TaskState.Finihed_CanRecv] = 10
}
ActivityConst.energyMatchThemeMax = 100
ActivityConst.TaskLogType = {
	Oneclick_Received = 3,
	Received = 2,
	Finished = 1
}
ActivityConst.SignDayType = {
	FourteenDay = 2,
	SevenDay = 1,
	LongSign = 3
}
ActivityConst.CommonGuideType = {
	WaterAreaPreview = 2,
	GamePlayShow = 1,
	CenterPet = 3
}
ActivityConst.PetDispatchPetMaxNum = 4
ActivityConst.PetDispatchPetMinNum = 2
ActivityConst.BattlePassGear = {
	Pay2 = 2,
	Pay1 = 1,
	Free = 0
}
ActivityConst.BattlePassBackItemIdGear1 = 1601000
ActivityConst.BattlePassBackItemIdGear2 = 1601001
ActivityConst.LittleFireEnergyReportResult = {
	INVALID_PARAM = "INVALID_PARAM",
	ACTIVITY_CLOSED = "ACTIVITY_CLOSED",
	ACTIVITY_NOT_FOUND = "ACTIVITY_NOT_FOUND",
	DATA_NOT_READY = "DATA_NOT_READY",
	DUPLICATED = "DUPLICATED",
	SUCCESS = "SUCCESS",
	INTERNAL_ERROR = "INTERNAL_ERROR",
	SERVICE_BUSY = "SERVICE_BUSY",
	UID_MISMATCH = "UID_MISMATCH"
}
ActivityConst.FishingCaptureRecordType = {
	Phase = 1003,
	Weekly = 1002,
	Daily = 1001
}
ActivityConst.FishingCaptureRecordChannel = {
	SideQuest = 3,
	WorldGather = 2,
	MainQuest = 1,
	EcoTrace = 8,
	RegionSilverBadge = 7,
	LeylineTreeAmberTribute = 6,
	EliteChallenge = 5,
	BossFirstKill = 4
}

return ActivityConst
