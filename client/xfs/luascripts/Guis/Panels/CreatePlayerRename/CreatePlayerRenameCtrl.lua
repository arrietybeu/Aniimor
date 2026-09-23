-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayerRename\\CreatePlayerRenameCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CreatePlayerRenameCtrl = Class.LightClass("CreatePlayerRenameCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CreatePlayerRenameCtrl")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local SysNoticeData = require("Data.sys_notice_data")

CreatePlayerRenameCtrl.messages = {}

function CreatePlayerRenameCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CreatePlayerRenameCtrl:addListener()
	function self.view.inputField.luaValueChanged(name)
		self:onNameChanged(name)
	end

	function self.view.btnRandom.luaClick()
		self:randomName()
	end

	function self.view.btnEnter.luaClick()
		self:submitRename()
	end
end

function CreatePlayerRenameCtrl:onDestroy()
	UICtrl.onDestroy(self)
	LuaUIUtils.resetPlayerState()
end

function CreatePlayerRenameCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.canSubmit = true

	LuaUIUtils.openWristWatch()
	self.view.inputField:Select()
end

function CreatePlayerRenameCtrl:randomName()
	local randomName = self.model:getRandomName()

	self.view.inputField:SetTextWithoutNotify(randomName)
end

function CreatePlayerRenameCtrl:onNameChanged(name)
	name = self.model:getValidName(name)

	self.view.inputField:SetTextWithoutNotify(name)
end

function CreatePlayerRenameCtrl:submitRename()
	local newName = self.view.inputField.text

	if string.isNilOrEmpty(newName) then
		self.view.rootComponent:TryChangePage("Tips", 1)
		ClientTextUtils.setText(self.view.txtTips, pg.getGameString("TAG_NAME_NULL"))

		return
	end

	if ClientTextUtils.containsBlank(newName) then
		self.view.rootComponent:TryChangePage("Tips", 1)
		ClientTextUtils.setText(self.view.txtTips, pg.getGameString("PLAYER_NAME_CONTAINS_BLANK"))

		return
	end

	if ClientTextUtils.containsRichText(newName) then
		self.view.rootComponent:TryChangePage("Tips", 1)
		ClientTextUtils.setText(self.view.txtTips, pg.getGameString("CONTENT_CONTAINS_RICH_TEXT"))

		return
	end

	if not self.view.inputField:CanRenderText(newName) then
		self.view.rootComponent:TryChangePage("Tips", 1)
		ClientTextUtils.setText(self.view.txtTips, pg.getGameString("NAME_NOT_VALID"))

		return
	end

	if not self.canSubmit then
		return
	end

	self.canSubmit = false

	logger:info("@zqd createNameResult1: ", newName)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@zqd create user name: ", newName)
	end

	pg.me:serverMsg("RPC_CS_ChangePlayerName", newName)
end

function CreatePlayerRenameCtrl:createNameResult(errorCode)
	logger:info("@zqd createNameResult2: ", errorCode)

	if errorCode == Const.CHANGE_NAME_RETURN_CODE.SUCCESS then
		self.view.rootComponent:TryChangePage("Tips", 0)
		self.view.rootComponent:TryChangePage("Pass", 1)
		self:dismiss()

		return
	else
		self.canSubmit = true

		self.view.rootComponent:TryChangePage("Tips", 1)
		self.view.rootComponent:TryChangePage("Pass", 0)
	end

	if errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_CHECK_FAIL or errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_OP_TIMEOUT or errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_EXCEPTION then
		local noticeData = SysNoticeData[NoticeDef.TID_SERVICE_ERROR]

		ClientTextUtils.setText(self.view.txtTips, pg.getLocalizationText(noticeData.text))
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_REPEAT then
		ClientTextUtils.setText(self.view.txtTips, pg.getGameString("NAME_EDIT_SAME"))
	elseif errorCode == Const.CHANGE_NAME_RETURN_CODE.ERROR_NAME_FAIL then
		ClientTextUtils.setText(self.view.txtTips, pg.getGameString("NAME_EDIT_DEFEAT"))
	end
end

return CreatePlayerRenameCtrl
