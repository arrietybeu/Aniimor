-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetsBreedComponent.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local SocialConst = require("Common.Const.SocialConst")
local NoticeDef = require("Common.NoticeDef")
local ClientPetsBreedComponent = Class.Component("ClientPetsBreedComponent")

function ClientPetsBreedComponent:queryCanBreedPets(uid, selfPetId)
	local queryInfo = {
		selfPetId
	}

	self:serverMsg("RPC_CS_SocialQuery", SocialConst.QUERY_CAN_BREED_PETS, uid, queryInfo)
end

function ClientPetsBreedComponent:onQueryCanBreedPetsReply(uid, replyInfo)
	if pg.logDebug() then
		self.logger:debug("__petbreed onQueryCanBreedPetsReply", uid, inspect(lume.map(replyInfo, "templateId")))
	end
end

function ClientPetsBreedComponent:invitePetBreed(srcPetId, inviteeUid, dstPetId)
	local inviteInfo = {
		srcPetId = srcPetId,
		dstPetId = dstPetId,
		srcPetInfo = self.pets[srcPetId]:getRawTable()
	}

	self:serverMsg("RPC_CS_SocialInvite", SocialConst.SOCIAL_PET_BREED, inviteeUid, inviteInfo)
end

function ClientPetsBreedComponent:onRecvPetBreedInvite(invitorUid, inviteInfo)
	if pg.logDebug() then
		self.logger:debug("__petbreed onRecvInvitePetBreed", invitorUid, inspect(inviteInfo, {
			depth = 3
		}))
	end

	self:replyPetBreedInvite(invitorUid, true, {})
end

function ClientPetsBreedComponent:replyPetBreedInvite(invitorUid, accept, replyInfo)
	self:serverMsg("RPC_CS_SocialInviteReply", SocialConst.SOCIAL_PET_BREED, invitorUid, {
		accept,
		replyInfo
	})
end

function ClientPetsBreedComponent:onRecvPetBreedInviteReply(inviteeUid, accept, replyInfo)
	if pg.logDebug() then
		self.logger:debug("__petbreed onRecvPetBreedInviteReply", inviteeUid, accept, inspect(replyInfo, {
			depth = 3
		}))
	end
end

function ClientPetsBreedComponent:onStartPetBreedSocial(socialInfo, isResume)
	if pg.logDebug() then
		self.logger:debug("__petbreed onStartPetBreedSocial, socialInfo=%s, isResume=%s", inspect(socialInfo, {
			depth = 3
		}), isResume)
	end
end

function ClientPetsBreedComponent:sendPetBreedOperation(op, params, callback)
	local localCallback = callback or function(result, resp)
		if (not result or ToInt(resp and resp.noticeId) ~= 0) and pg.logDebug() then
			self.logger:debug("__petbreed operation reply, op=%s, params=%s, result=%s, resp=%s", op, inspect(params, {
				depth = 3
			}), result, inspect(resp, {
				depth = 3
			}))
		end
	end

	self:sendSocialOperation(op, params, localCallback)
end

function ClientPetsBreedComponent:onNotifyPetBreedSocial(op, params)
	if pg.logDebug() then
		self.logger:debug("__petbreed onNotifyPetBreedSocial", op, inspect(params, {
			depth = 3
		}))
	end

	if op == SocialConst.PB_SC_ChangeSelectInfo then
		local uid, selectInfo = params[1], params[2]

		self.curSocialInfo.players[uid].selectInfo = selectInfo
	elseif op == SocialConst.PB_SC_ConfirmBreed then
		local uid = params[1]

		self.curSocialInfo.players[uid].confirm = true
	elseif op == SocialConst.PB_SC_SendNotice then
		local noticeId, noticeArgs = params[1], params[2]

		pg.global.showBubbleMessageById(noticeId, noticeArgs)
	end
end

function ClientPetsBreedComponent:onEndPetBreedSocial()
	if pg.logDebug() then
		self.logger:debug("__petbreed onEndPetBreedSocial")
	end
end

function ClientPetsBreedComponent:sendPetBreedSelf(fatherId, motherId, selectInfo, callback)
	local localCallback = callback or function(noticeId, noticeArgs)
		if noticeId ~= NoticeDef.SUCCESS then
			pg.global.showBubbleMessageById(noticeId, noticeArgs)
		end

		if pg.logDebug() then
			self.logger:debug("__petbreed sendPetBreedSelf reply, fatherId=%s, motherId=%s, selectInfo=%s, noticeId=%s, noticeArgs=%s", fatherId, motherId, inspect(selectInfo, {
				depth = 3
			}), noticeId, inspect(noticeArgs, {
				depth = 3
			}))
		end
	end

	self:serverMsg("RPC_CS_PetBreedSelf", fatherId, motherId, selectInfo, localCallback)
end

return ClientPetsBreedComponent
