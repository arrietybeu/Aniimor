-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChangeName\\ChangeNameCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local UICtrl = require("Guis.UICtrl")
local ChangeNameCtrl = Class.LightClass("ChangeNameCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local SysNoticeData = require("Data.sys_notice_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local SysConfigData = require("Data.sys_config_data")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local PlayerForbidConst = require("Common.Const.PlayerForbidConst")
local EditType = {
	Remark = 1,
	Name = 0,
	GroupName = 2
}

local function getPlainInputText(text)
	return tostring(text or ""):gsub("<[^>]->", "")
end

function ChangeNameCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info or {}
	self.editType = self.info.editType or EditType.Name
	self.playerId = self.info.playerId
	self.groupId = self.info.groupId
	self.originText = self.editType == EditType.Remark and getPlainInputText(info.initialInputText) or info.initialInputText

	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("EDIT_NAME"))
	ClientTextUtils.setText(self.view.tipsUSDFText, pg.getFormatText(pg.getGameString("EDIT_NAME_LENGTH_LIMIT"), SysConfigData.playerNameMaxLen))

	self.originText, self.useSpace = ClientTextUtils.getValidName(self.originText, SysConfigData.playerNameMaxLen)

	ClientTextUtils.setText(self.view.txtLimitUSDFText, self.useSpace .. "/" .. SysConfigData.playerNameMaxLen * 2)
	ClientTextUtils.setText(self.view.textConsumeUSDFText, pg.getGameString("NAME_CHANGE_COST"))

	self.view.inputFieldUTMPInputField.text = self.originText

	if self.editType == EditType.Remark then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("EDIT_REMARK"))
		ClientTextUtils.setText(self.view.tipsUSDFText, pg.getFormatText(pg.getGameString("EDIT_REMARK_LENGTH_LIMIT"), SysConfigData.playerNameMaxLen))
		self.view.widget:TryChangePage("CostItem", 1)
	elseif self.editType == EditType.Name then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("EDIT_NAME"))
		ClientTextUtils.setText(self.view.tipsUSDFText, pg.getFormatText(pg.getGameString("EDIT_NAME_LENGTH_LIMIT"), SysConfigData.playerNameMaxLen))

		local costItems = {}

		for id, val in pairs(SysConfigData.playerNameCost) do
			table.insert(costItems, {
				itemId = id,
				itemCount = val
			})
		end

		if #costItems > 0 then
			self.view.widget:TryChangePage("CostItem", 0)
			self.view.consumeListUList:SetList(costItems)
		end
	elseif self.editType == EditType.GroupName then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("EDIT_CHAT_GROUP_NAME"))
		self.view.widget:TryChangePage("CostItem", 1)
	end
end

function ChangeNameCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	self:bindHotKeyPerform("Common/ClosePanelCommon", function()
		self.view.btnCloseUButton.luaClick()
	end, self.view.widget.gameObject)

	function self.view.btnCancelUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirmButtonClick()
	end

	function self.view.inputFieldUTMPInputField.luaValueChanged(newName)
		self.newArgs, self.useSpace = ClientTextUtils.getValidName(newName, SysConfigData.playerNameMaxLen)

		self.view.inputFieldUTMPInputField:SetTextWithoutNotify(self.newArgs)
		ClientTextUtils.setText(self.view.txtLimitUSDFText, self.useSpace .. "/" .. SysConfigData.playerNameMaxLen * 2)
	end

	function self.view.consumeListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUText = objectReference:GetRefValue("txtNumUText")

		itemIconUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

		local curItemCount = ItemUtils.getItemCountById(pg.me, data.itemId) or 0

		LuaUIUtils.renderConsumeText(txtNumUText, curItemCount, data.itemCount, UIConst.ITEM_STATE.FULL)

		local itemConfig = ItemData[data.itemId]

		if itemConfig then
			button:TryChangePage("Quality", itemConfig.quality)
		end

		button.tooltipMode = 1

		function button.luaRenderTooltip(btn, tooltip)
			LuaUIUtils.refreshItemInfo(tooltip, data, button, nil, function()
				if self.view then
					self.view:setViewVisible(false)
				end

				self:close()
			end)
		end
	end
end

function ChangeNameCtrl:onConfirmButtonClick()
	if self.editType == EditType.Remark then
		self:changeFriendRemark()
	elseif self.editType == EditType.Name then
		self:changePlayerName()
	elseif self.editType == EditType.GroupName then
		self:changeChatGroupName()
	end
end

function ChangeNameCtrl:changeFriendRemark()
	if self.newArgs == self.originText then
		pg.global.showBubbleMessageRaw(pg.getGameString("FRIEND_REMARK_NO_DIFFERENCE"))

		return
	end

	pg.me:setFriendRemark(self.playerId, self.newArgs)
end

function ChangeNameCtrl:changeChatGroupName()
	if self.newArgs == self.originText then
		pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_GROUP_NAME_NO_DIFFERENCE"))

		return
	elseif string.isNilOrEmpty(self.newArgs) then
		pg.global.showBubbleMessageRaw(pg.getGameString("GROUPCHAT_NAME_DESC"))

		return
	end

	pg.me:setChatGroupStatus(self.groupId, self.newArgs)
end

function ChangeNameCtrl:changePlayerName()
	self.newArgs = self.newArgs or self.view.inputFieldUTMPInputField.text

	if LuaUIUtils.checkFeatureForbid(PlayerForbidConst.PLAYER_SWITCH.CHANGE_PLAYER_NAME) then
		return
	end

	if ClientTextUtils.containsBlank(self.newArgs) then
		pg.global.showBubbleMessageRaw(pg.getGameString("PLAYER_NAME_CONTAINS_BLANK"), 2)

		return
	end

	if ClientTextUtils.containsRichText(self.newArgs) then
		pg.global.showBubbleMessageRaw(pg.getGameString("CONTENT_CONTAINS_RICH_TEXT"), 2)

		return
	end

	for id, val in pairs(SysConfigData.playerNameCost) do
		local curItemCount = ItemUtils.getItemCountById(pg.me, id) or 0

		if curItemCount < val then
			self:createNameResult(Const.CHANGE_NAME_RETURN_CODE.ERROR_ITEM_NOT_ENOUGH)

			return
		end
	end

	if string.isNilOrEmpty(self.newArgs) then
		self:createNameResult(Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_NULL)

		return
	elseif pg.me.playerName == self.newArgs then
		-- block empty
	end

	pg.me:serverMsg("RPC_CS_ChangePlayerName", self.newArgs, CallbackHandler(self, "changePlayerName"))
	self.view.inputFieldUTMPInputField:SetTextWithoutNotify(self.newArgs)
end

function ChangeNameCtrl:createNameResult(errorCode)
	local index = 0

	if errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_REPEAT then
		index = 10611
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_FAIL then
		index = 10612
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_OP_TIMEOUT then
		index = 10613
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_EXCEPTION then
		index = 10614
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.SUCCESS then
		index = 10615
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_NULL then
		index = 10618
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_ITEM_NOT_ENOUGH then
		index = 10217
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_CHECK_FAIL then
		index = 10610
	end

	local cData = SysNoticeData[index or 0]

	if cData then
		local desc = pg.getLocalizationText(cData.text)

		pg.global.showBubbleMessageRaw(desc, 2)
	end

	if errorCode == Const.CHANGE_NAME_RETURN_CODE.SUCCESS then
		self:close()
	end
end

return ChangeNameCtrl
