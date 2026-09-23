-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IGroundComponent.lua

local Class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local enums = require("Common.AI.Behaviac.Enums")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local EBTStatus = enums.EBTStatus
local IGroundComponent = Class.Component("IGroundComponent")

function IGroundComponent:switchToGroundIn__resetState(resetStateType)
	self.x_switchToGroundIn_state = nil
end

function IGroundComponent:switchToGroundIn()
	if self.x_switchToGroundIn_state == nil then
		self.x_switchToGroundIn_state = 1

		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.GROUNDIN)
	end

	if AIControllerUtils.getCurrentAnimationState(self.ent) == CharacterStateConst.GROUNDIN then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IGroundComponent:switchToGroundOut__resetState(resetStateType)
	self.x_switchToGroundOut_state = nil
end

function IGroundComponent:switchToGroundOut()
	if self.x_switchToGroundOut_state == nil then
		self.x_switchToGroundOut_state = 1

		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.GROUNDOUT)
	end

	if AIControllerUtils.getCurrentAnimationState(self.ent) == CharacterStateConst.GROUNDOUT then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

return IGroundComponent
