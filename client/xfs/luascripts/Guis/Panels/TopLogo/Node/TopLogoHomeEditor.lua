-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoHomeEditor.lua

local Class = require("Core.Framework.Class")
local TopLogoItemBase = require("Guis.Panels.TopLogo.Node.TopLogoItemBase")
local AddressDataConst = require("Const.AddressDataConst")
local SysConfigData = require("Data.sys_config_data")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeObjectData = require("Data.home_object_data")
local Const = require("Common.Const.Const")
local HomelandFormulaData = require("Data.homeland_formula_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomelandOperateData = require("Data.homeland_operate_data")
local TopLogoHomeEditor = Class.LightClass("TopLogoHomeEditor", TopLogoItemBase)
local RequireType = {
	PetAbility = 4,
	Light = 3,
	Temperature = 2,
	Electric = 1
}
local DemandType = {
	Recommend = 3,
	DemandFit = 2,
	RecommendFit = 1,
	Demand = 4
}

function TopLogoHomeEditor:ctor(entity, topLogoHelper)
	TopLogoHomeEditor.super.ctor(self, topLogoHelper)

	self.entity = entity
	self.resId = AddressDataConst.HOME_EDITOR_TOPLOGO_RESID
	self.envRequireList = {}
	self.petRequireList = {}
	self.recommendData = {}
	self.demandData = {}
end

function TopLogoHomeEditor:getTopLogoName()
	if not self.entity or not self.entity.actorId then
		return "TopLogoHomeEditor_Template"
	end

	return "TopLogoHomeEditor_" .. self.entity.actorId
end

function TopLogoHomeEditor:initTopLogoAttach()
	self:setTopLogoAttachTrans()
end

function TopLogoHomeEditor:refreshTopLogoItemOnLoaded()
	if not self.templateId then
		return
	end

	self:refreshEditorTopLogoInfo()
end

function TopLogoHomeEditor:onTopLogoReset()
	if self.demandList then
		self.demandList:SetList({})

		self.demandList = nil
	end

	if self.demandRoot then
		self.demandRoot:TryChangePage("Condition", 4)

		self.demandRoot = nil
	end
end

function TopLogoHomeEditor:getTopLogoHeight()
	local modelHeight = self.entity:getHeight() + SysConfigData.toplogoOffset

	return modelHeight
end

function TopLogoHomeEditor:setTopLogoAttachTrans()
	local eModel = self.entity.eModel

	if eModel == nil then
		return
	end

	if NotNil(self.topLogoScript) then
		local offset = self:getTopLogoHeight()

		self.topLogoScript:AttachToEntity(eModel)

		local worldOffset = Vector3(0, offset or 0, 0)

		self.topLogoScript:SetOffset(worldOffset, Vector2.zero)
	end
end

function TopLogoHomeEditor:findObjects()
	if self.objectReference then
		self.demandRoot = self.objectReference:GetRefValue("demandRoot")
		self.demandObjectRef = self.demandRoot:GetComponent("ObjectReference")
		self.demandList = self.demandObjectRef:GetRefValue("requireList")

		LuaUIUtils.setUIVisible(self.demandRoot, false)

		function self.demandList.luaRenderItem(button, idx, data)
			self:rendererRequireItem(button, idx, data)
		end

		function self.demandList.luaSetToPool(button)
			button:TryChangePage("Condition", 4)
		end
	end
end

function TopLogoHomeEditor:refreshInfoIfDirty()
	if self.gameObject and self.editorInfoDirty then
		self:refreshEditorTopLogoInfo()
	end
end

function TopLogoHomeEditor:refreshEditorTopLogoInfo()
	if not self.gameObject then
		return
	end

	self:refreshRequireList()

	self.editorInfoDirty = false
end

function TopLogoHomeEditor:setTopLogoBaseInfo(templateId, formulaId, operationId, ornamentInfo)
	local changed = false

	if self.templateId ~= templateId then
		self.templateId = templateId
		changed = true
	end

	if self.formulaId ~= formulaId then
		self.formulaId = formulaId
		changed = true
	end

	if self.operationId ~= operationId then
		self.operationId = operationId
		changed = true
	end

	self.ornamentInfo = ornamentInfo

	local electricMode = self.ornamentInfo.electricMode

	if self.electricMode ~= electricMode then
		self.electricMode = electricMode
		changed = true
	end

	if changed then
		self.editorInfoDirty = true
	end
end

function TopLogoHomeEditor:refreshRequireList()
	self:refreshEnvRequireList()
	self:refreshOpRequireList()
	table.clear(self.recommendData)
	table.clear(self.demandData)

	local recommendFit = true
	local demandFit = true

	for _, v in ipairs(self.envRequireList) do
		if v.dType == DemandType.DemandFit then
			table.insert(self.demandData, v)
		elseif v.dType == DemandType.Demand then
			demandFit = false

			table.insert(self.demandData, v)
		elseif v.dType == DemandType.RecommendFit then
			table.insert(self.recommendData, v)
		elseif v.dType == DemandType.Recommend then
			recommendFit = false

			table.insert(self.recommendData, v)
		end
	end

	for _, v in ipairs(self.petRequireList) do
		if v.dType == DemandType.DemandFit then
			table.insert(self.demandData, v)
		elseif v.dType == DemandType.Demand then
			demandFit = false

			table.insert(self.demandData, v)
		elseif v.dType == DemandType.RecommendFit then
			table.insert(self.recommendData, v)
		elseif v.dType == DemandType.Recommend then
			recommendFit = false

			table.insert(self.recommendData, v)
		end
	end

	local hideIfFit = false

	if recommendFit and demandFit and not pg.game.home.editor.isInEditMode then
		hideIfFit = true
	end

	if #self.demandData <= 0 and #self.recommendData <= 0 or hideIfFit then
		LuaUIUtils.setUIVisible(self.demandRoot, false)
	else
		LuaUIUtils.setUIVisible(self.demandRoot, true)

		if not demandFit then
			self.demandRoot:TryChangePage("Condition", "Demand")
			self.demandList:SetList(self.demandData)
		elseif #self.recommendData > 0 then
			self.demandList:SetList(self.recommendData)

			if recommendFit then
				self.demandRoot:TryChangePage("Condition", "MeetRecommendation")
			else
				self.demandRoot:TryChangePage("Condition", "Recommend")
			end
		else
			self.demandList:SetList(self.demandData)
			self.demandRoot:TryChangePage("Condition", "MeetDemand")
		end
	end
end

function TopLogoHomeEditor:markDirty()
	self.editorInfoDirty = true
end

function TopLogoHomeEditor:setEnvSimulateInfo(isElectricLink, temperature, light, hasEntDoOper, entOperFit)
	local changed = false

	if self.isElectricLink ~= isElectricLink then
		self.isElectricLink = isElectricLink
		changed = true
	end

	if self.temperature ~= temperature then
		self.temperature = temperature
		changed = true
	end

	if self.light ~= light then
		self.light = light
		changed = true
	end

	if self.hasEntDoOper ~= hasEntDoOper or self.entOperFit ~= entOperFit then
		self.hasEntDoOper = hasEntDoOper
		self.entOperFit = entOperFit
		changed = true
	end

	if changed then
		self.editorInfoDirty = true
	end
end

function TopLogoHomeEditor:refreshOpRequireList()
	table.clear(self.petRequireList)

	if self.operationId and self.operationId ~= 0 then
		local homeOperationData = HomelandOperateData[self.operationId]
		local homeAbility = homeOperationData.homeAbility

		if homeAbility then
			local petAbilityInfo = {
				tIndex = 1,
				rType = RequireType.PetAbility,
				homeAbilityId = homeAbility[1],
				level = homeAbility[2]
			}

			if homeOperationData.needLevelFit then
				if self.hasEntDoOper then
					petAbilityInfo.dType = DemandType.DemandFit
				else
					petAbilityInfo.dType = DemandType.Demand
				end
			elseif self.entOperFit then
				petAbilityInfo.dType = DemandType.RecommendFit
			else
				petAbilityInfo.dType = DemandType.Recommend
			end

			table.insert(self.petRequireList, petAbilityInfo)
		end
	end
end

function TopLogoHomeEditor:refreshEnvRequireList()
	table.clear(self.envRequireList)

	if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq or self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		local demandType

		if self.isElectricLink then
			demandType = DemandType.DemandFit
		else
			demandType = DemandType.Demand
		end

		table.insert(self.envRequireList, {
			tIndex = 0,
			rType = RequireType.Electric,
			dType = demandType
		})
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		if self.electricMode then
			local demandType

			if self.isElectricLink then
				demandType = DemandType.DemandFit
			else
				demandType = DemandType.Demand
			end

			table.insert(self.envRequireList, {
				tIndex = 0,
				rType = RequireType.Electric,
				dType = demandType
			})
		end
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire and self.formulaId then
		local formulaData = HomelandFormulaData[self.formulaId]
		local lightRequireInfo, temperatureRequireInfo

		if formulaData and formulaData.lightRequire then
			lightRequireInfo = {
				tIndex = 0,
				rType = RequireType.Light,
				level = formulaData.lightRequire
			}

			if formulaData.forceEnvRequire then
				if self.light == formulaData.lightRequire then
					lightRequireInfo.dType = DemandType.DemandFit
				else
					lightRequireInfo.dType = DemandType.Demand
				end
			elseif math.abs(self.light - formulaData.lightRequire) > 2 then
				lightRequireInfo.dType = DemandType.Demand
			elseif self.light == formulaData.lightRequire then
				lightRequireInfo.dType = DemandType.RecommendFit
			else
				lightRequireInfo.dType = DemandType.Recommend
			end
		end

		if formulaData and formulaData.temperatureRequire then
			temperatureRequireInfo = {
				tIndex = 0,
				rType = RequireType.Temperature,
				level = formulaData.temperatureRequire
			}

			if formulaData.forceEnvRequire then
				if self.temperature == formulaData.temperatureRequire then
					temperatureRequireInfo.dType = DemandType.DemandFit
				else
					temperatureRequireInfo.dType = DemandType.Demand
				end
			elseif math.abs(self.temperature - formulaData.temperatureRequire) > 2 then
				temperatureRequireInfo.dType = DemandType.Demand
			elseif self.temperature == formulaData.temperatureRequire then
				temperatureRequireInfo.dType = DemandType.RecommendFit
			else
				temperatureRequireInfo.dType = DemandType.Recommend
			end
		end

		if lightRequireInfo then
			table.insert(self.envRequireList, lightRequireInfo)
		end

		if temperatureRequireInfo then
			table.insert(self.envRequireList, temperatureRequireInfo)
		end
	end
end

function TopLogoHomeEditor:rendererRequireItem(button, idx, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local numLevelUSDFText = objectReference:GetRefValue("numLevelUSDFText")

		if data.rType == RequireType.Electric then
			button:TryChangePage("Type", 0)
		elseif data.rType == RequireType.Light then
			button:TryChangePage("Type", 2)
		elseif data.rType == RequireType.Temperature then
			if data.level > 0 then
				button:TryChangePage("Type", 1)
			else
				button:TryChangePage("Type", 3)
			end
		end

		if data.level then
			ClientTextUtils.setText(numLevelUSDFText, math.abs(data.level))
		else
			ClientTextUtils.setText(numLevelUSDFText, "")
		end

		if data.dType == DemandType.DemandFit then
			button:TryChangePage("Condition", 3)
		elseif data.dType == DemandType.Demand then
			button:TryChangePage("Condition", 2)
		elseif data.dType == DemandType.RecommendFit then
			button:TryChangePage("Condition", 1)
		elseif data.dType == DemandType.Recommend then
			button:TryChangePage("Condition", 0)
		end
	else
		LuaUIUtils.renderHomeAbility(button, data.homeAbilityId, data.level)

		if data.dType == DemandType.DemandFit then
			button:TryChangePage("Condition", "MeetRecommendation")
		elseif data.dType == DemandType.Demand then
			button:TryChangePage("Condition", "Demand")
		elseif data.dType == DemandType.RecommendFit then
			button:TryChangePage("Condition", "MeetRecommendation")
		elseif data.dType == DemandType.Recommend then
			button:TryChangePage("Condition", "Recommend")
		end
	end
end

return TopLogoHomeEditor
