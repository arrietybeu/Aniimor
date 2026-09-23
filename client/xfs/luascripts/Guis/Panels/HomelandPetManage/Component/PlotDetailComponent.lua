-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotDetailComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlotDetailComponent")
local Class = require("Core.Framework.Class")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PlotDetailComponent = Class.LightClass("PlotDetailComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlotDetailRecipeComponent = require("Guis.Panels.HomelandPetManage.Component.PlotDetailRecipeComponent")
local PlotDetailManageComponent = require("Guis.Panels.HomelandPetManage.Component.PlotDetailManageComponent")
local PlotDetailUpgradeComponent = require("Guis.Panels.HomelandPetManage.Component.PlotDetailUpgradeComponent")
local PlotDetailEnvironmentComponent = require("Guis.Panels.HomelandPetManage.Component.PlotDetailEnvironmentComponent")
local MessageName = require("Const.MessageName")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local HomeObjectData = require("Data.home_object_data")

PlotDetailComponent.messages = {
	[MessageName.HOMELAND_FACILITY_DISABLE_CHANGED] = {
		"onFacilityDisableChanged",
		true
	}
}

function PlotDetailComponent:findObjects()
	return
end

function PlotDetailComponent:initView()
	self.selectType = -1
	self.tabList = {}

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()

		self.plotDetailRefreshTimer = self:startTimer(function()
			self:updatePlotDetail()
		end, 0.5, true)
	end)
end

function PlotDetailComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.btnRecipeUButton = objectReference:GetRefValue("btnRecipeUButton")
	self.btnManageUButton = objectReference:GetRefValue("btnManageUButton")
	self.btnUpgradeUButton = objectReference:GetRefValue("btnUpgradeUButton")
	self.txtRecipeUButton = objectReference:GetRefValue("txtRecipeUButton")
	self.txtManageUButton = objectReference:GetRefValue("txtManageUButton")
	self.txtUpgradeUButton = objectReference:GetRefValue("txtUpgradeUButton")
	self.btnUButton = objectReference:GetRefValue("btnUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.iconPlotUImage = objectReference:GetRefValue("iconPlotUImage")
	self.txtPlotUImage = objectReference:GetRefValue("txtPlotUImage")
	self.txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
	self.recipeUContainer = objectReference:GetRefValue("recipeUContainer")
	self.manageUContainer = objectReference:GetRefValue("manageUContainer")
	self.upgradeUContainer = objectReference:GetRefValue("upgradeUContainer")
	self.environmentUContainer = objectReference:GetRefValue("environmentUContainer")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.tabNewUWidget = objectReference:GetRefValue("tabNewUWidget")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.txtSwitchUSDFText = objectReference:GetRefValue("txtSwitchUSDFText")
end

function PlotDetailComponent:refreshPlotDetailBox(ornamentInfo)
	self.ornamentInfo = ornamentInfo

	if Utils.isHomeEnvFacility(ornamentInfo.homeId) then
		self.iconPlotUImage.url = ornamentInfo.iconId
	else
		self.iconPlotUImage.url = ornamentInfo.iconId
	end

	local configData = HomeObjectData[ornamentInfo.homeId] or {}
	local name = pg.getLocalizationText(configData.name)

	ClientTextUtils.setText(self.txtPlotUImage, name)

	self.plotDetailRecipe.selectFormulaId = nil

	self:refreshSwitchBtn()
	self:refreshTabList()
	self:refreshPasueBtn()
end

function PlotDetailComponent:refreshTabList()
	self.tabList = self:getTabListInfo()

	if #self.tabList == 0 then
		self.uWidget.content:TryChangePage("Empty", 1)
	else
		self.uWidget.content:TryChangePage("Empty", 0)
		self.tabNewUWidget:SetActive(true)
		self.listTabUList:SetList(self.tabList)

		local selectIndex = self:haveSelectType(self.tabList) or 0
		local res, button = self.listTabUList:TryGetChildAt(selectIndex)

		if res then
			button:OnClickSimulate()
		end
	end

	self.tabNewUWidget:SetActive(#self.tabList > 1)
end

function PlotDetailComponent:haveSelectType(tabList)
	for index, info in ipairs(tabList) do
		if self.selectType == info.selectType then
			return index - 1
		end
	end

	return nil
end

function PlotDetailComponent:getTabListInfo()
	local res = {}
	local ornamentInfo = self.ornamentInfo
	local facilityInfo = pg.me.space.facility[ornamentInfo.ornamentId]
	local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)

	if self.model:canHomeObjectEnvironment(self.ornamentInfo.homeId) then
		table.insert(res, {
			text = "QUEST_DELEGATION_DETAIL",
			func = "onEnvironmentClick",
			selectType = 3
		})
	end

	if self.model:canHomeObjectSwitchFormula(self.ornamentInfo.homeId) then
		table.insert(res, {
			text = "HOME_FORMULA_LEVEL_PRODUCT",
			func = "onRecipeClick",
			selectType = 0
		})
	end

	table.insert(res, {
		text = "HOMELAND_PLOT_MANAGE",
		func = "onManageClick",
		selectType = 1
	})

	if self.model:canHomeObjectUpgrade(self.ornamentInfo.homeId) then
		table.insert(res, {
			text = "UPGRADE",
			func = "onUpgradeClick",
			selectType = 2
		})
	end

	if #res == 1 then
		res[1].tIndex = 1
	elseif #res == 2 then
		res[1].tIndex = 0
		res[2].tIndex = 2
	elseif #res >= 3 then
		res[1].tIndex = 0

		for idx = 2, #res - 1 do
			res[idx].tIndex = 1
		end

		res[#res].tIndex = 2
	end

	return res
end

function PlotDetailComponent:refreshPlotDetailInfo(ornamentId, forceRefresh)
	if not self.ornamentInfo or not ornamentId then
		return
	end

	local configData = HomeObjectData[self.ornamentInfo.homeId] or {}
	local name = pg.getLocalizationText(configData.name)

	ClientTextUtils.setText(self.txtPlotUImage, name)

	if ornamentId == self.ornamentInfo.ornamentId then
		if self.selectType == 0 then
			self.plotDetailRecipe:refreshPlotDetailRecipe(self.ornamentInfo, forceRefresh)
		elseif self.selectType == 1 then
			self.plotDetailManage:refreshPlotDetailManage(self.ornamentInfo)
		elseif self.selectType == 2 then
			self.plotDetailUpgrade:refreshPlotDetailUpgrade(self.ornamentInfo)
		elseif self.selectType == 3 then
			self.plotDetailEnvironment:refreshPlotDetailEnvironment(self.ornamentInfo)
		end
	end
end

function PlotDetailComponent:refreshPasueBtn()
	local facilityInfo = pg.me.space.facility[self.ornamentInfo.ornamentId]
	local showPauseBtn = true
	local facilityType = Utils.getHomeFacilityType(self.ornamentInfo.homeId)

	if Utils.isHomeHatchBox(self.ornamentInfo.homeId) or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink or self.ornamentInfo.homeId == Const.STORE_ORNAMENT_ID then
		showPauseBtn = false
	end

	if HomeLandUtils.isFieldOrWoodland(self.ornamentInfo.homeId) then
		showPauseBtn = false
	end

	self.btnUButton:SetActive(showPauseBtn)

	if facilityInfo then
		local isPause = facilityInfo.disable

		if isPause then
			self.btnUButton:TryChangePage("Play", 0)
			ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("HOMELAND_PLOT_OPEN"))
		else
			self.btnUButton:TryChangePage("Play", 1)
			ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("HOMELAND_PLOT_PAUSE"))
		end
	end
end

function PlotDetailComponent:getElectricModeSwitchEntity(ornamentInfo)
	if not ornamentInfo or Utils.getHomeFacilityType(ornamentInfo.homeId) ~= Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		return nil
	end

	local entity = pg.game.home:getHomeEntity(self.ornamentInfo.ornamentId)

	if not entity then
		return nil
	end

	if ornamentInfo.electricMode then
		return entity:canDisableElectricMode() and entity or nil
	end

	return entity:canEnableElectricMode() and entity or nil
end

function PlotDetailComponent:refreshSwitchBtn()
	local ornamentInfo = pg.me.space.ornament[self.ornamentInfo.ornamentId]
	local electricMode = ornamentInfo and ornamentInfo.electricMode == true or false
	local entity = self:getElectricModeSwitchEntity(ornamentInfo)

	self.btnSwitchUButton:SetActive(entity ~= nil)
	self.btnSwitchUButton:TryChangePage("Switch", electricMode and 1 or 0)

	if ornamentInfo then
		self.ornamentInfo.electricMode = electricMode
	end
end

function PlotDetailComponent:onElectricModeChanged(ornamentId)
	if not self.ornamentInfo or ornamentId ~= self.ornamentInfo.ornamentId then
		return
	end

	self:refreshSwitchBtn()

	if self.selectType == 0 then
		self.plotDetailRecipe:refreshPlotDetailRecipe(self.ornamentInfo, true)
	end
end

function PlotDetailComponent:onFacilityDisableChanged(ornamentId)
	if not self.ornamentInfo or ornamentId ~= self.ornamentInfo.ornamentId then
		return
	end

	self:refreshPasueBtn()
end

function PlotDetailComponent:onRecipeClick()
	self.uWidget.content:TryChangePage("Tab", 0)
	self.uWidget.content:TryChangePage("Empty", 0)

	self.selectType = 0

	self:refreshPlotDetailInfo(self.ornamentInfo.ornamentId, true)
	self.plotDetailRecipe:onEnterPage()
end

function PlotDetailComponent:onManageClick()
	self.uWidget.content:TryChangePage("Tab", 1)

	local facilityInfo = pg.me.space.facility[self.ornamentInfo.ornamentId]
	local canPlacePet = self.model:canHomeObjectPlacePet(self.ornamentInfo.homeId, facilityInfo)

	self.uWidget.content:TryChangePage("Empty", canPlacePet and 0 or 1)

	if not canPlacePet and self.txtEmptyUSDFText then
		ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("WORK_NOT_REQUIRED"))
	end

	self.selectType = 1

	self:refreshPlotDetailInfo(self.ornamentInfo.ornamentId)
	self:exitMultipleMode()
end

function PlotDetailComponent:onUpgradeClick()
	self.uWidget.content:TryChangePage("Tab", 2)
	self.uWidget.content:TryChangePage("Empty", 0)

	self.selectType = 2

	self:refreshPlotDetailInfo(self.ornamentInfo.ornamentId)
	self:exitMultipleMode()
end

function PlotDetailComponent:onEnvironmentClick()
	self.uWidget.content:TryChangePage("Tab", 3)
	self.uWidget.content:TryChangePage("Empty", 0)

	self.selectType = 3

	self:refreshPlotDetailInfo(self.ornamentInfo.ornamentId)
	self:exitMultipleMode()
end

function PlotDetailComponent:startMultipleMode(formulaId)
	self.ctrl:refreshOrnamentGridMultipleMode(Const.HOMELAND_MULTIPLE_MODE.Formula, self.ornamentInfo.ornamentId, formulaId)
end

function PlotDetailComponent:exitMultipleMode()
	self.ctrl:exitOrnamentGridMultipleMode()
end

function PlotDetailComponent:selectAllMultiple(selectAll, isBtn)
	self.ctrl:selectAllOrnamentGridMultiple(selectAll, isBtn)
end

function PlotDetailComponent:getMultipleOrnamentTableAndCount()
	return self.ctrl.isMultipleOrnamentTable, self.ctrl.multipleCount
end

function PlotDetailComponent:addListener()
	self.plotDetailRecipe = PlotDetailRecipeComponent.new(self, self.recipeUContainer)
	self.plotDetailManage = PlotDetailManageComponent.new(self, self.manageUContainer)
	self.plotDetailUpgrade = PlotDetailUpgradeComponent.new(self, self.upgradeUContainer)
	self.plotDetailEnvironment = PlotDetailEnvironmentComponent.new(self, self.environmentUContainer)

	function self.btnCloseUButton.luaClick()
		self.ctrl:changeSelectornamen(nil)
	end

	function self.btnUButton.luaClick()
		local facilityInfo = pg.me.space.facility[self.ornamentInfo.ornamentId]

		if not facilityInfo then
			return
		end

		if facilityInfo.disable then
			pg.space:setProduceDisable(self.ornamentInfo.ornamentId, false)
		else
			pg.space:setProduceDisable(self.ornamentInfo.ornamentId, true)
		end
	end

	function self.btnSwitchUButton.luaClick()
		local ornamentInfo = pg.me.space.ornament[self.ornamentInfo.ornamentId]
		local entity = self:getElectricModeSwitchEntity(ornamentInfo)

		if not entity then
			return
		end

		entity:setEnableElectricMode(not ornamentInfo.electricMode)
	end

	function self.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(nameText, pg.getGameString(data.text))
	end

	function self.listTabUList.luaClick(button, data)
		if data.func then
			self[data.func](self)
		end
	end

	ClientTextUtils.setText(self.txtSwitchUSDFText, pg.getGameString("CONSOLE_BAR_SWITCH"))
end

function PlotDetailComponent:updatePlotDetail()
	if self.ornamentInfo ~= nil then
		local tabList = self:getTabListInfo()

		if #tabList ~= #self.tabList then
			self:refreshTabList()
		end

		if self.selectType == 0 then
			self.plotDetailRecipe:updatePlotDetailRecipe(self.ornamentInfo)
		end
	end
end

function PlotDetailComponent:onDestroy()
	self.selectType = -1
	self.tabList = {}

	if self.plotDetailRefreshTimer then
		self:killTimer(self.plotDetailRefreshTimer)
	end

	self.plotDetailRefreshTimer = nil

	UIComponent.onDestroy(self)
end

function PlotDetailComponent:onEnterPage()
	return
end

return PlotDetailComponent
