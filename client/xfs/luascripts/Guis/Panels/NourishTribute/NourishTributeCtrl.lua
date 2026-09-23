-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NourishTribute\\NourishTributeCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local NourishTributeCtrl = Class.LightClass("NourishTributeCtrl", UICtrl)

function NourishTributeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.confirmFunc = info.confirmFunc
	self.blockId = info.blockId

	local configId = info.configId or 1
	local selectorTitle = self.model:getSelectorTitle(configId)

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("CULTIVATE_TRIBUTE"))
	ClientTextUtils.setText(self.view.textAttractUSDFText, pg.getGameString("CAN_ATTRACT"))
	ClientTextUtils.setText(self.view.textChooseUSDFText, selectorTitle and pg.getLocalizationText(selectorTitle) or pg.getGameString("CHOOSE_ITEM"))

	self.items = self.model:getDirectionalItems(configId, self.blockId)

	self.view.listPropUList:SetList(self.items)

	if #self.items > 0 then
		self.view.listPropUList:SelectItem(0)
	else
		self:refreshEmpty()
	end
end

function NourishTributeCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnOKUButton.luaClick()
		self:onConfirm()
	end

	function self.view.listPropUList.luaRenderItem(button, _, data)
		self:renderItem(button, data)
	end

	function self.view.listPropUList.luaSelectedChanged(_, isSelected)
		if isSelected then
			self:refreshSelected(self.view.listPropUList.selectedItem)
		end
	end

	function self.view.listPetUList.luaRenderItem(button, _, data)
		LuaUIUtils.renderCultivatePetItem(button, data)
	end
end

function NourishTributeCtrl:renderItem(button, data)
	function data.extraFunc()
		return
	end

	local ownNum = data.ownNum or 0
	local fixedCost = data.numParam or 1
	local ownText = ownNum

	if ownNum < fixedCost then
		ownText = string.format("<style=Item_Lack>%s</style>", ownNum)
	end

	LuaUIUtils.renderRewardItem(button, data, ownText)
	button:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, 0, function()
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = data.id,
			num = data.ownNum,
			targetRect = button
		})

		return false
	end)
	button:SetHotkeyActiveOnlyInCurrentItem(true)
	button:SetHotkeyConsoleBar("GIFTPACK_TIPS", 0)
end

function NourishTributeCtrl:refreshEmpty()
	self.selectedItem = nil
	self.view.itemSelUButton.luaClick = nil

	self.view.itemSelUButton.gameObject:SetActiveEx(false)
	ClientTextUtils.setText(self.view.textTitleUSDFText, "")
	ClientTextUtils.setText(self.view.textSubUSDFText, "")
	ClientTextUtils.setText(self.view.textConsumptionUSDFText, "")
	self.view.listPetUList:SetList({})
	self.view.btnOKUButton:TryChangePage("enable", 0)
end

function NourishTributeCtrl:refreshSelected(item)
	if not item then
		return
	end

	self.selectedItem = item

	self.view.itemSelUButton.gameObject:SetActiveEx(true)
	self.view.btnOKUButton:TryChangePage("enable", 1)

	local mainItem = {}

	for key, value in pairs(item) do
		mainItem[key] = value
	end

	mainItem.num = 0

	LuaUIUtils.renderRewardItem(self.view.itemSelUButton, mainItem)

	function self.view.itemSelUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = item.id,
			num = item.ownNum,
			targetRect = self.view.itemSelUButton
		})
	end

	ClientTextUtils.setText(self.view.textTitleUSDFText, pg.getLocalizationText(item.shortName))
	ClientTextUtils.setText(self.view.textSubUSDFText, pg.getLocalizationText(item.shortDesc))

	local consumeText = LuaUIUtils.renderConsumeText(nil, item.ownNum or 0, item.numParam or 1, UIConst.ITEM_STATE.FULL)

	ClientTextUtils.setText(self.view.textConsumptionUSDFText, pg.getGameString("FLOWER_NEED_ITEM_NUM"), consumeText)
	self.view.listPetUList:SetList(self.model:getAttractedPets(item))
end

function NourishTributeCtrl:onConfirm()
	local item = self.selectedItem

	if not item then
		return
	end

	local fixedCost = item.numParam or 1
	local ownNum = ClientUtils.getItemCountById(item.id, true) or 0

	if ownNum < fixedCost then
		pg.global.showBubbleMessageRaw(pg.getGameString("ITEM_NUM_LESS"))

		return
	end

	if self.confirmFunc then
		self.confirmFunc(item.id, fixedCost)
	end

	self.confirmFunc = nil

	self:close()
end

function NourishTributeCtrl:onDestroy()
	self.confirmFunc = nil

	UICtrl.onDestroy(self)
end

return NourishTributeCtrl
