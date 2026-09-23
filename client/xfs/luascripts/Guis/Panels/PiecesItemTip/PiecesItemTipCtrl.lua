-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PiecesItemTip\\PiecesItemTipCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PiecesItemTipCtrl = Class.LightClass("PiecesItemTipCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local PiecesItemSpecialData = require("Data.pieces_item_special_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIUtils = UIUtils
local ClientTextUtils = require("Utils.ClientTextUtils")
local canClick = false

PiecesItemTipCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PiecesItemTipCtrl:getManagedBlurEffect()
	return self.view.blurEffect
end

function PiecesItemTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()

	self.state = 0
	canClick = false

	if info.piecesId and info.piecesId > 0 then
		self.piecesId = info.piecesId
		self.openType = 1
	else
		self.openType = 0
	end

	self.data = info
end

function PiecesItemTipCtrl:addListener()
	function self.view.close.luaClick()
		self:onCloseBtnClick()
	end
end

function PiecesItemTipCtrl:onCloseBtnClick()
	if canClick then
		if self.state == 0 then
			self.state = self.model:getPiecesItemState(self.data.id, self.openType)

			if self.state == 0 then
				self:onBtnClose()
			end

			self:setPiecesState()
		elseif self.state ~= 0 then
			self:onBtnClose()
		end
	end
end

function PiecesItemTipCtrl:onDestroy()
	local _h = PiecesItemTipCtrl._platformHooks

	if _h and _h.onDestroy then
		_h.onDestroy(self)
	end

	UICtrl.onDestroy(self)
end

function PiecesItemTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.state = 0

	if info.piecesId and info.piecesId > 0 then
		self.piecesId = info.piecesId
		self.openType = 1
	else
		self.openType = 0
	end

	self.data = info

	if self.openType == 1 then
		pg.me:serverMsg("RPC_CS_OnShowPieces", self.piecesId)
	end
end

function PiecesItemTipCtrl:onShow()
	pg.game.audio:triggerEvent("SFX_UI_ItemObtain_Special")
	self:setPiecesState()
	self:onInputDeviceChanged()

	local _h = PiecesItemTipCtrl._platformHooks

	if _h and _h.onShow then
		_h.onShow(self)
	end
end

function PiecesItemTipCtrl:setPiecesState()
	if self.state == 0 then
		self.view.cmp:TryChangePage("State", 0)
		self:setPiecesScanInfo()
	elseif self.state == 1 then
		self.view.cmp:TryChangePage("State", 1)
		self:setSpiecesItemInfo()

		canClick = true
	elseif self.state == 2 then
		self.view.cmp:TryChangePage("State", 2)
		self:setPiecesItemInfo()

		canClick = true
	end

	self:onInputDeviceChanged()
end

function PiecesItemTipCtrl:setPiecesScanInfo()
	local data = self.model:getPiecesInfo(self.data)

	if self.openType == 1 then
		data = self.model:getEventPiecesInfo(self.piecesId)
	end

	self.view.iconPropUImage.url = data.icon
	self.view.iconProp4UImage.url = data.icon
	self.view.iconProp5UImage.url = data.icon
	self.view.iconProp2UImage.url = data.icon
	self.view.iconProp1UImage.url = data.icon

	UIUtils.PlayAnimation(self.view.contentAnimation, "VX_Pb_FragmentInfo_Scan_In", function()
		UIUtils.PlayAnimation(self.view.contentAnimation, "VX_Pb_FragmentInfo_Scan_Loop", function()
			return
		end)

		self.state = self.openType == 1 and 2 or 1

		self:updateScanFinshInfo()
	end)
end

function PiecesItemTipCtrl:updateScanFinshInfo()
	self.state = self.model:getPiecesItemState(self.data.id, self.openType)

	if self.state == 0 then
		self:onBtnClose()
	end

	self:setPiecesState()
end

function PiecesItemTipCtrl:setPiecesStartInfo()
	UIUtils.PlayAnimation(self.view.contentAnimation, "VX_Pb_FragmentInfo_Info_In", function()
		UIUtils.PlayAnimation(self.view.contentAnimation, "VX_Pb_FragmentInfo_Info_Loop", function()
			return
		end)
	end)
end

function PiecesItemTipCtrl:setSpiecesItemInfo()
	local anchoredPos = self.view.cmp.transform.anchoredPosition
	local offsetY = self.data.offsetY ~= nil and self.data.offsetY or 0

	self.view.cmp.transform.anchoredPosition = Vector2(anchoredPos.x, anchoredPos.y - offsetY)

	local data = self.model:getPiecesInfo(self.data)

	self.view.icon.url = data.icon

	ClientTextUtils.setText(self.view.name, data.name)
	ClientTextUtils.setText(self.view.num, string.format("X%s", self.data.num * (self.data.magnification or 1)))
	ClientTextUtils.setText(self.view.ownNum, ItemUtils.getItemCountById(pg.me, self.data.id, true) or 0)
	LuaUIUtils.setUIVisible(self.view.num, false)
	LuaUIUtils.setUIVisible(self.view.ownName, false)
	LuaUIUtils.setUIVisible(self.view.ownNum, false)
	self.view.cmp:TryChangePage("Quality", data.quality)
	ClientTextUtils.setText(self.view.detail, data.funcRep)
	self.view.worldDetail:SetActive(true)
	ClientTextUtils.setText(self.view.worldDetail, pg.getLocalizationText(data.itemDesc))
end

function PiecesItemTipCtrl:setPiecesItemInfo()
	local data = self.model:getPiecesInfo(self.data)

	if self.openType == 1 then
		data = self.model:getEventPiecesInfo(self.piecesId)
	end

	local anchoredPos = self.view.cmp.transform.anchoredPosition
	local offsetY = self.data.offsetY ~= nil and self.data.offsetY or 0

	self.view.cmp.transform.anchoredPosition = Vector2(anchoredPos.x, anchoredPos.y - offsetY)

	LuaUIUtils.setUIVisible(self.view.ownNum, false)

	self.view.icon.url = data.icon

	ClientTextUtils.setText(self.view.name, data.name)
	ClientTextUtils.setText(self.view.ownNum, "")
	ClientTextUtils.setText(self.view.detail, data.funcRep)

	if self.openType == 1 then
		self.view.cmp:TryChangePage("Quality", 1)
	else
		self.view.cmp:TryChangePage("Quality", data.quality)
	end

	ClientTextUtils.setText(self.view.worldDetail, pg.getLocalizationText(data.itemDesc))
end

function PiecesItemTipCtrl:onHide()
	local _h = PiecesItemTipCtrl._platformHooks

	if _h and _h.onHide then
		_h.onHide(self)
	end
end

function PiecesItemTipCtrl:onBtnClose()
	if self.view.detail.IsRunningTypewriter or self.view.worldDetail.IsRunningTypewriter then
		self.view.worldDetail:TryFinishedStoryText()
		self.view.detail:TryFinishedStoryText()
	end

	self:dismiss()

	self.openType = 0
	self.state = 0

	if self.data.closeFunc then
		self.data.closeFunc()
	end
end

function PiecesItemTipCtrl:getWhiteList()
	return {
		[UIConst.UI_ID_NPC_CALL] = true
	}
end

function PiecesItemTipCtrl:onVisibleChange(visible)
	if visible then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PiecesItem, {
			[UIConst.UI_ID_PIECES_ITEM_PANEL] = true,
			[UIConst.UI_ID_TIPS] = true,
			[UIConst.UI_ID_PET_EVOLVE_PET_SHOW] = true,
			[UIConst.UI_ID_COMMON_CONFIRM] = true,
			[UIConst.UI_ID_NET_LOADING] = true
		})
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PiecesItem)
	end
end

function PiecesItemTipCtrl:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		-- block empty
	end
end

return PiecesItemTipCtrl
