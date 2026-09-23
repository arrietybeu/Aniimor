-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerRename\\PlayerRenameCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PlayerRenameCtrl = Class.LightClass("PlayerRenameCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local RedDotConst = require("Const.RedDotConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")

PlayerRenameCtrl.messages = {}

function PlayerRenameCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PlayerRenameCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnCloseMin.luaClick()
		self:dismiss()
	end

	function self.view.btnCloseNewUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.headList.luaRenderItem(button, _, data)
		self:onRenderHeadItem(button, data)
	end

	function self.view.btnConfirm.luaClick()
		self:onBtnConfirm()
	end

	function self.view.btnConfirmNewUButton.luaClick()
		self:onBtnConfirm()
	end

	function self.view.inputField.luaValueChanged(newName)
		local maxLen = self.argData and self.argData.maxLen or SysConfigData.playerNameMaxLen

		self.newArgs = ClientTextUtils.getValidName(newName, maxLen)

		self.view.inputField:SetTextWithoutNotify(self.newArgs)
	end
end

function PlayerRenameCtrl:onDestroy()
	self.model:redDot_CheckSaveDirty()
	UICtrl.onDestroy(self)
end

function PlayerRenameCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.argData = info
	self.newArgs = nil
end

function PlayerRenameCtrl:onShow()
	self:onRefreshView()
end

function PlayerRenameCtrl:onRefreshView()
	if self.argData.mode == "Rename" then
		ClientTextUtils.setText(self.view.txtTitle, self.argData.title)
		self.view.rootComponent:TryChangePage("State", 0)

		local placeholder = self.argData.placeholder or pg.me.playerName

		ClientTextUtils.setText(self.view.inputField.placeHolder, placeholder)

		if self.argData.initialText then
			self.newArgs = self.argData.initialText

			self.view.inputField:SetTextWithoutNotify(self.argData.initialText)
		end
	else
		self.view.rootComponent:TryChangePage("State", 1)

		local dataList = self.model:getUserHeadIconList()

		self.view.headList:SetList(dataList)

		local res, headBtn = self.view.headList:TryGetChildAt(0)

		if res then
			headBtn:OnClickSimulate()
		end
	end
end

function PlayerRenameCtrl:onRenderHeadItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local headIcon = oc:GetRefValue("headIcon")

	headIcon.url = data.icon

	local treePath = string.format(RedDotConst.RedDotPath.PLAYER_ICON_ITEM, data.icon or "")
	local showRedDot = self.model:redDot_GetPlayerIconListItemState(data)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.NEW)

	function button.luaClick()
		self:onClickSkillItem(button)
		self.model:redDot_SetPlayerIconListItemState(data)
		pg.global.setRedDot(treePath, button, false)
	end

	button:TryChangePage("Selected", data.selected and 1 or 0)
end

function PlayerRenameCtrl:onClickSkillItem(button)
	local btnList = self.view.headList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		v:TryChangePage("GamePadFocus", v == button and 1 or 0)
	end

	local data = button.dataFromUList

	self.newArgs = data.id
end

function PlayerRenameCtrl:onBtnConfirm()
	if self.argData.confirmCallback == nil then
		self:close()

		return
	end

	if self.argData.mode == "Rename" then
		pg.me:sensitiveWordsCheck(self.newArgs, function(text)
			self:close()
			self.argData.confirmCallback(text)
		end, nil, self.argData.sensitiveWordsCheckExtraInfo)
	else
		self:close()
		self.argData.confirmCallback(self.newArgs)
	end
end

function PlayerRenameCtrl:close()
	if self.argData.mode == "Rename" then
		self.view.inputField.placeHolder:SetActive(false)
	end

	UICtrl.close(self)
end

function PlayerRenameCtrl:onHide()
	return
end

return PlayerRenameCtrl
