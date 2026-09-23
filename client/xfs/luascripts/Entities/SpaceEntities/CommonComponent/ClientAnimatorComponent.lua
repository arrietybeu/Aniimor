-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAnimatorComponent.lua

local class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local RigidbodyData = require("Data.rigidbody_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PlayableEventConst = require("Const.PlayableEventConst")
local ClientAnimatorComponent = class.Component("ClientAnimatorComponent")

function ClientAnimatorComponent:init(dict)
	return true
end

function ClientAnimatorComponent:start()
	return
end

function ClientAnimatorComponent:EVENT_AddEComponent()
	if self.needCreateAnimatorComponent and self:needCreateAnimatorComponent() == false then
		return
	end

	self:addEModelComponent(Const.COMPONENT_INDEX_ANIMATOR)
end

function ClientAnimatorComponent:destroy()
	return
end

function ClientAnimatorComponent:resetAnimator()
	self.eModel:ResetAnimator(Const.COMPONENT_INDEX_ANIMATOR)
end

function ClientAnimatorComponent:setAnimatorBool(varName, val)
	self.eModel:SetAnimatorBool(Const.COMPONENT_INDEX_ANIMATOR, varName, val)
end

function ClientAnimatorComponent:setAnimatorTrigger(varName)
	self.eModel:SetAnimatorTrigger(Const.COMPONENT_INDEX_ANIMATOR, varName)
end

function ClientAnimatorComponent:animatorPlay(varName)
	self.eModel:AnimatorPlay(Const.COMPONENT_INDEX_ANIMATOR, varName)
end

function ClientAnimatorComponent:playAnimancerAnim(animName, fadeTime, restart)
	if not self:hasEModelComponent(Const.COMPONENT_INDEX_ANIMATOR) then
		return
	end

	fadeTime = fadeTime or 0.5
	restart = restart or false

	local animancerAnim = self.eModel:PlayAnimancerAnim(Const.COMPONENT_INDEX_ANIMATOR, animName, fadeTime, restart)

	self:postComponentMethod("EVENT_AnimancerAnimUpdate")

	return animancerAnim
end

function ClientAnimatorComponent:stopAnimancerAnim(reset)
	if not self:hasEModelComponent(Const.COMPONENT_INDEX_ANIMATOR) then
		return
	end

	reset = reset or false

	self.eModel:StopAnimancerAnim(Const.COMPONENT_INDEX_ANIMATOR, reset)
	self:postComponentMethod("EVENT_AnimancerAnimUpdate")
end

function ClientAnimatorComponent:getCurNamedAnimancerState()
	return self.eModel:GetCurAnimancerState(Const.COMPONENT_INDEX_ANIMATOR)
end

function ClientAnimatorComponent:playAnimancerAnimAtEnd(animName)
	if not self.eModel then
		return
	end

	local state = self.eModel:PlayAnimancerAnim(Const.COMPONENT_INDEX_ANIMATOR, animName, 0, true)

	if state then
		state.NormalizedTime = 1
		state.IsPlaying = false
	end

	return state
end

function ClientAnimatorComponent:getCurAnimPlayedTime()
	if not self.eModel then
		return false, 0
	end

	local valid, playedTime, duration = self.eModel:GetAnimPlayedTime(Const.COMPONENT_INDEX_ANIMATOR)

	return valid or false, playedTime or 0, duration
end

return ClientAnimatorComponent
