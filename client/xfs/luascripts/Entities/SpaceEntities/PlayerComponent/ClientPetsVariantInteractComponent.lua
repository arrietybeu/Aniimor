-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetsVariantInteractComponent.lua

local CallbackHandler = require("Core.Common.CallbackHandler")
local EntityManager = require("Core.Common.EntityManager")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local SocialConst = require("Common.Const.SocialConst")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local PetExchangeCountdownCtrl = require("Guis.Panels.PetExchangeCountdown.PetExchangeCountdownCtrl")
local ClientPetsVariantInteractComponent = Class.Component("ClientPetsVariantInteractComponent")
local PET_VARIANT_UI_IDS = {
	UIConst.UI_ID_PET_EXCHANGE_TIP,
	UIConst.UI_ID_PET_EXCHANGE_SELECT
}
local VARIANT_COUNTDOWN_DURATION = 3

function ClientPetsVariantInteractComponent:invitePetVariantInteract(inviteeUid)
	local playerInfo = pg.game.chat:getPlayerInfo(inviteeUid)

	if not playerInfo.online then
		pg.global.ui.tips:showTextTipById(NoticeDef.TEAM_INVITE_MEMBER_OFFLINE)

		return
	end

	if self.curSocialInfo ~= nil then
		self.logger:error("invitePetVariantInteract, but curSocialInfo not nil, ignore", self:repr())

		return
	end

	local targetPlayer = EntityManager.getEntityByUid(inviteeUid)

	if not targetPlayer or Utils.distanceEntity(pg.me, targetPlayer) >= Const.EXCHANGE_DISTANCE then
		self:handleRemoteInviteSinglePlayer(inviteeUid, Const.InviteWorldType.EXCHANGE_PET)

		return
	end

	pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))
	self:serverMsg("RPC_CS_SocialInvite", SocialConst.SOCIAL_PET_VARIANT_INTERACT, inviteeUid, {})
end

function ClientPetsVariantInteractComponent:onRecvPetVariantInteractInvite(invitorUid, inviteInfo)
	if pg.logDebug() then
		self.logger:debug("__petvariantinteract onRecvPetVariantInteractInvite, invitorUid=%s, inviteInfo=%s", tostring(invitorUid), inspect(inviteInfo, {
			depth = 3
		}))
	end

	local function acceptInvite()
		self:replyPetVariantInteractInvite(invitorUid, true, {})
	end

	local function rejectInvite()
		self:replyPetVariantInteractInvite(invitorUid, false, {})
	end

	pg.game.chat:showVariantFriendInvite(invitorUid, acceptInvite, rejectInvite, rejectInvite)
end

function ClientPetsVariantInteractComponent:replyPetVariantInteractInvite(invitorUid, accept, replyInfo)
	self:serverMsg("RPC_CS_SocialInviteReply", SocialConst.SOCIAL_PET_VARIANT_INTERACT, invitorUid, {
		accept,
		replyInfo or {}
	})
end

function ClientPetsVariantInteractComponent:onRecvPetVariantInteractInviteReply(inviteeUid, accept, replyInfo)
	if pg.logDebug() then
		self.logger:debug("__petvariantinteract onRecvPetVariantInteractInviteReply, inviteeUid=%s, accept=%s, replyInfo=%s", tostring(inviteeUid), tostring(accept), inspect(replyInfo, {
			depth = 3
		}))
	end

	if not accept then
		local errNoticeId = replyInfo and (replyInfo.srcErr or replyInfo.dstErr or replyInfo.dstErr2 or replyInfo.srcErr2)

		if errNoticeId then
			ClientUtils.showBubbleMessageById(errNoticeId)
		end
	end
end

function ClientPetsVariantInteractComponent:onStartPetVariantInteractSocial(socialInfo, isResume)
	if pg.logDebug() then
		self.logger:debug("__petvariantinteract onStartPetVariantInteractSocial, socialInfo=%s, isResume=%s", inspect(socialInfo, {
			depth = 3
		}), tostring(isResume))
	end

	local state = self.petVariantPresentationState

	if not state or state.socialId ~= socialInfo.socialId then
		self.petVariantPresentationState = nil

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN) then
			pg.global.ui:closeImmediately(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN)
		end
	end

	local _, _, friendUid = Utils.unpackSocialPlayerInfo(socialInfo.players, self.uid)

	self:openPetVariantInteractSelectPage(friendUid)
	self:tryStartPetVariantPresentation(socialInfo)
end

function ClientPetsVariantInteractComponent:openPetVariantInteractSelectPage(friendUid)
	pg.global.ui:open(UIConst.UI_ID_PET_EXCHANGE_SELECT, {
		isChange = 1,
		uid = friendUid
	}, nil, nil, {
		textureHeight = 1024,
		textureWidth = 1024
	})
end

function ClientPetsVariantInteractComponent:getPetVariantInteractSocialInfo()
	return self.curSocialInfo
end

function ClientPetsVariantInteractComponent:sendPetVariantInteractPetInfoOperation(op, petId, callback)
	local pet = petId and pg.me.pets[petId]

	if not pet then
		if pg.logDebug() then
			self.logger:debug("__petvariantinteract sendPetVariantInteractPetInfoOperation skipped, op=%s, petId=%s", tostring(op), tostring(petId))
		end

		return
	end

	local petInfo = Utils.deepCopyTable(pet:getRawTable())

	self:sendPetVariantInteractOperation(op, {
		petInfo
	}, callback)
end

function ClientPetsVariantInteractComponent:chooseVariantInteractPet(petId, callback)
	self:sendPetVariantInteractPetInfoOperation(SocialConst.PVI_CS_ChoosePet, petId, callback)
end

function ClientPetsVariantInteractComponent:confirmVariantInteractPet(petId, callback)
	self:sendPetVariantInteractPetInfoOperation(SocialConst.PVI_CS_ConfirmPet, petId, callback)
end

function ClientPetsVariantInteractComponent:cancelConfirmVariantInteractPet()
	self:sendPetVariantInteractOperation(SocialConst.PVI_CS_CancelConfirm, {})
end

function ClientPetsVariantInteractComponent:cancelVariantInteract(quitReason)
	self:sendPetVariantInteractOperation(SocialConst.PVI_CS_Quit, {
		quitReason
	})
end

function ClientPetsVariantInteractComponent:sendPetVariantInteractOperation(op, params, callback)
	local localCallback = callback or function(result, resp)
		if (not result or ToInt(resp and resp.noticeId) ~= 0) and pg.logDebug() then
			self.logger:debug("__petvariantinteract operation reply, op=%s, params=%s, result=%s, resp=%s", tostring(op), inspect(params, {
				depth = 3
			}), tostring(result), inspect(resp, {
				depth = 3
			}))
		end
	end

	self:sendSocialOperation(op, params, localCallback)
end

function ClientPetsVariantInteractComponent:onNotifyPetVariantInteractSocial(op, params)
	if pg.logDebug() then
		self.logger:debug("__petvariantinteract onNotifyPetVariantInteractSocial, op=%s, params=%s", tostring(op), inspect(params, {
			depth = 3
		}))
	end

	if op == SocialConst.PVI_SC_Notice then
		local noticeId, noticeArgs = unpack(params)

		if noticeId == NoticeDef.EXCHANGE_PET_CLIENT_QUIT then
			local uid = unpack(noticeArgs)
			local textKey = uid == pg.me.uid and "PET_VARIANT_INTERACT_SELF_QUIT" or "PET_VARIANT_INTERACT_FRIEND_QUIT"

			pg.global.ui.tips:showTextTip(pg.getGameString(textKey))
		else
			ClientUtils.showBubbleMessageById(noticeId, unpack(noticeArgs or {}))
		end
	elseif op == SocialConst.PVI_SC_SyncInfo then
		self.curSocialInfo = params[1]

		self:tryStartPetVariantPresentation(self.curSocialInfo)

		local state = self.petVariantPresentationState

		if state and state.socialId == self.curSocialInfo.socialId then
			state.socialInfo = self.curSocialInfo
		end

		facade:SendMessageCommand(MessageName.PET_VARIANT_INTERACT_SYNC_INFO, params)

		if params[2] ~= nil then
			if state and state.socialId == self.curSocialInfo.socialId then
				state.result = params[2]
			end

			facade:SendMessageCommand(MessageName.PET_VARIANT_INTERACT_SYNC_RESULT, {
				isSuccess = params[2]
			})
		end
	end
end

function ClientPetsVariantInteractComponent:tryStartPetVariantPresentation(socialInfo)
	local state = self.petVariantPresentationState

	if state and state.socialId == socialInfo.socialId then
		return
	end

	for _, playerInfo in pairs(socialInfo.players) do
		if playerInfo.confirm ~= true then
			return
		end
	end

	local isOpened = PetExchangeCountdownCtrl.openPresentation({
		duration = VARIANT_COUNTDOWN_DURATION,
		completeCallback = CallbackHandler(self, "onPetVariantInteractCountdownComplete", socialInfo.socialId)
	})

	if not isOpened then
		return
	end

	self.petVariantPresentationState = {
		countdownCompleted = false,
		socialEnded = false,
		socialId = socialInfo.socialId,
		socialInfo = socialInfo
	}
end

function ClientPetsVariantInteractComponent:closePetVariantInteractUI()
	for _, uiId in ipairs(PET_VARIANT_UI_IDS) do
		if pg.global.ui:checkUIOpen(uiId) then
			pg.global.ui:closeImmediately(uiId)
		end
	end
end

function ClientPetsVariantInteractComponent:onEndPetVariantInteractSocial()
	local state = self.petVariantPresentationState

	if state and state.socialId == self.curSocialInfo.socialId then
		state.socialInfo = self.curSocialInfo
		state.socialEnded = true

		self:tryPlayPetVariantResultAnimation()
	else
		self:closePetVariantInteractUI()
	end

	if pg.logDebug() then
		self.logger:debug("__petvariantinteract onEndPetVariantInteractSocial")
	end
end

function ClientPetsVariantInteractComponent:onPetVariantInteractCountdownComplete(socialId)
	local state = self.petVariantPresentationState

	if not state or state.socialId ~= socialId then
		return
	end

	state.countdownCompleted = true

	self:tryPlayPetVariantResultAnimation()
end

function ClientPetsVariantInteractComponent:tryPlayPetVariantResultAnimation()
	local state = self.petVariantPresentationState

	if not state.countdownCompleted or not state.socialEnded then
		return
	end

	local socialInfo = state.socialInfo
	local result = state.result

	self.petVariantPresentationState = nil

	self:playPetVariantResultAnimation(socialInfo, result)
end

function ClientPetsVariantInteractComponent:playPetVariantResultAnimation(socialInfo, isSuccess)
	if pg.logDebug() then
		self.logger:debug("__petvariantinteract play result animation, success=%s, socialInfo=%s", tostring(isSuccess), inspect(socialInfo, {
			depth = 3
		}))
	end

	self:closePetVariantInteractUI()

	if isSuccess ~= true then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_VARIANT_PROCESS, {
		socialInfo = socialInfo,
		isSuccess = isSuccess,
		uid = self.uid
	})
end

return ClientPetsVariantInteractComponent
