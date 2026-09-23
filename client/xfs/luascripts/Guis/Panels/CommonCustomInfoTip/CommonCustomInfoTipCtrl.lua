-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonCustomInfoTip\\CommonCustomInfoTipCtrl.lua

local Class = require("Core.Framework.Class")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local CommonCustomInfoTipCtrl = Class.LightClass("CommonCustomInfoTipCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

CommonCustomInfoTipCtrl.messages = {}

function CommonCustomInfoTipCtrl:onCreate(data)
	UICtrl.onCreate(self, data)
end

function CommonCustomInfoTipCtrl:onOpen(data)
	UICtrl.onOpen(self, data)

	self.iData = data

	if self.iData.extra and self.iData.extra.openFun then
		self.iData.extra.openFun()
	end
end

function CommonCustomInfoTipCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.rootCmp.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			pg.global.ui:close(UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP)
		end
	end

	function self.view.rootCmp.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end
end

function CommonCustomInfoTipCtrl:checkCanOpen(showNotice, data)
	if data == nil then
		return false
	end

	self.iData = data

	return true
end

function CommonCustomInfoTipCtrl:onShow()
	if self.iData == nil then
		return
	end

	self:refreshCustomInfo()

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)
	self.view.rootCmp:OpenPopup(self.iData.targetRect)
end

function CommonCustomInfoTipCtrl:refreshCustomInfo()
	local data = self.iData

	self.view.rootCmp:TryChangePage("BuffType", "None")

	self.view.iconUImage.url = data.icon

	ClientTextUtils.setText(self.view.buffNameUText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(self.view.buffDetailUText, pg.getLocalizationText(data.desc))

	if data.extra then
		self.view.rootCmp:TryChangePage("GroupType", data.extra.groupType)
		self.view.rootCmp:TryChangePage("Quality", data.extra.quality)
	end
end

return CommonCustomInfoTipCtrl
