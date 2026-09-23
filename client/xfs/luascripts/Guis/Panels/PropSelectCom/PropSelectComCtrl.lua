-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PropSelectCom\\PropSelectComCtrl.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local lume = require("Core.Common.lume")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ItemSelectData = require("Data.item_select_data")
local UIConst = require("Const.UIConst")
local PropSelectComCtrl = Class.LightClass("PropSelectComCtrl", UICtrl)

PropSelectComCtrl.messages = {}

function PropSelectComCtrl:ctor()
	UICtrl.ctor(self)

	self.propId = nil
	self.propCount = 0
end

function PropSelectComCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PropSelectComCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:close()
	end

	function self.view.btnClose2.luaClick()
		self:close()
	end

	function self.view.listPropUList.luaRenderItem(button, idx, data)
		self:renderItemList(button, idx, data)
	end

	function self.view.listTabUList.luaRenderItem(button, idx, data)
		self:renderTabItemList(button, idx, data)
	end

	function self.view.btnConfirmUButton.luaClick()
		if not self.countEnough then
			pg.global.showBubbleMessageRaw(pg.getGameString("ITEM_NUM_LESS"))
		else
			if self.confirmFunc then
				self.confirmFunc(self.propId, self.propCount)
			end

			self.confirmFunc = nil

			self:close()
		end
	end

	function self.view.listTabUList.luaSelectedChanged(uList, isSelect)
		if isSelect then
			local selectData = self.view.listTabUList.selectedItem
			local data = lume.clone(selectData)
			local propInfos = self.model:buildPropInfos(data.configId, data.index, self.fromLeylineFlower, self.reservedItems)

			self.view.widget:TryChangePage("State", #propInfos > 0 and 1 or 0)
			self:refreshItemList(propInfos)
		end
	end

	function self.view.listPropUList.luaSelectedChanged(uList, isSelect)
		if isSelect then
			local selectData = self.view.listPropUList.selectedItem
			local data = lume.clone(selectData)

			data.extraFunc = nil

			self:refreshCostStyle(data.numType)
			self:refreshMainIcon(data)
		end
	end

	function self.view.numSelectorUNumSelector.luaValueChanged(num)
		self:onNumSelectChange(num)
	end

	self.view.btnCancelUButton:SetActive(false)
end

function PropSelectComCtrl:onNumSelectChange(num)
	self.propCount = num

	local rmbValue, numValue = self.model:countItemRMBValue(self.propId, num)

	ClientTextUtils.setText(self.view.txtTitleUSDFText, rmbValue)
	self.view.widget:TryChangePage("Quality", self.model:checkNumValuePageState(numValue))
end

function PropSelectComCtrl:refreshCostStyle(numType)
	self.numType = numType

	if numType == 2 then
		self.view.numSelectorUNumSelector:SetActive(true)
		self.view.layoutConsumeULayoutBox:SetActive(true)
	else
		self.view.numSelectorUNumSelector:SetActive(false)
		self.view.layoutConsumeULayoutBox:SetActive(true)
	end
end

function PropSelectComCtrl:refreshMainIcon(itemInfo)
	if itemInfo.isEmpty then
		return
	end

	local ownNum = itemInfo.ownNum
	local numParam = itemInfo.numParam

	itemInfo.num = 0

	LuaUIUtils.renderRewardItem(self.view.itemSelUButton, itemInfo)

	function self.view.itemSelUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = itemInfo.id,
			num = itemInfo.num,
			targetRect = self.view.itemSelUButton,
			closeOnJumpToSource = function()
				self:close()
			end
		})
	end

	ClientTextUtils.setText(self.view.itemDesc, pg.getLocalizationText(itemInfo.shortDesc))
	ClientTextUtils.setText(self.view.itemName, pg.getLocalizationText(itemInfo.shortName))

	self.propId = itemInfo.id

	if self.numType == 2 then
		local maxVal = numParam and math.min(ownNum, numParam) or ownNum

		self.countEnough = ownNum > 0

		if ownNum > 0 then
			self.view.numSelectorUNumSelector.minValue = 1
			self.view.numSelectorUNumSelector.maxValue = maxVal
			self.view.numSelectorUNumSelector.value = 1
			self.propCount = 1
		else
			self.view.numSelectorUNumSelector.minValue = 0
			self.view.numSelectorUNumSelector.maxValue = 0
			self.view.numSelectorUNumSelector.value = 0
			self.propCount = 0
		end

		ClientTextUtils.setText(self.view.costCountTxt, "")

		local rmbValue, numValue = self.model:countItemRMBValue(self.propId, self.view.numSelectorUNumSelector.value)

		if self.fromLeylineFlower then
			ClientTextUtils.setText(self.view.txtTitleUSDFText, rmbValue)
			self.view.widget:TryChangePage("Quality", self.model:checkNumValuePageState(numValue))
		end
	else
		local fixCost = numParam or 1
		local rmbValue, numValue

		if fixCost <= ownNum then
			self.countEnough = true
			self.propCount = fixCost
			rmbValue, numValue = self.model:countItemRMBValue(self.propId, fixCost)
		else
			self.countEnough = false
			self.propCount = 0
			rmbValue, numValue = self.model:countItemRMBValue(self.propId, ownNum)
		end

		LuaUIUtils.renderConsumeText(self.view.costCountTxt, ownNum, fixCost, UIConst.ITEM_STATE.FULL)

		if self.fromLeylineFlower then
			ClientTextUtils.setText(self.view.txtTitleUSDFText, rmbValue)
			self.view.widget:TryChangePage("Quality", self.model:checkNumValuePageState(numValue))
		end
	end
end

function PropSelectComCtrl:refreshTabList(configId)
	local tabInfo = self.model:getTabInfo(configId)

	self.view.listTabUList:SetList(tabInfo)
	self.view.listTabUList:SelectItem(0)
end

function PropSelectComCtrl:refreshItemList(propInfos)
	local ret = {}

	for _, item in ipairs(propInfos) do
		ret[#ret + 1] = item
	end

	local targetCount = math.ceil(math.max(#ret, 1) / 4) * 4

	for i = #ret + 1, targetCount do
		ret[#ret + 1] = {
			isEmpty = true,
			tIndex = 1
		}
	end

	self.view.listPropUList:SetList(ret)
	self.view.listPropUList:SelectItem(0)
end

function PropSelectComCtrl:renderTabItemList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = data.icon
end

function PropSelectComCtrl:renderItemList(button, idx, data)
	if not data.isEmpty then
		function data.extraFunc()
			return
		end

		if data.ownNum > 0 then
			LuaUIUtils.renderRewardItem(button, data, data.ownNum)
		else
			LuaUIUtils.renderRewardItem(button, data, string.format("<style=Item_Lack>%s</style>", data.ownNum))
		end
	end
end

function PropSelectComCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PropSelectComCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local configGroup = ItemSelectData[info.configId]

	self.confirmFunc = info.confirmFunc
	self.fromLeylineFlower = info.fromLeylineFlower
	self.reservedItems = info.reservedItems

	ClientTextUtils.setText(self.view.txtTitleUBaseText, configGroup.title and pg.getLocalizationText(configGroup.title) or pg.getGameString("CHOOSE_ITEM"))
	self:refreshTabList(info.configId)
end

function PropSelectComCtrl:onShow()
	return
end

function PropSelectComCtrl:onHide()
	return
end

return PropSelectComCtrl
