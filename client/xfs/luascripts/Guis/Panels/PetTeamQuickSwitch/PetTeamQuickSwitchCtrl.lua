-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTeamQuickSwitch\\PetTeamQuickSwitchCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetTeamQuickSwitchCtrl = Class.LightClass("PetTeamQuickSwitchCtrl", UICtrl)

PetTeamQuickSwitchCtrl.messages = {}

function PetTeamQuickSwitchCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetTeamQuickSwitchCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.panelTransform.gameObject, "Common/KeyboardCancel", function()
		self:dismiss()
	end)
	LuaUIUtils.bindHotKey(self.view.panelTransform.gameObject, "Hud/SwitchPetTeam", function()
		self:dismiss()
	end)
end

function PetTeamQuickSwitchCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetTeamQuickSwitchCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetTeamQuickSwitchCtrl:onShow()
	return
end

function PetTeamQuickSwitchCtrl:onHide()
	return
end

return PetTeamQuickSwitchCtrl
