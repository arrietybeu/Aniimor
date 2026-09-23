-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetOverview\\PetOverviewCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetOverviewCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetProtoTypeData = require("Data.pet_prototype_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local PetOverviewCtrl = Class.LightClass("PetOverviewCtrl", UICtrl)

PetOverviewCtrl.messages = {}

function PetOverviewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petsData = {}
	self.petNumInfos = {}
	self.needRefreshListMask = false
end

function PetOverviewCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnShareUButton.luaClick()
		return
	end

	function self.view.btnSwitchUButton.luaClick()
		self:switchShowTab()
	end

	function self.view.listPetUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local groupUList = objectReference:GetRefValue("groupUList")

		groupUList.groupType = self.disableSelectState and CS.XGUI.EGroupType.None or CS.XGUI.EGroupType.Radio

		function groupUList.luaRenderItem(groupBtn, groupIndex, groupData)
			self:_renderPetGroup(groupBtn, groupIndex, groupData)
		end

		groupUList:SetList(data.groupData)
	end

	function self.view.listPetUList.luaFinishRender()
		self:_tryRefreshPetListMask()
	end

	function self.view.numInfoUList.luaRenderItem(numBtn, index, numData)
		local objectReference = numBtn:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local textUText = objectReference:GetRefValue("textUText")

		numBtn.tooltipId = pg.getGameString(numData.tooltipId)
		iconUImage.url = numData.icon

		ClientTextUtils.setText(textUText, numData.num)
	end

	self.view.btnShareUButton:SetActiveFastest(false)
end

function PetOverviewCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.selectBtn = nil
	self.checkShowMapView = nil
	self.clickFunc = nil
	self.exRenderFunc = nil
	self.switchTabCallback = nil
end

function PetOverviewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.areaId = info.areaId or PetResearchUtils.getLastPetResearchAreaId()
	self.showTab = info.showTab or PetResearchUtils.getLastPetShowTab()
	self.titleName = info.titleName or pg.getGameString("TITLE_OVERVIEW")
	self.enableTooltip = info.enableTooltip or false
	self.checkShowMapView = info.checkShowMapView
	self.clickFunc = info.clickFunc
	self.exRenderFunc = info.exRenderFunc
	self.disableSelectState = info.disableSelectState or false
	self.switchTabCallback = info.switchTabCallback

	self:refreshView()
end

function PetOverviewCtrl:onShow()
	return
end

function PetOverviewCtrl:onHide()
	return
end

function PetOverviewCtrl:refreshView()
	self.selectBtn = nil

	ClientTextUtils.setText(self.view.titleUSDFText, self.titleName)

	if self.petNumInfos[self.showTab] == nil then
		self.petNumInfos[self.showTab] = PetResearchUtils.getAreaPetCollectInfo(self.areaId, self.showTab)
	end

	self.view.numInfoUList:SetList(self.petNumInfos[self.showTab])

	if self.petsData[self.showTab] == nil then
		self.petsData[self.showTab] = self.model.getPetOverviewData(self.areaId, self.showTab)
	end

	self.needRefreshListMask = true

	self.view.listPetUList:SetList(self.petsData[self.showTab])
	self:_refreshBtnSwitch()
end

function PetOverviewCtrl:_tryRefreshPetListMask()
	if not self.needRefreshListMask then
		return
	end

	self.needRefreshListMask = false

	TimerManager.addNextFrameCb(function()
		if not self.view or not self.view.listPetUList then
			return
		end

		self.view.listPetUList:SetActive(false)
		self.view.listPetUList:SetActive(true)
	end)
end

function PetOverviewCtrl:switchShowTab()
	self.showTab = self.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and PetResearchUtils.PET_SHOW_TAB.FORM or PetResearchUtils.PET_SHOW_TAB.SPECIES

	if self.switchTabCallback then
		self.switchTabCallback(self.showTab)
	end

	self:refreshView()
end

function PetOverviewCtrl:_renderPetGroup(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgPetUImage = objectReference:GetRefValue("imgPetUImage")
	local btnMapViewUButton = objectReference:GetRefValue("btnMapViewUButton")
	local flashUContainer = objectReference:GetRefValue("flashUContainer")
	local displayTemplateId, label, shinyStyle = PetResearchUtils.getPetDisplayFormLabelTemplateId(data.templateId, self.showTab, self.areaId)
	local pData = PetProtoTypeData[displayTemplateId]

	if pData then
		imgPetUImage.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON, label)
	end

	if Utils.isLabelShiny(label) then
		flashUContainer:SetActive(true)

		if shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			flashUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_FLASH_OVERVIEW_WHITE)
		elseif shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			flashUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_FLASH_OVERVIEW_BLACK)
		else
			flashUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_FLASH_OVERVIEW)
		end
	else
		flashUContainer:SetActive(false)
	end

	button:SetSelected(false)

	button.enabledTooltip = self.enableTooltip

	local statePage = data.state - 1

	if data.state == PetResearchUtils.PET_STATE_IS_AllSTAR then
		statePage = PetResearchUtils.PET_STATE_IS_CATCH - 1
	end

	button:TryChangePage("State", statePage)

	if self.checkShowMapView then
		local showMapView = self.checkShowMapView(data)

		btnMapViewUButton:SetActiveFastest(showMapView)
	else
		btnMapViewUButton:SetActiveFastest(false)
	end

	function button.luaClick()
		if not self.disableSelectState then
			if self.selectBtn then
				self.selectBtn:SetSelected(false)
			end

			self.selectBtn = button

			self.selectBtn:SetSelected(true)
		end

		if self.clickFunc then
			self.clickFunc(data)
		end
	end

	if self.exRenderFunc then
		self.exRenderFunc(button, index, data, self.showTab)
	end
end

function PetOverviewCtrl:_refreshBtnSwitch()
	local isSpecies = self.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES
	local pageId = isSpecies and 0 or 1

	self.view.rootView:TryChangePage("Type", pageId)
	ClientTextUtils.setText(self.view.btnSwitchNameUSDFText, pg.getGameString(PetResearchUtils.ShowTabName[self.showTab]))
end

return PetOverviewCtrl
