-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\Component\\EditCardBgBarComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EditCardBgBarComponent = Class.LightClass("EditCardBgBarComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CardBackgroundData = require("Data.card_background_data")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")

function EditCardBgBarComponent:onCtor(info)
	self.playerInfo = info.playerInfo
	self.btnConfirm = info.btnConfirm
	self.getWayBottomText = info.getWayBottomText
	self.usingUWidget = info.usingUWidget
	self.btnConfirmText = self.btnConfirm:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	function self.refreshPanelHandler(order)
		self.order = order

		self:refreshEditCardBgBarPanel()
		self.cardList:DeselectAll()
	end

	function self.confirmHandler()
		self:onConfirmBtnClick()
	end
end

function EditCardBgBarComponent:initView()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.cardList = self.objectReference:GetRefValue("cardList")

	function self.cardList.luaRenderItem(button, index, data)
		self:renderCardItem(button, index, data)
	end
end

function EditCardBgBarComponent:refreshEditCardBgBarPanel()
	local cardInfos = self.model:getCardBackGroundList()

	self.cardInfos = cardInfos

	self.cardList:SetList(cardInfos)
	self:refreshConfirmButtonState(pg.me.cardBackground)
end

function EditCardBgBarComponent:renderCardItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameText = objectReference:GetRefValue("nameText")
	local cardImage = objectReference:GetRefValue("cardImage")
	local getWayText = objectReference:GetRefValue("getWayText")

	ClientTextUtils.setText(nameText, pg.getLocalizationText(data.cardName))
	ClientTextUtils.setText(getWayText, pg.getLocalizationText(data.sourceDec))

	cardImage.url = data.res

	if data.id == self.playerInfo.cardBackground then
		button:TryChangePage("State", 2)
	else
		button:TryChangePage("State", data.isLock and 1 or 0)
	end

	function button.luaClick()
		self:refreshConfirmButtonState(data.id)

		self.curSelectedCardId = data.id

		self:previewCardBackground(data.id)

		button.isSelected = true
	end
end

function EditCardBgBarComponent:previewCardBackground(id)
	local cardBackgroundData = CardBackgroundData[id]

	if cardBackgroundData then
		self.ctrl.playerBgImage.url = cardBackgroundData.res
	end
end

function EditCardBgBarComponent:clearCardBackgroundPreview()
	self.curSelectedCardId = self.playerInfo.cardBackground

	self:previewCardBackground(self.playerInfo.cardBackground)
end

function EditCardBgBarComponent:refreshConfirmButtonState(id)
	self.usingUWidget:SetActive(false)
	self.btnConfirm:SetActive(true)
	self.btnConfirm:TryChangePage("IconState", 0)

	if self.model:isCardBackgroundLock(id) then
		if CardBackgroundData[id].item and ItemData[CardBackgroundData[id]] and ItemData[CardBackgroundData[id]].source and ItemSourceData[CardBackgroundData[id].item] and ItemSourceData[CardBackgroundData[id].item].param then
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GO_GET_ITEM"))
			self.btnConfirm:TryChangePage("IconState", 1)
			self.btnConfirm:TryChangePage("button", 0)

			self.btnConfirm.interactable = true

			self.getWayBottomText:SetActive(false)
		else
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("SKILL_LOCKED"))
			self.btnConfirm:TryChangePage("button", 4)

			self.btnConfirm.interactable = false

			self.getWayBottomText:SetActive(true)
			ClientTextUtils.setText(self.getWayBottomText, pg.getLocalizationText(CardBackgroundData[id].sourceDec))
		end
	elseif id == pg.me.cardBackground then
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GRAB_EGG_USE_LOADING"))
		self.btnConfirm:TryChangePage("button", 4)

		self.btnConfirm.interactable = false

		self.getWayBottomText:SetActive(false)
		self.usingUWidget:SetActive(true)
		self.btnConfirm:SetActive(false)
	else
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("USE"))
		self.btnConfirm:TryChangePage("button", 0)

		self.btnConfirm.interactable = true

		self.getWayBottomText:SetActive(false)
	end
end

function EditCardBgBarComponent:onConfirmBtnClick()
	if self.model:isCardBackgroundLock(self.curSelectedCardId) then
		local data = ItemSourceData[CardBackgroundData[self.curSelectedCardId].item]

		pg.me:doEventByData({
			data.param[1],
			data.param[2]
		})
	elseif self.curSelectedCardId and self.curSelectedCardId ~= pg.me.cardBackground then
		pg.me:serverMsg("RPC_CS_SetCardBackground", self.curSelectedCardId)
	end
end

function EditCardBgBarComponent:onCardBackgroundChange()
	self:previewCardBackground(self.playerInfo.cardBackground)
	self.cardList:RefreshList()
	self:refreshConfirmButtonState(self.playerInfo.cardBackground)
end

return EditCardBgBarComponent
