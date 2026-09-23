-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilityInfoDetail\\HomelandFacilityInfoDetailCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local PetData = require("Data.pet_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandFacilityInfoDetailCtrl = Class.LightClass("HomelandFacilityInfoDetailCtrl", UICtrl)
local WorkState = {
	Stop = 1,
	Normal = 0,
	High = 3,
	Low = 2
}

HomelandFacilityInfoDetailCtrl.messages = {
	[MessageName.UI_ON_HIDE] = {
		"onUIHide",
		true
	}
}

function HomelandFacilityInfoDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view = self.view
end

function HomelandFacilityInfoDetailCtrl:addListener()
	function self.view.envList.luaRenderItem(button, index, data)
		self:renderEnvList(button, index, data)
	end

	function self.view.petList.luaRenderItem(button, index, data)
		self:renderPetList(button, index, data)
	end

	function self.view.rootComponent.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end
end

function HomelandFacilityInfoDetailCtrl:onOpen(data)
	UICtrl.onOpen(self, data)

	self.iData = data
	self.entity = data.entity
	self.homeTemplateId = data.homeTemplateId
	self.isHatchBox = data.isHatchBox or false
	self.facilityInfo = data.facilityInfo or {}
	self.ornamentInfo = data.ornamentInfo or {}
	self.facilityType = Utils.getHomeFacilityType(self.homeTemplateId)
	self.extraInfo = data.extraInfo
	self.formulaId = self.facilityInfo.formulaId

	self:refreshView()
	self:refreshEnvList()
	self:refreshPetList()
end

function HomelandFacilityInfoDetailCtrl:refreshView()
	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootComponent:SetAutoVertical(autoVer, autoHor)
	self.view.rootComponent:SetPadding(self.iData.padding)
	self.view.rootComponent:OpenPopup(self.iData.targetRect)

	if self.isHatchBox then
		self.curWorkRatio = HomeLandUtils.getHatchBoxRealWorkRatio(self.iData and self.iData.ornamentId or 0)
	else
		self.curWorkRatio = Utils.getFacilityCurWorkRate(self.iData.facilityInfo, self.iData.homeTemplateId, self.iData.ornamentId, self.iData.statePaused)
	end

	if self.curWorkRatio > 0 then
		ClientTextUtils.setText(self.view.workloadText, math.floor(self.curWorkRatio * 100) .. "%")

		if self.curWorkRatio < 1 then
			self.curWorkState = WorkState.Low
		elseif self.curWorkRatio == 1 then
			self.curWorkState = WorkState.Normal
		else
			self.curWorkState = WorkState.High
		end
	else
		self.curWorkState = WorkState.Stop
	end

	if not self.isHatchBox and self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		ClientTextUtils.setText(self.view.titleText, pg.getGameString("TITLE_ELECTRIC_WORK_RATE"))
	else
		ClientTextUtils.setText(self.view.titleText, pg.getGameString("TITLE_WORK_RATE"))
	end

	self.view.titleUWidget:TryChangePage("State", self.curWorkState)
end

function HomelandFacilityInfoDetailCtrl:renderEnvList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rateText = objectReference:GetRefValue("rateText")
	local envText = objectReference:GetRefValue("envText")
	local list = objectReference:GetRefValue("list")
	local envIcon = objectReference:GetRefValue("envIcon")

	ClientTextUtils.setText(envText, data.envName)
	ClientTextUtils.setText(rateText, math.floor(data.workRatio * 100) .. "%")

	envIcon.url = data.envIcon

	function list.luaRenderItem(button1, index1, data1)
		self:renderEnvItemList(button1, index1, data1)
	end

	local requireInfo = {
		itemName = pg.getGameString("REQUIRE_LABEL"),
		itemDetail = data.envRequire
	}
	local curInfo = {
		itemName = pg.getGameString("CURRENT"),
		itemDetail = data.envCurrent,
		workRatio = data.workRatio
	}

	if data.workRatio == 0 then
		button:TryChangePage("State", 1)
	elseif data.workRatio > 0 and data.workRatio < 1 then
		button:TryChangePage("State", 2)
	elseif data.workRatio == 1 then
		button:TryChangePage("State", 0)
	elseif data.workRatio > 1 then
		button:TryChangePage("State", 3)
	end

	local envItemInfos = {
		requireInfo,
		curInfo
	}

	list:SetList(envItemInfos)
end

function HomelandFacilityInfoDetailCtrl:renderEnvItemList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameText = objectReference:GetRefValue("nameText")
	local detailText = objectReference:GetRefValue("detailText")

	ClientTextUtils.setText(nameText, data.itemName)
	ClientTextUtils.setText(detailText, data.itemDetail)

	if data.workRatio then
		if data.workRatio == 1 then
			button:TryChangePage("State", 0)
		elseif data.workRatio == 0 then
			button:TryChangePage("State", 1)
		elseif data.workRatio > 0 and data.workRatio < 1 then
			button:TryChangePage("State", 2)
		elseif data.workRatio > 1 then
			button:TryChangePage("State", 3)
		end
	else
		button:TryChangePage("State", 4)
	end
end

function HomelandFacilityInfoDetailCtrl:refreshEnvList()
	local envInfos = {}

	if self.isHatchBox then
		local recommendInfos, recommendEnvRatio = HomeLandUtils.getHatchEggRecommendEnvInfos(self.iData.ornamentId)

		for _, recommendInfo in ipairs(recommendInfos) do
			local isTemperature = recommendInfo.isTemperature
			local workRatio = isTemperature and recommendInfo.tempWorkRatio or recommendInfo.lightWorkRatio
			local envCurrentText = ""

			if isTemperature then
				envCurrentText = HomeLandUtils.getTempLevelText(recommendInfo.requireRate or 0)
			elseif workRatio == 0 then
				envCurrentText = pg.getGameString("HOMELAND_NO_LIGHT")
			elseif workRatio > 0 and workRatio < 1 then
				envCurrentText = pg.getGameString("NORMAL")
			else
				envCurrentText = pg.getGameString("SUFFICIENT")
			end

			local envInfo = {
				workRatio = recommendInfo.isTemperature and recommendInfo.tempWorkRatio or recommendInfo.lightWorkRatio,
				envName = recommendInfo.isTemperature and pg.getGameString("TEMPERATURE") or pg.getGameString("HOMELAND_LIGHT_ENVIRONMENT"),
				envIcon = recommendInfo.isTemperature and AddressDataConst.HOME_TOPLOGO_ICON_TEMPERATURE or AddressDataConst.HOME_TOPLOGO_ICON_LIGHT,
				envRequire = recommendInfo.isTemperature and HomeLandUtils.getTempLevelText(recommendInfo.requireRate or 0) or pg.getGameString("SUFFICIENT"),
				envCurrent = envCurrentText
			}

			table.insert(envInfos, envInfo)
		end
	elseif Utils.checkNeedEnvRequire(self.iData.facilityInfo) then
		local isElectricType = Utils.checkIsElectricReqType(self.facilityType, self.ornamentInfo.electricMode)

		if isElectricType then
			local workRatio = self.iData.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Electric)
			local facilityId = Utils.getHomeObjectFacilityId(self.iData.homeTemplateId)
			local facilityData = HomelandFacilityData[facilityId]
			local electricRequire = facilityData.electricRequire
			local electricInfo = {
				workRatio = workRatio,
				envName = pg.getGameString("HOMELAND_ELECTRIC_ENVIRONMENT"),
				envIcon = AddressDataConst.HOME_TOPLOGO_ICON_POWER,
				envRequire = math.floor(electricRequire) .. "W",
				envCurrent = math.floor(electricRequire * workRatio) .. "W"
			}

			table.insert(envInfos, electricInfo)
		elseif HomelandFormulaData[self.iData.facilityInfo.formulaId].temperatureRequire or HomelandFormulaData[self.iData.facilityInfo.formulaId].lightRequire then
			local lightWorkRatio, lightRequireType = self.iData.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Light)
			local tempWorkRatio, tempRequireType = self.iData.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Temperature)

			if lightRequireType then
				local envCurrentText = ""

				if lightWorkRatio == 0 then
					envCurrentText = pg.getGameString("HOMELAND_NO_LIGHT")
				elseif lightWorkRatio > 0 and lightWorkRatio < 1 then
					envCurrentText = pg.getGameString("NORMAL")
				else
					envCurrentText = pg.getGameString("SUFFICIENT")
				end

				local envInfo = {
					workRatio = lightWorkRatio,
					envName = pg.getGameString("HOMELAND_LIGHT_ENVIRONMENT"),
					envIcon = AddressDataConst.HOME_TOPLOGO_ICON_LIGHT,
					envRequire = pg.getGameString("SUFFICIENT"),
					envCurrent = envCurrentText
				}

				table.insert(envInfos, envInfo)
			end

			if tempRequireType then
				local envCurrentText = ""

				if tempWorkRatio == 0 then
					envCurrentText = pg.getGameString("HOMELAND_NO_TEMPERATURE")
				elseif tempWorkRatio > 0 and tempWorkRatio < 1 then
					envCurrentText = pg.getGameString("NORMAL")
				else
					envCurrentText = pg.getGameString("SUFFICIENT")
				end

				local curTemperature = self.iData.entity:getOrnamentEnvInfo().temperature
				local envInfo = {
					workRatio = tempWorkRatio,
					envName = pg.getGameString("TEMPERATURE"),
					envIcon = AddressDataConst.HOME_TOPLOGO_ICON_TEMPERATURE,
					envRequire = HomeLandUtils.getTempLevelText(tempRequireType),
					envCurrent = HomeLandUtils.getTempLevelText(curTemperature)
				}

				table.insert(envInfos, envInfo)
			end
		end
	end

	self.view.envList:SetList(envInfos)

	if #envInfos > 0 then
		self.view.envList:SetActive(true)
	else
		self.view.envList:SetActive(false)
	end
end

function HomelandFacilityInfoDetailCtrl:renderPetList(button, index, data)
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

			local workType = 0

			if data.opId ~= 0 and data.opId == facilityInfo.facilityState then
				if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
					local formulaData = HomelandFormulaData[self.formulaId]
					local workRate = Utils.calcWorkRate(self.facilityType, data.opId, data.workload, self.formulaId)
					local electricProduce = workRate * formulaData.electricProduce

					ClientTextUtils.setText(workloadText, math.floor(electricProduce) .. "W")

					if workRate then
						button:TryChangePage("State", workRate >= 1 and 1 or 0)
					else
						button:TryChangePage("State", 0)
					end

					workType = 1
				else
					ClientTextUtils.setText(workloadText, data.workload)

					local workRate = Utils.calcWorkRate(self.facilityType, data.opId, data.workload, self.formulaId)

					if workRate then
						button:TryChangePage("State", workRate >= 1 and 1 or 0)
					else
						button:TryChangePage("State", 0)
					end
				end

				button:TryChangePage("workType", workType)
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

function HomelandFacilityInfoDetailCtrl:refreshPetList()
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

	if #self.petData == 0 or self.isHatchBox then
		self.view.petDetail:SetActive(false)
		self.view.petList:SetActive(false)
	else
		self.view.petDetail:SetActive(true)
		self.view.petList:SetActive(true)
		self.view.petList:SetList(self.petData)
	end
end

function HomelandFacilityInfoDetailCtrl:checkCanOpen(showNotice, data)
	if not data or not data.ornamentId then
		return false
	end

	return true
end

function HomelandFacilityInfoDetailCtrl:onUIHide()
	if not self:checkUIShow() then
		return
	end

	self:close()
end

return HomelandFacilityInfoDetailCtrl
