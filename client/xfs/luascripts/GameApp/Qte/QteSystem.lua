-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\QteSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local Time = require("Core.Common.Time")
local QteTimeline = require("GameApp.Qte.QteTimeline")
local QteClipData = require("Data.qte_clip_data")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local QteSystem = Class.LightClass("QteSystem", SystemBase)

function QteSystem:onCtor()
	self.timelineList = {}
	self.qteComponents = {}
	self.preloadItems = {}
	self.lastTickTime = Time.realSecondCache
	self._temp_remove = {}
end

function QteSystem:onInit()
	return
end

function QteSystem:onSpaceDestroy(space)
	self:stopAllQte()
end

function QteSystem:refreshUIState()
	local blockInteract = #self.timelineList > 0 or #self.qteComponents > 0

	pg.global.ui.interact:setInteractVisible(ClientConst.InteractVisibleKey.Qte, not blockInteract)

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.MD and pg.global.ui.hudV2.MD.hpFuse then
		pg.global.ui.hudV2.MD.hpFuse:refreshStatusVisible()
	end
end

function QteSystem:preloadQteItems()
	for _, item in pairs(QteClipData) do
		self.preloadItems[item.prefabResID] = {}
	end

	for resId, _ in pairs(self.preloadItems) do
		pg.global.resMgr:PreLoadInstance(resId, 1)
	end
end

function QteSystem:isPlayingSkillQte(abilityId)
	for index, timelineItem in ipairs(self.timelineList) do
		if timelineItem.context and timelineItem.context.abilityId == abilityId then
			return true
		end
	end

	for index, qteComponent in ipairs(self.qteComponents) do
		if qteComponent.context and qteComponent.context.abilityId == abilityId then
			return true
		end
	end

	return false
end

function QteSystem:isPlayingDigEggQte()
	for index, timelineItem in ipairs(self.timelineList) do
		if timelineItem.context and timelineItem.context.src == Const.QTE_SRC.DigEgg then
			return true
		end
	end

	for index, qteComponent in ipairs(self.qteComponents) do
		if qteComponent.context and qteComponent.context.src == Const.QTE_SRC.DigEgg then
			return true
		end
	end

	return false
end

function QteSystem:isQtePlaying()
	for index, timelineItem in ipairs(self.timelineList) do
		if not timelineItem:isFinish() then
			return true
		end
	end

	for index, qteComponent in ipairs(self.qteComponents) do
		if not qteComponent:isFinish() then
			return true
		end
	end

	return false
end

function QteSystem:containsQteTimeline(groupId)
	for _, timelineItem in ipairs(self.timelineList) do
		if timelineItem.groupId == groupId then
			return true
		end
	end

	return false
end

function QteSystem:onTick()
	local now = Time.realSecondCache
	local deltaTime = now - self.lastTickTime

	table.clear(self._temp_remove)

	local refreshState = false

	for index, timelineItem in ipairs(self.timelineList) do
		timelineItem:update(deltaTime)

		if timelineItem:isFinish() then
			table.insert(self._temp_remove, index)
			timelineItem:destroy()

			refreshState = true
		end
	end

	for _, rmIndex in ipairs(self._temp_remove) do
		table.remove(self.timelineList, rmIndex)
	end

	table.clear(self._temp_remove)

	for index, qteComponent in ipairs(self.qteComponents) do
		qteComponent:update(deltaTime)

		if qteComponent:isFinish() then
			table.insert(self._temp_remove, index)
			qteComponent:destroy()

			refreshState = true
		end
	end

	for _, rmIndex in ipairs(self._temp_remove) do
		table.remove(self.qteComponents, rmIndex)
	end

	self.lastTickTime = now

	if refreshState then
		self:refreshUIState()
	end
end

function QteSystem:startQte(actorId, groupId, context)
	if self:containsQteTimeline(groupId) then
		self:stopQteByGroupId(groupId)
	end

	local timeline = QteTimeline.new(actorId, groupId)

	timeline:start(context)
	table.insert(self.timelineList, timeline)
	self:refreshUIState()
end

function QteSystem:startQteComponent(actorId, componentId, componentData, context)
	local sameIdComponent = self:getQteComponentById(componentId)

	if sameIdComponent then
		self:stopQteComponent(sameIdComponent)
	end

	local componentCls = componentData.clipClass
	local cls = require("GameApp.Qte." .. componentCls)

	if not cls then
		return
	end

	local qteComponent = cls.new(actorId, componentData)

	qteComponent:start(componentId, context)
	table.insert(self.qteComponents, qteComponent)
	self:refreshUIState()
end

function QteSystem:getQteComponentById(componentId)
	for _, qteComponent in ipairs(self.qteComponents) do
		if qteComponent.id == componentId then
			return qteComponent
		end
	end

	return nil
end

function QteSystem:stopQte(actorId, groupId)
	for index, timelineItem in ipairs(self.timelineList) do
		if timelineItem.actorId == actorId and timelineItem.groupId == groupId then
			table.remove(self.timelineList, index)
			timelineItem:pushResult()
			timelineItem:destroy()
			self:refreshUIState()

			return
		end
	end
end

function QteSystem:stopQteComponent(actorId, componentId)
	for index, component in ipairs(self.qteComponents) do
		if component.actorId == actorId and component.id == componentId then
			table.remove(self.qteComponents, index)
			component:pushResult()
			component:destroy()
			self:refreshUIState()

			return
		end
	end
end

function QteSystem:stopQteByGroupId(groupId)
	for index, timelineItem in ipairs(self.timelineList) do
		if timelineItem.groupId == groupId then
			table.remove(self.timelineList, index)
			timelineItem:pushResult()
			timelineItem:destroy()
			self:refreshUIState()

			return
		end
	end
end

function QteSystem:stopQteBySrc(actorId, src)
	for index, timelineItem in ipairs(self.timelineList) do
		if timelineItem.actorId == actorId and timelineItem.context and timelineItem.context.src == src then
			table.remove(self.timelineList, index)
			timelineItem:pushResult()
			timelineItem:destroy()
			self:refreshUIState()

			return
		end
	end
end

function QteSystem:stopAllQte()
	for index = #self.timelineList, 1, -1 do
		local timelineItem = self.timelineList[index]

		table.remove(self.timelineList, index)
		timelineItem:pushResult()
		timelineItem:destroy()
	end

	for index = #self.qteComponents, 1, -1 do
		local qteComponent = self.qteComponents[index]

		table.remove(self.qteComponents, index)
		qteComponent:pushResult()
		qteComponent:destroy()
	end

	self:refreshUIState()
end

function QteSystem:tryCancelQte()
	local refreshState = false

	for index = #self.timelineList, 1, -1 do
		local timelineItem = self.timelineList[index]

		if timelineItem:canBeCancel() then
			table.remove(self.timelineList, index)
			timelineItem:pushResult()
			timelineItem:destroy()

			refreshState = true
		end
	end

	for index = #self.qteComponents, 1, -1 do
		local qteComponent = self.qteComponents[index]

		if qteComponent:canBeCancel() then
			table.remove(self.qteComponents, index)
			qteComponent:pushResult()
			qteComponent:destroy()

			refreshState = true
		end
	end

	if refreshState then
		self:refreshUIState()
	end
end

function QteSystem:startChargeQte(actorId, componentId, context)
	local componentData = QteClipData[componentId] or {}

	self:startQteComponent(actorId, componentId, componentData, context)
end

function QteSystem:stopChargeQte(actorId, componentId)
	self:stopQteComponent(actorId, componentId)
end

function QteSystem:pushChargeQteResult(actorId, componentId, result)
	local chargeQteComponent = self:getQteComponentById(componentId)

	if chargeQteComponent and chargeQteComponent.actorId == actorId then
		chargeQteComponent:pushResult(result)
	end
end

function QteSystem:isInChargeQte()
	for index, component in ipairs(self.qteComponents) do
		if component.isChargeQte then
			return true
		end
	end

	return false
end

function QteSystem:testChargeQte()
	self:startChargeQte(pg.me.actorId, "QTE_Hammer", {
		perfectDuration = 1,
		perfectStartTime = 5,
		goodDuration = 4,
		goodStartTime = 4,
		duration = 8
	})
end

function QteSystem:testChargeQteResult()
	self:pushChargeQteResult(pg.me.actorId, "QTE_Hammer", 2)
end

function QteSystem:handleMobileSkillButtonClick(actionPath)
	if not self:isQtePlaying() or string.isNilOrEmpty(actionPath) then
		return false
	end

	local matched = false

	for _, timelineItem in ipairs(self.timelineList) do
		if not timelineItem:isFinish() and timelineItem:isSkillButtonActionPath(actionPath) then
			matched = true

			if timelineItem:clickSkillButtonQte(actionPath) then
				return true
			end
		end
	end

	return matched
end

return QteSystem
