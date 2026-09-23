-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PeepExit\\PeepExitCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local PeepExitCtrl = Class.LightClass("PeepExitCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PeepExitCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view.iconUImage.url = "$UI_SkillIcon_Pet_SkillExit.png"

	if pg.game.input:isUsingGamepad() then
		self.view.keyHotKeyContent:SetHotKeyPaths("Raw/GamepadButtonEast")
	else
		self.view.keyHotKeyContent:SetHotKeyPaths("Photo/Esc")
	end

	self.view.btnSpecialUButton:TryChangePage("Ready", 1)
	ClientTextUtils.setText(self.view.txtNameUText, pg.getGameString("PEEP_QUIT"))
end

function PeepExitCtrl:addListener()
	function self.view.btnSpecialUButton.luaClick()
		facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.PLAYER_HURT, {})
	end
end

function PeepExitCtrl:checkUILockCursor()
	return true
end

function PeepExitCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function PeepExitCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PeepExitCtrl:onShow()
	UICtrl.onShow(self)
end

return PeepExitCtrl
