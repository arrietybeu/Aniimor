-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotPanelComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlotPanelComponent")
local Class = require("Core.Framework.Class")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PlotPanelComponent = Class.LightClass("PlotPanelComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Const = require("Common.Const.Const")
local HomelandAreaData = require("Data.homeland_area_data")

function PlotPanelComponent:findObjects()
	return
end

function PlotPanelComponent:initView()
	self.zoneInfo = nil

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPlotPanel(self.zoneInfo)

		if self.ctrl:isOrnamenMode() then
			self.uWidget.content:SetActive(false)
		end
	end)
end

function PlotPanelComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	self.listCoinUList = objectReference:GetRefValue("listCoinUList")
	self.btnOKUButton = objectReference:GetRefValue("btnOKUButton")
	self.txtUnLockNameUSDFText = objectReference:GetRefValue("txtUnLockNameUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.itemListUList = objectReference:GetRefValue("itemListUList")
	self.viewDetailUWidget = objectReference:GetRefValue("viewDetailUWidget")
	self.textUSDFText2 = objectReference:GetRefValue("textUSDFText2")
	self.btnViewUButton = objectReference:GetRefValue("btnViewUButton")
	self.txtViewInfoUSDFText = objectReference:GetRefValue("txtViewInfoUSDFText")
	self.btnOKHotKeyContent = objectReference:GetRefValue("btnOKHotKeyContent")
	self.btnViewHotKeyContent = objectReference:GetRefValue("btnViewHotKeyContent")
	self.picUImage = objectReference:GetRefValue("picUImage")

	local scrollRectobjectReference = self.scrollRectUScrollRect.content.transform:GetComponent("ObjectReference")

	self.detailTextUSDFText = scrollRectobjectReference:GetRefValue("detailTextUSDFText")
end

function PlotPanelComponent:addListener()
	ClientTextUtils.setText(self.txtUnLockNameUSDFText, pg.getGameString("ACCESSORY_UNLOCK"))
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("HOMELAND_PLOT_UNLOCK_REWARD"))
	ClientTextUtils.setText(self.textUSDFText2, pg.getGameString("HOMELAND_PLOT_UNLOCKED"))
	ClientTextUtils.setText(self.txtViewInfoUSDFText, pg.getGameString("ITEM_DETAIL_TEXT"))

	function self.btnCloseUButton.luaClick(button, data)
		self.ctrl:clearSelectornamen()
	end

	function self.btnOKUButton.luaClick(button, data)
		local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
		local zoneData = HomelandZoneUnlockConfigData[self.zoneInfo.level]

		if zoneData.canUnlock == nil or zoneData.canUnlock == 0 then
			pg.global.showBubbleMessage(NoticeDef.HOME_BLOCK_NOT_OPEN)

			return
		end

		for _, costInfo in pairs(zoneData.unlockCost) do
			local count = costInfo[2]
			local hasCount = ItemUtils.getItemCountById(pg.me, costInfo[1])

			if hasCount < count then
				local noticeId = self.ctrl.areaId == Const.HOMELAND_AREA_TYPE.BUILD and NoticeDef.HOMELAND_CANNOT_UNLOCK_AREA1 or NoticeDef.HOME_NOT_ENOUGH_PROPS

				pg.global.showBubbleMessage(noticeId)

				return
			end
		end

		pg.space:unlockHomelandZone(self.ctrl.selectLevel)
	end

	function self.btnViewUButton.luaClick(button, data)
		self.ctrl:changeViewMode(self.ctrl.VIEWMODE_TYPE.SmallOrnamen)
	end

	function self.listCoinUList.luaRenderItem(button, index, data)
		LuaUIUtils.setCostCurrencyItem(button, data.itemId, data.itemCount, true)
	end

	self.textUSDFText:SetActive(false)
	self.itemListUList:SetActive(false)
end

function PlotPanelComponent:refreshPlotPanel(data)
	if not data then
		return
	end

	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()

	self.zoneInfo = data

	local config = HomelandZoneUnlockConfigData[data.level]

	if not config or not self.uWidget:CheckURLLoaded() then
		return
	end

	self.uWidget.content:SetActive(true)
	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getLocalizationText(config.name))
	ClientTextUtils.setText(self.detailTextUSDFText, pg.getLocalizationText(config.desc))

	self.detailTextUSDFText.enabledHyperlink = true

	function self.detailTextUSDFText.luaOnHyperlinkClick(action, content, contentRect)
		LuaUIUtils.clickHyperText(action, content, contentRect)
	end

	self.listCoinUList:SetActive(data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlockable)
	self.btnOKUButton:SetActive(data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlockable)
	self.viewDetailUWidget:SetActive(data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlocked)
	self.btnViewUButton:SetActive(data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlocked and self.ctrl:canEnterPlotDetail())

	local areaData = HomelandAreaData[self.ctrl.areaId]

	self.picUImage.url = areaData.icon

	local costData = {}

	if data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlockable and config.unlockCost then
		for _, cost in ipairs(config.unlockCost) do
			local itemId = cost[1]
			local itemCount = cost[2]

			table.insert(costData, {
				itemId = itemId,
				itemCount = itemCount
			})
		end
	end

	self.listCoinUList:SetList(costData)
end

function PlotPanelComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PlotPanelComponent:onEnterPage()
	return
end

return PlotPanelComponent
