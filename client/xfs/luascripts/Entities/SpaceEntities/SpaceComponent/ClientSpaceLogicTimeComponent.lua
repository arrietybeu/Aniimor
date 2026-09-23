-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceLogicTimeComponent.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local SceneData = require("Data.scene_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientSpaceLogicTimeComponent = Class.Component("ClientSpaceLogicTimeComponent")

function ClientSpaceLogicTimeComponent:ctor()
	return
end

function ClientSpaceLogicTimeComponent:start()
	local forceDayNight = SceneData[self.sceneId].forceDayNight
	local forceTime = SceneData[self.sceneId].forceTime
	local spaceType = Utils.getSpaceType(self.sceneId)

	if (forceDayNight or forceTime) and (Utils.isSpacePhase(self.sceneId) or spaceType == Const.SPACE_TYPE_DITTO_DUNGEON) then
		if forceDayNight then
			pg.game.weather:setTodTime(Const.TOD_TIME_KEY.DITTO, true, 0, 0, forceDayNight)
		end

		if forceTime then
			pg.game.weather:setTodTime(Const.TOD_TIME_KEY.DITTO, true, forceTime, 0, 0)
		end
	else
		self.lastLogicTickTime = Time.secondCache
	end
end

function ClientSpaceLogicTimeComponent:synSpaceLogicTime()
	local mainSceneId = Utils.getPhaseMainSceneId(self.sceneId) or self.sceneId

	pg.me:serverMsg("RPC_CS_GetSpaceLogicTime", mainSceneId)
end

function ClientSpaceLogicTimeComponent:getLogicHourAndMin()
	return math.floor(self.logicTime / 60), self.logicTime % 60
end

function ClientSpaceLogicTimeComponent:flushLogicTimeMainScene()
	local mainSceneId = Utils.getPhaseMainSceneId(self.sceneId)

	if mainSceneId == nil then
		return
	end

	local logicTime = pg.me.spaceLogicTime[mainSceneId]

	self.logicTime = logicTime or self.logicTime

	local logicPeriod = self:getLogicPeriod(self.logicTime)

	pg.timePeriod = logicPeriod or pg.timePeriod
end

function ClientSpaceLogicTimeComponent:getLogicPeriod(logicTime)
	if logicTime == nil then
		return Const.TimePeriod.Day
	end

	local timePeriodInfo = SysConfigData.DAYTIME_NIGHTTIME_ZONES

	if Utils.tableIsEmptyOrNil(timePeriodInfo) then
		return Const.TimePeriod.Day
	end

	local minutesInDay = Const.DAY_LOGIC_END - Const.DAY_LOGIC_START

	for index, info in ipairs(timePeriodInfo) do
		local beginHour, endHour, beginTotalMin, endTotalMin, addDay, periodChangeTime = self:getLogicPeriodChangeInfo(info)

		if endHour < beginHour and (beginTotalMin <= logicTime or logicTime < endTotalMin % minutesInDay) or beginHour <= endHour and beginTotalMin <= logicTime and logicTime < endTotalMin then
			return info[5]
		end
	end

	return Const.TimePeriod.Day
end

function ClientSpaceLogicTimeComponent:getLogicPeriodChangeInfo(info)
	local minutesInDay = Const.DAY_LOGIC_END - Const.DAY_LOGIC_START
	local beginHour, beginMin, endHour, endMin, beginTotalMin, endTotalMin

	beginHour = info[1] or 0
	beginMin = info[2] or 0
	endHour = info[3] or 0
	endMin = info[4] or 0
	beginTotalMin = beginHour * 60 + beginMin
	endTotalMin = endHour * 60 + endMin

	if endHour < beginHour then
		endTotalMin = endTotalMin + minutesInDay
	end

	local addDay = 0
	local periodChangeTime = endHour * 60 + endMin

	if endHour < beginHour then
		addDay = 1
	elseif endTotalMin == minutesInDay then
		addDay = 1
		periodChangeTime = 0
	end

	return beginHour, endHour, beginTotalMin, endTotalMin, addDay, periodChangeTime
end

function ClientSpaceLogicTimeComponent:getLogicTime()
	return self.logicTime
end

function ClientSpaceLogicTimeComponent:getTimePeriod()
	return pg.timePeriod
end

function ClientSpaceLogicTimeComponent:destroy()
	if self.logicMinTimerId then
		self:removeTimer(self.logicMinTimerId)

		self.logicMinTimerId = nil
	end

	local forceDayNight = SceneData[self.sceneId].forceDayNight
	local forceTime = SceneData[self.sceneId].forceTime
	local spaceType = Utils.getSpaceType(self.sceneId)

	if (forceDayNight or forceTime) and (Utils.isSpacePhase(self.sceneId) or spaceType == Const.SPACE_TYPE_DITTO_DUNGEON) then
		if forceDayNight then
			pg.game.weather:setTodTime(Const.TOD_TIME_KEY.DITTO, false, 0, 0, forceDayNight)
		end

		if forceTime then
			pg.game.weather:setTodTime(Const.TOD_TIME_KEY.DITTO, false, forceTime, 0, 0)
		end
	end
end

function ClientSpaceLogicTimeComponent:RPC_SC_OnTimePeriodChange(logicTime, timePeriod, curPeriodIndex, banLogicTimeTick, showAnim)
	self.banLogicTimeTick = banLogicTimeTick
	self.logicTime = logicTime
	self.curPeriodIndex = curPeriodIndex

	if timePeriod == pg.timePeriod then
		return
	end

	if showAnim and self:tryPlaySwitchAnim(timePeriod) then
		return
	end

	self:applyTimePeriod(timePeriod)
end

function ClientSpaceLogicTimeComponent:applyTimePeriod(timePeriod)
	pg.timePeriod = timePeriod

	pg.game:onTimePeriodChange(pg.timePeriod)
	facade:SendMessageCommand(MessageName.LOGIC_TIME_UPDATE, self.logicTime)
	self:onRenderTimePeriodChange()
end

function ClientSpaceLogicTimeComponent:tryPlaySwitchAnim(timePeriod)
	if timePeriod ~= Const.TimePeriod.Day and timePeriod ~= Const.TimePeriod.Night and timePeriod ~= Const.TimePeriod.Morning and timePeriod ~= Const.TimePeriod.Dusk then
		return false
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TIME_SWITCH) then
		return false
	end

	self.switchAnimTimePeriod = timePeriod

	pg.global.ui:open(UIConst.UI_ID_TIME_SWITCH, {
		animOnly = true,
		endTimePeriod = timePeriod,
		onBlack = CallbackHandler(self, "applyPendingSwitchAnim")
	}, nil, CallbackHandler(self, "applyPendingSwitchAnim"))

	return true
end

function ClientSpaceLogicTimeComponent:applyPendingSwitchAnim()
	local timePeriod = self.switchAnimTimePeriod

	self.switchAnimTimePeriod = nil

	if timePeriod then
		self:applyTimePeriod(timePeriod)
	end
end

function ClientSpaceLogicTimeComponent:RPC_SC_TideChange()
	pg.game.weather:refreshTideState()
end

function ClientSpaceLogicTimeComponent:timePeriodSwitch(setTimePeriod)
	local isSpacePhase = self.sceneId and SceneData[self.sceneId].mainScene == 3000
	local forceDayNight = SceneData[self.sceneId].forceDayNight

	if pg.me:isSpaceOwner() or isSpacePhase and not forceDayNight then
		pg.me:serverMsg("RPC_CS_TimePeriodSwitch", pg.timePeriod, setTimePeriod)
	else
		ClientUtils.showBubbleMessage(NoticeDef.CANNOT_CHANGE_LOGIC_TIME)
	end
end

function ClientSpaceLogicTimeComponent:setLogicTime(hour, min)
	if pg.me:isSpaceOwner() then
		pg.me:serverMsg("RPC_CS_SetSpaceLogicTime", hour, min)
	else
		ClientUtils.showBubbleMessage(NoticeDef.CANNOT_CHANGE_LOGIC_TIME)
	end
end

function ClientSpaceLogicTimeComponent:onRenderTimePeriodChange()
	local hour, min = self:getLogicHourAndMin()

	pg.game.weather:setTodTime(Const.TOD_TIME_KEY.SERVER_TIME, true, hour, min, pg.timePeriod)
end

function ClientSpaceLogicTimeComponent:setTimePeriodClient(timePeriod)
	if timePeriod ~= Const.TimePeriod.Day and timePeriod ~= Const.TimePeriod.Night and timePeriod ~= Const.TimePeriod.Morning and timePeriod ~= Const.TimePeriod.Dusk then
		return
	end

	self:applyTimePeriod(timePeriod)
end

return ClientSpaceLogicTimeComponent
