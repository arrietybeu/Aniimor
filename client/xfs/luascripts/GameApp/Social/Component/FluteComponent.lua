-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\FluteComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local SocialTypeData = require("Data.social_type_data")
local TimerManager = require("Core.Timer.TimerManager")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PlayableConst = require("Common.Const.PlayableConst")
local AppearanceAction = require("Data.appearance_action_data")
local VehicleSeatAttachData = require("Data.vehicle_seat_attach_data")
local Const = require("Common.Const.Const")
local AvatarPresetData = require("Data.avatar_preset_data")
local UIConst = require("Const.UIConst")
local FluteComponent = Class.LiteClass("FluteComponent")
local AI_RECEIVE_FLUTE_ID = 39
local AI_RECEIVE_REPLY_FLUTE_ID = 40
local AI_NEW_FLUTE_PLAYED = 41
local MAX_PLAY_FLUTE_TIME = 180
local FLUTE_ICON_URL = "$UI_Icon_Dizi.png"
local FLUTE_BENCH_ID = 46
local FLUTE_EFFECT_TYPE = {
	FLUTE_REPLY = 3,
	RECEIVE_REPLY = 2,
	RECEIVE_FLUTE = 1,
	PLAY_FLUTE = 0
}
local FLUTE_SOUND = {
	[Const.GENDER_TYPE_FEMALE] = {
		[1] = "BGM_Flutefemale",
		[2] = "BGM_Flutefemale_ensemble"
	},
	[Const.GENDER_TYPE_MALE] = {
		[1] = "BGM_Flutemale",
		[2] = "BGM_Flutemale_ensemble"
	},
	[Const.GENDER_TYPE_NONE] = {
		[1] = "BGM_Flutenogender",
		[2] = "BGM_Flutenogender_ensemble"
	}
}

function FluteComponent:ctor()
	self.inviteInfoOther = {}
	self.inviteInfoSelf = {}
	self.socialTypeInfo = SocialTypeData[1]
	self.lastAiId = nil
end

function FluteComponent:destroy()
	self:resetAllState()
end

function FluteComponent:stopAllSound()
	for _, soundEvents in pairs(FLUTE_SOUND) do
		for _, eventName in ipairs(soundEvents) do
			pg.game.audio:stopEvent(eventName)
		end
	end
end

function FluteComponent:resetAllState()
	self:removeAITip()

	if self.ignoreTimer then
		TimerManager.removeTimer(self.ignoreTimer)

		self.ignoreTimer = nil
	end

	self.lastAiId = nil

	if self.portalDestroyTimer then
		TimerManager.removeTimer(self.portalDestroyTimer)

		self.portalDestroyTimer = nil
	end

	self.portalDistance = nil

	if pg.me then
		self:removePortalAndInteraction()
	end

	if self.inviteInfoSelf and self.inviteInfoSelf.reqId then
		self:handleFluteEffect(false, self.inviteInfoSelf.reqId)
	end

	if self.inviteInfoOther and self.inviteInfoOther.reqId then
		self:handleFluteEffect(false, self.inviteInfoOther.reqId)
	end

	self.inviteInfoSelf = nil
	self.inviteInfoOther = nil

	local ui = pg.global and pg.global.ui

	if self.isPlaying and ui then
		if ui.tips then
			ui.tips:hideCountDown(ClientConst.PlayFluteStandActionId)
		end

		local vehicleView = ui.VehicleInteration and ui.VehicleInteration.view

		if vehicleView then
			vehicleView.interListUList:SetActive(true)
		end
	end

	self.isPlaying = false
	self.selfFluteType = nil
	self.otherFluteType = nil

	self:stopAllSound()
end

function FluteComponent:onAcceptFluteNotify(uid, reqId)
	if self.otherFluteType then
		pg.game.audio:stopEvent(FLUTE_SOUND[self.otherFluteType][1])

		self.otherFluteType = nil
	end

	pg.me:serverMsg("RPC_CS_AcceptFluteNotify", uid, reqId)
	self:removePortalAndInteraction()
end

function FluteComponent:onAcceptFluteNotifyReply(pos)
	self.portalDestroyTimer = TimerManager.addTimer(5, function()
		self:removePortalAndInteraction()
	end)
end

function FluteComponent:onReceiveFluteNotify(uid, reqId, pos, fluteGender, playerGender)
	if pg.me then
		self:removeAITip()

		self.inviteInfoOther = {
			uid = uid,
			reqId = reqId,
			pos = pos
		}

		local aiId = AI_RECEIVE_FLUTE_ID

		self.lastAiId = aiId

		facade:sendMsgToUI(MessageName.UI_AI_HELPER_LIT, {
			isInsert = true,
			id = self.lastAiId
		})
		self:handleFluteEffect(true, reqId, FLUTE_EFFECT_TYPE.RECEIVE_FLUTE, playerGender)

		if fluteGender then
			pg.game.audio:playEvent(FLUTE_SOUND[fluteGender][1])

			self.otherFluteType = fluteGender
		end
	else
		self.inviteInfoOther = nil
	end
end

function FluteComponent:onReplyFluteNotify(portalDistance)
	if not self.inviteInfoOther then
		return
	end

	self.portalDistance = portalDistance

	pg.me:serverMsg("RPC_CS_ReplyFluteNotify", self.inviteInfoOther.uid, self.inviteInfoOther.reqId)

	local playerGender = pg.me.templateId == 3 and Const.GENDER_TYPE_FEMALE or Const.GENDER_TYPE_MALE

	self:handleFluteEffect(true, self.inviteInfoOther.reqId, FLUTE_EFFECT_TYPE.FLUTE_REPLY, playerGender)
	self:removeAITip()
end

function FluteComponent:onReplyFluteNotifyCallBack()
	local actionPrototypeId = InteractionConst.STYLE_CONST.ENTER_FLUTE_PORTAL

	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
		needCheckDis = true,
		dist = 0,
		globalId = pg.me:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_ENTER_FLUTE_PORTAL,
		actionPrototypeId = actionPrototypeId,
		interactFunc = function()
			if not self.inviteInfoOther then
				return
			end

			self:onAcceptFluteNotify(self.inviteInfoOther.uid, self.inviteInfoOther.reqId)
		end
	})

	if self.otherFluteType then
		pg.game.audio:playEvent(FLUTE_SOUND[self.otherFluteType][2])
	end
end

function FluteComponent:onReceiveFluteNotifyReply(uid, pos)
	if pg.me then
		self:removeAITip()

		self.lastAiId = AI_RECEIVE_REPLY_FLUTE_ID

		facade:sendMsgToUI(MessageName.UI_AI_HELPER_LIT, {
			isInsert = true,
			id = self.lastAiId
		})
		pg.me:queryPlayerInfo(uid, nil, true, function(playerData)
			local presetData = pg.game.avatar:getAvatarPresetData(playerData.avatarPresetKey) or {}
			local templateId = presetData.templateId or 0
			local gender = templateId == 3 and Const.GENDER_TYPE_FEMALE or Const.GENDER_TYPE_MALE

			self:handleFluteEffect(true, self.inviteInfoSelf and self.inviteInfoSelf.reqId, FLUTE_EFFECT_TYPE.RECEIVE_REPLY, gender)

			if self.selfFluteType then
				pg.game.audio:playEvent(FLUTE_SOUND[self.selfFluteType][2])
			end
		end)
	else
		self.inviteInfoSelf = nil
	end
end

function FluteComponent:onFluteNotifyClosed()
	self:removeAITip()
	pg.global.showBubbleMessageRaw(pg.getGameString("FLUTE_CLOSED"))
	self:removePortalAndInteraction()
	self:handleFluteEffect(false, self.inviteInfoOther and self.inviteInfoOther.reqId)

	self.inviteInfoOther = nil

	if self.otherFluteType then
		pg.game.audio:stopEvent(FLUTE_SOUND[self.otherFluteType][1])

		self.otherFluteType = nil
	end
end

function FluteComponent:onPlayFlute(fluteType)
	local vehicleStaticId = 0
	local curVehicleActorId = pg.me.onVehicleActorId

	if curVehicleActorId > 0 then
		local curVehicleEnt = pg.getEntityByActorId(curVehicleActorId)

		if curVehicleEnt then
			vehicleStaticId = curVehicleEnt.staticId
		end
	end

	pg.me:serverMsg("RPC_CS_ReqFluteMatch", fluteType, vehicleStaticId)

	self.selfFluteType = fluteType

	if pg.me and self.lastAiId == AI_RECEIVE_FLUTE_ID then
		self:removeAITip()

		local aiId = AI_NEW_FLUTE_PLAYED

		self.lastAiId = aiId

		facade:sendMsgToUI(MessageName.UI_AI_HELPER_LIT, {
			isInsert = true,
			id = self.lastAiId
		})
	end
end

function FluteComponent:onPlayFluteSuccess(reqId)
	local carryType = pg.me.carryType

	if carryType == Const.CARRY_TYPE.PET then
		pg.me:putDownCarryEnt()
	end

	self.inviteInfoSelf = {
		uid = pg.me.uid,
		reqId = reqId
	}
	self.isPlaying = true

	if pg.me:RIDING_ST() then
		pg.me:playAnimation(PlayableConst.Sit_Flute_Loop, true, nil, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	else
		pg.me:playTrivialAnimation(PlayableConst.Flute_Skill_Cure_StandLoop)
	end

	pg.me:serverMsg("RPC_CS_PlayAppearanceAction", pg.me:RIDING_ST() and ClientConst.PlayFluteSitActionId or ClientConst.PlayFluteStandActionId, "", false)
	pg.global.ui.tips:showCountDown(MAX_PLAY_FLUTE_TIME, ClientConst.PlayFluteStandActionId, {
		overrideIcon = FLUTE_ICON_URL,
		closeFunc = function()
			self:onStopFluteMatch()
		end,
		finishCb = function()
			self:onStopFluteMatch(true)
		end
	})
	self:handleFluteEffect(true, self.inviteInfoSelf.reqId, FLUTE_EFFECT_TYPE.PLAY_FLUTE, self.selfFluteType)

	if self.selfFluteType then
		pg.game.audio:playEvent(FLUTE_SOUND[self.selfFluteType][1])
	end

	if pg.global.ui.VehicleInteration.view then
		pg.global.ui.VehicleInteration.view.interListUList:SetActive(false)
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("FLUTE_MATCHING_TOAST"))
end

function FluteComponent:onAiHelperLitShow(aiId)
	if aiId == self.lastAiId and not self.ignoreTimer then
		self.ignoreTimer = TimerManager.addTimer(self.socialTypeInfo.stopMatchTime, function()
			self:removeAITip()
			self:onFluteInvitationIgnored()
		end)
	end
end

function FluteComponent:onFluteInvitationIgnored()
	self:handleFluteEffect(false, self.inviteInfoOther and self.inviteInfoOther.reqId)
end

function FluteComponent:removePortalAndInteraction()
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = pg.me:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_ENTER_FLUTE_PORTAL
	})
end

function FluteComponent:removeAITip()
	if self.ignoreTimer and self.lastAiId then
		TimerManager.removeTimer(self.ignoreTimer)

		self.ignoreTimer = nil

		if self.lastAiId then
			facade:sendMsgToUI(MessageName.UI_AI_HELPER_LIT, {
				isInsert = false,
				id = self.lastAiId
			})

			self.lastAiId = nil
		end

		self.lastAiId = nil
	end
end

function FluteComponent:onDismountSelf()
	self:onStopFluteMatch(true)
end

function FluteComponent:onStopFluteMatch(force)
	if force then
		pg.me:serverMsg("RPC_CS_StopFluteMatch")
	elseif self.isPlaying then
		pg.global.showConfirmMsgRaw(pg.getGameString("STOP_FLUTE_MATCH_TITLE"), pg.getGameString("STOP_FLUTE_MATCH_DESC"), function()
			pg.me:serverMsg("RPC_CS_StopFluteMatch")
		end, nil)
	end
end

function FluteComponent:onStopFluteMatchCallback()
	if not pg.me then
		return
	end

	self.isPlaying = false

	pg.global.ui.tips:hideCountDown(ClientConst.PlayFluteStandActionId)

	if not pg.me then
		return
	end

	if pg.me.onVehicleActorId > 0 then
		pg.me:playAnimation(PlayableConst.Sit_Flute_End, true, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	else
		pg.me:stopAnimation(PlayableConst.Flute_Skill_Cure_StandLoop)
		pg.me:playAnimation(PlayableConst.Flute_Skill_Cure_StandEnd, true, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end

	self:handleFluteEffect(false, self.inviteInfoSelf and self.inviteInfoSelf.reqId)

	self.inviteInfoSelf = nil

	if self.selfFluteType then
		pg.game.audio:stopEvent(FLUTE_SOUND[self.selfFluteType][1])

		self.selfFluteType = nil
	end

	if pg.global.ui.VehicleInteration.view then
		pg.global.ui.VehicleInteration.view.interListUList:SetActive(true)
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("STOP_FLUTE_MATCH"), 3)
end

function FluteComponent:handleFluteEffect(enable, id, effectType, fluteGender)
	local info = {
		enable = enable,
		id = id,
		effectType = effectType,
		fluteGender = fluteGender
	}

	facade:sendMsgToUI(MessageName.UI_TRACK_FLUTE_INVITER, info)
end

return FluteComponent
