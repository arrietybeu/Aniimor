-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpMenu\\Component\\PvpMenuComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PvpMenuComponent = Class.LightClass("PvpMenuComponent", UIComponent)
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")

function PvpMenuComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnMod1 = self.objectReference:GetRefValue("btnMod1")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnLeft = self.objectReference:GetRefValue("btnLeft")
	self.btnRight = self.objectReference:GetRefValue("btnRight")
end

function PvpMenuComponent:initView()
	local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
	local HotkeyConst = require("Const.HotkeyConst")
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnClose.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			pg.global.ui:close(UIConst.UI_ID_PVP_MENU)
		end
	end

	function self.btnClose.luaClick()
		pg.global.ui:close(UIConst.UI_ID_PVP_MENU)
	end

	function self.btnMod1.luaClick()
		pg.game.audio:triggerEvent("SFX_UI_PVP_Mode_In")
		self.ctrl:switchPage(1)
	end

	function self.btnLeft.luaClick()
		self:switchMode(-1)
	end

	function self.btnRight.luaClick()
		self:switchMode(1)
	end
end

function PvpMenuComponent:switchMode(switch)
	local newMode = pg.game.pvp.souDaCheMode + switch

	if newMode < Const.SpaceBattleMode.OnePlusThree then
		newMode = Const.SpaceBattleMode.TwoPlusTwo
	end

	if newMode > Const.SpaceBattleMode.TwoPlusTwo then
		newMode = Const.SpaceBattleMode.OnePlusThree
	end

	pg.game.pvp.souDaCheMode = newMode

	self:refreshModeState()
end

function PvpMenuComponent:onShow()
	self.view.animation:Play("VX_Pb_PVP_Main_In")
	self:refreshModeState()
end

function PvpMenuComponent:refreshModeState()
	self.view.component:TryChangePage("GameMode", pg.game.pvp:isOne2Three() and 0 or 1)
end

function PvpMenuComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PvpMenuComponent
