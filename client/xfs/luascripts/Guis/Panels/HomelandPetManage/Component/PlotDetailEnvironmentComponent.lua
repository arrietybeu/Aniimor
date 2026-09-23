-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotDetailEnvironmentComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlotDetailEnvironmentComponent")
local Class = require("Core.Framework.Class")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PlotDetailEnvironmentComponent = Class.LightClass("PlotDetailEnvironmentComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local ClientUtils = require("Utils.ClientUtils")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandConfigData = require("Data.homeland_config_data")

PlotDetailEnvironmentComponent.ENV_FACILITY_TYPE = {
	[Const.HOMELAND_FACILITY_TYPE.Electric] = 0,
	[Const.HOMELAND_FACILITY_TYPE.HighTemperate] = 1,
	[Const.HOMELAND_FACILITY_TYPE.LowTemperate] = 2,
	[Const.HOMELAND_FACILITY_TYPE.Light] = 3
}

function PlotDetailEnvironmentComponent:findObjects()
	return
end

function PlotDetailEnvironmentComponent:initView()
	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPlotDetailEnvironment(self.ornamentInfo)
	end)
end

function PlotDetailEnvironmentComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnLowUButton = objectReference:GetRefValue("btnLowUButton")
	self.btnHighUButton = objectReference:GetRefValue("btnHighUButton")
	self.btnLowUSDFText = objectReference:GetRefValue("btnLowUSDFText")
	self.btnHighUSDFText = objectReference:GetRefValue("btnHighUSDFText")
	self.toggleTabUWidget = objectReference:GetRefValue("toggleTabUWidget")
end

function PlotDetailEnvironmentComponent:getEnvEffectName(type)
	if type == Const.HOMELAND_FACILITY_TYPE.Electric then
		return pg.getGameString("HOMELAND_MANAGE_ELECTRICITY")
	elseif type == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
		return pg.getGameString("HOMELAND_MANAGE_HIGH_TEMP")
	elseif type == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
		return pg.getGameString("HOMELAND_MANAGE_LOW_TEMP")
	elseif type == Const.HOMELAND_FACILITY_TYPE.Light then
		return pg.getGameString("HOMELAND_MANAGE_LIGHT")
	end

	return ""
end

function PlotDetailEnvironmentComponent:addListener()
	function self.listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
		local listDetailsUList = objectReference:GetRefValue("listDetailsUList")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_MANAGE_GRID_POWER_SUPPLY"))
		ClientTextUtils.setText(txtNumUSDFText, data.rate .. "%")

		btnInfoUButton.enabledTooltip = true

		function btnInfoUButton.luaRenderTooltip(_button, popup)
			local _objectReference = popup:GetComponent("ObjectReference")
			local txtTitle = _objectReference:GetRefValue("txtTitle")
			local txtNum = _objectReference:GetRefValue("txtNum")
			local txtDesc = _objectReference:GetRefValue("txtDesc")

			logger:info("self.listUList.luaRenderItem 111111", txtTitle, txtDesc, pg.getLocalizationText(HomelandConfigData.electricTip))
			ClientTextUtils.setText(txtTitle, pg.getGameString("ELECTRIC_TIP_TITLE"))
			ClientTextUtils.setText(txtDesc, pg.getLocalizationText(HomelandConfigData.electricTip))
		end

		local detailList = {}

		table.insert(detailList, {
			name = "ELECTRIC_MAX_PRODUCE",
			num = data.max
		})
		table.insert(detailList, {
			name = "ELECTRIC_CUR_PRODUCE",
			num = data.current
		})
		table.insert(detailList, {
			name = "ELECTRIC_COST",
			num = data.need
		})

		function listDetailsUList.luaRenderItem(_button, _index, _data)
			local _objectReference = _button:GetComponent("ObjectReference")
			local _txtNameUSDFText = _objectReference:GetRefValue("txtNameUSDFText")
			local _txtNumUSDFText = _objectReference:GetRefValue("txtNumUSDFText")

			ClientTextUtils.setText(_txtNameUSDFText, pg.getGameString(_data.name))
			ClientTextUtils.setText(_txtNumUSDFText, _data.num .. "W")
		end

		listDetailsUList:SetList(detailList)
	end

	function self.btnLowUButton.luaClick()
		local facilityInfo = pg.me.space.facility[self.ornamentInfo.ornamentId]

		if facilityInfo.envParam == 2 then
			self.toggleTabUWidget:TryChangePage("StateTab", 0)
			pg.space:setProduceEnvParam(self.ornamentInfo.ornamentId, 1)
		end
	end

	function self.btnHighUButton.luaClick()
		local facilityInfo = pg.me.space.facility[self.ornamentInfo.ornamentId]

		if facilityInfo.envParam == 1 then
			self.toggleTabUWidget:TryChangePage("StateTab", 1)
			pg.space:setProduceEnvParam(self.ornamentInfo.ornamentId, 2)
		end
	end
end

function PlotDetailEnvironmentComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PlotDetailEnvironmentComponent:getFacilityWarnText(ornamentId)
	local facilityInfo = pg.me.space.facility[ornamentId]

	if not facilityInfo then
		return ""
	end

	local facilityStateInfo = facilityInfo.facilityStateInfo
	local facilityState = facilityInfo.facilityState

	if not facilityStateInfo or facilityStateInfo.ptype ~= Const.HOMELAND_PRODUCE_TYPE.ENV then
		return ""
	end

	if facilityInfo.disable then
		return pg.getGameString("HOMELAND_PAUSING")
	end

	local hasWorker = false

	for _, playerOperInfo in pairs(pg.space.playerAllocation) do
		if playerOperInfo.ornamentId == ornamentId and playerOperInfo.opId == facilityState then
			hasWorker = true

			break
		end
	end

	if not hasWorker then
		local relatedPets = pg.space.facilityAllocationInfo[ornamentId]

		if relatedPets then
			for _, petId in ipairs(relatedPets) do
				local allocation = pg.me.space.allocation[petId]

				if allocation and allocation.opId == facilityState then
					hasWorker = true

					break
				end
			end
		end
	end

	if not hasWorker then
		return pg.getGameString("HOMELAND_NO_WORKLOAD")
	end
end

function PlotDetailEnvironmentComponent:refreshPlotDetailEnvironment(ornamentInfo)
	if not ornamentInfo then
		return
	end

	self.ornamentInfo = ornamentInfo

	if not self.uWidget:CheckURLLoaded() then
		return
	end

	local envInfo = self.model:getEnvFacilityInfo(ornamentInfo.homeId)
	local effectName = self:getEnvEffectName(envInfo.facilityType)

	ClientTextUtils.setText(self.txtNameUSDFText, effectName)

	local subType = PlotDetailEnvironmentComponent.ENV_FACILITY_TYPE[envInfo.facilityType] or 0

	self.uWidget.content:TryChangePage("FacilityType", subType)

	local stateText = self:getFacilityWarnText(ornamentInfo.ornamentId)

	self.txtStateUSDFText:SetActive(stateText ~= nil)

	if stateText then
		ClientTextUtils.setText(self.txtStateUSDFText, stateText)
	end

	if envInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		local electricList = {}
		local ornamentId = self.ornamentInfo.ornamentId
		local linkInfo = pg.me.space.homeLinkMap[ornamentId]
		local rate = 0
		local max = 0
		local current = 0
		local need = 0

		if linkInfo and linkInfo.groupId ~= 0 then
			local linkGroupInfo = pg.me.space.homeLinkGroupMap[linkInfo.groupId]

			if linkGroupInfo then
				local totalCost = linkGroupInfo.totalCost or 0
				local electricProduce = 0
				local maxProduce = 0

				for _, oid in ipairs(linkGroupInfo.mainOrnaments) do
					local facilityInfo = pg.me.space.facility[oid]

					if facilityInfo and facilityInfo.formulaId ~= 0 then
						local formulaData = HomelandFormulaData[facilityInfo.formulaId]

						maxProduce = maxProduce + formulaData.electricProduce

						if not facilityInfo.disable and formulaData.unitWorkload > 0 then
							local relatedPetList = pg.space.facilityAllocationInfo[oid]

							if relatedPetList then
								local totalWorkLoad = 0

								for _, petId in ipairs(relatedPetList) do
									local petAllocationInfo = pg.me.space.allocation[petId]

									if petAllocationInfo and petAllocationInfo.opId == facilityInfo.facilityState then
										totalWorkLoad = totalWorkLoad + petAllocationInfo.workload
									end
								end

								electricProduce = electricProduce + math.min(1, totalWorkLoad / formulaData.unitWorkload) * formulaData.electricProduce
							end
						end
					end
				end

				local realProduce = math.min((HomelandConfigData.electricMaxWorkRate or 1) * totalCost, electricProduce)

				if realProduce > 0 then
					rate = math.floor(realProduce / totalCost * 100)
				end

				max = maxProduce
				current = math.floor(electricProduce)
				need = totalCost
			end
		end

		table.insert(electricList, {
			rate = rate,
			max = max,
			current = current,
			need = need
		})
		self.listUList:SetList(electricList)
	elseif envInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate or envInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
		if envInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
			ClientTextUtils.setText(self.btnLowUSDFText, pg.getGameString("TEMPERATURE_WARM"))
			ClientTextUtils.setText(self.btnHighUSDFText, pg.getGameString("TEMPERATURE_HOT"))
		elseif envInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
			ClientTextUtils.setText(self.btnLowUSDFText, pg.getGameString("TEMPERATURE_COLD"))
			ClientTextUtils.setText(self.btnHighUSDFText, pg.getGameString("TEMPERATURE_FROZEN"))
		end

		local facilityInfo = pg.me.space.facility[self.ornamentInfo.ornamentId]

		self.toggleTabUWidget:TryChangePage("StateTab", facilityInfo.envParam == 1 and 0 or 1)
	end
end

function PlotDetailEnvironmentComponent:onEnterPage()
	if not self.uWidget:CheckURLLoaded() then
		return
	end
end

return PlotDetailEnvironmentComponent
