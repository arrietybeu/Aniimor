-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotSpeedUpComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local HomeObjectData = require("Data.home_object_data")
local HomeFacilityData = require("Data.homeland_facility_data")
local PlotSpeedUpComponent = Class.LightClass("PlotSpeedUpComponent", UIComponent)
local BATCH_LIMIT = 100

function PlotSpeedUpComponent:findObjects()
	return
end

function PlotSpeedUpComponent:initView()
	self.selectedOrnaments = {}

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshSelection()
	end)
end

function PlotSpeedUpComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.listPlotUList = objectReference:GetRefValue("listPlotUList")
	self.listCostUList = objectReference:GetRefValue("listCostUList")
	self.btnAllSelectedUButton = objectReference:GetRefValue("btnAllSelectedUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleCostUSDFText = objectReference:GetRefValue("txtTitleCostUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.confirmUSDFText = objectReference:GetRefValue("confirmUSDFText")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
end

function PlotSpeedUpComponent:addListener()
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("HOME_ACCELERATE_SELECT_ALL"))
	ClientTextUtils.setText(self.txtTitleCostUSDFText, pg.getGameString("CONSUME_LABEL"))
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("HOME_ACCELERATE_BATCH"))
	ClientTextUtils.setText(self.confirmUSDFText, pg.getGameString("HOME_ACCELERATE"))
	ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("HOMELAND_SPEED_EMPTY"))

	function self.btnCloseUButton.luaClick()
		self.ctrl:exitOrnamentGridMultipleMode()
	end

	function self.btnAllSelectedUButton.luaClick()
		self.ctrl:selectAllOrnamentGridMultiple(not self.btnAllSelectedUButton.isSelected, true)
	end

	function self.btnConfirmUButton.luaClick()
		self:submitSpeedUp()
	end

	function self.listPlotUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local item96UButton = objectReference:GetRefValue("item96UButton")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		LuaUIUtils.renderCostItem(item96UButton, {
			showNum = true,
			id = data.itemId,
			num = data.ownedCount,
			costNum = data.costNum
		})
		ClientTextUtils.setText(txtNameUSDFText, string.format("%s×%d", data.name, data.count))
	end

	function self.listCostUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderCostItem(button, data)
	end
end

function PlotSpeedUpComponent:onEnterPage()
	self.selectedOrnaments = {}

	self:refreshSelection()
end

function PlotSpeedUpComponent:setSelectedOrnaments(ornamentIds)
	self.selectedOrnaments = {}

	for ornamentId in pairs(ornamentIds) do
		self.selectedOrnaments[ornamentId] = true
	end

	self:refreshSelection()
end

function PlotSpeedUpComponent:refreshSelection()
	if not self.listPlotUList then
		return
	end

	local plotMap = {}
	local costMap = {}
	local itemNameMap = {}
	local selectedOrnamentIds = {}

	for ornamentId in pairs(self.selectedOrnaments) do
		local ornamentInfo = pg.me.space.ornament[ornamentId]
		local accelerateInfo = ClientHomelandUtils.getProduceAccelerateInfo(ornamentId)

		if ornamentInfo and accelerateInfo then
			selectedOrnamentIds[#selectedOrnamentIds + 1] = ornamentId

			local itemId = accelerateInfo.itemId
			local facilityType = Utils.getHomeOrnamentCurLevelInfo(ornamentInfo.homeId) or ornamentInfo.homeId
			local plotInfo = plotMap[facilityType]

			if not plotInfo then
				local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
				local facilityData = HomeFacilityData[facilityId] or {}
				local homeObjectData = HomeObjectData[ornamentInfo.homeId] or {}

				plotInfo = {
					count = 0,
					costNum = 0,
					type = facilityType,
					itemId = itemId,
					ownedCount = accelerateInfo.ownedCount,
					name = pg.getLocalizationText(facilityData.typeName or homeObjectData.name)
				}
				plotMap[facilityType] = plotInfo
			end

			plotInfo.count = plotInfo.count + 1
			plotInfo.costNum = plotInfo.costNum + accelerateInfo.costNum
			costMap[itemId] = (costMap[itemId] or 0) + accelerateInfo.costNum
			itemNameMap[itemId] = accelerateInfo.itemName
		end
	end

	local plotList = {}

	for _, plotInfo in pairs(plotMap) do
		plotList[#plotList + 1] = plotInfo
	end

	table.sort(plotList, function(a, b)
		return a.type < b.type
	end)
	table.sort(selectedOrnamentIds)

	local costList = {}

	for itemId, costNum in pairs(costMap) do
		costList[#costList + 1] = {
			showNum = true,
			id = itemId,
			num = ClientUtils.getItemCountById(itemId) + ClientUtils.getHomelandItemCountById(itemId),
			costNum = costNum
		}
	end

	table.sort(costList, function(a, b)
		return a.id < b.id
	end)

	local itemNames = {}

	for _, costInfo in ipairs(costList) do
		itemNames[#itemNames + 1] = itemNameMap[costInfo.id]
	end

	self.plotList = plotList
	self.costList = costList
	self.accelerateItemNameText = table.concat(itemNames, "、")
	self.selectedOrnamentIds = selectedOrnamentIds

	self.listPlotUList:SetList(plotList)
	self.listCostUList:SetList(costList)
	self.uWidget.content:TryChangePage("Empty", #plotList > 0 and 0 or 1)

	self.btnAllSelectedUButton.isSelected = self.ctrl.canMultipleCount > 0 and self.ctrl.multipleCount >= self.ctrl.canMultipleCount
	self.btnConfirmUButton.interactable = #selectedOrnamentIds > 0
end

function PlotSpeedUpComponent:submitSpeedUp()
	self.ctrl:refreshSpeedUpCandidates()

	if #self.selectedOrnamentIds == 0 then
		return
	end

	for _, costInfo in ipairs(self.costList) do
		if costInfo.num < costInfo.costNum then
			pg.global.showBubbleMessage(NoticeDef.ITEM_USE_OUT)

			return
		end
	end

	ClientHomelandUtils.showProduceAccelerateConfirm(self.accelerateItemNameText, function()
		self.btnConfirmUButton.interactable = false

		local requestSignatures = self.ctrl:getSpeedUpWaitSignatures(self.selectedOrnamentIds)

		pg.me.space:batchAccelerateHomelandPlant(self.selectedOrnamentIds, function(code, results)
			self.ctrl:onBatchSpeedUpResult(code, results, requestSignatures)
		end)
	end)
end

return PlotSpeedUpComponent
