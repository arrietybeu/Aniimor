-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PlatformSwitchUtils.lua

local UIConst = require("Const.UIConst")
local PlatformSwitchUtils = {}

function PlatformSwitchUtils.onPlatformSwitched()
	if not pg.me then
		return
	end

	local hudCtrl = pg.global.ui.ctrlDict.hudV2
	local hudWasVisible = hudCtrl and hudCtrl._visible
	local hudHideMarks

	if hudCtrl and hudCtrl.hideMarkDict then
		hudHideMarks = {}

		for k, v in pairs(hudCtrl.hideMarkDict) do
			hudHideMarks[k] = v
		end
	end

	pg.global.ui:closePlatformSensitivePanels()
	pg.global.ui:open(UIConst.UI_ID_HUD_V2)

	local newHudCtrl = pg.global.ui.ctrlDict.hudV2

	if newHudCtrl then
		if hudWasVisible == false and newHudCtrl.hide then
			newHudCtrl:hide()
		end

		if hudHideMarks and newHudCtrl.setUIHide then
			for key, _ in pairs(hudHideMarks) do
				newHudCtrl:setUIHide(key, true)
			end
		end
	end

	if pg.global.ui:runPlatformByMobile() then
		pg.global.ui.mobileOperate:open()
	end

	if pg.game.camera then
		pg.game.camera:refreshCameraZoomLimit()
	end
end

return PlatformSwitchUtils
