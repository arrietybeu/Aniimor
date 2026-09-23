-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoHomeFacilityComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local SysConfigData = require("Data.sys_config_data")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomelandOperateData = require("Data.homeland_operate_data")
local Const = require("Common.Const.Const")
local InteractData = require("Data.interact_data")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local HomelandFormulaData = require("Data.homeland_formula_data")
local Utils = require("Common.Utils.Utils")
local AddressDataConst = require("Const.AddressDataConst")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local NoticeDef = require("Common.NoticeDef")
local TopLogoWorkHomeFacilityComponent = Class.LightClass("TopLogoWorkHomeFacilityComponent", TopLogoItemComponent)
local DistanceState = {
	Near = 0,
	Far = 2,
	Mid = 1
}
local WorkState = {
	Normal = 0,
	High = 3,
	Low = 2,
	Stop = 1
}

function TopLogoWorkHomeFacilityComponent:ctor(refUContainer, topLogoItem)
	TopLogoWorkHomeFacilityComponent.super.ctor(self, refUContainer, topLogoItem)
	pg.game.topLogo.homeFacilityLimiter:register(self.entity.actorId, self)

	self.ignoreCompVisibleCheck = true
end

function TopLogoWorkHomeFacilityComponent:onDestroy()
	pg.game.topLogo.homeFacilityLimiter:unregister(self.entity.actorId)
	TopLogoWorkHomeFacilityComponent.super.onDestroy(self)

	self.m_loadedHomeFacilityCallBack = nil
end

function TopLogoWorkHomeFacilityComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.widget = self.objectReference:GetComponent("UWidget")
	self.debuffText = self.objectReference:GetRefValue("debuffText")
	self.warnRoot = self.objectReference:GetRefValue("warnRoot")
	self.warnIcon = self.objectReference:GetRefValue("warnIcon")
	self.warnText = self.objectReference:GetRefValue("warnText")
	self.buffList = self.objectReference:GetRefValue("buffList")
	self.numText = self.objectReference:GetRefValue("numText")
	self.numBox = self.objectReference:GetRefValue("numBox")
	self.progress = self.objectReference:GetRefValue("progress")
	self.icon = self.objectReference:GetRefValue("icon")
	self.requireWidget = self.objectReference:GetRefValue("requireWidget")
	self.requireText = self.objectReference:GetRefValue("requireText")
	self.requireAbilityUButton = self.objectReference:GetRefValue("requireAbilityUButton")
	self.operationStateRoot = self.objectReference:GetRefValue("lackWaterUWidget")
	self.lackIcon = self.objectReference:GetRefValue("lackIcon")
	self.progressSpeedUp = self.objectReference:GetRefValue("progressSpeedUp")
	self.topLogoProgressBg = self.objectReference:GetRefValue("topLogoProgressBg")
	self.topLogoProgressFill = self.objectReference:GetRefValue("topLogoProgressFill")
	self.envContainerUContainer = self.objectReference:GetRefValue("envContainerUContainer")
	self.farUContainer = self.objectReference:GetRefValue("farUContainer")
	self.tipsUContainer = self.objectReference:GetRefValue("tipsUContainer")
	self.progressHighImg = self.objectReference:GetRefValue("progressHighImg")
	self.buffData = {}
	self.tempBuffData = {}

	function self.buffList.luaRenderItem(button, index, data)
		button:TryChangePage("BuffType", data.buffType)

		local icon = button.transform:Find("Icon"):GetComponent("UImage")

		icon.url = data.iconUrl
	end

	self.workloadRate = 0
	self.nearDistance = HomelandConfigData.facilityTopLogoNearDistance or 3
	self.midDistance = HomelandConfigData.facilityTopLogoMidDistance or 8
	self.farDistance = HomelandConfigData.facilityTopLogoFarDistance or 10
	self.warnTextStr = ""
	self.tipText = ""
end

function TopLogoWorkHomeFacilityComponent:shouldBeActive()
	return true
end

function TopLogoWorkHomeFacilityComponent:resetRender()
	self.objectReference = nil
	self.widget = nil
	self.debuffText = nil
	self.warnRoot = nil
	self.warnIcon = nil
	self.warnText = nil
	self.buffList = nil
	self.numText = nil
	self.numBox = nil
	self.progress = nil
	self.icon = nil
	self.requireWidget = nil
	self.requireText = nil
	self.requireAbilityUButton = nil
	self.operationStateRoot = nil
	self.lackIcon = nil
	self.progressSpeedUp = nil
	self.topLogoProgressBg = nil
	self.topLogoProgressFill = nil
	self.progressSpeedUpVisible = nil
	self.curProgressOpId = nil
	self.curLackOpId = nil
	self.envContainerUContainer = nil
	self.farUContainer = nil
	self.tipsUContainer = nil
	self.progressHighImg = nil
	self.tipsInfoComponent = nil
	self.tipsRequireTitleText = nil
	self.tipsRequireList = nil
	self.timeText = nil
	self.demandUComponent = nil
	self.farHomeItem = nil
	self.envWidget = nil
	self.envWarnText = nil
	self.curEnvContainerUrl = nil
	self.distanceState = nil

	TopLogoWorkHomeFacilityComponent.super.resetRender(self)
end

function TopLogoWorkHomeFacilityComponent:addEntityListener()
	return
end

function TopLogoWorkHomeFacilityComponent:innerGetVisible()
	if not TopLogoWorkHomeFacilityComponent.super.innerGetVisible(self) then
		return false
	end

	if not pg.me or not pg.me.space then
		return false
	end

	return true
end

function TopLogoWorkHomeFacilityComponent:checkHasEntDoingOper(operId)
	local space = pg.space or pg.me and pg.me.space
	local ornamentId = self.entity and self.entity.ornamentId
	local playerAllocation = space and space.playerAllocation

	if not ornamentId or not playerAllocation then
		return false
	end

	for playerId, playerOperInfo in pairs(playerAllocation) do
		if playerOperInfo.ornamentId == ornamentId and playerOperInfo.opId == operId then
			return true
		end
	end

	local relatedPets = space.facilityAllocationInfo and space.facilityAllocationInfo[ornamentId]

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = space.allocation and space.allocation[petId]

			if allocation and allocation.opId == operId then
				return true
			end
		end
	end

	return false
end

function TopLogoWorkHomeFacilityComponent:tryRefreshTimerOper()
	local facilityInfo = self.entity.facilityInfo
	local timerStateMap = facilityInfo.timerStateMap or {}

	for operId, _ in pairs(timerStateMap) do
		if self:checkHasEntDoingOper(operId) then
			self.widget:TryChangePage("MainState", 1)

			local facilityState = facilityInfo.facilityState
			local baseOperInfo = HomelandOperateData[facilityState]

			if baseOperInfo then
				self.icon.url = self:getOperateIcon(baseOperInfo, facilityInfo)
			end

			return true
		end
	end

	return false
end

function TopLogoWorkHomeFacilityComponent:getOutputNum(facilityInfo)
	local outputNum = 0

	for itemId, num in pairs(facilityInfo.outputMap) do
		outputNum = outputNum + num
	end

	outputNum = outputNum + HomeLandUtils.sumSpecialOutput(facilityInfo)

	return outputNum
end

function TopLogoWorkHomeFacilityComponent:refreshBuffs(buffData)
	self.buffList:SetActive(true)

	local changed = false

	if #buffData ~= #self.buffData then
		changed = true
	else
		for index, data in ipairs(buffData) do
			local originData = self.buffData[index]

			if not originData then
				changed = true

				break
			end

			if originData.buffType ~= data.buffType or originData.iconUrl ~= data.iconUrl then
				changed = true

				break
			end
		end
	end

	if changed then
		table.clear(self.buffData)

		local buffInfo = {}

		for index, data in ipairs(buffData) do
			self.buffData[index] = data

			table.insert(buffInfo, data)
		end

		self.buffList:SetList(buffInfo)
	end
end

function TopLogoWorkHomeFacilityComponent:refreshElectricState()
	if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		self:setEnvContainerUrl(AddressDataConst.HOME_TOP_LOGO_ENV_ELECTRIC)

		local linkInfo = self.entity:getHomeLinkInfo()

		if linkInfo then
			if linkInfo.groupId ~= 0 then
				local linkGroupInfo = pg.me.space.homeLinkGroupMap[linkInfo.groupId]

				if linkGroupInfo.totalProduce > 0 then
					self.envWidget:TryChangePage("State", 2)
				else
					self.envWidget:TryChangePage("State", 3)

					if self.envWarnText then
						ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_NO_ELECTRIC"))
					end
				end
			else
				self.envWidget:TryChangePage("State", 3)

				if self.envWarnText then
					ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_NO_ELECTRIC_LINK"))
				end
			end
		end
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		self:setEnvContainerUrl(AddressDataConst.HOME_TOP_LOGO_ENV_ELECTRIC)

		local envFacilityInfo = self.entity:getEnvFacilityInfo()

		if envFacilityInfo then
			if envFacilityInfo.envProduce > 0 then
				self.workloadInvalid = false

				self.envWidget:TryChangePage("State", 2)
			else
				self.workloadInvalid = true

				self.envWidget:TryChangePage("State", 0)

				local facilityInfo = self.entity.facilityInfo

				if self.envWarnText and facilityInfo then
					if facilityInfo.disable then
						ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_PAUSING"))
					else
						ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))
					end
				end
			end
		end
	end
end

function TopLogoWorkHomeFacilityComponent:refreshHTempState()
	self:setEnvContainerUrl(AddressDataConst.HOME_TOP_LOGO_ENV_HEAT)

	local envFacilityInfo = self.entity:getEnvFacilityInfo()

	if envFacilityInfo then
		if envFacilityInfo.envProduce == 0 then
			self.workloadInvalid = true

			self.envWidget:TryChangePage("State", 0)

			local facilityInfo = self.entity.facilityInfo

			if self.envWarnText and facilityInfo then
				if facilityInfo.disable then
					ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_PAUSING"))
				else
					ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))
				end
			end
		else
			self.workloadInvalid = false

			if envFacilityInfo.envProduce == 1 then
				self.envWidget:TryChangePage("State", 2)
			else
				self.envWidget:TryChangePage("State", 4)
			end
		end
	end
end

function TopLogoWorkHomeFacilityComponent:refreshLTempState()
	self:setEnvContainerUrl(AddressDataConst.HOME_TOP_LOGO_ENV_COOL)

	local envFacilityInfo = self.entity:getEnvFacilityInfo()

	if envFacilityInfo then
		if envFacilityInfo.envProduce == 0 then
			self.workloadInvalid = true

			self.envWidget:TryChangePage("State", 0)

			local facilityInfo = self.entity.facilityInfo

			if self.envWarnText and facilityInfo then
				if facilityInfo.disable then
					ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_PAUSING"))
				else
					ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))
				end
			end
		else
			self.workloadInvalid = false

			if envFacilityInfo.envProduce == -1 then
				self.envWidget:TryChangePage("State", 2)
			else
				self.envWidget:TryChangePage("State", 4)
			end
		end
	end
end

function TopLogoWorkHomeFacilityComponent:refreshLightState()
	self:setEnvContainerUrl(AddressDataConst.HOME_TOP_LOGO_ENV_LIGHT)

	local envFacilityInfo = self.entity:getEnvFacilityInfo()

	if envFacilityInfo then
		if envFacilityInfo.envProduce == 0 then
			self.workloadInvalid = true

			self.envWidget:TryChangePage("State", 0)

			local facilityInfo = self.entity.facilityInfo

			if self.envWarnText and facilityInfo then
				if facilityInfo.disable then
					ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_PAUSING"))
				else
					ClientTextUtils.setText(self.envWarnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))
				end
			end
		else
			self.workloadInvalid = false

			self.envWidget:TryChangePage("State", 2)
		end
	end
end

function TopLogoWorkHomeFacilityComponent:setEnvContainerUrl(url)
	if self.curEnvContainerUrl ~= url then
		self.curEnvContainerUrl = url
		self.envContainerUContainer.url = url
		self.envWidget = self.envContainerUContainer.content:GetComponent("UComponent")

		local objectReference = self.envWidget:GetComponent("ObjectReference")

		if objectReference then
			self.envWarnText = objectReference:GetRefValue("envWarnText")
		else
			self.envWarnText = nil
		end
	end
end

function TopLogoWorkHomeFacilityComponent:tryShowOutputNum(facilityInfo)
	if not facilityInfo then
		self.numBox:SetActive(false)

		return
	end

	local outputNum = self:getOutputNum(facilityInfo)

	if outputNum > 0 then
		self.numBox:SetActive(true)

		if facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] then
			self.widget:TryChangePage("NumState", 1)
		else
			self.widget:TryChangePage("NumState", 0)
		end

		ClientTextUtils.setText(self.numText, outputNum)
	else
		self.numBox:SetActive(false)
		self.widget:TryChangePage("NumState", 0)
	end
end

function TopLogoWorkHomeFacilityComponent:checkIsEnvFacility()
	if not self.entity then
		return false
	end

	return Utils.isHomeEnvFacility(self.entity.homeTemplateId)
end

function TopLogoWorkHomeFacilityComponent:refreshEnvFacilityInfo()
	if not self.entity then
		return
	end

	if not self.entity.homeFacilityType then
		return
	end

	local facilityInfo = self.entity.facilityInfo

	self.widget:TryChangePage("MainState", 3)

	if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		self:refreshElectricState()
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		self:refreshElectricState()
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
		self:refreshHTempState()
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
		self:refreshLTempState()
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Light then
		self:refreshLightState()
	end

	self.numBox:SetActive(false)
end

function TopLogoWorkHomeFacilityComponent:refreshEnvRequireInfo()
	self.electricWorkRatio = nil
	self.lightWorkRatio = nil
	self.lightRequireType = nil
	self.tempWorkRatio = nil
	self.tempRequireType = nil

	if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq or self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		self.electricWorkRatio = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Electric)
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
		self.lightWorkRatio, self.lightRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Light)
		self.tempWorkRatio, self.tempRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Temperature)
	end
end

function TopLogoWorkHomeFacilityComponent:refreshEnvRequireText()
	if not self.entity then
		return
	end

	if not self.entity.homeFacilityType then
		return
	end

	if self.entity.facilityInfo.disable then
		return
	end

	if Utils.checkNeedEnvRequire(self.entity.facilityInfo) then
		local ornamentInfo = pg.space.ornament[self.entity.ornamentId] or {}
		local isElectricType = Utils.checkIsElectricReqType(self.entity.homeFacilityType, ornamentInfo.electricMode)

		if isElectricType then
			local ornamentEnvInfo = self.entity:getOrnamentEnvInfo()
			local linkValid = false

			if ornamentEnvInfo then
				local refEnvFacilityInfo = ornamentEnvInfo.refEnvFacilityInfo or {}

				for refEnvOrnamentId, _ in pairs(refEnvFacilityInfo) do
					local linkInfo = pg.space.homeLinkMap[refEnvOrnamentId]

					if linkInfo and linkInfo.groupId ~= 0 then
						linkValid = true
					end
				end
			end

			if linkValid then
				if self.entity.facilityInfo.envWorkRatio <= 0 then
					self.warnTextStr = pg.getGameString("HOMELAND_NO_ELECTRIC")
					self.tipText = pg.getGameString("HOMELAND_NO_ELECTRIC")
				end
			else
				self.warnTextStr = pg.getGameString("HOMELAND_NO_ELECTRIC_LINK")
				self.tipText = pg.getGameString("HOMELAND_NO_ELECTRIC_LINK")
			end
		elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
			local ornamentEnvInfo = self.entity:getOrnamentEnvInfo()

			if HomelandFormulaData[self.entity.facilityInfo.formulaId].forceEnvRequire then
				self.envNotSatisfied = self.tempRequireType and ornamentEnvInfo.temperature ~= self.tempRequireType or self.lightRequireType and ornamentEnvInfo.light ~= self.lightRequireType
			else
				local tempNotSatisfied = self.tempRequireType and math.abs(ornamentEnvInfo.temperature - self.tempRequireType) > 2
				local lightNotSatisfied = self.lightRequireType and math.abs(ornamentEnvInfo.light - self.lightRequireType) > 2

				self.envNotSatisfied = tempNotSatisfied or lightNotSatisfied
			end

			if self.envNotSatisfied then
				self.warnTextStr = pg.getGameString("ENV_NOT_VALID")
				self.tipText = pg.getGameString("ENV_NOT_VALID")
			end
		end
	else
		self.envNotSatisfied = false
	end

	return false
end

function TopLogoWorkHomeFacilityComponent:refreshFacilityInfo()
	if not self.entity then
		return false
	end

	local facilityInfo = self.entity.facilityInfo

	if not facilityInfo or facilityInfo.facilityState == 0 then
		if Utils.isClientHomeTrash(self.entity) then
			LuaUIUtils.setUIVisible(self.refUContainer.content, false)
		else
			self.widget:TryChangePage("MainState", 0)
			self.widget:TryChangePage("ShowDetail", 0)
			self.widget:TryChangePage("Distance", 1)

			self.statePaused = true
		end

		if facilityInfo then
			self:tryShowOutputNum(facilityInfo)
		end

		return
	end

	local facilityState = facilityInfo.facilityState
	local facilityStateInfo = facilityInfo.facilityStateInfo
	local operateInfo = HomelandOperateData[facilityState]

	if not operateInfo then
		self.widget:TryChangePage("MainState", 0)
		self.widget:TryChangePage("Distance", 1)
		self.widget:TryChangePage("ShowDetail", 0)

		return
	end

	self.warnIcon:SetActive(false)

	local statePaused = false
	local showOutputIcon = false
	local hasEntDoOper = self:checkHasEntDoingOper(facilityState)

	self.workloadInvalid = false

	self:refreshEnvRequireInfo()

	self.itemNotEnough = false

	if facilityInfo.disable then
		self.warnTextStr = pg.getGameString("HOMELAND_PAUSING")
		self.tipText = pg.getGameString("HOMELAND_PAUSING")
		statePaused = true
	elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.UNDER_CONSUME] then
		self.warnTextStr = pg.getGameString("HOMELAND_ITEM_NOT_ENOUGH")
		self.tipText = pg.getGameString("HOMELAND_ITEM_NOT_ENOUGH")
		self.itemNotEnough = true
		statePaused = true
	elseif facilityInfo.envWorkRatio <= 0 then
		statePaused = true
	elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] then
		self.warnTextStr = pg.getGameString("HOMELAND_ITEM_NEED_TRANSPORT")
		self.tipText = pg.getGameString("HOMELAND_ITEM_NEED_TRANSPORT")
		self.itemNotEnough = true
		statePaused = true
		showOutputIcon = true
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		if not hasEntDoOper then
			self.workloadInvalid = true

			if facilityStateInfo.curValue > 0 then
				self.warnTextStr = pg.getGameString("HOMELAND_NO_WORKLOAD")
				self.tipText = pg.getGameString("HOMELAND_NO_WORKLOAD")
				statePaused = true
			end
		else
			self.warnTextStr = ""
		end
	end

	self:tryShowOutputNum(facilityInfo)

	self.statePaused = statePaused

	self:refreshEnvRequireText()
	self:refreshFacilityProgress(facilityInfo)

	if not self:tryRefreshTimerOper() then
		if showOutputIcon then
			self.widget:TryChangePage("MainState", 2)

			self.icon.url = self:getOutputIcon(facilityInfo)
		else
			self.icon.url = self:getOperateIcon(operateInfo, facilityInfo)

			if operateInfo.topLogoIconType == ClientConst.HomelandTopLogoIconType.OutputSpecial then
				self.widget:TryChangePage("MainState", 2)
			else
				self.widget:TryChangePage("MainState", 1)
			end
		end
	end

	if Utils.isClientHomeTrash(self.entity) then
		if statePaused or not hasEntDoOper then
			LuaUIUtils.setUIVisible(self.refUContainer.content, false)
		else
			LuaUIUtils.setUIVisible(self.refUContainer.content, true)
		end
	end

	ClientTextUtils.setText(self.warnText, self.warnTextStr)
	self:refreshWaterLoosenToplogo(facilityInfo)

	if self.compDistance then
		self:refreshInfoStateByDistance(self.compDistance, facilityInfo)
	end
end

function TopLogoWorkHomeFacilityComponent:refreshMutationPickupProgress()
	if not self.entity or not self.entity.getMutationPickupProgress then
		return false
	end

	local progressValue, progressMaxValue, mutationItemId, pickupText = self.entity:getMutationPickupProgress()

	if progressValue == nil then
		return false
	end

	local facilityInfo = self.entity.facilityInfo

	self.leftTime = nil
	self.statePaused = false
	self.workloadRate = 1
	self.warnTextStr = pickupText
	self.tipText = pickupText

	self.warnIcon:SetActive(false)
	self.numBox:SetActive(false)
	self.progress:SetActive(true)
	self.progress:TryChangePage("State", 0)

	self.progress.maxValue = progressMaxValue
	self.progress.value = progressValue

	self.widget:TryChangePage("MainState", 1)

	self.icon.url = mutationItemId and LuaUIUtils.getIconByItemId(mutationItemId) or self:getOutputIcon(facilityInfo)

	self:setProgressSpeedUpVisible(false)

	if self.operationStateRoot then
		self.operationStateRoot:SetActive(false)
	end

	ClientTextUtils.setText(self.warnText, pickupText)

	if self.compDistance and facilityInfo then
		self:refreshInfoStateByDistance(self.compDistance, facilityInfo)
	end

	return true
end

function TopLogoWorkHomeFacilityComponent:setProgressSpeedUpVisible(visible)
	if self.progressSpeedUp and self.progressSpeedUpVisible ~= visible then
		self.progressSpeedUpVisible = visible

		self.progressSpeedUp:SetActive(visible)
	end

	if self.lackIcon then
		self.lackIcon:SetActive(not visible)
	end
end

function TopLogoWorkHomeFacilityComponent:setProgressStyle(opId, value)
	local operData = HomelandOperateData[opId]

	if operData and self.curProgressOpId ~= opId then
		self.curProgressOpId = opId

		if self.topLogoProgressBg and operData.topLogoProgressBg then
			self.topLogoProgressBg.url = operData.topLogoProgressBg
		end

		if self.topLogoProgressFill and operData.topLogoProgressFill then
			self.topLogoProgressFill.url = operData.topLogoProgressFill
		end
	end

	if self.progressSpeedUp then
		self.progressSpeedUp.maxValue = 1
		self.progressSpeedUp.value = math.clamp(value or 0, 0, 1)
	end
end

function TopLogoWorkHomeFacilityComponent:setLackStyle(opId)
	if self.curLackOpId == opId then
		return
	end

	self.curLackOpId = opId

	local operData = HomelandOperateData[opId]

	if self.lackIcon and operData and operData.topLogoIcon then
		self.lackIcon.url = operData.topLogoIcon
	end
end

function TopLogoWorkHomeFacilityComponent:refreshWaterLoosenToplogo(facilityInfo)
	if not facilityInfo then
		self:setProgressSpeedUpVisible(false)

		if self.operationStateRoot then
			self.operationStateRoot:SetActive(false)
		end

		return
	end

	local timerStateMap = facilityInfo.timerStateMap or {}
	local space = pg.me and pg.me.space
	local ornamentId = self.entity and self.entity.ornamentId
	local isOtherHome = space and ornamentId and not space:isSelfHomeland(pg.me)
	local loosenProgress
	local tillOpId = isOtherHome and HomeLandUtils.getFacilityTillOpId(space, ornamentId) or nil

	if tillOpId and self:checkHasEntDoingOper(tillOpId) then
		if facilityInfo.tilled then
			loosenProgress = 1
		else
			local tillStateInfo = space.facility and space.facility[ornamentId] and space.facility[ornamentId].tillStateInfo
			local total = tillStateInfo and tillStateInfo.totalValue
			local current = tillStateInfo and tillStateInfo.curValue

			loosenProgress = total and total > 0 and math.clamp((current or 0) / total, 0, 1) or 0
		end
	end

	if loosenProgress ~= nil then
		if self.operationStateRoot then
			self.operationStateRoot:SetActive(true)
		end

		self:setProgressSpeedUpVisible(true)
		self:setProgressStyle(tillOpId, loosenProgress)

		return
	end

	for operId, timerStateInfo in pairs(timerStateMap) do
		if self:checkHasEntDoingOper(operId) then
			if self.operationStateRoot then
				self.operationStateRoot:SetActive(true)
			end

			self:setProgressSpeedUpVisible(true)

			local total = timerStateInfo.totalValue
			local ratio = total and total > 0 and timerStateInfo.curValue / total or 0

			self:setProgressStyle(operId, ratio)

			return
		end
	end

	local showCanLoosen = isOtherHome and tillOpId ~= nil and not facilityInfo.tilled and HomeLandUtils.canTill(space, ornamentId, pg.me.uid) == NoticeDef.SUCCESS

	self:setProgressSpeedUpVisible(false)

	if showCanLoosen then
		if self.operationStateRoot then
			self.operationStateRoot:SetActive(true)
		end

		self:setLackStyle(tillOpId)

		return
	end

	local lackOpId

	for operId, _ in pairs(timerStateMap) do
		lackOpId = operId

		break
	end

	if self.operationStateRoot then
		self.operationStateRoot:SetActive(lackOpId ~= nil)
	end

	if lackOpId then
		self:setLackStyle(lackOpId)
	end
end

function TopLogoWorkHomeFacilityComponent:refreshRequireAbility(facilityInfo)
	if not facilityInfo then
		return
	end

	if self.workloadInvalid then
		local abilityId, abilityLv = Utils.getHomePetTimeWorkloadAbilityLevel(facilityInfo.facilityState)
	end
end

function TopLogoWorkHomeFacilityComponent:refreshBuffData(facilityInfo)
	local hasTimerState = false

	table.clear(self.tempBuffData)

	if self.workloadInvalid then
		table.insert(self.tempBuffData, {
			iconUrl = "$UI_HomeToplogo_Icon_Productivity.png",
			buffType = ClientConst.HOME_BUFF_TYPE.Stop
		})
	end

	for operId, _ in pairs(facilityInfo.timerStateMap) do
		hasTimerState = true

		local buffData = ClientConst.HomelandTopLogoBuff[operId]

		if buffData then
			table.insert(self.tempBuffData, {
				iconUrl = buffData.IconUrl,
				buffType = buffData.BuffType
			})
		end
	end

	if self.electricWorkRatio then
		self.electricBuffInfo = {}
		self.electricBuffInfo.iconUrl = AddressDataConst.HOME_TOPLOGO_ICON_POWER

		if self.electricWorkRatio <= 0 then
			self.electricBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Stop
		elseif self.electricWorkRatio >= 1 then
			self.electricBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Buff
		else
			self.electricBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Debuff
		end
	else
		self.electricBuffInfo = nil
	end

	if self.electricBuffInfo then
		table.insert(self.tempBuffData, self.electricBuffInfo)
	end

	if self.tempRequireType then
		self.temperatureBuffInfo = {}
		self.temperatureBuffInfo.iconUrl = ClientConst.TemperatureBuffIcon[self.tempRequireType]

		if self.tempWorkRatio <= 0 then
			self.temperatureBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Stop
		elseif self.tempWorkRatio >= 1 then
			self.temperatureBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Buff
		else
			self.temperatureBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Debuff
		end
	else
		self.temperatureBuffInfo = nil
	end

	if self.temperatureBuffInfo then
		table.insert(self.tempBuffData, self.temperatureBuffInfo)
	end

	if self.lightRequireType then
		self.lightBuffInfo = {}
		self.lightBuffInfo.iconUrl = ClientConst.LightBuffIcon[self.lightRequireType]

		if self.lightWorkRatio <= 0 then
			self.lightBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Stop
		elseif self.lightWorkRatio >= 1 then
			self.lightBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Buff
		else
			self.lightBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Debuff
		end
	else
		self.lightBuffInfo = nil
	end

	if self.lightBuffInfo then
		table.insert(self.tempBuffData, self.lightBuffInfo)
	end
end

function TopLogoWorkHomeFacilityComponent:getCurWorkload(facilityState)
	local workload = 0
	local space = pg.space or pg.me.space
	local ornamentId = self.entity.ornamentId

	for _, allocation in pairs(space.playerAllocation) do
		if allocation.ornamentId == ornamentId and allocation.opId == facilityState then
			workload = workload + HomelandConfigData.playerUnitTimeWorkload
		end
	end

	local relatedPets = space.facilityAllocationInfo[ornamentId]

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = space.allocation[petId]

			if allocation and allocation.opId == facilityState then
				workload = workload + allocation.workload
			end
		end
	end

	return workload
end

function TopLogoWorkHomeFacilityComponent:refreshFacilityProgress(facilityInfo)
	self.leftTime = nil

	local facilityStateInfo = facilityInfo.facilityStateInfo
	local facilityState = facilityInfo.facilityState

	self:refreshFacilityProgressState(facilityInfo)

	local operateInfo = HomelandOperateData[facilityState]
	local progressText, warnTextStr

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		if facilityStateInfo.curValue <= 0 and not self:checkHasEntDoingOper(facilityState) then
			self.progress:SetActive(false)

			if not facilityInfo.disable then
				local operateName = self:getOperateName(operateInfo)

				if operateName then
					warnTextStr = pg.getFormatText(pg.getGameString("HOMELAND_NOT_YET"), pg.getLocalizationText(operateName))
					progressText = pg.getFormatText(pg.getGameString("HOMELAND_NOT_YET"), pg.getLocalizationText(operateName))
				else
					warnTextStr = ""
					progressText = ""
				end
			end
		else
			self.progress:SetActive(true)

			self.progress.maxValue = facilityStateInfo.totalValue
			self.progress.value = facilityStateInfo.curValue

			self.progressHighImg:SetImgFillAmount(facilityStateInfo.curValue / facilityStateInfo.totalValue)

			if not facilityInfo.disable then
				local operateName = self:getOperateName(operateInfo)

				if not operateName then
					warnTextStr = ""
				end

				if self.workloadState ~= WorkState.Stop then
					progressText = pg.getLocalizationText(HomelandOperateData[facilityState].workingNameWithoutEllipsis)

					if not self.statePaused then
						local leftWorkload = math.max(facilityStateInfo.totalValue - facilityStateInfo.curValue, 0)
						local curWorkload = self:getCurWorkload(facilityState)

						if leftWorkload > 0 and curWorkload > 0 then
							local leftTime = leftWorkload / curWorkload * 60
							local timeStr = LuaUIUtils.getCountDownString(leftTime, UIConst.TimeType.Short, true)

							warnTextStr = string.format("<style=Nml_L>%s</style>", timeStr)
							self.leftTime = timeStr
						end
					end
				end
			end
		end
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		self.progress:SetActive(true)

		self.progress.maxValue = facilityStateInfo.totalValue

		local curValue = facilityStateInfo.curValue

		if facilityStateInfo.startTs ~= 0 then
			curValue = facilityStateInfo.curValue + (Time.getSecond() - facilityStateInfo.startTs)
		end

		local leftTs = math.max(facilityStateInfo.totalValue - curValue, 0)

		self.progress.value = math.min(curValue, facilityStateInfo.totalValue)

		if not facilityInfo.disable and leftTs > 0 and self.workloadState ~= WorkState.Stop then
			local timeStr = LuaUIUtils.getCountDownString(leftTs, UIConst.TimeType.Short, true)

			warnTextStr = string.format("<style=Nml_L>%s</style>", timeStr)
			progressText = pg.getLocalizationText(HomelandOperateData[facilityState].workingNameWithoutEllipsis)
			self.leftTime = timeStr
		end
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		self.progress:SetActive(false)

		if not facilityInfo.disable then
			warnTextStr = ""
			progressText = ""
		end
	end

	if not self.itemNotEnough and not self.envNotSatisfied then
		self.tipText = progressText or self.tipText
		self.warnTextStr = warnTextStr or self.warnTextStr
	end
end

function TopLogoWorkHomeFacilityComponent:refreshFacilityProgressState(facilityInfo)
	self.workloadRate = self:getCurWorkRate(facilityInfo)

	if self.workloadRate == 0 then
		if self:checkHasEntDoingOper(facilityInfo.facilityState) then
			self.workloadState = WorkState.Normal

			self.progress:TryChangePage("State", 0)
		else
			self.workloadState = WorkState.Stop

			self.progress:TryChangePage("State", 1)
		end
	elseif self.workloadRate > 0 and self.workloadRate < 1 then
		self.progress:TryChangePage("State", 2)

		self.workloadState = WorkState.Low
	elseif self.workloadRate == 1 then
		self.progress:TryChangePage("State", 0)

		self.workloadState = WorkState.Normal
	elseif self.workloadRate > 1 then
		self.progress:TryChangePage("State", 3)

		self.workloadState = WorkState.High
	end
end

function TopLogoWorkHomeFacilityComponent:getCurWorkRate(facilityInfo)
	return Utils.getFacilityCurWorkRate(facilityInfo, self.entity.homeTemplateId, self.entity.ornamentId, self.statePaused)
end

function TopLogoWorkHomeFacilityComponent:getOutputIcon(facilityInfo)
	local formulaId = facilityInfo.formulaId
	local formulaData = HomelandFormulaData[formulaId] or {}
	local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)
	local showOutputItem

	for itemId, num in pairs(facilityInfo.outputMap) do
		if itemId == defaultOutputItem then
			showOutputItem = itemId

			break
		else
			showOutputItem = itemId
		end
	end

	if not showOutputItem and facilityInfo.specialOutputMap then
		for itemId, info in pairs(facilityInfo.specialOutputMap) do
			if info.num > 0 then
				showOutputItem = itemId

				break
			end
		end
	end

	return LuaUIUtils.getIconByItemId(showOutputItem)
end

function TopLogoWorkHomeFacilityComponent:getOperateIcon(operateInfo, facilityInfo)
	if not operateInfo or not facilityInfo then
		return ""
	end

	local topLogoIconType = operateInfo.topLogoIconType or ClientConst.HomelandTopLogoIconType.Default

	if topLogoIconType == ClientConst.HomelandTopLogoIconType.Default then
		return operateInfo.topLogoIcon or ""
	end

	if topLogoIconType == ClientConst.HomelandTopLogoIconType.Output or topLogoIconType == ClientConst.HomelandTopLogoIconType.OutputSpecial then
		local formulaId = facilityInfo.formulaId
		local formulaData = HomelandFormulaData[formulaId] or {}
		local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

		return LuaUIUtils.getIconByItemId(defaultOutputItem)
	end

	return nil
end

function TopLogoWorkHomeFacilityComponent:getOperateName(operateInfo)
	local interactionId = operateInfo.interactionId

	if interactionId then
		return InteractData[interactionId].actionName
	end

	return nil
end

function TopLogoWorkHomeFacilityComponent:refreshTopLogoInfo(callFromUpdate)
	if self:checkFinalVisible() then
		if self:checkContainerLoaded() then
			self:m_refreshTplFacilityInfo()
		else
			if not self.m_loadedHomeFacilityCallBack then
				function self.m_loadedHomeFacilityCallBack(isSuccess)
					if isSuccess then
						self:m_refreshTplFacilityInfo()
					end
				end
			end

			self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedHomeFacilityCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end
	end
end

function TopLogoWorkHomeFacilityComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoWorkHomeFacilityComponent.super.onLanguageChanged(self)
	self:m_refreshTplFacilityInfo()
end

function TopLogoWorkHomeFacilityComponent:m_refreshTplFacilityInfo()
	if self:checkIsEnvFacility() then
		self:refreshEnvFacilityInfo()
	else
		if self:refreshMutationPickupProgress() then
			return
		end

		self:refreshFacilityInfo()
	end
end

function TopLogoWorkHomeFacilityComponent:renderRequireList(button, index, data)
	if data.tIndex == 1 then
		LuaUIUtils.renderHomeAbility(button, data.abilityId, data.abilityLv)
	else
		local objectReference = button:GetComponent("ObjectReference")
		local numLevelUSDFText = objectReference:GetRefValue("numLevelUSDFText")

		ClientTextUtils.setText(numLevelUSDFText, data.requireRate and math.abs(data.requireRate) or "")

		if data.isElectric then
			button:TryChangePage("Type", 0)

			if data.electricWorkRatio == 0 then
				button:TryChangePage("Condition", 2)
			elseif data.electricWorkRatio > 0 and data.electricWorkRatio < 1 then
				button:TryChangePage("Condition", 0)
			elseif data.electricWorkRatio >= 1 then
				button:TryChangePage("Condition", 1)
			end
		elseif data.isLight then
			button:TryChangePage("Type", 2)

			if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
				if HomelandFormulaData[self.entity.facilityInfo.formulaId].forceEnvRequire then
					button:TryChangePage("Condition", self.lightWorkRatio == 0 and 2 or 3)
				elseif self.lightWorkRatio == 0 then
					button:TryChangePage("Condition", 2)
				elseif self.lightWorkRatio > 0 and self.lightWorkRatio < 1 then
					button:TryChangePage("Condition", 0)
				elseif self.lightWorkRatio >= 1 then
					button:TryChangePage("Condition", 1)
				end
			end
		elseif data.isTemperature then
			button:TryChangePage("Type", data.requireRate > 0 and 1 or 3)

			if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
				if HomelandFormulaData[self.entity.facilityInfo.formulaId].forceEnvRequire then
					button:TryChangePage("Condition", self.tempWorkRatio == 0 and 2 or 3)
				elseif self.tempWorkRatio == 0 then
					button:TryChangePage("Condition", 2)
				elseif self.tempWorkRatio > 0 and self.tempWorkRatio < 1 then
					button:TryChangePage("Condition", 0)
				elseif self.tempWorkRatio >= 1 then
					button:TryChangePage("Condition", 1)
				end
			end
		end
	end
end

function TopLogoWorkHomeFacilityComponent:refreshInfoStateByDistance(distance, facilityInfo)
	if self.widget == nil then
		return
	end

	if distance >= 0 and distance < self.nearDistance then
		if self.distanceState ~= DistanceState.Near then
			self.distanceState = DistanceState.Near

			self.widget:TryChangePage("Distance", 0)
		end

		if pg.me.space.playerAllocation[pg.me.id] and self.entity.ornamentId == pg.me.space.playerAllocation[pg.me.id].ornamentId or self.entity.id == pg.game.home.curInteractEntId then
			self.widget:TryChangePage("ShowDetail", 1)

			if NotNil(self.tipsUContainer) and not self.tipsUContainer:CheckURLLoaded() then
				self.tipsUContainer:LoadDefaultUrlManually(function()
					if IsNil(self.tipsUContainer) or not self.tipsUContainer.content then
						return
					end

					self.tipsInfoComponent = self.tipsUContainer.content:GetComponent("UComponent")

					local objectReference = self.tipsInfoComponent:GetComponent("ObjectReference")

					self.tipsRequireTitleText = objectReference:GetRefValue("requireTitleText")
					self.tipsRequireList = objectReference:GetRefValue("requireList")
					self.timeText = objectReference:GetRefValue("timeText")
					self.demandUComponent = objectReference:GetRefValue("demandUComponent")

					function self.tipsRequireList.luaRenderItem(button, index, data)
						self:renderRequireList(button, index, data)
					end

					self:refreshDetailInfos(facilityInfo)
					self.tipsInfoComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
				end)
			end

			if self.tipsInfoComponent then
				self:refreshDetailInfos(facilityInfo)
			end
		else
			self.widget:TryChangePage("ShowDetail", 0)
		end
	elseif distance >= self.nearDistance and distance < self.midDistance then
		if self.distanceState == DistanceState.Mid then
			return
		end

		self.widget:TryChangePage("ShowDetail", 0)

		self.distanceState = DistanceState.Mid

		self.widget:TryChangePage("Distance", 1)
	elseif distance >= self.midDistance then
		if self.farHomeItem then
			self.farHomeItem:SetActive(self.workloadRate >= 0 and self.workloadRate < 1)
			self.farHomeItem:TryChangePage("Icon", self.workloadRate == 0 and 1 or 0)
		end

		if self.distanceState == DistanceState.Far then
			return
		end

		self.widget:TryChangePage("ShowDetail", 0)

		self.distanceState = DistanceState.Far

		self.widget:TryChangePage("Distance", 2)

		if NotNil(self.farUContainer) and not self.farUContainer:CheckURLLoaded() then
			self.farUContainer:LoadDefaultUrlManually(function()
				if IsNil(self.farUContainer) or not self.farUContainer.content then
					return
				end

				self.farHomeItem = self.farUContainer.content:GetComponent("UComponent")

				self.farHomeItem:SetActive(self.workloadRate >= 0 and self.workloadRate < 1)
				self.farHomeItem:TryChangePage("Icon", self.workloadRate == 0 and 1 or 0)
			end)
		end
	end
end

function TopLogoWorkHomeFacilityComponent:refreshEnvFacilityInfoStateByDistance(distance, facilityInfo)
	if self.envWidget == nil then
		return
	end

	local envWarnTextVisible = false

	if distance >= 0 and distance < self.nearDistance then
		if self.distanceState ~= DistanceState.Near then
			self.distanceState = DistanceState.Near

			self.widget:TryChangePage("Distance", 0)
		end

		if pg.me.space.playerAllocation[pg.me.id] and self.entity.ornamentId == pg.me.space.playerAllocation[pg.me.id].ornamentId or self.entity.id == pg.game.home.curInteractEntId then
			envWarnTextVisible = false

			self.widget:TryChangePage("ShowDetail", 1)

			if NotNil(self.tipsUContainer) and not self.tipsUContainer:CheckURLLoaded() then
				self.tipsUContainer:LoadDefaultUrlManually(function()
					if IsNil(self.tipsUContainer) or not self.tipsUContainer.content then
						return
					end

					self.tipsInfoComponent = self.tipsUContainer.content:GetComponent("UComponent")

					local objectReference = self.tipsInfoComponent:GetComponent("ObjectReference")

					self.tipsRequireTitleText = objectReference:GetRefValue("requireTitleText")
					self.demandUComponent = objectReference:GetRefValue("demandUComponent")

					self.tipsInfoComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
					self.tipsInfoComponent:TryChangePage("ShowDemand", 1)

					local timeText = objectReference:GetRefValue("timeText")

					ClientTextUtils.setText(timeText, "")

					self.tipsRequireList = objectReference:GetRefValue("requireList")

					function self.tipsRequireList.luaRenderItem(button, index, data)
						self:renderRequireList(button, index, data)
					end

					self:refreshEnvFacilityDetailInfos(facilityInfo)
				end)
			end

			if self.tipsInfoComponent then
				self:refreshEnvFacilityDetailInfos(facilityInfo)
			end
		else
			self.widget:TryChangePage("ShowDetail", 0)

			envWarnTextVisible = true
		end
	elseif distance >= self.nearDistance and distance < self.midDistance then
		if self.distanceState == DistanceState.Mid then
			return
		end

		self.widget:TryChangePage("ShowDetail", 0)

		self.distanceState = DistanceState.Mid

		self.widget:TryChangePage("Distance", 1)

		envWarnTextVisible = false
	elseif distance >= self.midDistance then
		if self.distanceState == DistanceState.Mid then
			return
		end

		self.widget:TryChangePage("ShowDetail", 0)

		self.distanceState = DistanceState.Mid

		self.widget:TryChangePage("Distance", 1)

		envWarnTextVisible = false
	end

	if envWarnTextVisible then
		self.envWarnText.visibility = CS.XGUI.EVisibility.Visible
	else
		self.envWarnText.visibility = CS.XGUI.EVisibility.Hidden
	end
end

function TopLogoWorkHomeFacilityComponent:refreshEnvFacilityDetailInfos(facilityInfo)
	local tipText = pg.getGameString("HOMELAND_NO_WORKLOAD")
	local infoIsWarn = true

	self.tipsInfoComponent:TryChangePage("State", 1)

	if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		local linkInfo = self.entity:getHomeLinkInfo()

		if linkInfo then
			if linkInfo.groupId ~= 0 then
				local linkGroupInfo = pg.me.space.homeLinkGroupMap[linkInfo.groupId]

				if linkGroupInfo.totalProduce > 0 then
					tipText = facilityInfo and HomelandOperateData[facilityInfo.facilityState].workingNameWithoutEllipsis or pg.getGameString("HOME_FACILITY_WORKING")
					infoIsWarn = false
				else
					tipText = pg.getGameString("HOMELAND_NO_ELECTRIC")
				end
			else
				tipText = pg.getGameString("HOMELAND_ELECTRIC_NOT_VALID")
			end
		end
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		self:setEnvContainerUrl(AddressDataConst.HOME_TOP_LOGO_ENV_ELECTRIC)

		local envFacilityInfo = self.entity:getEnvFacilityInfo()

		if envFacilityInfo and envFacilityInfo.envProduce > 0 then
			tipText = pg.getLocalizationText(HomelandOperateData[facilityInfo.facilityState].workingNameWithoutEllipsis)
			infoIsWarn = false
		end
	else
		local envFacilityInfo = self.entity:getEnvFacilityInfo()

		if envFacilityInfo then
			if envFacilityInfo.envProduce ~= 0 then
				tipText = pg.getLocalizationText(HomelandOperateData[facilityInfo.facilityState].workingNameWithoutEllipsis)
				infoIsWarn = false
			else
				tipText = self:checkHasEntDoingOper(facilityInfo.facilityState) and pg.getGameString("HOMELAND_NO_ELECTRIC") or pg.getGameString("HOMELAND_NO_WORKLOAD")
			end
		end
	end

	if facilityInfo and facilityInfo.disable then
		tipText = pg.getGameString("HOMELAND_PAUSING")
		infoIsWarn = true
	end

	ClientTextUtils.setText(self.tipsRequireTitleText, tipText)
	self.tipsInfoComponent:TryChangePage("State", infoIsWarn and 1 or 0)

	local requireAbility = self:getDetailRequireAbility(facilityInfo)

	if requireAbility then
		self.tipsRequireList:SetList({
			requireAbility
		})
	end

	self.tipsInfoComponent:TryChangePage("ShowDemand", requireAbility ~= nil and 0 or 1)

	if facilityInfo then
		self.demandUComponent:TryChangePage("Condition", HomelandOperateData[facilityInfo.facilityState].needLevelFit and 2 or 0)
	end
end

function TopLogoWorkHomeFacilityComponent:refreshDetailInfos(facilityInfo)
	local requireInfos = {}
	local isForceRequire = false

	if (self.workloadState ~= WorkState.Stop or self.envNotSatisfied) and Utils.checkNeedEnvRequire(facilityInfo) then
		if (self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq or self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch) and facilityInfo.envWorkRatio < 1 then
			local requireInfo = {
				tIndex = 0,
				isElectric = true,
				electricWorkRatio = facilityInfo.envWorkRatio
			}

			table.insert(requireInfos, requireInfo)
		end

		local temperatureRequire = HomelandFormulaData[facilityInfo.formulaId].temperatureRequire
		local lightRequire = HomelandFormulaData[facilityInfo.formulaId].lightRequire

		if self.lightWorkRatio and self.lightWorkRatio < 1 or self.tempWorkRatio and self.tempWorkRatio < 1 then
			if lightRequire then
				local requireInfo = {
					isLight = true,
					tIndex = 0,
					requireRate = lightRequire
				}

				table.insert(requireInfos, requireInfo)
			end

			if temperatureRequire then
				local requireInfo = {
					tIndex = 0,
					isTemperature = true,
					requireRate = temperatureRequire
				}

				table.insert(requireInfos, requireInfo)
			end
		end
	end

	local requireAbility = self:getDetailRequireAbility(facilityInfo)

	if requireAbility then
		table.insert(requireInfos, requireAbility)
	end

	local operateInfo = HomelandOperateData[facilityInfo.facilityState]
	local operateName = self:getOperateName(operateInfo)

	if operateInfo.needLevelFit or HomelandFormulaData[facilityInfo.formulaId].forceEnvRequire then
		isForceRequire = true
	end

	self.showDemand = #requireInfos > 0

	self.tipsInfoComponent:TryChangePage("ShowDemand", self.showDemand and 0 or 1)
	self.tipsRequireList:SetList(requireInfos)
	ClientTextUtils.setText(self.tipsRequireTitleText, self.leftTime and self.tipText .. ":" or self.tipText)
	ClientTextUtils.setText(self.timeText, self.leftTime or "")
	self.demandUComponent:TryChangePage("Condition", isForceRequire and 2 or 0)
	self.tipsInfoComponent:TryChangePage("State", self.workloadState)
end

function TopLogoWorkHomeFacilityComponent:getDetailRequireAbility(facilityInfo)
	if not facilityInfo then
		return nil
	end

	local abilityId, abilityLv = Utils.getHomePetTimeWorkloadAbilityLevel(facilityInfo.facilityState)

	if self.workloadInvalid and abilityId and abilityLv then
		local requireAbility = {
			tIndex = 1,
			abilityId = abilityId,
			abilityLv = abilityLv
		}

		return requireAbility
	end

	return nil
end

return TopLogoWorkHomeFacilityComponent
