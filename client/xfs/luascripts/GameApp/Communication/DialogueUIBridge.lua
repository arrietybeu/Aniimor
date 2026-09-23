-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueUIBridge.lua

local ClientConst = require("Const.ClientConst")
local DialogueConst = require("Const.DialogueConst")
local UIConst = require("Const.UIConst")
local M = {}

function M.closeDialogUI(key)
	pg.global.ui.npcCall:setIsModel(false)
	pg.global.ui.plotPhoneCall:setIsModel(true)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:close()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PLOT_PHONE_CALL) then
		pg.global.ui.plotPhoneCall:close()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOTTOM_DIALOGUE) then
		pg.global.ui.dialogue:finishDialogue()
		pg.global.ui.dialogue:close()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_AI_ASSISTANT) then
		pg.global.ui.aiAssistant:startClose()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SUBTITLES_PANEL) then
		pg.global.ui.SubtitlesPanel:close()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BLACK_SCREEN) and key ~= DialogueConst.DIALOGUE_CLOSE_KEY.DIALOG_CLOSE_NODE and pg.global.ui.blackScreen:isDialogueGraphScreen() then
		pg.global.ui.blackScreen:startCloseScreen()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_WHITE_SCREEN) and key ~= DialogueConst.DIALOGUE_CLOSE_KEY.DIALOG_CLOSE_NODE and pg.global.ui.whiteScreen:isDialogueGraphScreen() then
		pg.global.ui.whiteScreen:startCloseScreen()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_DIALOG_REVIEW) then
		pg.global.ui:close(UIConst.UI_ID_DIALOG_REVIEW)
	end
end

function M.hideDialogueTextUI()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_SUBTITLES_PANEL) then
		pg.global.ui.SubtitlesPanel:hide()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:hideNpcCallContent()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BOTTOM_DIALOGUE) then
		pg.global.ui.dialogue:finishDialogue()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_AI_ASSISTANT) then
		pg.global.ui.aiAssistant:hide()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BLACK_SCREEN) and pg.global.ui.blackScreen.isDialogueGraph and pg.global.ui.blackScreen:isDialogueGraphScreen() then
		pg.global.ui.blackScreen:closeScreen()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_WHITE_SCREEN) then
		pg.global.ui.whiteScreen:closeScreen()
	end
end

function M.enableDialogUIMonopoly(enable)
	if enable then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.Dialogue, {
			[UIConst.UI_ID_BOTTOM_DIALOGUE] = true,
			[UIConst.UI_ID_TIPS] = true,
			[UIConst.UI_ID_COMMON_OBTAIN] = true,
			[UIConst.UI_ID_CONFIG_TOPPING] = true,
			[UIConst.UI_ID_PLOT_PHONE_CALL] = true,
			[UIConst.UI_ID_DIALOG_REVIEW] = true,
			[UIConst.UI_ID_BLACK_SCREEN] = true,
			[UIConst.UI_ID_LOADING] = true,
			[UIConst.UI_ID_SUBTITLES_PANEL] = true,
			[UIConst.UI_ID_PICTURE] = true,
			[UIConst.UI_ID_AI_ASSISTANT] = true,
			[UIConst.UI_ID_NPC_CALL] = true,
			[UIConst.UI_ID_COMMON_CONFIRM] = true,
			[UIConst.UI_ID_DIALOGUE_SKIP] = true,
			[UIConst.UI_ID_BLACK_SCREEN_SKIP_PANEL] = true,
			[UIConst.UI_ID_WHITE_SCREEN] = true
		})
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.Dialogue)
	end
end

function M.enableDeprivePlayerControl(enable)
	pg.global.ui.npcCall:setIsModel(enable)
	pg.global.ui.plotPhoneCall:setIsModel(enable)
	pg.global.ui.dialogue:setIsModel(enable)
	pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, not enable)
end

return M
