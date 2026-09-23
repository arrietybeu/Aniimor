-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\DialogFunction\\DialogFunctionCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local DialogFunctionCtrl = Class.LightClass("DialogFunctionCtrl", UICtrl)

function DialogFunctionCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.reviewLogBtn.luaClick()
		self:onReviewLogBtnClick()
	end
end

function DialogFunctionCtrl:addListener()
	self:bindHotKeyPerform("Hud/DialogueReviewLogGamepad", self.onReviewLogBtnClick, self.view.reviewLogBtn.gameObject, "gamepadDialogueReviewLog")
end

function DialogFunctionCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function DialogFunctionCtrl:onReviewLogBtnClick()
	pg.game.communication:openDialogReview()
end

function DialogFunctionCtrl:onAutoBtnClick()
	if not self.isPlaying then
		self.isPlaying = true

		self:startDialogueTimer(self.curDuration)
		self.view:switchPlayMode(true)
	end
end

function DialogFunctionCtrl:onSkipBtnClick()
	local me = pg.me
	local maxDialogIndex = table.maxn(NpcDialogueData[self.dialogId])

	if self.waitPlayerChooseOption then
		return
	end

	me:serverMsg("RPC_CS_SkipDialogueGroup", self.dialogId, self.dialogIndex or 1, maxDialogIndex - 1, {})
	DialogueUtils.sendDialogueInfoReport(self.dialogId, self.dialogIndex, DialogueConst.SEND_REPORT_ACTION_EVENT.SKIP_DIALOGUE, pg.me:getGameTime() - self.dialogStartTime)

	if ToBool(NpcDialogueData[self.dialogId][maxDialogIndex].branchParam) then
		self.dialogIndex = maxDialogIndex

		self:showCurrentDialogueInfo()
		self:triggerDialogueBranch(NpcDialogueData[self.dialogId][self.dialogIndex].branchParam, maxDialogIndex)
	elseif ToBool(NpcDialogueData[self.dialogId][maxDialogIndex].switchBack) then
		self:triggerDialogueSwitchBack(maxDialogIndex)
	else
		me:serverMsg("RPC_CS_SetDialogueGroup", self.dialogId, maxDialogIndex, 2, {})
		pg.game.communication:finishNpcDialog()
	end
end

function DialogFunctionCtrl:onPlayingBtnClick()
	self.isPlaying = false

	self:stopDialogueTimer()
	self.view:switchPlayMode(false)
end

return DialogFunctionCtrl
