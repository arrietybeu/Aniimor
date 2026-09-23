-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\ItemUseComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local SocialTypeData = require("Data.social_type_data")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local PlayableConst = require("Common.Const.PlayableConst")
local TimerManager = require("Core.Timer.TimerManager")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Vector3 = Vector3
local ItemUseComponent = Class.LiteClass("ItemUseComponent")
local AI_ID = {
	RECEIVE_FRIEND = "HORN_MATCHED_FRIEND_TIP",
	RECEIVE_NONE = "HORN_NOBODY_TIP",
	RECEIVE_NORMAL = "HORN_MATCHED_STRANGER_TIP",
	INVITE_STOP = "HORN_STOP_TIP",
	INVITE_FRIEND = 24,
	INVITE_NORMAL = 23
}

function ItemUseComponent:ctor()
	self._inviteInfo = nil
	self._cacheItemInfo = SocialTypeData[1]
end

function ItemUseComponent:destroy()
	if self._inviteInfo then
		local info = {
			enable = false,
			pos = self._inviteInfo.pos3,
			id = self._inviteInfo.reqId
		}

		facade:sendMsgToUI(MessageName.UI_TRACK_HORN_INVITER, info)
	end

	pg.game.audio:stopEvent("SFX_Act_Player_MeetHorn")

	self._inviteInfo = nil
	self._cacheItemInfo = nil
	self._reqId = nil
	self._lastAiId = nil
end

function ItemUseComponent:useInviteItem(invIdx, genId)
	local me = pg.me

	if me then
		if pg.me:isInTeam() or pg.me.space.sceneId ~= ClientConst.SCENE_MAIN_SINGLE_WORLD and Utils.isSpacePhase(pg.me.space.sceneId) ~= ClientConst.SCENE_MAIN_SINGLE_WORLD then
			pg.global.showBubbleMessageRaw(pg.getGameString("CANT_USE_HORN_TIPS"))
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("USE_HORN_TIPS"), function()
				pg.global.ui:closeAllNormalPanel()

				if pg.me:isControllingPet() then
					pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Horn, nil, function()
						pg.me.eModel.InSocialAnim = true

						me:reqSendHorn(invIdx, genId)
					end)
				else
					pg.me.eModel.InSocialAnim = true

					me:reqSendHorn(invIdx, genId)
				end
			end, nil)
		end
	end
end

function ItemUseComponent:onUseInviteItemResult(flag, reqRetInfo, matchUids)
	local me = pg.me

	if flag and me then
		self._reqId = reqRetInfo.reqId

		local time = reqRetInfo.startTs + 500 - Time.secondCache

		if time > 0 then
			pg.global.ui.tips:showCountDown(time, nil, {
				positiveTiming = true
			})
		end

		if me:isDead() then
			return
		end

		self._onSleAnimationEndCb = CallbackHandlerNoGC.newOnceCSharpCb(self, "onSleAnimationEnd")

		AnimationUtils.playSleAnimation(pg.me, AnimationUtils.getID("Daily_Horn_Start"), AnimationUtils.getID("Daily_Horn_Loop"), AnimationUtils.getID("Daily_Horn_End"), false, 500, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_BASE, self._onSleAnimationEndCb)

		function self._openFunc()
			self:checkAndStopHornAnimation()
		end

		pg.global.ui:addOpenFullScreenCallback(self._openFunc)
	elseif me then
		pg.global.showBubbleMessageRaw(pg.getGameString(AI_ID.RECEIVE_NONE), 3)
	end
end

function ItemUseComponent:checkAndStopHornAnimation()
	local me = pg.me

	if me then
		local isPlaying = me:isAnimationPlaying("Daily_Horn_Start") or me:isAnimationPlaying("Daily_Horn_Loop") or me:isAnimationPlaying("Daily_Horn_End")

		if isPlaying then
			me:stopCfgAnimation()

			pg.me.eModel.InSocialAnim = false

			self:onSleAnimationEnd()
		end
	end
end

function ItemUseComponent:onSleAnimationEnd(endReason)
	pg.global.ui:removeOpenFullScreenCallback(self._openFunc)
	pg.game.audio:stopEvent("SFX_Act_Player_MeetHorn")

	if pg.me then
		pg.me:reqStopHornAction()
	end

	pg.global.ui.tips:hideCountDown()

	if not pg.me:isInCatchMode() then
		pg.me:playDefaultAnimation()
	else
		pg.me:playAnimation(PlayableConst.HoldBall_Idle)
	end
end

function ItemUseComponent:onOtherRequestEnterSpace(reqId, playerInfo)
	local me = pg.me

	if me and self._reqId and self._reqId == reqId then
		local uid = playerInfo.uid
		local isFriend = pg.game.chat:checkFriendList(uid)
		local aiId = isFriend and AI_ID.RECEIVE_FRIEND or AI_ID.RECEIVE_NORMAL

		pg.global.showBubbleMessageRaw(pg.getGameString(aiId), 3)
		self:checkAndStopHornAnimation()
	end
end

function ItemUseComponent:onInviteReceive(inviteInfo)
	local me = pg.me

	if me then
		if self._ignoreTimer and self._lastAiId then
			TimerManager.removeTimer(self._ignoreTimer)

			self._ignoreTimer = nil

			pg.me:doEventByData({
				"finishAIRemind",
				{
					self._lastAiId
				}
			})

			self._lastAiId = nil

			if self._inviteInfo then
				local info = {
					enable = false,
					pos = self._inviteInfo.pos3,
					id = self._inviteInfo.reqId
				}

				facade:sendMsgToUI(MessageName.UI_TRACK_HORN_INVITER, info)
			end
		end

		self._inviteInfo = inviteInfo

		local uid = inviteInfo.uid
		local isFriend = pg.game.chat:checkFriendList(uid)
		local aiId = isFriend and AI_ID.INVITE_FRIEND or AI_ID.INVITE_NORMAL

		self._lastAiId = aiId

		pg.me:doEventByData({
			"startAIRemind",
			{
				aiId
			}
		})
	else
		self._inviteInfo = nil
	end
end

function ItemUseComponent:onAiHelperLitShow(aiId)
	if aiId == self._lastAiId and not self._ignoreTimer then
		pg.game.audio:playEvent("SFX_Act_Player_MeetHorn")

		self._ignoreTimer = TimerManager.addTimer(self._cacheItemInfo.stopMatchTime, function()
			pg.me:doEventByData({
				"finishAIRemind",
				{
					self._lastAiId
				}
			})
			self:ignoreInvitation()
		end)

		local info = {
			enable = true,
			pos = self._inviteInfo.pos3,
			id = self._inviteInfo.reqId
		}

		facade:sendMsgToUI(MessageName.UI_TRACK_HORN_INVITER, info)
	end
end

function ItemUseComponent:ignoreInvitation()
	local me = pg.me

	if me and self._inviteInfo then
		local info = {
			enable = false,
			pos = self._inviteInfo.pos3,
			id = self._inviteInfo.reqId
		}

		facade:sendMsgToUI(MessageName.UI_TRACK_HORN_INVITER, info)
		pg.game.audio:stopEvent("SFX_Act_Player_MeetHorn")
		me:ignoreHornNotify()

		self._inviteInfo = nil
		self._ignoreTimer = nil
		self._lastAiId = nil
	end
end

function ItemUseComponent:acceptInvitation()
	if self._ignoreTimer then
		TimerManager.removeTimer(self._ignoreTimer)

		self._ignoreTimer = nil
	end

	local me = pg.me

	if me and self._inviteInfo then
		local info = {
			enable = false,
			pos = self._inviteInfo.pos3,
			id = self._inviteInfo.reqId
		}

		facade:sendMsgToUI(MessageName.UI_TRACK_HORN_INVITER, info)
		pg.game.audio:stopEvent("SFX_Act_Player_MeetHorn")
		me:acceptHornNotify(self._inviteInfo)
	end
end

function ItemUseComponent:onAcceptInvitationResult(flag, pos3)
	if self._lastAiId then
		pg.me:doEventByData({
			"finishAIRemind",
			{
				self._lastAiId
			}
		})

		self._lastAiId = nil
	end

	if flag == 2 then
		pg.global.showBubbleMessageRaw(pg.getGameString(AI_ID.INVITE_STOP), 3)
	else
		self.facePos = pos3
	end

	self._inviteInfo = nil
end

function ItemUseComponent:testHorn(actorId, enable)
	if enable then
		local ent = pg.getEntityByActorId(actorId)

		if ent then
			local wPos = ent:getPosition()
			local info = {
				id = 111,
				enable = true,
				pos = wPos
			}

			facade:sendMsgToUI(MessageName.UI_TRACK_HORN_INVITER, info)
		end
	else
		local info = {
			id = 111,
			enable = false
		}

		facade:sendMsgToUI(MessageName.UI_TRACK_HORN_INVITER, info)
	end
end

return ItemUseComponent
