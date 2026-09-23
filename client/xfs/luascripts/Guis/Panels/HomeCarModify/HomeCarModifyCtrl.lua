-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarModify\\HomeCarModifyCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarModifyCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeCarModifyTypeData = require("Data.home_car_modify_type_data")
local HomeCarModifyData = require("Data.home_car_modify_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCarModifyCtrl = Class.LightClass("HomeCarModifyCtrl", UICtrl)

HomeCarModifyCtrl.messages = {
	[MessageName.HOME_CAR_UPGRADE_STATE_CHANGED] = {
		"onHomeCarUpgradeStateChanged",
		true
	}
}

function HomeCarModifyCtrl:onCreate(info)
	HomeCarModifyCtrl.super.onCreate(self, info)

	info = info or {}
	self.isModify = info.isModify
	self.basicInfo = info.basicInfo

	if not self.basicInfo then
		self.basicInfo = self:initDefaultBaseInfo()
	end

	if info.homeMainPage then
		self.homeMainPage = info.homeMainPage
	end

	self.shapeInfo = self.basicInfo.carShapeInfo
	self.modelLevel = HomeLandUtils.getHomeCarModelLevel(self.basicInfo.level)

	self:initHomeCarEntity()

	if self.uiScene then
		self.uiScene:changeCarRotate(true)
	end
end

function HomeCarModifyCtrl:onHomeCarUpgradeStateChanged()
	if not self:checkUIShow() then
		return
	end

	local homeCarInfo = HomeLandUtils.getHomeCarInfo()

	self.basicInfo.upgradeEndTs = homeCarInfo.upgradeEndTs

	self.uiScene:refreshHomeCar(self.basicInfo)
end

function HomeCarModifyCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:closePanel()
	end

	function self.view.confirmBtn.luaClick()
		self:confirm()
	end

	function self.view.itemList.luaRenderItem(button, index, data)
		self:rendererPartItem(button, index, data)
	end

	function self.view.listPointUList.luaRenderItem(button, index, data)
		self:rendererPointItem(button, index, data)
	end

	function self.view.tabList.luaRenderItem(button, index, data)
		self:rendererTabItem(button, index, data)
	end

	function self.view.tabList.luaSelectedChanged(uList, isSelected)
		local data = uList.selectedItem

		if data then
			self:selectTabType(data.tabId)

			if data.cameraType then
				self.uiScene:switchCamera(data.cameraType, self.modelLevel)
			end
		end
	end

	self.view.itemTitle:SetActive(false)
end

function HomeCarModifyCtrl:closePanel()
	if self.homeMainPage and not IsNil(self.homeMainPage.view.widget) then
		self.homeMainPage:refreshHomeCarInfo()
	end

	self.view.widget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
		self:close()
	end)
end

function HomeCarModifyCtrl:checkCommonQuit()
	if self.isModify then
		return true
	end

	return HomeCarModifyCtrl.super:checkCommonQuit(self)
end

function HomeCarModifyCtrl:onOpen(info)
	if self.isModify then
		self.view.btnBack:SetActive(true)
	else
		self.view.btnBack:SetActive(false)
	end

	self:initTabList()
end

function HomeCarModifyCtrl:initDefaultBaseInfo()
	local basicInfo = {}

	basicInfo.carShapeInfo = Utils.getDefaultCarShapeInfo()
	basicInfo.level = 1
	basicInfo.upgradeEndTs = 0

	return basicInfo
end

function HomeCarModifyCtrl:onDestroy()
	HomeCarModifyCtrl.super.onDestroy(self)

	self.homeMainPage = nil
end

function HomeCarModifyCtrl:confirm()
	if self.isModify then
		pg.me:setHomeCarShape(self.shapeInfo, function(noticeId, noticeArgs)
			if noticeId == NoticeDef.SUCCESS then
				self:closePanel()
			else
				ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
			end
		end)
	else
		pg.global.ui.homeCarName:setDefaultShapeInfo(self.shapeInfo)
		self:close()
	end
end

function HomeCarModifyCtrl:initTabList()
	local tabList = {}
	local cameraType = {
		UIConst.HOMECAR_MODE_IDX.MODIFYSHAPE,
		UIConst.HOMECAR_MODE_IDX.MODIFYTOP
	}

	for tabId, tabInfo in pairs(HomeCarModifyTypeData) do
		local info = {
			tabId = tabId,
			icon = tabInfo.icon,
			name = tabInfo.name,
			cameraType = cameraType[tabId]
		}

		table.insert(tabList, info)
	end

	local function sortFunc(a, b)
		return a.tabId < b.tabId
	end

	table.sort(tabList, sortFunc)
	self.view.tabList:SetList(tabList)
	self.view.tabList:SelectItem(0)
end

function HomeCarModifyCtrl:refreshModifyList()
	local subTabData = HomeCarModifyData[self.curTab]
	local modifyList = {}

	for subTabId, subTabInfo in pairs(subTabData) do
		local info = {
			tabId = self.curTab,
			subTabId = subTabId,
			icon = subTabInfo.icon,
			name = subTabInfo.name,
			partId = subTabInfo.partId,
			partValue = subTabInfo.partValue
		}

		table.insert(modifyList, info)
	end

	local function sortFunc(a, b)
		return a.subTabId < b.subTabId
	end

	table.sort(modifyList, sortFunc)

	self.modifyList = modifyList

	self.view.itemList:SetList(modifyList)
	self:refreshSelectPointList()
end

function HomeCarModifyCtrl:refreshSelectPointList()
	local pointList = {}

	for i = 1, #self.modifyList do
		local data = self.modifyList[i]

		table.insert(pointList, {
			subTabId = data.subTabId,
			partId = data.partId
		})
	end

	self.view.listPointUList:SetList(pointList)
end

function HomeCarModifyCtrl:rendererPartItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local lockUImage = objectReference:GetRefValue("lockUImage")

	lockUImage:SetActive(false)

	iconUImage.url = data.icon

	local curValue = self.shapeInfo[data.partId] or 0

	if curValue == data.subTabId then
		button:TryChangePage("State", 1)
	else
		button:TryChangePage("State", 0)
	end

	function button.luaClick()
		self:selectPartItem(data.partId, data.subTabId)
	end
end

function HomeCarModifyCtrl:rendererPointItem(button, index, data)
	local curValue = self.shapeInfo[data.partId] or 0

	if curValue == data.subTabId then
		button:TryChangePage("Selected", 1)
	else
		button:TryChangePage("Selected", 0)
	end
end

function HomeCarModifyCtrl:rendererTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = data.icon

	ClientTextUtils.setText(objectReference:GetRefValue("txtNameTextPlus"), pg.getLocalizationText(data.name))
end

function HomeCarModifyCtrl:selectTabType(tabId)
	self.curTab = tabId

	self:refreshModifyList()
end

function HomeCarModifyCtrl:selectPartItem(partId, subTabId)
	if self.shapeInfo[partId] ~= subTabId then
		self.shapeInfo[partId] = subTabId

		self.view.itemList:RefreshList(true)
		self.view.listPointUList:RefreshList(true)
		self.uiScene:refreshHomeCar(self.basicInfo)
	end
end

function HomeCarModifyCtrl:initHomeCarEntity()
	self.uiScene:refreshHomeCar(self.basicInfo)
end

return HomeCarModifyCtrl
