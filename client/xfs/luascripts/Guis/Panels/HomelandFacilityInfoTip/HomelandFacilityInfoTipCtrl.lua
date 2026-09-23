-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilityInfoTip\\HomelandFacilityInfoTipCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local ClientConst = require("Const.ClientConst")
local HomelandFacilityInfoTipCtrl = Class.LightClass("HomelandFacilityInfoTipCtrl", UICtrl)

HomelandFacilityInfoTipCtrl.messages = {
	[MessageName.UI_ON_HIDE] = {
		"onUIHide",
		true
	}
}

function HomelandFacilityInfoTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view = self.view
end

function HomelandFacilityInfoTipCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadB, function()
		self:close()
	end)
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRS, function()
		self:close()
	end)

	function self.view.rootCmp.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end

	function self.view.rootCmp.luaSetScale()
		local scale = Vector3.one * (self.iData.scale or 1)

		self.view.transform.localScale = scale
	end

	function self.view.petList.luaRenderItem(button, index, data)
		self:renderPetItem(button, data)
	end

	function self.view.envList.luaRenderItem(button, index, data)
		self:renderEnvItem(button, data)
	end
end

function HomelandFacilityInfoTipCtrl:onOpen(data)
	UICtrl.onOpen(self, data)

	self.iData = data

	if self.iData.extra and self.iData.extra.openFun then
		self.iData.extra.openFun()
	end

	if self.iData.enableBtn == nil then
		self.iData.enableBtn = true
	end

	self.entity = data.entity
	self.homeTemplateId = data.homeTemplateId
	self.facilityInfo = data.facilityInfo or {}
	self.ornamentInfo = data.ornamentInfo or {}
	self.facilityType = Utils.getHomeFacilityType(self.homeTemplateId)
	self.extraInfo = data.extraInfo
	self.formulaId = self.facilityInfo.formulaId

	self:refreshView()
end

function HomelandFacilityInfoTipCtrl:checkCanOpen(showNotice, data)
	if not data or not data.ornamentId then
		return false
	end

	return true
end

function HomelandFacilityInfoTipCtrl:refreshView()
	if self.iData == nil then
		return
	end

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)

	if self.iData.autoClose ~= nil then
		self.view.rootCmp:SetAutoClose(self.iData.autoClose)
	end

	if self.iData.checkTouchBegin ~= nil then
		self.view.rootCmp:SetCheckTouchState(self.iData.checkTouchBegin)
	end

	if self.iData.rayCastParent then
		self.view.rootCmp:AddRayOcclusionMask(self.iData.rayCastParent, self.iData.addSibling or 0)
	end

	if self.iData.padding ~= nil then
		self.view.rootCmp:SetPadding(self.iData.padding)
	end

	self.view.rootCmp:OpenPopup(self.iData.targetRect)
	self:refreshFacilityInfo()
end

function HomelandFacilityInfoTipCtrl:refreshFacilityInfo()
	if not self.iData then
		return
	end

	self:refreshBaseInfo()
	self:refreshPetDetail()
	self:refreshPetList()
	self:refreshEnv()
	self:refreshPower()
end

function HomelandFacilityInfoTipCtrl:onUIHide()
	if not self:checkUIShow() then
		return
	end

	self:close()
end

function HomelandFacilityInfoTipCtrl:refreshPetList()
	local petList = self.iData.petList or {}

	self.petData = {}

	for _, petInfo in pairs(petList) do
		if petInfo.petId then
			table.insert(self.petData, {
				petId = petInfo.petId,
				opId = petInfo.opId,
				workload = petInfo.workload,
				fitPersonality = petInfo.fitPersonality
			})
		end
	end

	if #self.petData == 0 then
		self.view.petList:SetActive(false)
	else
		self.view.petList:SetActive(true)
		self.view.petList:SetList(self.petData)
	end
end

function HomelandFacilityInfoTipCtrl:renderPetItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("icon")
	local nameText = objectReference:GetRefValue("nameText")
	local workloadText = objectReference:GetRefValue("workloadText")
	local petExchangeUWidget = objectReference:GetRefValue("petExchangeUWidget")
	local petExchangeUButton = objectReference:GetRefValue("petExchangeUButton")
	local petId = data.petId
	local facilityInfo = self.iData.facilityInfo

	if petId then
		local petInfo = pg.me.space.pets[petId]

		if petInfo then
			local petData = PetData[petInfo.templateId]

			icon:SetUrlWithCallback(LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petInfo.label), function()
				if icon.sprite == nil then
					icon.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, 0)
				end
			end)
			ClientTextUtils.setText(nameText, pg.getLocalizationText(LuaUIUtils.getPetNameByPetInfo(petInfo)))

			if data.opId ~= 0 and data.opId == facilityInfo.facilityState then
				if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
					local formulaData = HomelandFormulaData[self.formulaId]
					local electricProduce = math.min(1, data.workload / formulaData.unitWorkload) * formulaData.electricProduce

					ClientTextUtils.setText(workloadText, electricProduce .. "W")
				else
					ClientTextUtils.setText(workloadText, data.workload)
				end
			else
				ClientTextUtils.setText(workloadText, "-")
			end
		end

		if data.fitPersonality and data.fitPersonality ~= 0 then
			petExchangeUWidget:SetActive(true)
			LuaUIUtils.renderTalentItem(petExchangeUButton, data.fitPersonality)
		else
			petExchangeUWidget:SetActive(false)
		end
	end
end

function HomelandFacilityInfoTipCtrl:refreshBaseInfo()
	local statePaused = self.iData.statePaused

	if statePaused then
		self.view.baseInfo:TryChangePage("WorkState", 1)
		ClientTextUtils.setText(self.view.workloadText, pg.getGameString("HOMELAND_WORK_STOP"))
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		ClientTextUtils.setText(self.view.workloadText, "")
	else
		self.view.baseInfo:TryChangePage("WorkState", 0)

		local workRate = self.facilityInfo.envWorkRatio

		ClientTextUtils.setText(self.view.workloadText, string.format("%s%%", math.floor(workRate * 100)))
	end
end

function HomelandFacilityInfoTipCtrl:refreshPetDetail()
	self.view.petDetail:SetActive(false)
end

function HomelandFacilityInfoTipCtrl:refreshPower()
	local facilityId = Utils.getHomeObjectFacilityId(self.homeTemplateId)
	local facilityData = HomelandFacilityData[facilityId]
	local isElectricType = Utils.checkIsElectricReqType(self.facilityType, self.ornamentInfo.electricMode)

	if isElectricType then
		self.view.electric:SetActive(true)

		local require = facilityData.electricRequire
		local produce = require * self.facilityInfo.envWorkRatio
		local buffType = ClientConst.HOME_BUFF_TYPE.Buff

		if self.facilityInfo.envWorkRatio >= 1 then
			buffType = ClientConst.HOME_BUFF_TYPE.Buff
		elseif self.facilityInfo.envWorkRatio == 0 then
			buffType = ClientConst.HOME_BUFF_TYPE.Stop
		else
			buffType = ClientConst.HOME_BUFF_TYPE.Debuff
		end

		self.view.electricBuff:TryChangePage("BuffType", buffType)
		self.view.electricInfo:TryChangePage("BuffType", buffType)
		ClientTextUtils.setText(self.view.electricText, string.format("%sW/%sW", math.floor(produce), math.floor(require)))
		ClientTextUtils.setText(self.view.electricWorkRatio, string.format("%s%%", math.floor(self.facilityInfo.envWorkRatio * 100)))
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		ClientTextUtils.setText(self.view.electricText, string.format("%sW/%sW", self.extraInfo.realProduce, self.extraInfo.maxProduce))

		local workRate = 0

		if self.extraInfo.realProduce > 0 then
			workRate = self.extraInfo.realProduce / self.extraInfo.totalCost
		end

		local buffType = ClientConst.HOME_BUFF_TYPE.Buff

		if workRate >= 1 then
			buffType = ClientConst.HOME_BUFF_TYPE.Buff
		elseif workRate == 0 then
			buffType = ClientConst.HOME_BUFF_TYPE.Stop
		else
			buffType = ClientConst.HOME_BUFF_TYPE.Debuff
		end

		self.view.electricBuff:TryChangePage("BuffType", buffType)
		self.view.electricInfo:TryChangePage("BuffType", buffType)
		ClientTextUtils.setText(self.view.electricWorkRatio, string.format("%s%%", math.floor(workRate * 100)))
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		ClientTextUtils.setText(self.view.electricText, string.format("%sW/%sW", self.extraInfo.realProduce, self.extraInfo.maxProduce))

		local workRate = 0

		if self.extraInfo.realProduce > 0 then
			workRate = self.extraInfo.realProduce / self.extraInfo.totalCost
		end

		local buffType = ClientConst.HOME_BUFF_TYPE.Buff

		if workRate >= 1 then
			buffType = ClientConst.HOME_BUFF_TYPE.Buff
		elseif workRate == 0 then
			buffType = ClientConst.HOME_BUFF_TYPE.Stop
		else
			buffType = ClientConst.HOME_BUFF_TYPE.Debuff
		end

		self.view.electricBuff:TryChangePage("BuffType", buffType)
		self.view.electricInfo:TryChangePage("BuffType", buffType)
		ClientTextUtils.setText(self.view.electricWorkRatio, string.format("%s%%", math.floor(workRate * 100)))
	else
		self.view.electric:SetActive(false)
	end
end

function HomelandFacilityInfoTipCtrl:refreshEnv()
	self.electricWorkRatio = nil
	self.lightWorkRatio = nil
	self.lightRequireType = nil
	self.tempWorkRatio = nil
	self.tempRequireType = nil

	if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
		self.lightWorkRatio, self.lightRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Light)
		self.tempWorkRatio, self.tempRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Temperature)
	end

	if not self.lightRequireType and not self.tempRequireType then
		self.view.environment:SetActive(false)

		return
	end

	self.view.environment:SetActive(true)

	if not self.envDataList then
		self.envDataList = {}
	else
		table.clear(self.envDataList)
	end

	if self.tempRequireType then
		self.temperatureBuffInfo = {}
		self.temperatureBuffInfo.iconUrl = ClientConst.TemperatureBuffIcon[self.tempRequireType]
		self.temperatureBuffInfo.workRatio = self.tempWorkRatio

		if self.tempWorkRatio <= 0 then
			self.temperatureBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Stop
			self.temperatureBuffInfo.text = pg.getGameString("TEMPERATURE_INVALID")
		elseif self.tempWorkRatio >= 1 then
			self.temperatureBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Buff
			self.temperatureBuffInfo.text = pg.getGameString("TEMPERATURE_GOOD")
		else
			self.temperatureBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Debuff
			self.temperatureBuffInfo.text = pg.getGameString("TEMPERATURE_FIT")
		end

		table.insert(self.envDataList, self.temperatureBuffInfo)
	end

	if self.lightRequireType then
		self.lightBuffInfo = {}
		self.lightBuffInfo.iconUrl = ClientConst.LightBuffIcon[self.lightRequireType]
		self.lightBuffInfo.workRatio = self.lightWorkRatio

		if self.lightWorkRatio <= 0 then
			self.lightBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Stop
			self.lightBuffInfo.text = pg.getGameString("LIGHT_INVALID")
		elseif self.lightWorkRatio >= 1 then
			self.lightBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Buff
			self.lightBuffInfo.text = pg.getGameString("LIGHT_GOOD")
		else
			self.lightBuffInfo.buffType = ClientConst.HOME_BUFF_TYPE.Debuff
			self.lightBuffInfo.text = pg.getGameString("LIGHT_FIT")
		end

		table.insert(self.envDataList, self.lightBuffInfo)
	end

	self.view.envList:SetList(self.envDataList)
end

function HomelandFacilityInfoTipCtrl:renderEnvItem(item, data)
	item:TryChangePage("BuffType", data.buffType)

	local objectReference = item:GetComponent("ObjectReference")
	local infoText = objectReference:GetRefValue("infoText")
	local workRateText = objectReference:GetRefValue("workRateText")
	local envBuff = objectReference:GetRefValue("envBuff")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(infoText, data.text)
	envBuff:TryChangePage("BuffType", data.buffType)
	ClientTextUtils.setText(workRateText, string.format("%s%%", math.floor(data.workRatio * 100)))

	iconUImage.url = data.iconUrl
end

return HomelandFacilityInfoTipCtrl
