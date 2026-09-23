-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRogueResult\\CatchRogueResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRogueResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local CatchRogueResultCtrl = Class.LightClass("CatchRogueResultCtrl", UICtrl)

CatchRogueResultCtrl.messages = {}

function CatchRogueResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.result = self.model:getCatchRogueResult()
	self.catchPetList = self.model:getCatchPetList()
	self.rewardItemList = info.itemList
end

function CatchRogueResultCtrl:addListener()
	function self.view.petList.luaRenderItem(button, index, data)
		self:renderPet(button, index, data)
	end

	function self.view.rewardList.luaRenderItem(button, index, data)
		self:renderRewardItem(button, index, data)
	end

	function self.view.backGroundCloseUButton.luaClick()
		if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
			ClientUtils.exitDungeon()
		end

		self:dismiss()
	end
end

function CatchRogueResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CatchRogueResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:initUI()
end

function CatchRogueResultCtrl:onShow()
	return
end

function CatchRogueResultCtrl:onHide()
	return
end

function CatchRogueResultCtrl:initUI()
	local state

	if self.result then
		state = 0
	elseif self.result == false then
		state = 1
	end

	self.view.rootWidget:TryChangePage("Type", state)
	self.view.panelPetUWidget:TryChangePage("Empty", #self.catchPetList <= 0 and 1 or 0)
	self.view.panelRewardUWidget:TryChangePage("Empty", #self.catchPetList <= 0 and 1 or 0)
	ClientTextUtils.setText(self.view.petEmptyTxt, pg.getGameString("CATCH_ROGUE_END_PETTIP"))
	self.view.petList:SetList(self.catchPetList)
	self.view.rewardList:SetList(self.rewardItemList)
end

function CatchRogueResultCtrl:renderRewardItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local imgDisableUImage = objectReference:GetRefValue("imgDisableUImage")

	itemIconUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

	ClientTextUtils.setText(txtNumUBaseText, data.itemCount)

	local itemConfig = ItemData[data.itemId]

	if itemConfig then
		button:TryChangePage("Quality", itemConfig.quality)
	end

	button.draggable = false
	button.enabledTooltip = false
	data.id = data.itemId
	data.num = data.itemCount

	function button.luaClick()
		LuaUIUtils.onRewardItemClick(button, data)
	end
end

function CatchRogueResultCtrl:renderPet(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local characterUImage = objectReference:GetRefValue("characterUImage")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")
	local listElementUList = objectReference:GetRefValue("listElementUList")
	local templateId = data.templateId
	local cnt = data.num
	local pData = PetData[templateId]

	button.draggable = false
	button.enabledTooltip = false
	characterUImage.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)

	ClientTextUtils.setText(numUBaseText, cnt)

	local _, names = LuaUIUtils.getElementInfo(pData.elementType)
	local temp = {}

	for _, info in ipairs(names) do
		temp[#temp + 1] = info.element
	end

	LuaUIUtils.renderPetElement(listElementUList, temp)
	button:TryChangePage("Rare", data.showRareVfx and "Rare" or "Normal")

	function button.luaClick()
		return
	end
end

return CatchRogueResultCtrl
