-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\CaptureWizard.lua

local SysConfigData = require("Data.sys_config_data")
local NoticeDef = require("Common.NoticeDef")
local CaptureWizard = {}

function CaptureWizard.advise(prob)
	if prob < 0.5 then
		pg.global.showBubbleMessage(NoticeDef.CAPTURE_FAILED)

		return true
	end

	return false
end

return CaptureWizard
