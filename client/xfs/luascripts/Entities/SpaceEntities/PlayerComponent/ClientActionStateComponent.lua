-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientActionStateComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local EntityManager = require("Core.Common.EntityManager")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local EventConst = require("Common.Const.EventConst")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local UIConst = require("Const.UIConst")
local ClientActionStateComponent = class.Component("ClientActionStateComponent")

function ClientActionStateComponent:ctor()
	return
end

function ClientActionStateComponent:init(avtDict)
	if self then
		self:setActionState(Const.PlayerActionState.None)
	end

	return true
end

function ClientActionStateComponent:destroy()
	return
end

function ClientActionStateComponent:setActionState(actionState)
	self:serverMsg("RPC_CS_SetActionState", actionState)
end

function ClientActionStateComponent:on_actionState_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_actionState_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	self:handleActionStateChanged(oldv, newv)
	self:setFeedbackEntity(self, newv)
	self:tryPetActionFeedback()
end

function ClientActionStateComponent:handleActionStateChanged(oldv, newv)
	local ent = self.uid == pg.me.uid and pg.me or EntityManager.getEntityByUid(self.uid)

	if ent then
		if ent.refreshActionStateInteraction then
			ent:refreshActionStateInteraction()
		end

		local targetEnt = ent
		local isControllingPet = false

		if ent:isControllingPet() then
			targetEnt = ent:getCurPetEntity()
			isControllingPet = true
		end

		if not targetEnt then
			return
		end

		if newv ~= Const.PlayerActionState.None then
			targetEnt:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.ACTION_STATE)
		end

		targetEnt.eventEmitter:emit(EventConst.PLAYER_ACTION_STATE_CHANGED, newv)

		if CharacterStateConst.isChildOfState(targetEnt.characterState, CharacterStateConst.LOCOMOTION) then
			self:playActionStateAnim(oldv, newv, targetEnt, isControllingPet)
		end
	end
end

function ClientActionStateComponent:playActionStateAnim(oldv, newv, targetEnt, isControllingPet)
	local startAnimList = {}
	local animLayer = PlayableConst.AnimationLayer.HUMAN_LAYER_BASE

	if newv == Const.PlayerActionState.AFK then
		if isControllingPet then
			startAnimList = {
				PlayableConst.Behav_SleepStart,
				PlayableConst.Behav_SleepLoop
			}
		else
			startAnimList = {
				PlayableConst.Emotion_Anxious_Start,
				PlayableConst.Emotion_Anxious_Loop
			}
		end
	elseif newv == Const.PlayerActionState.FuncMenu then
		if not isControllingPet then
			startAnimList = not pg.me:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY) and {
				PlayableConst.MainMenu_Idle_Start,
				PlayableConst.MainMenu_Idle_Loop
			} or {}
		else
			startAnimList = {
				PlayableConst.Idle
			}
		end
	end

	if #startAnimList > 0 then
		if not isControllingPet and newv == Const.PlayerActionState.AFK then
			local fadeTime = 1
			local startState = targetEnt:playAnimation(startAnimList[1], true, nil, false, animLayer)

			if startState then
				targetEnt:setAnimationSequence(startState, math.max(startState.Length - fadeTime, 0), function(stateTime)
					if stateTime > 0 then
						local loopState = targetEnt:playRawAnimation(startAnimList[2], fadeTime, 0, nil, nil, animLayer)

						if loopState then
							loopState:SetLogicLoop(true)
						end
					end

					return true
				end)

				return
			end
		end

		AnimationUtils.playAnimationList(targetEnt, startAnimList, nil, animLayer)

		return
	end

	if newv == Const.PlayerActionState.None and oldv == Const.PlayerActionState.AFK then
		AnimationUtils.playAnimationState(targetEnt, CharacterStateConst.IDLE)

		local endAnim = isControllingPet and PlayableConst.Behav_SleepEnd or PlayableConst.Emotion_Anxious_End

		AnimationUtils.playAnimation(targetEnt, endAnim, animLayer)
	end
end

return ClientActionStateComponent
