-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ThrowPanel\\Component\\ThrowPanelPCComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("ThrowPanelPCComponent")
local AddressDataConst = require("Const.AddressDataConst")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ThrowPanelPCComponent = Class.LightClass("ThrowPanelPCComponent", UIComponent)

function ThrowPanelPCComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listBtnUList = objectReference:GetRefValue("listBtnUList")
	self.cancelBtnTxt = nil
	self.catchBtnTxt = nil
end

function ThrowPanelPCComponent:initView()
	local bindObject = self.ctrl.view.widget.gameObject
	local catchBind = KeyBindingPro.GetOrAddKeyBindingByName(bindObject, "catchBind")

	catchBind.isVirtual = true
	catchBind.actionPath = "Catch/SwitchCatchMode"

	function catchBind.luaTrigger(inputInfo)
		local useGamepadHold = pg.game.input:isUsingGamepad() and pg.game.setting:getHoldToEnterCatchMode()

		if useGamepadHold then
			if inputInfo.phase == "Performed" then
				self:handleSwitchCatchModeAction(true)
			elseif inputInfo.phase == "Canceled" then
				self:handleSwitchCatchModeAction(false)
			end
		elseif inputInfo.phase == "Performed" then
			self:handleSwitchCatchModeAction()
		end
	end

	if self.listBtnUList then
		function self.listBtnUList.luaRenderItem(button, idx, data)
			self:renderOperateBtn(button, idx, data)
		end

		self:setOperateBtn()
	else
		logger:warn("initView failed: listBtnUList is nil, check prefab ObjectReference key")
	end
end

function ThrowPanelPCComponent:renderOperateBtn(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(txtNameUText, data.name)

	iconUImage.url = data.icon

	if idx == 0 then
		self.catchBtnTxt = txtNameUText

		self:bindCatchButton(button)
	elseif idx == 1 then
		self.cancelBtnTxt = txtNameUText

		self:bindCancelButton(button)
	end
end

function ThrowPanelPCComponent:getOperateData()
	local ret = {}

	ret[#ret + 1] = {
		name = pg.getGameString("THROW"),
		icon = AddressDataConst.UI_ICON_HUD_THROW
	}
	ret[#ret + 1] = {
		name = pg.getGameString("CANCEL_THROW_MODE"),
		icon = AddressDataConst.UI_ICON_HUD_THROW_CANCEL
	}

	return ret
end

function ThrowPanelPCComponent:setOperateBtn()
	self.listBtnUList:SetList(self:getOperateData())
end

function ThrowPanelPCComponent:bindCancelButton(btn)
	local cancelKeyBind = btn:GetComponent("KeyBindingPro")

	cancelKeyBind.actionPath = "Catch/ThrowCanel"
	cancelKeyBind.isVirtual = true

	function cancelKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:handleSwitchCatchModeAction()
		end
	end
end

function ThrowPanelPCComponent:bindCatchButton(btn)
	local throwKeyBind = btn:GetComponent("KeyBindingPro")

	throwKeyBind.actionPath = "Catch/Throw"
	throwKeyBind.isVirtual = true

	function throwKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:handleCatchAction()
		end
	end
end

function ThrowPanelPCComponent:handleSwitchCatchModeAction(enable)
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if pg.me.space:isRogueEnv() then
		return
	end

	if pg.game.controller ~= nil then
		pg.game.controller:onHandleSwitchCatchMode(enable)
	end
end

function ThrowPanelPCComponent:handleCatchAction()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleThrow()
	end
end

function ThrowPanelPCComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return ThrowPanelPCComponent
