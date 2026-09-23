-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetsExchangeComponent.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local SocialConst = require("Common.Const.SocialConst")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local CommonSwitch = require("Common.CommonSwitch")
local SysConfigData = require("Data.sys_config_data")
local FuncIdConfigData = require("Data.func_index_config_data")
local Time = require("Core.Common.Time")
local ClientPetsExchangeComponent = Class.Component("ClientPetsExchangeComponent")

function ClientPetsExchangeComponent:init()
	self.petExchangeInviteHistory = {}

	local hooks = ClientPetsExchangeComponent._platformHooks

	if hooks and hooks.init then
		hooks.init(self)
	end
end

function ClientPetsExchangeComponent:destroy()
	local hooks = ClientPetsExchangeComponent._platformHooks

	if hooks and hooks.destroy then
		hooks.destroy(self)
	end
end

function ClientPetsExchangeComponent.tryPetExchangePlatformHook(methodName, self, ...)
	local _h = ClientPetsExchangeComponent._platformHooks

	return _h and _h[methodName] and _h[methodName](self, ...) == true
end

function ClientPetsExchangeComponent:invitePetExchange(inviteeUid)
	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.TEAM) then
		pg.global.ui.tips:showTextTip(pg.getLocalizationText(FuncIdConfigData[Const.FUNCTION_NAME.TEAM].unlockDesc))

		return
	end

	if not pg.game.chat:checkFriendList(inviteeUid) then
		pg.global.ui.tips:showTextTip(pg.getGameString("NOT_FRIEND_EXCHAGEPET_TIP"))

		return
	end

	if self.curSocialInfo ~= nil then
		self.logger:error("invitePetExchange, but curSocialInfo not nil, ignore", self:repr())

		return
	end

	if ClientPetsExchangeComponent.tryPetExchangePlatformHook("beforeSendPetExchangeInvite", self, inviteeUid) then
		return
	end

	if self.petExchangeInviteHistory[inviteeUid] and self.petExchangeInviteHistory[inviteeUid] + SysConfigData.INVITE_CD > Time.realSecondCache then
		pg.global.ui.tips:showTextTip(pg.getGameString("OPERATE_TOO_MANY"))

		return
	end

	self.petExchangeInviteHistory[inviteeUid] = Time.realSecondCache

	pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))

	local inviteInfo = {}

	self:serverMsg("RPC_CS_SocialInvite", SocialConst.SOCIAL_PET_EXCHANGE, inviteeUid, inviteInfo)
end

function ClientPetsExchangeComponent:onRecvPetExchangeInvite(invitorUid, inviteInfo)
	if pg.logDebug() then
		self.logger:debug("__petexchange onRecvInvitePetExchange", invitorUid, inspect(inviteInfo, {
			depth = 3
		}))
	end

	if ClientPetsExchangeComponent.tryPetExchangePlatformHook("beforeRecvPetExchangeInvite", self, invitorUid, inviteInfo) then
		return
	end

	local playerInfo = pg.game.chat:getPlayerInfo(invitorUid)

	if pg.me.curSocialInfo ~= nil then
		return
	end

	local extraParam = {
		type = 3,
		tIndex = 1,
		funcName = Const.FUNCTION_NAME.TEAM
	}

	pg.global.ui.tips:addHudNotice(invitorUid, playerInfo, pg.getGameString("EXCHANGE_PET_INVITE"), SysConfigData.WAIT_APPLICANT_TIME, function()
		self:replyPetExchangeInvite(invitorUid, true, {})
		self:openPetExchangeSelectPage(invitorUid)
	end, function()
		self:replyPetExchangeInvite(invitorUid, false, {})
	end, function()
		self:replyPetExchangeInvite(invitorUid, false, {})
	end, extraParam)
end

function ClientPetsExchangeComponent:replyPetExchangeInvite(invitorUid, accept, replyInfo)
	self:serverMsg("RPC_CS_SocialInviteReply", SocialConst.SOCIAL_PET_EXCHANGE, invitorUid, {
		accept,
		replyInfo
	})
end

function ClientPetsExchangeComponent:onRecvPetExchangeInviteReply(inviteeUid, accept, replyInfo)
	if pg.logDebug() then
		self.logger:debug("__petexchange onRecvPetExchangeInviteReply", inviteeUid, accept, inspect(replyInfo, {
			depth = 3
		}))
	end

	if accept then
		ClientUtils.showBubbleMessageById(NoticeDef.EXCHANGE_PET_ACCEPT, inviteeUid)
		pg.global.ui.tips:removeTeamInviteNoticeByPlayerId(inviteeUid)
		self:openPetExchangeSelectPage(inviteeUid)
	else
		local errNoticeId = replyInfo and (replyInfo.srcErr or replyInfo.dstErr or replyInfo.dstErr2 or replyInfo.srcErr2)

		if errNoticeId then
			ClientUtils.showBubbleMessageById(errNoticeId)
		else
			ClientUtils.showBubbleMessageById(NoticeDef.EXCHANGE_PET_REJECT, inviteeUid)
		end
	end
end

function ClientPetsExchangeComponent:openPetExchangeSelectPage(friendUid)
	pg.global.ui:open(UIConst.UI_ID_PET_EXCHANGE_SELECT, {
		uid = friendUid
	}, nil, nil, {
		textureWidth = 1024,
		textureHeight = 1024
	})
end

function ClientPetsExchangeComponent:getExchangeSocialInfo()
	return self.curSocialInfo
end

function ClientPetsExchangeComponent:onStartPetExchangeSocial(socialInfo, isResume)
	if pg.logDebug() then
		self.logger:debug("__petexchange onStartPetExchangeSocial, socialInfo=%s, isResume=%s", inspect(socialInfo, {
			depth = 3
		}), isResume)
	end

	local hooks = ClientPetsExchangeComponent._platformHooks

	if hooks and hooks.onStartPetExchangeSocial then
		hooks.onStartPetExchangeSocial(self, socialInfo, isResume)
	end
end

function ClientPetsExchangeComponent:sendPetExchangePetInfoOperation(op, petId, callback)
	local pet = petId and pg.me.pets[petId]

	if not pet then
		if pg.logDebug() then
			self.logger:debug("__petexchange sendPetExchangePetInfoOperation skipped, op=%s, petId=%s not in pg.me.pets", tostring(op), tostring(petId))
		end

		return
	end

	local petInfo = Utils.deepCopyTable(pet:getRawTable())
	local isCatchReporting = pet:isCatchReporting()

	if op == SocialConst.PE_CS_ConfirmPet then
		Utils.genBasePropertyPreview(pet, Const.PROP_PREVIEW_EXCHANGE_SEND, nil, function(displayDict)
			petInfo.basePropertyList = displayDict
			petInfo.isCatchReporting = isCatchReporting

			self:sendPetExchangeOperation(op, {
				petInfo
			}, callback)
		end)
	else
		petInfo.isCatchReporting = isCatchReporting

		self:sendPetExchangeOperation(op, {
			petInfo
		}, callback)
	end
end

function ClientPetsExchangeComponent:chooseExchangePet(petId, callback)
	self:sendPetExchangePetInfoOperation(SocialConst.PE_CS_ChoosePet, petId, callback)
end

function ClientPetsExchangeComponent:confirmExchangePet(petId, callback)
	self:sendPetExchangePetInfoOperation(SocialConst.PE_CS_ConfirmPet, petId, callback)
end

function ClientPetsExchangeComponent:confirmExchange(isClickOk)
	self:sendPetExchangeOperation(SocialConst.PE_CS_FinalClick, {
		isClickOk
	})
end

function ClientPetsExchangeComponent:cancelConfirmExchangePetState()
	self:sendPetExchangeOperation(SocialConst.PE_CS_CancelConfirm, {})
end

function ClientPetsExchangeComponent:cancelExchangePet()
	self:sendPetExchangeOperation(SocialConst.PE_CS_Quit, {
		Const.EPQR_CLIENT_QUIT
	})
end

function ClientPetsExchangeComponent:sendPetExchangeOperation(op, params, callback)
	local localCallback = callback or function(result, resp)
		if (not result or ToInt(resp and resp.noticeId) ~= 0) and pg.logDebug() then
			self.logger:debug("__petexchange operation reply, op=%s, params=%s, result=%s, resp=%s", op, inspect(params, {
				depth = 3
			}), result, inspect(resp, {
				depth = 3
			}))
		end
	end

	self:sendSocialOperation(op, params, localCallback)
end

function ClientPetsExchangeComponent:onNotifyPetExchangeSocial(op, params)
	if pg.logDebug() then
		self.logger:debug("__petexchange onNotifyPetExchangeSocial", op, inspect(params, {
			depth = 3
		}))
	end

	if op == SocialConst.PE_SC_Notice then
		local noticeId, noticeArgs = unpack(params)

		if noticeId == NoticeDef.EXCHANGE_PET_CLIENT_QUIT then
			local uid = unpack(noticeArgs)

			if uid == pg.me.uid then
				pg.global.ui.tips:showTextTip(pg.getGameString("EXCHANGE_PET_SELF_QUIT"))
			else
				pg.global.ui.tips:showTextTip(pg.getGameString("EXCHANGE_PET_FRIEND_QUIT"))
			end

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_WAIT) then
				pg.global.ui:close(UIConst.UI_ID_PET_EXCHANGE_WAIT)
			end
		else
			ClientUtils.showBubbleMessageById(noticeId, unpack(noticeArgs or {}))

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_WAIT) then
				pg.global.ui:close(UIConst.UI_ID_PET_EXCHANGE_WAIT)
			end
		end
	elseif op == SocialConst.PE_SC_SyncExchangeInfo then
		local ov, nv, isSuccess = self.curSocialInfo, params[1], params[2]

		self.curSocialInfo = nv

		facade:SendMessageCommand(MessageName.PET_EXCHANGE_SYNC_INFO)

		if isSuccess ~= nil then
			facade:SendMessageCommand(MessageName.PET_EXCHANGE_SYNC_RESULT, {
				isSuccess = isSuccess
			})
		end
	end
end

function ClientPetsExchangeComponent:onEndPetExchangeSocial()
	self.tempSocialInfo = self.curSocialInfo

	if pg.logDebug() then
		self.logger:debug("__petexchange onEndPetExchangeSocial")
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_SELECT) then
		pg.global.ui:close(UIConst.UI_ID_PET_EXCHANGE_SELECT)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN) then
		pg.global.ui:close(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_TIP) then
		pg.global.ui:close(UIConst.UI_ID_PET_EXCHANGE_TIP)
	end
end

function ClientPetsExchangeComponent:EVENT_CommonSwitchStateChanged()
	if not CommonSwitch.PET_EXCHANGE then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)
		self:cancelExchangePet()
	end
end

return ClientPetsExchangeComponent
