-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformPlayerEnhanceLoadingCtrl.lua

local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local M = {}
local CONFIRM_BIND_NAME = "playerEnhanceLoadingConfirmBind"

function M:onShow()
	local gameObject = self.view and self.view.transform and self.view.transform.gameObject

	if not gameObject then
		return
	end

	local confirmBind = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, CONFIRM_BIND_NAME)

	confirmBind.isVirtual = true
	confirmBind.priority = -1
	confirmBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Confirm

	function confirmBind.luaTrigger(inputInfo)
		if inputInfo.phase ~= "Performed" then
			return
		end

		if self.entering then
			return
		end

		self:startEnter()
	end

	self._gamepadConfirmBind = confirmBind
end

function M:onHide()
	if self._gamepadConfirmBind then
		self._gamepadConfirmBind.luaTrigger = nil
	end
end

function M:onDestroy()
	if self._gamepadConfirmBind then
		self._gamepadConfirmBind.luaTrigger = nil
		self._gamepadConfirmBind = nil
	end
end

function M:onStartEnter()
	if self._gamepadConfirmBind then
		self._gamepadConfirmBind.luaTrigger = nil
	end
end

function M:afterOpenPlayerEnhanceInBackground()
	return
end

return M
