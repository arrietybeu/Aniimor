-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPhotographyStudioComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local MessageName = require("Const.MessageName")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local json = require("json")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local PlatformPhotographyStudioInviteFilterService = require("SDK.Platform.PlatformPhotographyStudioInviteFilterService")
local INVITED_PLAYER_DEFAULT_POSITIONS = {
	{
		z = 0,
		y = 0,
		x = 1.5
	},
	{
		z = 0,
		y = 0,
		x = -1.5
	},
	{
		z = 1.5,
		y = 0,
		x = 0
	},
	{
		z = -1.5,
		y = 0,
		x = 0
	}
}
local ClientPhotographyStudioComponent = class.Component("ClientPhotographyStudioComponent")

function ClientPhotographyStudioComponent:ctor()
	self.studioMap = {}
	self.invitations = {}
	self.inviteds = {}
	self.contentCache = {}
	self.syncedStudioContentVersions = {}
	self.pendingStudioContentSyncWaiters = {}
	self.pendingCreateTip = false
	self.pendingSaveTipStudioUid = nil
	self.pendingRemoveStudioUid = nil
	self.pendingRemoveMemberUid = nil
	self.activePhotographyStudioMembers = {}
	self.editingPhotographyStudioUid = nil
end

function ClientPhotographyStudioComponent:init(avtDict)
	return true
end

function ClientPhotographyStudioComponent:destroy()
	PhotographyStudioUtils.clearPhotographyStudioCoverCache()

	self.activePhotographyStudioMembers = {}
	self.editingPhotographyStudioUid = nil
end

function ClientPhotographyStudioComponent:getStudioInfo(studioUid)
	return self.studioMap[studioUid]
end

function ClientPhotographyStudioComponent:getAllStudios()
	return self.studioMap
end

function ClientPhotographyStudioComponent:isStudioMaster(studioUid)
	local info = self.studioMap[studioUid]

	return info ~= nil and info.masterUid == self.uid
end

function ClientPhotographyStudioComponent:getStudioMasterUid(studioUid)
	local info = self.studioMap[studioUid]

	return info and info.masterUid
end

function ClientPhotographyStudioComponent:getCachedPhotographyStudioContent(studioUid)
	return self.contentCache[studioUid]
end

function ClientPhotographyStudioComponent:isPhotographyStudioMemberActive(studioUid, memberUid)
	if studioUid == nil or memberUid == nil then
		return false
	end

	local activeMembers = self.activePhotographyStudioMembers[tostring(studioUid)]

	return activeMembers ~= nil and activeMembers[tostring(memberUid)] == true
end

function ClientPhotographyStudioComponent:getPhotographyStudioActiveMemberCount(studioUid)
	if studioUid == nil then
		return 0
	end

	local activeMembers = self.activePhotographyStudioMembers[tostring(studioUid)]

	if activeMembers == nil then
		return 0
	end

	local count = 0

	for _ in pairs(activeMembers) do
		count = count + 1
	end

	return count
end

function ClientPhotographyStudioComponent:waitPhotographyStudioContentSynced(studioUid, version, callback)
	local targetVersion = tonumber(version)

	if not studioUid or not targetVersion or not callback then
		return
	end

	local syncedVersion = tonumber(self.syncedStudioContentVersions[studioUid]) or 0

	if targetVersion <= syncedVersion then
		callback()

		return
	end

	self.pendingStudioContentSyncWaiters[studioUid] = {
		version = targetVersion,
		callback = callback
	}
end

function ClientPhotographyStudioComponent:getSentPhotographyStudioInvitations()
	return self.invitations or {}
end

function ClientPhotographyStudioComponent:getReceivedPhotographyStudioInvitations()
	return self.inviteds or {}
end

function ClientPhotographyStudioComponent:notifyStudioChanged(createdStudioUid)
	facade:sendMsgToUI(MessageName.ON_PHOTOGRAPHY_STUDIO_CHANGED, createdStudioUid)
end

function ClientPhotographyStudioComponent:notifyStudioInvitationsChanged()
	facade:sendMsgToUI(MessageName.ON_PHOTOGRAPHY_STUDIO_INVITATIONS_CHANGED)
end

function ClientPhotographyStudioComponent:notifyPhotographyStudioActiveMembersChanged(studioUid, memberUid, active)
	facade:sendMsgToUI(MessageName.ON_PHOTOGRAPHY_STUDIO_ACTIVE_MEMBERS_CHANGED, {
		studioUid = studioUid,
		memberUid = memberUid,
		active = active
	})
end

local function getInvitationField(data, fieldName)
	if not data then
		return nil
	end

	local lowerFieldName = string.lower(string.sub(fieldName, 1, 1)) .. string.sub(fieldName, 2)

	return data[fieldName] ~= nil and data[fieldName] or data[lowerFieldName]
end

local function getInvitationRedDotRecordKey(prefix, record, playerUidField)
	return string.format("%s_%s_%s", prefix, tostring(getInvitationField(record, "PhotographyStudioUid")), tostring(getInvitationField(record, playerUidField)))
end

local function isSameInvitationStudio(record, studioUid)
	return studioUid == nil or tostring(getInvitationField(record, "PhotographyStudioUid")) == tostring(studioUid)
end

function ClientPhotographyStudioComponent:canReceivePhotographyStudioInvite(invitationUid)
	if invitationUid == nil then
		return false
	end

	local playerInfo = pg.game.chat:getPlayerInfo(invitationUid)

	return PlatformPhotographyStudioInviteFilterService:canReceiveInvite(playerInfo)
end

function ClientPhotographyStudioComponent:getUnreadPhotographyStudioAcceptedInviteCount(studioUid)
	local count = 0

	for _, record in ipairs(self.invitations) do
		if getInvitationField(record, "Accepted") == true and isSameInvitationStudio(record, studioUid) then
			local recordKey = getInvitationRedDotRecordKey("accepted", record, "InvitedUid")

			if self:getRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, true) then
				count = count + 1
			end
		end
	end

	return count
end

function ClientPhotographyStudioComponent:getUnreadPhotographyStudioInvitationCount()
	local count = 0

	for _, record in ipairs(self.inviteds) do
		local invitationUid = getInvitationField(record, "InvitationUid")

		if getInvitationField(record, "Accepted") ~= true and self:canReceivePhotographyStudioInvite(invitationUid) then
			local recordKey = getInvitationRedDotRecordKey("invited", record, "InvitationUid")

			if self:getRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, true) then
				count = count + 1
			end
		end
	end

	return count
end

function ClientPhotographyStudioComponent:markPhotographyStudioAcceptedInvitesRead(studioUid)
	local changed = false

	for _, record in ipairs(self.invitations) do
		if getInvitationField(record, "Accepted") == true and isSameInvitationStudio(record, studioUid) then
			local recordKey = getInvitationRedDotRecordKey("accepted", record, "InvitedUid")

			if self:getRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, true) then
				self:setRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, false)

				changed = true
			end
		end
	end

	return changed
end

function ClientPhotographyStudioComponent:markPhotographyStudioInvitationsRead()
	local changed = false

	for _, record in ipairs(self.inviteds) do
		local invitationUid = getInvitationField(record, "InvitationUid")

		if getInvitationField(record, "Accepted") ~= true and self:canReceivePhotographyStudioInvite(invitationUid) then
			local recordKey = getInvitationRedDotRecordKey("invited", record, "InvitationUid")

			if self:getRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, true) then
				self:setRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, false)

				changed = true
			end
		end
	end

	return changed
end

local function isSameUid(left, right)
	return left ~= nil and right ~= nil and tostring(left) == tostring(right)
end

local function getStudioMemberUid(member)
	if type(member) == "table" then
		return member.uid or member.Uid
	end

	return member
end

local function getStudioMemberMap(info)
	local memberMap = {}

	if not info or not info.members then
		return memberMap
	end

	for _, member in ipairs(info.members) do
		local uid = getStudioMemberUid(member)

		if uid ~= nil then
			memberMap[tostring(uid)] = member
		end
	end

	return memberMap
end

local function getStudioMemberName(uid, member)
	local playerName

	if type(member) == "table" then
		playerName = member.playerName or member.name
	end

	if string.isNilOrEmpty(playerName) and pg.game and pg.game.chat then
		local playerInfo = pg.game.chat:getPlayerInfo(uid)

		playerName = playerInfo and playerInfo.playerName
	end

	if string.isNilOrEmpty(playerName) then
		return tostring(uid)
	end

	return playerName
end

local function getMaskedStudioMemberName(uid, member)
	local playerInfo

	if pg.game and pg.game.chat then
		playerInfo = pg.game.chat:getPlayerInfo(uid)
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ToastName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = getStudioMemberName(uid, member)
	})
end

function ClientPhotographyStudioComponent:setPhotographyStudioMemberActive(studioUid, memberUid, active, showTip)
	if studioUid == nil or memberUid == nil then
		return false
	end

	local studioKey = tostring(studioUid)
	local memberKey = tostring(memberUid)
	local activeMembers = self.activePhotographyStudioMembers[studioKey]
	local wasActive = activeMembers ~= nil and activeMembers[memberKey] == true

	if active then
		if wasActive then
			return false
		end

		if activeMembers == nil then
			activeMembers = {}
			self.activePhotographyStudioMembers[studioKey] = activeMembers
		end

		activeMembers[memberKey] = true
	else
		if not wasActive then
			return false
		end

		activeMembers[memberKey] = nil

		if next(activeMembers) == nil then
			self.activePhotographyStudioMembers[studioKey] = nil
		end
	end

	if showTip and not isSameUid(memberUid, self.uid) then
		local studioInfo = self.studioMap[studioUid] or self.studioMap[studioKey]
		local memberMap = getStudioMemberMap(studioInfo)
		local playerName = getMaskedStudioMemberName(memberUid, memberMap[memberKey])
		local gameString = active and "PHOTO_STUDIO_MEMBER_ENTER_TIP" or "PHOTO_STUDIO_MEMBER_LEAVE_TIP"

		pg.global.showBubbleMessageRaw(string.format(pg.getGameString(gameString), playerName))
	end

	self:notifyPhotographyStudioActiveMembersChanged(studioUid, memberUid, active == true)

	return true
end

local function findInvitation(list, uidField, uid, studioUid)
	for index, data in ipairs(list or EMPTY_TABLE) do
		if isSameUid(getInvitationField(data, uidField), uid) and isSameUid(getInvitationField(data, "PhotographyStudioUid"), studioUid) then
			return data, index
		end
	end
end

local function removeInvitation(list, uidField, uid, studioUid)
	local _, index = findInvitation(list, uidField, uid, studioUid)

	if index then
		table.remove(list, index)

		return true
	end

	return false
end

local function removeInvitationsByStudio(list, studioUid)
	local changed = false

	for index = #(list or {}), 1, -1 do
		if isSameUid(getInvitationField(list[index], "PhotographyStudioUid"), studioUid) then
			table.remove(list, index)

			changed = true
		end
	end

	return changed
end

function ClientPhotographyStudioComponent:getReceivedPhotographyStudioInvitation(studioUid, invitationUid)
	return findInvitation(self.inviteds, "InvitationUid", invitationUid, studioUid)
end

function ClientPhotographyStudioComponent:getSentPhotographyStudioInvitation(studioUid, invitedUid)
	return findInvitation(self.invitations, "InvitedUid", invitedUid, studioUid)
end

function ClientPhotographyStudioComponent:isReceivedPhotographyStudioInvitationPending(studioUid, invitationUid)
	local data = self:getReceivedPhotographyStudioInvitation(studioUid, invitationUid)

	return data ~= nil and getInvitationField(data, "Accepted") ~= true
end

function ClientPhotographyStudioComponent:isReceivedPhotographyStudioInvitationAccepted(studioUid, invitationUid)
	local data = self:getReceivedPhotographyStudioInvitation(studioUid, invitationUid)

	return data ~= nil and getInvitationField(data, "Accepted") == true
end

function ClientPhotographyStudioComponent:isSentPhotographyStudioInvitationAccepted(studioUid, invitedUid)
	local data = self:getSentPhotographyStudioInvitation(studioUid, invitedUid)

	return data ~= nil and getInvitationField(data, "Accepted") == true
end

function ClientPhotographyStudioComponent:sendPhotographyStudioInviteMessage(studioUid, invitedUid)
	if studioUid == nil or invitedUid == nil then
		return false
	end

	return pg.game.chat:sendMessage(pg.getGameString("PHOTO_STUDIO_CHAT_INVITE_MESSAGE"), pg.game.chat.subMessageType.PhotographyStudioInvite, pg.game.chat.channelType.Player, invitedUid, {
		[Const.CHAT_EXTRA_TYPE.PhotographyStudioInvite] = {
			studioUid = studioUid,
			invitationUid = self.uid,
			invitedUid = invitedUid,
			inviteTime = Time.secondCache or os.time()
		}
	})
end

function ClientPhotographyStudioComponent:sendPhotographyStudioAcceptMessage(invitationUid)
	if invitationUid == nil then
		return false
	end

	return pg.game.chat:sendMessage(pg.getGameString("PHOTO_STUDIO_CHAT_ACCEPT_MESSAGE"), pg.game.chat.subMessageType.Text, pg.game.chat.channelType.Player, invitationUid, {
		[Const.CHAT_EXTRA_TYPE.ChatType] = Const.CHAT_MESSAGE_TYPE.System
	})
end

function ClientPhotographyStudioComponent:upsertSentInvitation(invitedUid, studioUid, accepted)
	if invitedUid == nil or studioUid == nil then
		return false
	end

	self.invitations = self.invitations or {}

	local data = findInvitation(self.invitations, "InvitedUid", invitedUid, studioUid)
	local isNewInvitation = data == nil
	local wasAccepted = data and getInvitationField(data, "Accepted") == true

	if not data then
		data = {
			InvitedUid = invitedUid,
			PhotographyStudioUid = studioUid,
			Atime = Time.secondCache or os.time()
		}

		table.insert(self.invitations, data)
	end

	data.Accepted = accepted == true

	if isNewInvitation or data.Accepted ~= wasAccepted then
		local recordKey = getInvitationRedDotRecordKey("accepted", data, "InvitedUid")

		self:setRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, true)
	end

	return true
end

function ClientPhotographyStudioComponent:upsertReceivedInvitation(invitationUid, studioUid, accepted)
	if invitationUid == nil or studioUid == nil then
		return false
	end

	self.inviteds = self.inviteds or {}

	local data = findInvitation(self.inviteds, "InvitationUid", invitationUid, studioUid)
	local wasPending = data and getInvitationField(data, "Accepted") ~= true

	if not data then
		data = {
			InvitationUid = invitationUid,
			PhotographyStudioUid = studioUid,
			Atime = Time.secondCache or os.time()
		}

		table.insert(self.inviteds, data)
	end

	data.Accepted = accepted == true

	if not data.Accepted and not wasPending then
		local recordKey = getInvitationRedDotRecordKey("invited", data, "InvitationUid")

		self:setRedDotRecord(Const.CLIENT_KEY.PHOTOGRAPHY_STUDIO_RED_DOT, recordKey, true)
	end

	return true
end

function ClientPhotographyStudioComponent:showStudioMemberChangeTips(studioUid, oldInfo, newInfo)
	if not oldInfo or not newInfo or not isSameUid(oldInfo.masterUid, self.uid) then
		return
	end

	local oldMemberMap = getStudioMemberMap(oldInfo)
	local newMemberMap = getStudioMemberMap(newInfo)

	for uidKey, member in pairs(newMemberMap) do
		if oldMemberMap[uidKey] == nil then
			local uid = getStudioMemberUid(member)
			local playerName = getMaskedStudioMemberName(uid, member)

			pg.global.showBubbleMessageRaw(string.format(pg.getGameString("PHOTO_STUDIO_INVITE_ACCEPTED_TIP"), playerName))
		end
	end

	for uidKey, member in pairs(oldMemberMap) do
		if newMemberMap[uidKey] == nil then
			local uid = getStudioMemberUid(member)
			local isPendingRemove = isSameUid(self.pendingRemoveStudioUid, studioUid) and isSameUid(self.pendingRemoveMemberUid, uid)

			if isPendingRemove then
				self.pendingRemoveStudioUid = nil
				self.pendingRemoveMemberUid = nil
			else
				local playerName = getMaskedStudioMemberName(uid, member)

				pg.global.showBubbleMessageRaw(string.format(pg.getGameString("PHOTO_STUDIO_MEMBER_LEFT_TIP"), playerName))
			end
		end
	end
end

function ClientPhotographyStudioComponent:removeSentInvitationsForRemovedMembers(studioUid, oldInfo, newInfo)
	if not oldInfo or not newInfo or not isSameUid(oldInfo.masterUid, self.uid) then
		return false
	end

	local changed = false
	local oldMemberMap = getStudioMemberMap(oldInfo)
	local newMemberMap = getStudioMemberMap(newInfo)

	for uidKey, member in pairs(oldMemberMap) do
		if newMemberMap[uidKey] == nil then
			local uid = getStudioMemberUid(member)
			local invitation, index = findInvitation(self.invitations, "InvitedUid", uid, studioUid)

			if index and getInvitationField(invitation, "Accepted") == true then
				table.remove(self.invitations, index)

				changed = true
			end
		end
	end

	return changed
end

function ClientPhotographyStudioComponent:onStudioNotice(noticeId, noticeArgs)
	if noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_CREATE_SUCCESS then
		if self.pendingCreateTip then
			self.pendingCreateTip = false

			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_CREATE_SUCCESS_TIP"))
		end
	elseif noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_CREATE_ERROR then
		self.pendingCreateTip = false
	elseif noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_SYNC_SUCCESS then
		local studioUid = noticeArgs and noticeArgs[1]

		if isSameUid(self.pendingSaveTipStudioUid, studioUid) then
			self.pendingSaveTipStudioUid = nil

			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_SAVE_SUCCESS_TIP"))
		end
	elseif noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_SYNC_ERROR or noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_CONTENT_ERROR then
		local studioUid = noticeArgs and noticeArgs[1]

		if isSameUid(self.pendingSaveTipStudioUid, studioUid) then
			self.pendingSaveTipStudioUid = nil
		end
	elseif noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_INVITE_SUCCESS then
		local studioUid = noticeArgs and noticeArgs[1]
		local invitedUid = noticeArgs and noticeArgs[2]

		if self:upsertSentInvitation(invitedUid, studioUid, false) then
			self:notifyStudioInvitationsChanged()
			self:sendPhotographyStudioInviteMessage(studioUid, invitedUid)
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_INVITE_SENT_TIP"))
	elseif noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_REFUSE_SUCCESS then
		self.inviteds = self.inviteds or {}

		removeInvitation(self.inviteds, "InvitationUid", noticeArgs and noticeArgs[2], noticeArgs and noticeArgs[1])
		self:notifyStudioInvitationsChanged()
	elseif noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_MEMBER_OVER then
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_INVITE_LIMIT_TIP"))
	elseif noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_REMOVE_ERROR then
		self.pendingRemoveStudioUid = nil
		self.pendingRemoveMemberUid = nil
	end

	facade:sendMsgToUI(MessageName.ON_PHOTOGRAPHY_STUDIO_NOTICE, {
		noticeId = noticeId,
		noticeArgs = noticeArgs
	})
end

function ClientPhotographyStudioComponent:RPC_SC_SyncPhotographyStudios(studioMap)
	self.studioMap = studioMap or {}

	self:notifyStudioChanged()
end

function ClientPhotographyStudioComponent:RPC_SC_SyncPhotographyStudio(studioUid, info)
	if not studioUid then
		return
	end

	local oldInfo = self.studioMap[studioUid]
	local createdStudioUid

	if oldInfo then
		self:showStudioMemberChangeTips(studioUid, oldInfo, info)

		if self:removeSentInvitationsForRemovedMembers(studioUid, oldInfo, info) then
			self:notifyStudioInvitationsChanged()
		end
	elseif self.pendingCreateTip and info and isSameUid(info.masterUid, self.uid) then
		createdStudioUid = studioUid
		self.pendingCreateTip = false

		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_CREATE_SUCCESS_TIP"))
	end

	self.studioMap[studioUid] = info

	if createdStudioUid then
		self:initializeStudioMasterSegment(studioUid)
	end

	self:notifyStudioChanged(createdStudioUid)
end

function ClientPhotographyStudioComponent:RPC_SC_RemovePhotographyStudio(studioUid)
	if not studioUid then
		return
	end

	self.studioMap[studioUid] = nil
	self.contentCache[studioUid] = nil
	self.activePhotographyStudioMembers[tostring(studioUid)] = nil

	if isSameUid(self.editingPhotographyStudioUid, studioUid) then
		self.editingPhotographyStudioUid = nil
	end

	PhotographyStudioUtils.invalidatePhotographyStudioCover(studioUid)

	if removeInvitationsByStudio(self.inviteds, studioUid) then
		self:notifyStudioInvitationsChanged()
	end

	self:notifyStudioChanged()
end

function ClientPhotographyStudioComponent:RPC_SC_UpdatePhotographyStudioName(studioUid, name)
	local info = self.studioMap[studioUid]

	if info then
		info.name = name
	end

	self:notifyStudioChanged()
end

function ClientPhotographyStudioComponent:RPC_SC_SyncPhotographyStudioInvitaions(invitations, inviteds)
	self.invitations = invitations or {}
	self.inviteds = inviteds or {}

	self:notifyStudioInvitationsChanged()
end

function ClientPhotographyStudioComponent:RPC_SC_EnterPhotographyStudio(studioUid, memberUid)
	local showTip = isSameUid(self.editingPhotographyStudioUid, studioUid)

	self:setPhotographyStudioMemberActive(studioUid, memberUid, true, showTip)
end

function ClientPhotographyStudioComponent:RPC_SC_LeavePhotographyStudio(studioUid, memberUid)
	local showTip = isSameUid(self.editingPhotographyStudioUid, studioUid)

	self:setPhotographyStudioMemberActive(studioUid, memberUid, false, showTip)
end

function ClientPhotographyStudioComponent:RPC_SC_AcceptInvitePhotographyStudio(studioUid)
	self:initializeInvitedPlayerSegment(studioUid)

	local invitationUid

	for _, data in ipairs(self.inviteds) do
		if isSameUid(getInvitationField(data, "PhotographyStudioUid"), studioUid) then
			if invitationUid == nil and getInvitationField(data, "Accepted") ~= true then
				invitationUid = getInvitationField(data, "InvitationUid")
			end

			data.Accepted = true
		end
	end

	self:notifyStudioInvitationsChanged()

	if invitationUid ~= nil then
		self:sendPhotographyStudioAcceptMessage(invitationUid)
	end
end

function ClientPhotographyStudioComponent:initializeStudioMasterSegment(studioUid)
	self:initializeSelfStudioSegment(studioUid)
end

function ClientPhotographyStudioComponent:initializeInvitedPlayerSegment(studioUid)
	local memberIndex = 1
	local info = self.studioMap[studioUid]

	if info and type(info.members) == "table" then
		for index, member in ipairs(info.members) do
			if isSameUid(getStudioMemberUid(member), self.uid) then
				memberIndex = index

				break
			end
		end
	end

	local defaultPos = INVITED_PLAYER_DEFAULT_POSITIONS[memberIndex]

	defaultPos = defaultPos or {
		z = 0,
		y = 0,
		x = memberIndex * 1.5
	}

	self:initializeSelfStudioSegment(studioUid, defaultPos)
end

function ClientPhotographyStudioComponent:initializeSelfStudioSegment(studioUid, defaultPos)
	if not studioUid then
		return
	end

	self:fetchStudioContent(studioUid, function(content, ok)
		if not ok then
			return
		end

		local players

		if type(content) == "table" and type(content.players) == "table" then
			players = content.players

			if players[self.uid] or players[tostring(self.uid)] then
				return
			end
		end

		local playerDelta = {}

		playerDelta[self.uid] = self:buildSelfDefaultSegment(defaultPos)

		self:saveStudioIncrementalContent(studioUid, {
			players = playerDelta
		})
	end)
end

function ClientPhotographyStudioComponent:buildSelfDefaultSegment(defaultPos)
	local me = pg.me
	local curShow = me.curShow or {}
	local playerPos = {
		z = 0,
		y = 0,
		x = 0
	}

	if defaultPos then
		playerPos.x = defaultPos.x or 0
		playerPos.y = defaultPos.y or 0
		playerPos.z = defaultPos.z or 0
	end

	return {
		templateId = me.templateId,
		avatarPresetKey = me.avatarPresetKey,
		avatarConfig = me.avatarConfig,
		appearance = PhotographyStudioUtils.serializeAppearanceFromCustomShow(curShow.customShow),
		curShow = PhotographyStudioUtils.serializeJsonSafeTable(curShow),
		jewelryLastInfos = PhotographyStudioUtils.serializeJsonSafeTable(me.jewelryLastInfos),
		playerPos = playerPos,
		playerRot = {
			z = 0,
			y = 0,
			x = 0
		}
	}
end

function ClientPhotographyStudioComponent:RPC_SC_UpdatePhotographyStudioContent(senderUid, studioUid, content)
	if not studioUid then
		return
	end

	if isSameUid(senderUid, self.uid) and type(content) == "table" then
		local syncedVersion = tonumber(content.version)

		if syncedVersion then
			local oldSyncedVersion = tonumber(self.syncedStudioContentVersions[studioUid]) or 0

			if oldSyncedVersion < syncedVersion then
				self.syncedStudioContentVersions[studioUid] = syncedVersion
			end

			local waiter = self.pendingStudioContentSyncWaiters[studioUid]

			if waiter and syncedVersion >= waiter.version then
				self.pendingStudioContentSyncWaiters[studioUid] = nil

				waiter.callback()
			end
		end
	end

	local cachedContent = self.contentCache[studioUid]
	local oldCoverVersion = type(cachedContent) == "table" and tonumber(cachedContent.coverVersion) or 0

	self:fetchStudioContent(studioUid, function(fullContent, ok)
		if ok and fullContent then
			local newCoverVersion = tonumber(fullContent.coverVersion) or 0

			if newCoverVersion ~= oldCoverVersion then
				PhotographyStudioUtils.invalidatePhotographyStudioCover(studioUid)
			end

			facade:sendMsgToUI(MessageName.ON_PHOTOGRAPHY_STUDIO_CONTENT_CHANGED, {
				senderUid = senderUid,
				studioUid = studioUid,
				content = fullContent,
				changedContent = content
			})
		end
	end)
end

function ClientPhotographyStudioComponent:fetchStudioContent(studioUid, callback)
	if not studioUid then
		if callback then
			callback(nil, false)
		end

		return
	end

	ServiceUtils.kvServiceFind(studioUid, function(status, response)
		local requestOk = status and status.status and true or false
		local contentStr = requestOk and response and response.value
		local content
		local ok = requestOk

		if not string.isNilOrEmpty(contentStr) then
			local decodeOk, decoded = pcall(json.decode, contentStr)

			if decodeOk and type(decoded) == "table" then
				content = decoded
			else
				ok = false

				self.logger:error("fetchStudioContent decode failed, studioUid=%s", tostring(studioUid))
			end
		end

		if ok then
			self.contentCache[studioUid] = content
		end

		if callback then
			callback(content, ok)
		end
	end)
end

function ClientPhotographyStudioComponent:saveStudioContent(studioUid, contentTable, callback, showSuccessTip, incremental)
	if not studioUid or type(contentTable) ~= "table" then
		if callback then
			callback(false)
		end

		return
	end

	if not incremental and not self:isStudioMaster(studioUid) then
		if callback then
			callback(false)
		end

		return
	end

	if not incremental then
		local currentVersion = tonumber(contentTable.version) or PhotographyStudioUtils.CONTENT_VERSION
		local cachedContent = self.contentCache[studioUid]

		currentVersion = type(cachedContent) == "table" and tonumber(cachedContent.version) or currentVersion
		contentTable.version = currentVersion + 1
	end

	if showSuccessTip then
		self.pendingSaveTipStudioUid = studioUid
	end

	local contentStr = json.encode(contentTable)

	if not incremental then
		self.contentCache[studioUid] = contentTable
	end

	self:serverMsg("RPC_CS_SyncPhotographyStudioContent", studioUid, contentStr, function(ok, code)
		if ok == false and isSameUid(self.pendingSaveTipStudioUid, studioUid) then
			self.pendingSaveTipStudioUid = nil
		end

		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:saveStudioIncrementalContent(studioUid, contentTable, callback, showSuccessTip)
	self:saveStudioContent(studioUid, contentTable, callback, showSuccessTip, true)
end

function ClientPhotographyStudioComponent:reqPhotographyStudioUnlock(callback)
	self:serverMsg("RPC_CS_ReqPhotographyStudioUnlock", function(ok, code)
		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqCreatePhotographyStudio(callback)
	self.pendingCreateTip = true

	self:serverMsg("RPC_CS_CreatePhotographyStudio", function(ok, code)
		if ok == false then
			self.pendingCreateTip = false
		end

		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqUpdatePhotographyStudioName(studioUid, name, callback)
	self:serverMsg("RPC_CS_UpdatePhotographyStudioName", studioUid, name, function(ok, code)
		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqInvitePhotographyStudio(studioUid, invitedUid, callback)
	self:serverMsg("RPC_CS_InvitePhotographyStudio", studioUid, invitedUid, function(ok, code)
		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqAcceptInvitePhotographyStudio(studioUid, invitationUid, callback)
	local playerInfo = pg.game.chat:getPlayerInfo(invitationUid)
	local canAccept = PlatformPhotographyStudioInviteFilterService:canReceiveInvite(playerInfo)

	if not canAccept then
		PlatformNoticeUtils.showTextTipById(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		if callback then
			callback(false)
		end

		return
	end

	self:serverMsg("RPC_CS_AcceptInvitePhotographyStudio", studioUid, invitationUid, function(ok, code)
		if ok == false and code == Const.PHOTOGRAPHY_STUDIO_RET_CODE.PHOTOGRAPHY_STUDIO_ACCEPT_OVER then
			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_INVITED_LIMIT_TIP"))
		end

		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqRefuseInvitePhotographyStudio(studioUid, invitationUid, callback)
	self:serverMsg("RPC_CS_RemoveInvitePhotographyStudio", studioUid, invitationUid, function(ok, code)
		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqRemovePhotographyStudioMember(studioUid, invitedUid, callback)
	self.pendingRemoveStudioUid = studioUid
	self.pendingRemoveMemberUid = invitedUid

	self:serverMsg("RPC_CS_RemovePhotographyStudio", studioUid, invitedUid, function(ok, code)
		if ok == false then
			self.pendingRemoveStudioUid = nil
			self.pendingRemoveMemberUid = nil
		end

		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqLeavePhotographyStudio(studioUid, invitationUid, callback)
	self:serverMsg("RPC_CS_LeaveInvitePhotographyStudio", studioUid, invitationUid, function(ok, code)
		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:reqChangeProfilePhotographyStudioUid(studioUid, callback)
	local value = studioUid and tostring(studioUid) or ""

	self:serverMsg("RPC_CS_ChangeProfilePhotographyStudioUid", value, function(ok, code)
		if callback then
			callback(ok, code)
		end
	end)
end

function ClientPhotographyStudioComponent:enterPhotographyStudioEdit(studioUid)
	if studioUid == nil or self:isPhotographyStudioMemberActive(studioUid, self.uid) then
		return
	end

	self.editingPhotographyStudioUid = studioUid

	self:setPhotographyStudioMemberActive(studioUid, self.uid, true, false)
	self:serverMsg("RPC_CS_EnterPhotographyStudio", studioUid)
end

function ClientPhotographyStudioComponent:leavePhotographyStudioEdit(studioUid)
	if studioUid == nil or self.studioMap[studioUid] == nil then
		return
	end

	self:serverMsg("RPC_CS_LeavePhotographyStudio", studioUid)

	if isSameUid(self.editingPhotographyStudioUid, studioUid) then
		self.editingPhotographyStudioUid = nil
	end

	local studioKey = tostring(studioUid)

	if self.activePhotographyStudioMembers[studioKey] ~= nil then
		self.activePhotographyStudioMembers[studioKey] = nil

		self:notifyPhotographyStudioActiveMembersChanged(studioUid, self.uid, false)
	end
end

function ClientPhotographyStudioComponent:reqPhotographyStudioActives(studioUid)
	if studioUid == nil or self.studioMap[studioUid] == nil then
		return
	end

	local studioKey = tostring(studioUid)

	if self.activePhotographyStudioMembers[studioKey] ~= nil then
		self.activePhotographyStudioMembers[studioKey] = nil

		self:notifyPhotographyStudioActiveMembersChanged(studioUid, nil, false)
	end

	self:serverMsg("RPC_CS_GetPhotographyStudioActives", studioUid)
end

function ClientPhotographyStudioComponent:on_profilePhotographyStudioUid_changed(oldVal, newVal)
	if self.isMainPlayer then
		pg.global.showBubbleMessageRaw(pg.getGameString("EXCHANGE_SUCCESS"))
	end

	facade:sendMsgToUI(MessageName.ON_PROFILE_PHOTOGRAPHY_STUDIO_CHANGED, newVal)
end

function ClientPhotographyStudioComponent:FriendService_onPhotoStudioInvite(uid, photographyStudioUid)
	self:upsertReceivedInvitation(uid, photographyStudioUid, false)
	self:notifyStudioInvitationsChanged()
end

function ClientPhotographyStudioComponent:FriendService_onPhotoStudioAcceptInvite(uid, photographyStudioUid)
	self:upsertSentInvitation(uid, photographyStudioUid, true)
	self:notifyStudioInvitationsChanged()
end

function ClientPhotographyStudioComponent:FriendService_onPhotoStudioRemoveInvite(invitationUid, uid, photographyStudioUid)
	self.invitations = self.invitations or {}
	self.inviteds = self.inviteds or {}

	local changed = removeInvitation(self.invitations, "InvitedUid", uid, photographyStudioUid)

	changed = removeInvitation(self.inviteds, "InvitationUid", invitationUid, photographyStudioUid) or changed

	if changed then
		self:notifyStudioInvitationsChanged()
	end
end

return ClientPhotographyStudioComponent
