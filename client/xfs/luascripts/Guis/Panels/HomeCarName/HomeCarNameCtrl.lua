-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarName\\HomeCarNameCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local OpDef = require("Common.OpDef")
local HomelandConfigData = require("Data.homeland_config_data")
local logger = LoggerManager.getLogger("HomeCarNameCtrl")
local HomeCarNameCtrl = Class.LightClass("HomeCarNameCtrl", UICtrl)

function HomeCarNameCtrl:onCreate(info)
	HomeCarNameCtrl.super.onCreate(self, info)
end

function HomeCarNameCtrl:addListener()
	function self.view.inputField.luaValueChanged(name)
		self:onNameChanged(name)
	end

	function self.view.btnEnter.luaClick()
		self:submitRename()
	end
end

function HomeCarNameCtrl:onOpen(info)
	local defaultName = pg.getFormatText(pg.getGameString("CAR_NAME_POSTFIX"), pg.me.playerName)

	defaultName = self.model:getValidName(defaultName)

	self.view.inputField:SetTextWithoutNotify(defaultName)
end

function HomeCarNameCtrl:setDefaultShapeInfo(shapeInfo)
	self.shapeInfo = shapeInfo
end

function HomeCarNameCtrl:onDestroy()
	HomeCarNameCtrl.super.onDestroy(self)
end

function HomeCarNameCtrl:onNameChanged(name)
	name = self.model:getValidName(name)

	self.view.inputField:SetTextWithoutNotify(name)
end

function HomeCarNameCtrl:submitRename()
	if pg.me.isHomeCampUnlocked then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAR_UNLOCK)
		self:close()

		return
	end

	local newName = self.view.inputField.text

	if string.isNilOrEmpty(newName) then
		local defaultName = pg.getFormatText(pg.getGameString("CAR_NAME_POSTFIX"), pg.me.playerName)

		newName = self.model:getValidName(defaultName)

		self.view.inputField:SetTextWithoutNotify(newName)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("HomeCarNameCtrl create car name: ", newName)
	end

	local firstCreateCampId = HomelandConfigData.unlockDefaultCampId or 84222580

	if not self.shapeInfo then
		self.shapeInfo = Utils.getDefaultCarShapeInfo()
	end

	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_UnlockCamp, {
		staticId = firstCreateCampId,
		name = newName,
		shapeInfo = self.shapeInfo
	}, function(noticeId, noticeArgs)
		if noticeId ~= NoticeDef.SUCCESS then
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
		end

		if noticeId == NoticeDef.HOME_CAR_UNLOCK then
			self:close()
		end
	end)
end

function HomeCarNameCtrl:onUnlockSucc()
	if self.view then
		self.view.rootComponent:TryChangePage("Tips", 0)
		self.view.rootComponent:TryChangePage("Pass", 1)
		self:dismiss()
	end
end

function HomeCarNameCtrl:onNameResult(noticeId)
	if self.view and noticeId == NoticeDef.HOME_CAR_NAME_SENSITIVE then
		self.view.rootComponent:TryChangePage("Tips", 1)
		self.view.rootComponent:TryChangePage("Pass", 0)
		ClientTextUtils.setText(self.view.txtTips, pg.getGameString("INPUT_TEXT_CONTAINS_SENSITIVE"))
	end
end

return HomeCarNameCtrl
