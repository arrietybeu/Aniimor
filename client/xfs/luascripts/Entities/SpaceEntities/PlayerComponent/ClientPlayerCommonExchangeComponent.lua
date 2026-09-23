-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerCommonExchangeComponent.lua

local class = require("Core.Framework.Class")
local SysNoticeData = require("Data.sys_notice_data")
local ClientPlayerCommonExchangeComponent = class.Component("ClientPlayerCommonExchangeComponent")

function ClientPlayerCommonExchangeComponent:ctor()
	return
end

function ClientPlayerCommonExchangeComponent:init(avtDict)
	return true
end

function ClientPlayerCommonExchangeComponent:destroy()
	return
end

function ClientPlayerCommonExchangeComponent:RPC_SC_OnCommonExchangeFail(failToast, failDialogue)
	if failToast and failToast ~= 0 then
		local noticeData = SysNoticeData[failToast]

		if noticeData then
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(noticeData.text))
		end
	end

	if failDialogue and failDialogue ~= 0 then
		pg.game.dialogue:playDialogueGraph(failDialogue)
	end
end

return ClientPlayerCommonExchangeComponent
