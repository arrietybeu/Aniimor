-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BaseAreaItem.lua

local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local CUTSCENE_FLAG = TipAreaConst.UITipAreaFlag.AreaFlag_Cutscene
local CUTSCENE_MAX_SUSPEND_TIME = TipAreaConst.CUTSCENE_MAX_SUSPEND_TIME
local BaseAreaItem = Class.LightClass("BaseAreaItem")

function BaseAreaItem:ctor(info)
	self.run_state = TipAreaConst.ITEM_RUN_STATE.EMPTY
	self.fix_state = info.config.fixed and 0 or 1
	self.owner = info.area
	self.rawData = info.config
	self.itemKey = info.itemKey
	self.priority = self.rawData.priority or 0
	self.uWidget = info.uWidget
	self.visible = false
	self.realVisible = false
	self.areaHideFlags = {}

	if not IsNil(self.uWidget) then
		self.uWidget:SetActive(self.visible)
	end

	self.__delayTime = -1
	self.__recycleTasks = {}
	self.__recycleDestroying = false
	self.__timelineSuspendCount = 0
	self.__timelineSuspendAt = 0

	ClientUtils.tryWithLogError(function()
		self:onCtor(info)
		self:onInit()
	end)
end

function BaseAreaItem:onCtor(info)
	return
end

function BaseAreaItem:onInit()
	return
end

function BaseAreaItem:pushData(data)
	return
end

function BaseAreaItem:GMPushData(data)
	return
end

function BaseAreaItem:postPushData(params)
	return
end

function BaseAreaItem:setDelayTime(delay)
	self.__delayTime = delay or 0
end

function BaseAreaItem:hasDelay()
	return self.__delayTime > 0
end

function BaseAreaItem:show()
	return
end

function BaseAreaItem:hideById(id)
	return
end

function BaseAreaItem:hide()
	return
end

function BaseAreaItem:refresh(...)
	return
end

function BaseAreaItem:start()
	self:setVisible(true)
	self:onStart()
end

function BaseAreaItem:onStart()
	return
end

function BaseAreaItem:update()
	self:onUpdate()
end

function BaseAreaItem:finished()
	self:setVisible(false)
	self:onFinished()
end

function BaseAreaItem:onFinished()
	return
end

function BaseAreaItem:onUpdate()
	return
end

function BaseAreaItem:checkRunState()
	self:refreshRunState()

	return self.run_state
end

function BaseAreaItem:isRunning()
	return self.run_state == TipAreaConst.ITEM_RUN_STATE.RUN_QUEUE or self.run_state == TipAreaConst.ITEM_RUN_STATE.RUN_FIXED
end

function BaseAreaItem:isWaitingOrRunning()
	return self.run_state == TipAreaConst.ITEM_RUN_STATE.RUN_QUEUE or self.run_state == TipAreaConst.ITEM_RUN_STATE.WAITING
end

function BaseAreaItem:setMaxLimit(max)
	return
end

function BaseAreaItem:isReachTheLimit()
	return self:isRunning()
end

function BaseAreaItem:setVisible(visible)
	if self.visible == visible then
		self:refreshRealVisible()

		return
	end

	self.visible = visible

	self:refreshRealVisible()
end

function BaseAreaItem:refreshRealVisible()
	local realVisible = self.visible and Utils.tableIsEmptyOrNil(self.areaHideFlags)

	if not IsNil(self.uWidget) then
		self.uWidget:SetActive(realVisible)
	end

	self.realVisible = realVisible

	self:onSetVisible(realVisible)
end

function BaseAreaItem:setAreaHideFlag(flag, isHide)
	flag = tostring(flag)

	if string.isNilOrEmpty(flag) then
		return
	end

	isHide = isHide and true or false

	local preHide = self.areaHideFlags[flag] == true

	if isHide then
		self.areaHideFlags[flag] = true
	else
		self.areaHideFlags[flag] = nil
	end

	if flag == CUTSCENE_FLAG and preHide ~= isHide then
		if isHide then
			self:suspendTimeline()
		else
			self:resumeTimeline()
		end
	end

	self:refreshRealVisible()
end

function BaseAreaItem:suspendTimeline()
	local count = (self.__timelineSuspendCount or 0) + 1

	self.__timelineSuspendCount = count

	if count == 1 then
		self.__timelineSuspendAt = Time.realSecondCache

		self.owner.owner.recycleController:suspendItem(self)
	end
end

function BaseAreaItem:resumeTimeline()
	local count = self.__timelineSuspendCount or 0

	if count <= 0 then
		return
	end

	count = count - 1
	self.__timelineSuspendCount = count

	if count > 0 then
		return
	end

	local suspendedAt = self.__timelineSuspendAt or Time.realSecondCache
	local delta = Time.realSecondCache - suspendedAt

	self.__timelineSuspendAt = 0

	self.owner.owner.recycleController:resumeItem(self)

	if delta > CUTSCENE_MAX_SUSPEND_TIME then
		self:onTimelineSuspendExpired(delta)

		return
	end

	if delta > 0 then
		self:onTimelineResume(delta, suspendedAt)
	end
end

function BaseAreaItem:isTimelineSuspended()
	return (self.__timelineSuspendCount or 0) > 0
end

function BaseAreaItem:onTimelineResume(delta, suspendedAt)
	return
end

function BaseAreaItem:onTimelineSuspendExpired(delta)
	return
end

function BaseAreaItem:clearAreaHideFlags()
	if Utils.tableIsEmptyOrNil(self.areaHideFlags) then
		return
	end

	local hadCutscene = self.areaHideFlags[CUTSCENE_FLAG] == true

	table.clear(self.areaHideFlags)

	if hadCutscene then
		self:resumeTimeline()
	end

	self:refreshRealVisible()
end

function BaseAreaItem:isAreaHidden()
	return not Utils.tableIsEmptyOrNil(self.areaHideFlags)
end

function BaseAreaItem:onSetVisible(visible)
	return
end

function BaseAreaItem:refreshRunState()
	local oldRunState = self.run_state

	if self:isAreaHidden() then
		self.run_state = self.visible and TipAreaConst.ITEM_RUN_STATE.WAITING or TipAreaConst.ITEM_RUN_STATE.EMPTY
	elseif self.realVisible then
		self.run_state = TipAreaConst.ITEM_RUN_STATE.RUN_FIXED
	else
		self.run_state = TipAreaConst.ITEM_RUN_STATE.WAITING
	end

	if self.run_state ~= oldRunState then
		self:onRunStateChanged(oldRunState, self.run_state)
	end
end

function BaseAreaItem:onRunStateChanged(oldState, newState)
	return
end

function BaseAreaItem:hideArea(flags)
	return
end

function BaseAreaItem:showArea(flags)
	return
end

function BaseAreaItem:clearDataQueue()
	self:onClearDataQueue()
end

function BaseAreaItem:onClearDataQueue()
	return
end

function BaseAreaItem:onUIVisibleToHide()
	self:clearRunningList()
end

function BaseAreaItem:clearRunningList(force)
	self:onClearRunningList(force)
	self:finished()
end

function BaseAreaItem:onClearRunningList(force)
	return
end

function BaseAreaItem:clearAllData(force)
	self:onClearDataQueue()
	self:onClearRunningList(force)
end

function BaseAreaItem:startTimer(func, delay, loop)
	if self.owner and self.owner.owner then
		return self.owner.owner:startTimer(func, delay, loop)
	else
		return -1
	end
end

function BaseAreaItem:killTimer(timerId)
	if self.owner and self.owner.owner then
		self.owner.owner:killTimer(timerId)
	end
end

function BaseAreaItem:setAreaVisibleWithFlag(areaType, flag, visible)
	if self.owner and self.owner.owner then
		self.owner.owner:setAreaVisibleWithFlag(areaType, flag, visible)
	end
end

function BaseAreaItem:onDestroy()
	return
end

function BaseAreaItem:destroy()
	self.__recycleDestroying = true

	self.owner.owner.recycleController:finishItem(self)
	self:onDestroy()
end

function BaseAreaItem:onInputDeviceChanged(deviceType)
	return
end

function BaseAreaItem:onSceneUnload()
	return
end

function BaseAreaItem:requestRecycle(data, force, exitEvent)
	return self.owner.owner.recycleController:request(self, data, force, self:getRecycleTarget(data), exitEvent)
end

function BaseAreaItem:completeRecycle(data, force)
	return self.owner.owner.recycleController:request(self, data, force, self:getRecycleTarget(data), nil, true)
end

function BaseAreaItem:onRecycleStarted(data, target)
	return
end

function BaseAreaItem:playRecycleAnimation(data, target, exitEvent, complete)
	if NotNil(target) and exitEvent and target:CheckHasEvent(exitEvent) then
		target:InvokeCallbackWithCallback(exitEvent, complete)
	else
		complete()
	end
end

function BaseAreaItem:onRecycleFinished(data, reason)
	return
end

return BaseAreaItem
