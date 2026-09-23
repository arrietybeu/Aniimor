-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\DialogueBaseCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local DialogueBaseCtrl = Class.LightClass("DialogueBaseCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

function DialogueBaseCtrl:addListener()
	local keyBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "Cancel")

	keyBinding.actionPath = "Common/Cancel"
	keyBinding.isVirtual = true

	function keyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			return self:onPerformCommonCancel(true)
		end

		return true
	end

	self:addNextBtnClick("space", "Hud/DialogueNext")
	self:addNextBtnClick("keyF", "Hud/Interact")
	self:addNextBtnClick("skipTypewriter", "Common/MouseLeftButton")
	self:addNextBtnClick("gamePadSkipTypewriter", "Common/GamepadConfirm")
end

function DialogueBaseCtrl:onPreShow(cmd)
	self.canMoveNext = false

	if self.isDialogueGraph then
		self.cmd = cmd

		self:onPlaybackStateChange(self.cmd:getPlaybackState())
	else
		self.cmd = nil
	end

	self.isPlaying = self:canAutoPlay()
end

function DialogueBaseCtrl:onPlaybackPermissionChange()
	return
end

function DialogueBaseCtrl:onPlaybackStateChange(state)
	if state == DialogueGraphConst.PLAYBACK_STATE.NORMAL then
		if pg.game.communication:isDialogueUnbreakable() then
			return
		end

		self.isPlaying = false
	elseif state == DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING then
		self.isPlaying = true
	elseif state == DialogueGraphConst.PLAYBACK_STATE.SKIPPING then
		-- block empty
	end
end

function DialogueBaseCtrl:addNextBtnClick(name, actionPath)
	local keyBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, name)

	keyBinding.actionPath = actionPath
	keyBinding.isVirtual = true

	function keyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onNextBtnClick(true)
		end

		return true
	end
end

function DialogueBaseCtrl:onPerformCommonCancel()
	if not pg.game.communication:getEnableStopUI() then
		return true
	end

	if self.isDialogueGraph then
		return true
	end

	if pg.game.communication:finishNpcDialog() then
		return false
	end

	self:close()
end

function DialogueBaseCtrl:onVisibleChange(visible)
	return
end

function DialogueBaseCtrl:onNextBtnClick(isClick)
	if self:tryStopTypewriterEffect() then
		return false
	elseif self:canTriggerNextBtn() then
		local tmpCallback = self.callback

		self.callback = nil

		self:removeMoveNextTimer()

		if tmpCallback then
			tmpCallback()

			return false
		end
	end

	return true
end

function DialogueBaseCtrl:tryStopTypewriterEffect()
	return false
end

function DialogueBaseCtrl:canTriggerNextBtn()
	return false
end

function DialogueBaseCtrl:nextHasOption()
	return false
end

function DialogueBaseCtrl:canAutoPlay()
	if self.isDialogueGraph then
		return self:canAutoPlayInDialogueGraph() or pg.game.communication:isDialogueUnbreakable()
	end

	return pg.game.communication:canAutoPlay()
end

function DialogueBaseCtrl:canAutoPlayInDialogueGraph()
	return self.cmd and self.cmd:isAutoPlaying()
end

function DialogueBaseCtrl:onHide()
	UICtrl.onHide(self)
	self:removeMoveNextTimer()
	self:invokeCallback()
end

function DialogueBaseCtrl:invokeCallback()
	if self.callback and not self.isInvokingCallback then
		self.isInvokingCallback = true

		local cb = self.callback

		self.callback = nil

		cb()

		self.isInvokingCallback = nil
	end
end

function DialogueBaseCtrl:startMoveNextTimer(duration, callback)
	self.callback = callback

	if not callback then
		return
	end

	self.canMoveNext = false
	self.moveNextTimer = self:startScaleTimer(function()
		self.canMoveNext = true

		if self:canAutoPlay() then
			self:invokeCallback()
		elseif self:nextHasOption() then
			self:invokeCallback()
		end
	end, duration, false)
end

function DialogueBaseCtrl:moveNext()
	if self.canMoveNext then
		self:invokeCallback()
	end
end

function DialogueBaseCtrl:removeMoveNextTimer()
	if self.moveNextTimer then
		self:killScaleTimer(self.moveNextTimer)

		self.moveNextTimer = nil
	end
end

return DialogueBaseCtrl
