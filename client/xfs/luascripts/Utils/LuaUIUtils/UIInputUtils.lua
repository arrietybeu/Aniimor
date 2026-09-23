-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIInputUtils.lua

local TimerManager = require("Core.Timer.TimerManager")

return function(LuaUIUtils)
	function LuaUIUtils.bindInputFieldGamepad(inputField, keyHotKeyContent, btnDeleteUButton)
		keyHotKeyContent.gameObject:SetActiveEx(false)

		function inputField.luaOnSelect()
			btnDeleteUButton:SetHotkeyForceHidden(false)
		end

		function inputField.luaOnDeSelect()
			btnDeleteUButton:SetHotkeyForceHidden(true)
		end

		function btnDeleteUButton.luaClick()
			local function refocusInputField()
				pg.global.navMgr:FocusItem(inputField)
				inputField:OnClickSimulate(true)
			end

			inputField.text = ""

			TimerManager.addNextFrameCb(refocusInputField)
		end

		btnDeleteUButton:SetActive(not string.isNilOrEmpty(inputField.text))
		btnDeleteUButton:SetHotkeyForceHidden(true)
	end
end
