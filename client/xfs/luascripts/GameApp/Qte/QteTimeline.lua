-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\QteTimeline.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local QteTimelineData = require("Data.qte_timeline_data")
local QteGroupData = require("Data.qte_group_data")
local QteClipData = require("Data.qte_clip_data")
local UIConst = require("Const.UIConst")
local logger = LoggerManager.getLogger("QteTimeline")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local QteTimeline = Class.LightClass("QteTimeline")

function QteTimeline:ctor(actorId, groupId)
	self.actorId = actorId
	self.groupId = groupId
	self.groupData = QteGroupData[self.groupId] or {}
	self.qteType = self.groupData.qteType or AbilityConst.QTE_TYPE.NORMAL
	self.qteTypeMobile = self.groupData.qteType1 or AbilityConst.QTE_TYPE.NORMAL
	self.timelineData = {}
	self.runningClips = {}
	self.resultReturned = false
	self.destroyed = false
end

function QteTimeline:getOwner()
	if not self.actorId then
		return nil
	end

	return pg.getEntityByActorId(self.actorId)
end

function QteTimeline:start(context)
	self:destroy()
	self:initClipItems()

	self.context = context or {}
	self.clipResult = {}
	self.curTime = 0
	self.curIndex = 1
	self.resultReturned = false
	self.destroyed = false

	self:refreshQteUIVisible()
	self:refreshQteRumble()
end

function QteTimeline:getClipDuration(clipData)
	local duration = clipData.failTime + clipData.loadTime + clipData.unloadTime

	if clipData.successTime > 0 then
		duration = duration + clipData.successTime
	end

	return duration
end

function QteTimeline:destroy()
	if self.destroyed then
		return
	end

	for index, clip in ipairs(self.runningClips) do
		clip:destroy()
	end

	self.runningClips = {}
	self.curIndex = #self.timelineData + 1
	self.destroyed = true

	self:refreshQteUIVisible()
	self:refreshQteRumble()
end

function QteTimeline:refreshQteRumble()
	local rumbleName = self.groupData.rumbleName

	if rumbleName then
		if self.destroyed then
			pg.game.input:stopRumble(ClientConst.RumbleLayer.QTE_TIMELINE)
		else
			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.QTE_TIMELINE, rumbleName)
		end
	end
end

function QteTimeline:refreshQteUIVisible()
	if self.qteType == AbilityConst.QTE_TYPE.THINKING then
		if self.destroyed then
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.QTE_CTRL)
		else
			pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.QTE_CTRL, {
				[UIConst.UI_ID_QTE] = true,
				[UIConst.UI_ID_TOPLOGO] = true,
				[UIConst.UI_ID_DAMAGE_NUMBER] = true
			})
		end
	end

	if self.qteTypeMobile == AbilityConst.QTE_MOBILE_TYPE.HIDE_SKILL then
		pg.global.ui.hudV2:onMobileQtePlay(not self.destroyed)
	end
end

function QteTimeline:update(deltaTime)
	if self:isFinish() then
		return
	end

	local isPause = self:updateClips(deltaTime)

	if not isPause then
		self:checkClipStart()

		self.curTime = self.curTime + deltaTime
	end
end

function QteTimeline:isFinish()
	if self.destroyed then
		return true
	end

	if self.curIndex > #self.timelineData and #self.runningClips <= 0 then
		return true
	end

	return false
end

function QteTimeline:canBeCancel()
	return self.groupData.canBeCancel
end

function QteTimeline:initClipItems()
	local timeData = QteTimelineData[self.groupId] or {}

	local function sortFunc(a, b)
		return a.startTime < b.startTime
	end

	self.timelineData = {}

	local preItem

	for clipIndex, timelineData in ipairs(timeData) do
		if timelineData.qtePartId then
			local clipData = QteClipData[timelineData.qtePartId] or {}
			local timelineItem = {}

			timelineItem.clipIndex = clipIndex

			table.merge(timelineItem, clipData)
			table.merge(timelineItem, timelineData)

			timelineItem.startTime = self:genStartTime(preItem, timelineItem)

			table.insert(self.timelineData, timelineItem)

			preItem = timelineItem
		end
	end

	table.sort(self.timelineData, sortFunc)
end

function QteTimeline:genStartTime(preItem, timelineItem)
	if timelineItem.startTime then
		if type(timelineItem.startTime) == "table" then
			return math.random(timelineItem.startTime[1], timelineItem.startTime[2])
		end

		return timelineItem.startTime
	end

	if timelineItem.offsetTime then
		local startTime = 0

		if preItem then
			startTime = preItem.startTime
		end

		if type(timelineItem.offsetTime) == "table" then
			startTime = startTime + math.random(timelineItem.offsetTime[1], timelineItem.offsetTime[2])
		else
			startTime = startTime + timelineItem.offsetTime
		end

		return startTime
	end

	return preItem and preItem.startTime or 0
end

function QteTimeline:checkClipStart()
	while self.curIndex <= #self.timelineData do
		local clipData = self.timelineData[self.curIndex]

		if clipData.startTime > self.curTime then
			break
		end

		self.curIndex = self.curIndex + 1

		local newClip = self:createClip(clipData)

		if newClip then
			newClip.clipIndex = clipData.clipIndex

			local clipTime = self.curTime - clipData.startTime

			newClip:start(clipTime)

			self.runningClips[#self.runningClips + 1] = newClip
		end
	end
end

function QteTimeline:createClip(clipData)
	local clipClass = clipData.clipClass
	local cls = require("GameApp.Qte." .. clipClass)

	if not cls then
		return nil
	end

	local clip = cls.new(self, clipData)

	return clip
end

function QteTimeline:updateClips(deltaTime)
	local isPause = false
	local removeIndex = {}

	for index, clip in ipairs(self.runningClips) do
		isPause = isPause or clip:update(deltaTime)

		if clip:isFinish() then
			clip:destroy()

			removeIndex[#removeIndex + 1] = index
		end
	end

	for index = #removeIndex, 1, -1 do
		table.remove(self.runningClips, removeIndex[index])
	end

	return isPause
end

function QteTimeline:onClipResult(clip, result)
	self.clipResult[clip.clipIndex] = result

	if self:isAllResultReturned() then
		self:pushResult()
	end
end

function QteTimeline:pushResult()
	if self.resultReturned then
		return
	end

	self.resultReturned = true

	local successTime = 0

	for _, result in pairs(self.clipResult) do
		if result == QteDef.QTE_CLIP_RESULT.GOOD or result == QteDef.QTE_CLIP_RESULT.PERFECT then
			successTime = successTime + 1
		end
	end

	if successTime >= (self.groupData.SuccessByPartCount or 0) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("dxk push QteTimeline success result:", self.groupData.successEvent)
		end

		self:triggerEvent(self.groupData.successEvent)
	else
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("dxk push QteTimeline fail result:", self.groupData.failEvent)
		end

		self:triggerEvent(self.groupData.failEvent)
	end
end

function QteTimeline:triggerEvent(eventName, customData)
	if string.isNilOrEmpty(eventName) then
		return
	end

	if self.context.triggerCallback then
		customData = customData or {}
		customData.eventTime = self.curTime

		self.context.triggerCallback(eventName, customData)
	end
end

function QteTimeline:isAllResultReturned()
	if self.curIndex <= #self.timelineData then
		return false
	end

	for _, clip in ipairs(self.runningClips) do
		if not self.clipResult[clip.clipIndex] then
			return false
		end
	end

	return true
end

function QteTimeline:isSkillButtonActionPath(actionPath)
	if string.isNilOrEmpty(actionPath) then
		return false
	end

	for _, clipData in ipairs(self.timelineData) do
		if clipData.keyType == QteDef.QTE_KEY_TYPE.BY_SKILL then
			local qteActionPath

			if self.context and self.context.abilityId then
				qteActionPath = LuaUIUtils.getSkillActionPath(self.context.abilityId)
			end

			qteActionPath = qteActionPath or clipData.actionPath or ""

			if qteActionPath == actionPath then
				return true
			end
		end
	end

	return false
end

function QteTimeline:clickSkillButtonQte(actionPath)
	for _, clip in ipairs(self.runningClips) do
		if clip.clipData.keyType == QteDef.QTE_KEY_TYPE.BY_SKILL and clip:getQteActionPath() == actionPath and clip:clickBySkillButton() then
			return true
		end
	end

	return false
end

return QteTimeline
