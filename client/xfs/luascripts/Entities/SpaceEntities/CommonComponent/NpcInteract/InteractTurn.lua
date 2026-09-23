-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\NpcInteract\\InteractTurn.lua

local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local PlayableConst = require("Common.Const.PlayableConst")
local InteractTurn = {}

function InteractTurn:onInteractRotationRecovered()
	if self.isInInteractTurnAnim then
		if Utils.isNpc(self) then
			if not self:isFullBodyDefaultAnimationPlaying() then
				self:stopLayerAnimation(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			end
		else
			self:playDefaultAnimation(true)
		end

		AIUtils.ResumeAI(self.id, AiConst.PauseBtReason.DialogueControl)
		pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.Dialogue, false)

		self.isInInteractTurnAnim = nil
	end
end

function InteractTurn:startInteractTurnTimer(npcTurnTime)
	if self.recoverInteractRotationTimer ~= nil then
		self:removeTimer(self.recoverInteractRotationTimer)

		self.recoverInteractRotationTimer = nil
	end

	self.isInInteractTurnAnim = true
	self.recoverInteractRotationTimer = self:addTimer(npcTurnTime, function()
		InteractTurn.onInteractRotationRecovered(self)
	end)
end

return InteractTurn
