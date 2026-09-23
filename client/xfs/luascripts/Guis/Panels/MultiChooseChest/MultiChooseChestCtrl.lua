-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MultiChooseChest\\MultiChooseChestCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local MultiChooseChestCtrl = Class.LightClass("MultiChooseChestCtrl", UICtrl)

MultiChooseChestCtrl.messages = {}

function MultiChooseChestCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:Init(info)
end

function MultiChooseChestCtrl:destroy()
	return
end

function MultiChooseChestCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnClose1UButton.luaClick()
		self:closePanel()
	end

	function self.view.btnCancelUButton.luaClick()
		self:closePanel()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderRewardItems(button, index, data)
	end

	function self.view.listUList.luaSelectedChanged(_, _)
		self:refreshSelectedData()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onEnsureClick()
	end
end

function MultiChooseChestCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function MultiChooseChestCtrl:Init(info)
	if not info.itemId then
		return
	end

	self.chestItemId = info.itemId
	self.chestItemOwned = ItemUtils.getItemCountById(pg.me, self.chestItemId)

	if self.chestItemOwned <= 0 then
		return
	end

	self.maxCount = self.model:getMaxChooseNum(self.chestItemId)

	if self.maxCount <= 0 then
		return
	end

	self.selectedItems = {}

	self:refreshTitleNum()

	self.view.numSelector.minValue = 1
	self.view.numSelector.maxValue = self.chestItemOwned
	self.view.numSelector.stepSize = 1

	self.view.listUList:SetList(self.model:getAllRewards(self.chestItemId))
end

function MultiChooseChestCtrl:refreshTitleNum()
	local selectedCount = Lume.count(self.selectedItems)
	local color = selectedCount < self.maxCount and "<color=#FF7575>%s</color>" or "<color=#5F93E0>%s</color>"

	ClientTextUtils.setText(self.view.textUSDFText, string.format(pg.getGameString("MULTI_CHOOSE_CHEST_TIP"), string.format(color, selectedCount), self.maxCount))

	if selectedCount < self.maxCount then
		self.view.btnConfirmUButton:TryChangePage("button", 4)
	else
		self.view.btnConfirmUButton:TryChangePage("button", 0)
	end
end

function MultiChooseChestCtrl:renderRewardItems(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.itemName)
	ClientTextUtils.setText(textUSDFText, string.format(pg.getGameString("ALREADY_OWNED"), data.owned))
	LuaUIUtils.renderRewardItem(rewardItemUButton, data)
end

function MultiChooseChestCtrl:refreshSelectedData()
	table.clear(self.selectedItems)

	local btns = self.view.listUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].isSelected then
			local data = btns[i].dataFromUList

			self.selectedItems[data.id] = {
				index = i + 1,
				num = data.num
			}
		end
	end

	btns = self.view.listUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local data = btns[i].dataFromUList

		if Lume.count(self.selectedItems) >= self.maxCount then
			if self.selectedItems[data.id] then
				btns[i].interactable = true

				btns[i]:TryChangePage("State", 0)
			else
				btns[i].interactable = false

				btns[i]:TryChangePage("State", 1)
			end
		else
			btns[i].interactable = true

			btns[i]:TryChangePage("State", 0)
		end
	end

	self:refreshTitleNum()
end

function MultiChooseChestCtrl:onEnsureClick()
	if Lume.count(self.selectedItems) < self.maxCount then
		pg.global.showBubbleMessageRaw(pg.getGameString("MULTI_CHOOSE_CHEST_NOT_VALID"))

		return
	end

	local clientArgs = {}

	clientArgs.selects = {}

	for _, v in pairs(self.selectedItems) do
		clientArgs.selects[v.index] = true
	end

	pg.me:serverMsg("RPC_CS_UseItemById", self.chestItemId, self.view.numSelector.value, clientArgs)
	self:closePanel()
end

function MultiChooseChestCtrl:closePanel()
	self:destroy()
	pg.global.ui:close(UIConst.UI_ID_MULTI_CHOOSE_CHEST)
end

return MultiChooseChestCtrl
