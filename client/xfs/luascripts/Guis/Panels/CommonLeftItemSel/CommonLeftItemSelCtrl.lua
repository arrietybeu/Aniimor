-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonLeftItemSel\\CommonLeftItemSelCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CommonLeftItemSelCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local CommonLeftItemSelCtrl = Class.LightClass("CommonLeftItemSelCtrl", UICtrl)

CommonLeftItemSelCtrl.messages = {}

function CommonLeftItemSelCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.tempItemCountMap = {}
end

function CommonLeftItemSelCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCornerClose.luaClick()
		self:dismiss()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end

	function self.view.btnLeftUButton.luaClick()
		self.tempItemCountMap = {}
		self.tempItemList = {}

		if self._curSelectBtn ~= nil then
			self.view.listUList:DeselectAll()

			self._curSelectBtn = nil

			self.view.numSelectorUNumSelector:SetActiveFastest(false)
		end

		self:refreshUI()
		self:refreshTempInfo()
	end

	function self.view.btnRightUButton.luaClick()
		self.tempItemList, self.tempItemCountMap = self.model:getTakeAllInfo(self.fromType, self.tempItemList, self.tempItemCountMap)

		logger:info("CommonLeftItemSelCtrl btnRightUButton.luaClick fromType:%s self.tempItemList:%s self.tempItemCountMap:%s", self.fromType, inspect(self.tempItemList), inspect(self.tempItemCountMap))
		self:refreshUI()
		self:refreshTempInfo()
	end

	function self.view.numSelectorUNumSelector.luaValueChanged(num)
		self:onNumSelectChange(num)
	end
end

function CommonLeftItemSelCtrl:testClickRightBtn()
	logger:info("CommonLeftItemSelCtrl testClickRightBtn rightBtn:%s", self.view.btnRightUButton)
	self.view.btnRightUButton:OnClickSimulate()
end

function CommonLeftItemSelCtrl:onDestroy()
	self.view.listUList:DeselectAll()

	self._curSelectBtn = nil

	UICtrl.onDestroy(self)
end

function CommonLeftItemSelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:initUI(info)
end

function CommonLeftItemSelCtrl:onShow()
	return
end

function CommonLeftItemSelCtrl:onHide()
	self.view.listUList:DeselectAll()

	self._curSelectBtn = nil

	self:refreshTempInfo()
end

function CommonLeftItemSelCtrl:refreshTempInfo()
	local result = {}

	for index, itemId in ipairs(self.tempItemList) do
		local cnt = self.tempItemCountMap[itemId]

		table.insert(result, {
			itemId = itemId,
			cnt = cnt
		})
	end

	self.refreshCb(result)
end

function CommonLeftItemSelCtrl:initUI(info)
	self.title = info.title
	self.fromType = info.fromType
	self.curCnt = info.curCnt
	self.maxCnt = info.maxCnt

	ClientTextUtils.setText(self.view.textTitleUBaseText, string.format(self.title, self.curCnt, self.maxCnt))
	self.view.numSelectorUNumSelector:SetActiveFastest(false)

	if #info.itemList <= 0 then
		self.view.rootWidget:TryChangePage("Empty", "Empty")
		self.view.btnLeftUButton:SetActiveFastest(false)
		self.view.btnRightUButton:SetActiveFastest(false)
	else
		self.view.rootWidget:TryChangePage("Empty", "normal")
		self.view.btnLeftUButton:SetActiveFastest(true)
		self.view.btnRightUButton:SetActiveFastest(true)

		local btnLeftTxt = self.view.btnLeftUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
		local btnRightTxt = self.view.btnRightUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

		ClientTextUtils.setText(btnLeftTxt, info.leftBtnTxt)
		ClientTextUtils.setText(btnRightTxt, info.rightBtnTxt)
	end

	self.itemNumLimitDict = {}
	self.tempItemCountMap = {}
	self.tempItemList = {}

	for index, data in ipairs(info.itemList) do
		self.itemNumLimitDict[data.id] = data.limitNum
		self.tempItemCountMap[data.id] = data.oriCnt

		if data.oriCnt > 0 then
			table.insert(self.tempItemList, data.id)
		end
	end

	self.view.listUList:SetList(info.itemList)

	self.refreshCb = info.refreshCb
end

function CommonLeftItemSelCtrl:refreshUI()
	ClientTextUtils.setText(self.view.textTitleUBaseText, string.format(self.title, self:getCurCnt(), self.maxCnt))
	self.view.listUList:RefreshList()

	if self._curSelectBtn then
		local button, index, data = unpack(self._curSelectBtn)

		self.view.numSelectorUNumSelector.value = self.tempItemCountMap[data.id]
	end
end

function CommonLeftItemSelCtrl:renderItem(button, index, data)
	LuaUIUtils.renderItem(button, data)

	local objectReference = button:GetComponent("ObjectReference")
	local viewableWidget = objectReference:GetRefValue("viewableWidget")
	local selectedStateUComponent = objectReference:GetRefValue("selectedStateUComponent")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")
	local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
	local disabledUImage = objectReference:GetRefValue("disabledUImage")
	local genIdTransform = objectReference:GetRefValue("genIdTransform")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local stateNewULayoutBox = objectReference:GetRefValue("stateNewULayoutBox")
	local slotIndex = objectReference:GetRefValue("slotIndex")
	local noneUWidget = objectReference:GetRefValue("noneUWidget")
	local itemNameUText = objectReference:GetRefValue("itemNameUText")
	local checkedUButton = objectReference:GetRefValue("checkedUButton")
	local selectedName = objectReference:GetRefValue("selectedName")
	local imgCheckOneUImage = objectReference:GetRefValue("imgCheckOneUImage")
	local uIComPropCardAnimation = objectReference:GetRefValue("uIComPropCardAnimation")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local checkNumberUText = objectReference:GetRefValue("checkNumberUText")
	local cancelUButton = objectReference:GetRefValue("cancelUButton")
	local rateUComponent = objectReference:GetRefValue("rateUComponent")
	local rateUBaseText = objectReference:GetRefValue("rateUBaseText")
	local carryItem = objectReference:GetRefValue("carryItem")
	local buttonUpUButton = objectReference:GetRefValue("buttonUpUButton")
	local txtOrderUBaseText = objectReference:GetRefValue("txtOrderUBaseText")
	local txtNameAddUBaseText = objectReference:GetRefValue("txtNameAddUBaseText")
	local exclusiveUContainer = objectReference:GetRefValue("exclusiveUContainer")

	selectedULayoutBox = selectedULayoutBox:GetComponent("UComponent")
	button.draggable = false
	button.enabledTooltip = false

	local itemId = data.id
	local curCnt = self.tempItemCountMap[itemId] or 0

	txtNameAddUBaseText:SetActive(true)

	local limitNum = self.itemNumLimitDict and self.itemNumLimitDict[itemId] or 0

	ClientTextUtils.setText(txtNameAddUBaseText, string.format(pg.getGameString("CATCH_ROGUE_BALL_TYPE_CARRY"), limitNum))
	ClientTextUtils.setText(selectedName, curCnt)

	if curCnt > 0 then
		selectedULayoutBox:SetActive(true)
		btnDelUButton:SetActive(true)
	else
		selectedULayoutBox:SetActive(false)
		btnDelUButton:SetActive(false)
	end

	btnDelUButton.enabledLongPress = true

	function btnDelUButton.luaClick()
		self:reduceNum(itemId, selectedULayoutBox, btnDelUButton, selectedName, button, index, data)
	end

	function btnDelUButton.luaLongPress(pressTime)
		self:reduceNum(itemId, selectedULayoutBox, btnDelUButton, selectedName, button, index, data)
	end

	button.enabledLongPress = true

	function button.luaClick()
		self:addNum(itemId, selectedULayoutBox, btnDelUButton, selectedName, button, index, data)
	end

	function button.luaLongPress(pressTime)
		self:addNum(itemId, selectedULayoutBox, btnDelUButton, selectedName, button, index, data)
	end
end

function CommonLeftItemSelCtrl:reduceNum(itemId, selectedULayoutBox, btnDelUButton, selectedName, button, index, data)
	local maxNum = self:getMaxNum(itemId)
	local curCnt = self.tempItemCountMap[itemId] or 0

	curCnt = math.max(curCnt - 1, 0)

	selectedULayoutBox:TryChangePage("Type", "Negative")

	if curCnt == 0 then
		selectedULayoutBox:SetActive(false)
		btnDelUButton:SetActive(false)

		if self._curSelectBtn ~= nil then
			self.view.listUList:DeselectAll()

			self._curSelectBtn = nil

			self.view.numSelectorUNumSelector:SetActiveFastest(false)
		end

		for curIndex, curItemId in ipairs(self.tempItemList) do
			if curItemId == itemId then
				table.remove(self.tempItemList, curIndex)
			end
		end
	else
		if self._curSelectBtn and self._curSelectBtn[2] == index then
			self.view.numSelectorUNumSelector.value = curCnt
		else
			self.view.listUList:SelectItem(index)

			self._curSelectBtn = {
				button,
				index,
				data
			}

			self.view.numSelectorUNumSelector:SetActiveFastest(true)

			self.view.numSelectorUNumSelector.minValue = 0
			self.view.numSelectorUNumSelector.maxValue = maxNum
			self.view.numSelectorUNumSelector.value = curCnt
		end

		ClientTextUtils.setText(selectedName, curCnt)
	end

	self.tempItemCountMap[itemId] = curCnt

	ClientTextUtils.setText(self.view.textTitleUBaseText, string.format(self.title, self:getCurCnt(), self.maxCnt))
	self:refreshTempInfo()
end

function CommonLeftItemSelCtrl:addNum(itemId, selectedULayoutBox, btnDelUButton, selectedName, button, index, data)
	local curCnt = self.tempItemCountMap[itemId] or 0
	local hasCnt = ItemUtils.getItemCountById(pg.me, itemId)
	local maxNum = self:getMaxNum(itemId)

	selectedULayoutBox:TryChangePage("Type", "Positive")

	if curCnt == maxNum then
		if curCnt == hasCnt then
			pg.global.showBubbleMessageRaw(pg.getGameString("CATCH_ROGUE_CARRY_BALL_LIMIT"))
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("CATCH_ROGUE_CATCH_BALL_MAX"))
		end
	end

	curCnt = math.min(curCnt + 1, maxNum)

	if curCnt == 1 then
		selectedULayoutBox:SetActive(true)
		btnDelUButton:SetActive(true)

		if not table.contains(self.tempItemList, itemId) then
			self.tempItemList[#self.tempItemList + 1] = itemId
		end
	end

	ClientTextUtils.setText(selectedName, curCnt)

	self.tempItemCountMap[itemId] = curCnt

	ClientTextUtils.setText(self.view.textTitleUBaseText, string.format(self.title, self:getCurCnt(), self.maxCnt))

	if self._curSelectBtn and self._curSelectBtn[2] == index then
		self.view.numSelectorUNumSelector.value = curCnt
	else
		self.view.listUList:SelectItem(index)

		self._curSelectBtn = {
			button,
			index,
			data
		}

		self.view.numSelectorUNumSelector:SetActiveFastest(true)

		self.view.numSelectorUNumSelector.minValue = 0
		self.view.numSelectorUNumSelector.maxValue = maxNum
		self.view.numSelectorUNumSelector.value = curCnt
	end

	self:refreshTempInfo()
end

function CommonLeftItemSelCtrl:onNumSelectChange(num)
	if not self._curSelectBtn then
		return
	end

	local button, index, data = self._curSelectBtn[1], self._curSelectBtn[2], self._curSelectBtn[3]
	local itemId = data.id
	local limitNum = self.itemNumLimitDict and self.itemNumLimitDict[itemId] or 0
	local hasCnt = ItemUtils.getItemCountById(pg.me, itemId)
	local curCnt = num

	if curCnt == limitNum or curCnt == hasCnt then
		if curCnt == hasCnt then
			pg.global.showBubbleMessageRaw(pg.getGameString("CATCH_ROGUE_CARRY_BALL_LIMIT"))
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("CATCH_ROGUE_CATCH_BALL_MAX"))
		end
	end

	local objectReference = button:GetComponent("ObjectReference")
	local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local selectedName = objectReference:GetRefValue("selectedName")

	selectedULayoutBox = selectedULayoutBox:GetComponent("UComponent")

	if curCnt == 1 then
		selectedULayoutBox:SetActive(true)
		btnDelUButton:SetActive(true)

		if not table.contains(self.tempItemList, itemId) then
			table.insert(self.tempItemList, itemId)
		end
	elseif curCnt == 0 then
		selectedULayoutBox:SetActive(false)
		btnDelUButton:SetActive(false)

		for curIndex, curItemId in ipairs(self.tempItemList) do
			if curItemId == itemId then
				table.remove(self.tempItemList, curIndex)
			end
		end

		if self._curSelectBtn ~= nil then
			self.view.listUList:DeselectAll()

			self._curSelectBtn = nil

			self.view.numSelectorUNumSelector:SetActiveFastest(false)
		end
	end

	ClientTextUtils.setText(selectedName, curCnt)

	if self.tempItemCountMap[itemId] ~= curCnt then
		selectedULayoutBox:TryChangePage("Type", curCnt > self.tempItemCountMap[itemId] and "Positive" or "Negative")
	end

	self.tempItemCountMap[itemId] = curCnt

	ClientTextUtils.setText(self.view.textTitleUBaseText, string.format(self.title, self:getCurCnt(), self.maxCnt))
	self:refreshTempInfo()
end

function CommonLeftItemSelCtrl:getMaxNum(itemId)
	local limitNum = self.itemNumLimitDict and self.itemNumLimitDict[itemId] or 0
	local hasCnt = ItemUtils.getItemCountById(pg.me, itemId)
	local curTotalCnt = 0

	for _, cnt in pairs(self.tempItemCountMap or EMPTY_TABLE) do
		curTotalCnt = curTotalCnt + cnt
	end

	local remainCnt = self.maxCnt - curTotalCnt

	return math.min(remainCnt + (self.tempItemCountMap[itemId] or 0), math.min(limitNum, hasCnt))
end

function CommonLeftItemSelCtrl:getCurCnt()
	local curTotalCnt = 0

	for _, cnt in pairs(self.tempItemCountMap or EMPTY_TABLE) do
		curTotalCnt = curTotalCnt + cnt
	end

	return curTotalCnt
end

return CommonLeftItemSelCtrl
