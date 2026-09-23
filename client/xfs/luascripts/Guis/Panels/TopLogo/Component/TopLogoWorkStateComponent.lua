-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoWorkStateComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoWorkStateComponent")
local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local SysConfigData = require("Data.sys_config_data")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomeEventTextData = require("Data.home_event_text_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local HomeLeisureBehaviorData = require("Data.home_leisure_behavior_data")
local HomelandConfigData = require("Data.homeland_config_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoWorkStateComponent = Class.LightClass("TopLogoWorkStateComponent", TopLogoItemComponent)

function TopLogoWorkStateComponent:isHomeDemoMode()
	if pg.space and pg.space.demoMode then
		return true
	end

	local ok, GmToolUtils = pcall(require, "Utils.GmToolUtils")

	return ok and GmToolUtils and GmToolUtils.homeDemoModeOn == true
end

function TopLogoWorkStateComponent:m_getHomeDemoPetName()
	if not self.entity or not self.entity.getAttachEntityName then
		return nil
	end

	local name = self.entity:getAttachEntityName()

	if string.isNilOrEmpty(name) then
		return nil
	end

	return pg.getLocalizationText(name)
end

function TopLogoWorkStateComponent:ctor(refUContainer, topLogoItem)
	TopLogoWorkStateComponent.super.ctor(self, refUContainer, topLogoItem)

	self.ignoreCompVisibleCheck = true
	self.transportListInfo = {}
end

function TopLogoWorkStateComponent:onCtor()
	self.m_pendingWorkStateRefresh = false

	self:refreshVisible()
end

function TopLogoWorkStateComponent:shouldBeActive()
	if not Utils.isHomePet(self.entity) then
		return false
	end

	if self:isHomeDemoMode() then
		return true
	end

	if pg.space.checkHomePetHasFood and not pg.space:checkHomePetHasFood() then
		return true
	end

	return self.isInWorkState == true or self.isInActionState == true or self.isInPettingState == true
end

function TopLogoWorkStateComponent:resetRender()
	self.transportVisible = nil
	self.objectReference = nil
	self.workText = nil
	self.iconUImage = nil
	self.transportList = nil

	TopLogoWorkStateComponent.super.resetRender(self)

	if not Utils.isHomePet(self.entity) then
		return
	end

	self:markDirty(EventConst.HOMELAND_WORK_STATE_CHANGED)
	self:markDirty(EventConst.HOMELAND_ACTION_STATE_CHANGED)
	self:markDirty(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED)
	self:markDirty(EventConst.HOMELAND_LEISURE_STATE_CHANGED)
end

function TopLogoWorkStateComponent:onDestroy()
	if not Utils.isHomePet(self.entity) then
		return
	end

	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.HOMELAND_WORK_STATE_CHANGED, self.onEntityWorkStateChanged)
		self.entity.eventEmitter:removeEventListener(EventConst.HOMELAND_ACTION_STATE_CHANGED, self.onEntityActionStateChanged)
		self.entity.eventEmitter:removeEventListener(EventConst.HOMELAND_LEISURE_STATE_CHANGED, self.onEntityLeisureStateChanged)
	end

	self.m_pendingWorkStateRefresh = false

	TopLogoWorkStateComponent.super.onDestroy(self)

	self.m_loadedWorkStateCallBack = nil
end

function TopLogoWorkStateComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.workText = self.objectReference:GetRefValue("workText")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.transportList = self.objectReference:GetRefValue("transportList")

	function self.transportList.luaRenderItem(button, idx, data)
		self:refreshTransportItem(button, idx, data)
	end
end

function TopLogoWorkStateComponent:addEntityListener()
	if not Utils.isHomePet(self.entity) then
		return
	end

	function self.onEntityWorkStateChanged()
		self.isInWorkState = self:checkInWorkState()

		self:markDirty(EventConst.HOMELAND_WORK_STATE_CHANGED)
		self:m_notifyPending()
	end

	if self.entity then
		self.isInWorkState = self:checkInWorkState()

		self:markDirty(EventConst.HOMELAND_WORK_STATE_CHANGED)
		self.entity.eventEmitter:addEventListener(EventConst.HOMELAND_WORK_STATE_CHANGED, self.onEntityWorkStateChanged)
	end

	function self.onEntityActionStateChanged()
		self.isInActionState = self:checkInActionState()

		self:markDirty(EventConst.HOMELAND_ACTION_STATE_CHANGED)
		self:m_notifyPending()
	end

	if self.entity then
		self.isInActionState = self:checkInActionState()

		self:markDirty(EventConst.HOMELAND_ACTION_STATE_CHANGED)
		self.entity.eventEmitter:addEventListener(EventConst.HOMELAND_ACTION_STATE_CHANGED, self.onEntityActionStateChanged)
	end

	function self.onEntityTransportChanged()
		self:markDirty(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED)
		self:m_notifyPending()
	end

	if self.entity then
		self:markDirty(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED)
		self.entity.eventEmitter:addEventListener(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED, self.onEntityTransportChanged)
	end

	function self.onEntityLeisureStateChanged()
		self.isInPettingState = self:checkInPettingState()

		self:markDirty(EventConst.HOMELAND_LEISURE_STATE_CHANGED)
		self:m_notifyPending()
	end

	if self.entity then
		self.isInPettingState = self:checkInPettingState()

		self:markDirty(EventConst.HOMELAND_LEISURE_STATE_CHANGED)
		self.entity.eventEmitter:addEventListener(EventConst.HOMELAND_LEISURE_STATE_CHANGED, self.onEntityLeisureStateChanged)
	end
end

function TopLogoWorkStateComponent:innerGetVisible()
	if not TopLogoWorkStateComponent.super.innerGetVisible(self) then
		return false
	end

	if not Utils.isHomePet(self.entity) then
		return false
	end

	if self:isHomeDemoMode() then
		return true
	end

	if pg.space.checkHomePetHasFood and not pg.space:checkHomePetHasFood() then
		return true
	end

	if not self.isInWorkState and not self.isInActionState and not self.isInPettingState then
		return false
	end

	return true
end

function TopLogoWorkStateComponent:checkInWorkState()
	if self.entity then
		local allocationInfo = self.entity.allocationInfo

		if allocationInfo then
			local opId = allocationInfo.opId

			if opId and opId ~= 0 then
				local operationInfo = HomelandOperateData[opId]

				return operationInfo ~= nil
			end
		end
	end

	return false
end

function TopLogoWorkStateComponent:checkInActionState()
	if self:isHomeDemoMode() then
		return false
	end

	if self.entity and self.entity.petInfo then
		return not Utils.checkHomePetStateValid(self.entity.petInfo, pg.space)
	end

	return false
end

function TopLogoWorkStateComponent:checkInPettingState()
	if self:isHomeDemoMode() or not self.entity or not self.entity.space then
		return false
	end

	local leisureState = self.entity.space.leisureState
	local leisureInfo = leisureState and leisureState[self.entity.id]
	local leisureConfig = leisureInfo and HomeLeisureBehaviorData[leisureInfo.leisureId]

	if not leisureConfig or leisureConfig.leisureType ~= Const.HOME_LEISURE_TYPE.PETTING or HomelandConfigData.pettingName == nil then
		return false
	end

	if string.isNilOrEmpty(HomelandConfigData.pettingIcon) then
		return false
	end

	return true
end

function TopLogoWorkStateComponent:refreshWorkInfo()
	self.transportVisible = false

	if self.isInActionState and not self:isHomeDemoMode() then
		local eventTypeData = self.entity.petInfo:getHomeEventTypeData(pg.space)

		if not eventTypeData then
			return false
		end

		LuaUIUtils.setUIVisible(self.iconUImage, true)

		self.iconUImage.url = eventTypeData.statusIcon

		ClientTextUtils.setText(self.workText, pg.getLocalizationText(eventTypeData.statusName))

		return true
	end

	if self.isInWorkState and self.entity.allocationInfo.opId then
		local workInfo = HomelandOperateData[self.entity.allocationInfo.opId]
		local workingName = pg.getLocalizationText(workInfo.workingName)

		if self:isHomeDemoMode() then
			local petName = self:m_getHomeDemoPetName()

			if petName then
				workingName = petName .. " " .. workingName
			end
		end

		ClientTextUtils.setText(self.workText, workingName)
		LuaUIUtils.setUIVisible(self.iconUImage, true)

		self.iconUImage.url = workInfo.workingIcon

		if self.entity.allocationInfo.opId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT_TO_STORE then
			self.transportVisible = true
		end

		return true
	end

	if not self:isHomeDemoMode() and not pg.space:checkHomePetHasFood() then
		local eventTypeData = HomeEventTypeData[Const.HOMELAND_FOOD_LACK_EVENT_ID]

		LuaUIUtils.setUIVisible(self.iconUImage, true)

		self.iconUImage.url = eventTypeData.statusIcon

		ClientTextUtils.setText(self.workText, pg.getLocalizationText(eventTypeData.statusName))

		return true
	end

	if self.isInPettingState and not self:isHomeDemoMode() then
		local leisureState = self.entity.space and self.entity.space.leisureState
		local leisureInfo = leisureState and leisureState[self.entity.id]
		local leisureConfig = leisureInfo and HomeLeisureBehaviorData[leisureInfo.leisureId]

		if leisureConfig and leisureConfig.leisureType == Const.HOME_LEISURE_TYPE.PETTING and HomelandConfigData.pettingName ~= nil and not string.isNilOrEmpty(HomelandConfigData.pettingIcon) then
			LuaUIUtils.setUIVisible(self.iconUImage, true)

			self.iconUImage.url = HomelandConfigData.pettingIcon

			ClientTextUtils.setText(self.workText, pg.getLocalizationText(HomelandConfigData.pettingName))

			return true
		end
	end

	if self:isHomeDemoMode() then
		local petName = self:m_getHomeDemoPetName()

		if petName then
			LuaUIUtils.setUIVisible(self.iconUImage, false)

			self.iconUImage.url = ""

			ClientTextUtils.setText(self.workText, petName)

			return true
		end
	end

	return false
end

function TopLogoWorkStateComponent:refreshBaseInfo()
	local isWorkInfoRefreshed = self:refreshWorkInfo()

	if not isWorkInfoRefreshed then
		self.iconUImage.url = ""

		ClientTextUtils.setText(self.workText, "")
	end

	LuaUIUtils.setUIVisible(self.transportList, self.transportVisible)
end

function TopLogoWorkStateComponent:refreshTransportInfo()
	if not self.entity then
		return
	end

	local transportData = pg.space.transportData[self.entity.id]

	table.clear(self.transportListInfo)

	if transportData then
		local itemList = transportData.itemInfo

		for itemId, itemNum in pairs(itemList) do
			table.insert(self.transportListInfo, {
				itemId = itemId,
				itemNum = itemNum
			})
		end
	end

	self.transportList:SetList(self.transportListInfo)
end

function TopLogoWorkStateComponent:m_notifyPending()
	local isActive = self:shouldBeActive()

	self.m_pendingWorkStateRefresh = isActive == true

	self:refreshVisible()
	self:notifyActiveStateChanged(isActive)
	self:notifyMaxDistanceChanged()

	if self.topLogoItem and self.topLogoItem:isTopLogoPrefabReady() then
		self.m_pendingWorkStateRefresh = false
	end
end

function TopLogoWorkStateComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoWorkStateComponent.super.onLanguageChanged(self)
	self:refreshTopLogoInfo()
end

function TopLogoWorkStateComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingWorkStateRefresh then
		self.m_pendingWorkStateRefresh = false
	end

	if self:checkFinalVisible() then
		if self:checkContainerLoaded() then
			self:m_refreshTplWorkStateInfo()
		else
			if not self.m_loadedWorkStateCallBack then
				function self.m_loadedWorkStateCallBack(isSuccess)
					if isSuccess then
						self:m_refreshTplWorkStateInfo()
					end
				end
			end

			self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedWorkStateCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end
	end
end

function TopLogoWorkStateComponent:m_refreshTplWorkStateInfo()
	local workResult = self:checkAndResetDirty(EventConst.HOMELAND_WORK_STATE_CHANGED)
	local actionResult = self:checkAndResetDirty(EventConst.HOMELAND_ACTION_STATE_CHANGED)
	local transportChanged = self:checkAndResetDirty(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED)
	local leisureResult = self:checkAndResetDirty(EventConst.HOMELAND_LEISURE_STATE_CHANGED)

	if workResult or actionResult or leisureResult then
		self:refreshBaseInfo()
	end

	if transportChanged then
		self:refreshTransportInfo()
	end
end

function TopLogoWorkStateComponent:refreshTransportItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = LuaUIUtils.getIconByItemId(data.itemId)
end

function TopLogoWorkStateComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoWorkStateComponent
