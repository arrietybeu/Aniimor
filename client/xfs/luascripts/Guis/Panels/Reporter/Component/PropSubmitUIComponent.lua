-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Reporter\\Component\\PropSubmitUIComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local Class = require("Core.Framework.Class")
local PropSubmitUIComponent = Class.LightClass("PropSubmitUIComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LuaUIUtils = require("Utils.LuaUIUtils")

function PropSubmitUIComponent:findObjects()
	if IsNil(self.transform) then
		return
	end

	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.component = self.objectReference:GetRefValue("component")
	self.exitBtn = self.objectReference:GetRefValue("exitBtn")
	self.takeBtn = self.objectReference:GetRefValue("takeBtn")
	self.requiredList = self.objectReference:GetRefValue("requiredList")
	self.choseList = self.objectReference:GetRefValue("choseList")
	self.descText = self.objectReference:GetRefValue("textUSDFText")

	if not IsNil(self.descText) then
		self.descText:SetActive(false)
	end

	function self.exitBtn.luaClick()
		self:switchReportState(false)
	end

	function self.takeBtn.luaClick()
		self:onTakeReward()
	end

	function self.requiredList.luaRenderItem(item, index, data)
		self:instantiateNeedItem(item, index, data)
	end

	function self.choseList.luaRenderItem(item, index, data)
		self:instantiateChoseItem(item, index, data)
	end
end

function PropSubmitUIComponent:initView()
	self.eventParam = nil
	self.successSubmitCallback = nil

	self:clearData()
end

function PropSubmitUIComponent:switchReportState(active, eventData, cb)
	self.ctrl:setPageIndex(active and self.model.PROP_REPORTER or self.model.NONE)
	pg.game.camera:enableNpcInteract(active)

	if active then
		self:clearData()

		self.eventParam = eventData
		self.successSubmitCallback = cb

		self:refreshView()
	end
end

function PropSubmitUIComponent:refreshView()
	self.needList, self.item2ConditionMap = self.model:getPropSubmitData(self.eventParam)
	self.ownList = self.model:getOwnPropData(self.needList)

	self:autoSelectExactItems()
	self.requiredList:SetList(self.needList)
	self.requiredList:SetNavGroupConsoleBar("CONSOLE_BAR_DETAILS", -1)

	if table.nums(self.ownList) > 0 then
		self.component:TryChangePage("state", 0)

		self.takeBtn.interactable = true

		self.takeBtn:TryChangePage("button", "normal")
		self.choseList:SetList(self.ownList)
	else
		self.component:TryChangePage("state", 1)

		self.takeBtn.interactable = false

		self.takeBtn:TryChangePage("button", "disabled")
	end
end

function PropSubmitUIComponent:autoSelectExactItems()
	for _, need in ipairs(self.needList) do
		if need.needNum and need.needNum > 0 then
			local own = self:tryGetItemData(self.ownList, need.id)

			if own and own.ownNum == need.needNum then
				self.selectMap[need.id] = need.needNum
			end
		end
	end
end

function PropSubmitUIComponent:instantiateNeedItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")

	itemIconUImage.url = data.icon

	local selectNum = self.selectMap[data.id] or 0

	if selectNum >= data.needNum then
		ClientTextUtils.setText(txtNumUBaseText, string.format("%d/%d", selectNum, data.needNum))
	else
		ClientTextUtils.setText(txtNumUBaseText, string.format("<color=#FE7676>%d</color>/%d", selectNum, data.needNum))
	end

	btnDelUButton:SetActive(selectNum > 0)

	if selectNum > 0 then
		function btnDelUButton.luaClick()
			self:decreaseItem(data)
		end

		function btnDelUButton.luaLongPress(pressTime)
			if pressTime > 3 then
				self:decreaseItem(data, 10)
			else
				self:decreaseItem(data, 1)
			end
		end
	end

	btnDelUButton:SetHotkeyConsoleBar("CONSOLE_BAR_REMOVE", -2)

	function item.luaClick()
		LuaUIUtils.popupPropTip({
			id = data.id,
			num = self.model:getOwnPropNum(data.id),
			targetRect = item,
			closeOnJumpToSource = function()
				if not self.ctrl then
					pg.global.ui:show(UIConst.UI_ID_INTERACT)
					pg.game.camera:enableNpcInteract(false)

					return
				end

				self:switchReportState(false)
			end
		})
	end

	item:TryChangePage("Quality", data.quality)
end

function PropSubmitUIComponent:instantiateChoseItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local itemNameUText = objectReference:GetRefValue("itemNameUText")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local txtCheckNumUBaseText = objectReference:GetRefValue("txtCheckNumUBaseText")
	local btnIconUButton = objectReference:GetRefValue("btnIconUButton")

	item.draggable = false
	item.tooltipMode = 0
	self.holdItems[#self.holdItems + 1] = item

	function item.luaClick()
		self:clickItem(data)
	end

	function btnDelUButton.luaClick()
		self:decreaseItem(data)
	end

	function btnDelUButton.luaLongPress(pressTime)
		if pressTime > 3 then
			self:decreaseItem(data, 10)
		else
			self:decreaseItem(data, 1)
		end
	end

	function btnIconUButton.luaClick()
		LuaUIUtils.popupPropTip({
			id = data.id,
			num = data.ownNum,
			targetRect = item,
			closeOnJumpToSource = function()
				if not self.ctrl then
					pg.global.ui:show(UIConst.UI_ID_INTERACT)
					pg.game.camera:enableNpcInteract(false)

					return
				end

				self:switchReportState(false)
			end
		})
	end

	btnDelUButton:SetHotkeyConsoleBar("CONSOLE_BAR_REMOVE", -2)

	itemIconUImage.url = data.icon

	ClientTextUtils.setText(itemNameUText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(txtNumUText, string.format("x%s", data.ownNum))
	item:TryChangePage("Quality", data.quality)

	if self.selectMap[data.id] ~= nil then
		item:TryChangePage("CheckMode", 1)
		ClientTextUtils.setText(txtCheckNumUBaseText, self.selectMap[data.id])
		item:TryChangePage("Cancel", 1)
	else
		item:TryChangePage("CheckMode", 0)
		item:TryChangePage("Cancel", 0)
	end
end

function PropSubmitUIComponent:decreaseItem(data, decreaseNum)
	if self.selectMap[data.id] == nil then
		return
	end

	decreaseNum = decreaseNum or 1

	local num = self.selectMap[data.id] - decreaseNum

	if num > 0 then
		self.selectMap[data.id] = num
	else
		self.selectMap[data.id] = nil
	end

	self.requiredList:RefreshList()
	self.choseList:RefreshList()
end

function PropSubmitUIComponent:clickItem(data)
	local needData = self:tryGetItemData(self.needList, data.id)

	if needData == nil then
		return
	end

	if data.ownNum == 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("ITEM_NUM_LESS"))

		return
	end

	local num = math.min(data.ownNum, needData.needNum)

	self.selectMap[data.id] = num

	self.requiredList:RefreshList()
	self.choseList:RefreshList()
end

function PropSubmitUIComponent:tryGetItemData(dataList, id)
	for _, v in ipairs(dataList) do
		if v.id == id then
			return v
		end
	end

	return nil
end

function PropSubmitUIComponent:clearData()
	self.selectMap = {}
	self.item2ConditionMap = {}
	self.needList = {}
	self.ownList = {}
	self.holdItems = {}
end

function PropSubmitUIComponent:onTakeReward()
	if not self:checkHasSelection() then
		pg.global.showBubbleMessageById(NoticeDef.PLEASE_SELECT_SUBMIT_ITEM)

		return
	end

	if not self:checkCanSubmit() then
		pg.global.showBubbleMessageById(NoticeDef.SUBMIT_ITEM_COUNT_NOT_ENOUGH)

		return
	end

	local me = pg.me

	for itemId, count in pairs(self.selectMap) do
		local conditionData = self.item2ConditionMap[itemId].params
		local npcId = self.item2ConditionMap[itemId].npcId

		me:serverMsg("RPC_CS_SubItem", conditionData[1], conditionData[2], conditionData[3], npcId, count, CallbackHandler(self, "callbackOnItemSubmit"))
	end
end

function PropSubmitUIComponent:callbackOnItemSubmit(noticeId)
	if noticeId ~= NoticeDef.SUCCESS then
		pg.global.showBubbleMessageRaw(pg.getGameString("SUCCEED"))

		return
	end

	if not self.ctrl then
		pg.global.ui:show(UIConst.UI_ID_INTERACT)
		pg.game.camera:enableNpcInteract(false)

		if self.successSubmitCallback then
			self.successSubmitCallback()

			self.successSubmitCallback = nil
		end

		return
	end

	self.selectMap = {}

	self:refreshView()
	self:switchReportState(false)

	if self.successSubmitCallback then
		self.successSubmitCallback()

		self.successSubmitCallback = nil
	end
end

function PropSubmitUIComponent:checkHasSelection()
	return table.getCount(self.selectMap) > 0
end

function PropSubmitUIComponent:checkCanSubmit()
	if #self.needList == 0 then
		return false
	end

	for _, v in ipairs(self.needList) do
		local num = self.selectMap[v.id]

		if num == nil or num < v.needNum then
			return false
		end
	end

	return true
end

return PropSubmitUIComponent
