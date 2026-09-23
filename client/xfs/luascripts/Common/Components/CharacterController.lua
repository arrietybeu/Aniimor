-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\CharacterController.lua

local class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local logger = require("Core.Log.LoggerManager").getLogger("CharacterController")
local CharacterController = class.Component("CharacterController")

function CharacterController:onCharacterStateChange(oldState, newState)
	if not newState then
		return
	end

	if self.characterState == newState then
		return
	end

	self.oldCharacterState = oldState or newState
	self.characterState = newState

	self:postComponentMethod("EVENT_OnCharacterStateChange", oldState, newState)
end

function CharacterController:EVENT_OnActiveChange(active)
	if not self.characterState then
		return
	end

	if not active and self.characterState ~= CharacterStateConst.IDLE then
		AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
	end
end

return CharacterController
