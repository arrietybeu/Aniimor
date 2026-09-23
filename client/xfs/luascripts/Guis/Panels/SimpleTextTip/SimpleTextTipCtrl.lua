-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SimpleTextTip\\SimpleTextTipCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("SimpleTextTipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local SimpleTextTipCtrl = Class.LightClass("SimpleTextTipCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

SimpleTextTipCtrl.messages = {
	[MessageName.UI_ON_HIDE] = {
		"onUIHide",
		true
	}
}

function SimpleTextTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function SimpleTextTipCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:close()
	end)

	function self.view.rootCmp.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end

	function self.view.rootCmp.luaSetScale()
		local scale = self.iData.scale or 1

		self.view.transform.localScale = Vector3(scale, scale, scale)
	end
end

function SimpleTextTipCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function SimpleTextTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.iData = info

	if self.iData.extra and self.iData.extra.openFun then
		self.iData.extra.openFun()
	end
end

function SimpleTextTipCtrl:checkCanOpen(showNotice, data)
	if data == nil then
		return false
	end

	self.iData = data

	return true
end

function SimpleTextTipCtrl:onUIHide()
	if not self:checkUIShow() then
		return
	end

	self:close()
end

function SimpleTextTipCtrl:onShow()
	if self.iData == nil then
		return
	end

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	ClientTextUtils.setText(self.view.txtNameUSDFText, self.iData.infoText)
	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)
	self.view.rootCmp:OpenPopup(self.iData.targetRect)

	if self.iData.tooltipAnchor then
		LuaUIUtils.alignTooltipToAnchorLeftTop(self.view.rootCmp, self.iData.tooltipAnchor)
	end
end

function SimpleTextTipCtrl:onHide()
	return
end

return SimpleTextTipCtrl
