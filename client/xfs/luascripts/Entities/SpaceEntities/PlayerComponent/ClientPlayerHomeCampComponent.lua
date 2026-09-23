-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerHomeCampComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCampTenantUtils = require("Common.Utils.HomeCampTenantUtils")
local CommonSwitch = require("Common.CommonSwitch")
local HomeCampData = require("Data.home_camp_data")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeCampDirectoryCaller = require("Common.Utils.HomeCampDirectoryCaller")
local ClientPlayerHomeCampComponent = class.Component("ClientPlayerHomeCampComponent")
local HOME_CAR_UPGRADE_AI_GROUP_ID = 132

function ClientPlayerHomeCampComponent:ctor()
	self.worldHomeCampInfo = {}
	self.tempWorldHomeCampInfo = {}
	self._campDispatchFinishTimer = nil
end

function ClientPlayerHomeCampComponent:init(avtDict)
	return true
end

function ClientPlayerHomeCampComponent:destroy()
	self:clearCampDispatchFinishTimer()
end

function ClientPlayerHomeCampComponent:start()
	self:queryWorldCampInfo()
	self:refreshCampDispatchFinishTimer()
end

function ClientPlayerHomeCampComponent:clearCampDispatchFinishTimer()
	if not self._campDispatchFinishTimer then
		return
	end

	self:removeTimer(self._campDispatchFinishTimer)

	self._campDispatchFinishTimer = nil
end

function ClientPlayerHomeCampComponent:getCampDispatchFinishTimestamp()
	local dispatchInfo = self.campDispatchInfo
	local finishTs = dispatchInfo and dispatchInfo.finishTs or 0

	if finishTs > 0 then
		return finishTs
	end

	return dispatchInfo and dispatchInfo.endTs or 0
end

function ClientPlayerHomeCampComponent:isCampDispatchFinished()
	local finishTs = self:getCampDispatchFinishTimestamp()

	return finishTs > 0 and finishTs <= Time.secondCache
end

function ClientPlayerHomeCampComponent:refreshCampDispatchFinishTimer()
	self:clearCampDispatchFinishTimer()

	local finishTs = self:getCampDispatchFinishTimestamp()

	if finishTs <= 0 or self:isCampDispatchFinished() then
		return
	end

	self._campDispatchFinishTimer = self:addTimer(finishTs - Time.secondCache, CallbackHandler(self, "onCampDispatchFinishTimer", finishTs))
end

function ClientPlayerHomeCampComponent:onCampDispatchFinishTimer(finishTs)
	if self:getCampDispatchFinishTimestamp() ~= finishTs then
		return
	end

	self._campDispatchFinishTimer = nil

	if not self:isCampDispatchFinished() then
		self:refreshCampDispatchFinishTimer()

		return
	end

	facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_DISPATCH_STATE_CHANGED, true)
end

function ClientPlayerHomeCampComponent:tryNotifyHomeCarUpgradeFinished()
	if not self.isInScene then
		return
	end

	local pendingLevel = self:getClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_ai_notice_level") or 0

	if pendingLevel <= 0 then
		return
	end

	local homeBasicInfo = self.homeBasicInfo

	if not homeBasicInfo or pendingLevel > homeBasicInfo.level or homeBasicInfo.upgradeEndTs > 0 then
		return
	end

	self:doEventByData({
		"startAIRemind",
		{
			HOME_CAR_UPGRADE_AI_GROUP_ID
		}
	})
	self:setClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_ai_notice_level", 0)
end

function ClientPlayerHomeCampComponent:on_campDispatchInfo_changed(ov, nv)
	self:refreshCampDispatchFinishTimer()
	facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_DISPATCH_STATE_CHANGED, self:isCampDispatchFinished())
end

function ClientPlayerHomeCampComponent:on_homeBasicInfo_upgradeEndTs_changed(ov, nv)
	local oldUpgradeEndTs = ov or 0
	local newUpgradeEndTs = nv or 0

	facade:sendMsgToUI(MessageName.HOME_CAR_UPGRADE_STATE_CHANGED)

	if oldUpgradeEndTs > 0 and newUpgradeEndTs == 0 then
		self:tryNotifyHomeCarUpgradeFinished()
	end
end

function ClientPlayerHomeCampComponent:on_homeBasicInfo_level_changed(ov, nv)
	local oldLevel = ov or 0
	local newLevel = nv or 0

	facade:sendMsgToUI(MessageName.HOME_CAR_UPGRADE_STATE_CHANGED)

	if oldLevel < newLevel then
		self:tryNotifyHomeCarUpgradeFinished()
	end
end

function ClientPlayerHomeCampComponent:on_campSpaceKeyMap_added(k, v)
	self:queryWorldCampInfo()
end

function ClientPlayerHomeCampComponent:on_campSpaceKeyMap_delete(k, v)
	self:queryWorldCampInfo()
end

function ClientPlayerHomeCampComponent:on_campSpaceKeyMap_changed(ov, nv, key)
	self:queryWorldCampInfo()
end

function ClientPlayerHomeCampComponent:on_curCampStaticId_changed(ov, nv)
	self:queryWorldCampInfo()
	facade:sendMsgToUI(MessageName.HOME_CUR_CAMP_STATIC_ID_CHANGED, ov, nv)
end

function ClientPlayerHomeCampComponent:on_statHomeCarOrnament_changed(ov, nv)
	facade:sendMsgToUI(MessageName.HOMELAND_STATHOMECAR_ORNAMENT_CHANGED)
end

function ClientPlayerHomeCampComponent:getOrnamentCarCurPlaceNum(templateId)
	return self:countOrnamentPlaceNum(self.statHomeCarOrnament, templateId)
end

function ClientPlayerHomeCampComponent:getCarGroupOrnamentCount()
	local homeCarOrnaments = self.statHomeCarOrnament

	if homeCarOrnaments[0] then
		return homeCarOrnaments[0]
	end

	local count = 0

	for homeId, num in pairs(homeCarOrnaments) do
		if homeId ~= 0 then
			count = count + num
		end
	end

	return count
end

function ClientPlayerHomeCampComponent:queryHomeBasicInfo(uid, callback)
	uid = uid or self.uid
	callback = callback or function(isUnlocked, basicInfo, homelandKey, homeCampKey)
		self.logger:debug("homeQuery isUnlocked=%s, basicInfo=%s, homelandKey=%s, homeCampKey=%s", isUnlocked, inspect(basicInfo:getRawTable()), homelandKey, homeCampKey)
	end

	self:callService("UserDataService", "getAttribute", {
		uid,
		{
			"homeBasicInfo",
			"homelandKey",
			"homeCampKey"
		}
	}, function(result, response)
		local attrMap = result.status and response.AttributesMap or {}
		local syncData = attrMap.homeBasicInfo or {}
		local syncInfo = require("CustomTypes.HomeBasicInfo")(syncData)

		callback(attrMap.homeUnlocked, syncInfo, attrMap.homelandKey, attrMap.homeCampKey)
	end, {
		callerId = uid
	})
end

function ClientPlayerHomeCampComponent:queryCampCarSyncInfo(uid, callback)
	uid = uid or self.uid
	callback = callback or function(syncInfo)
		self.logger:debug("homeQuery syncInfo=%s", inspect(syncInfo:getRawTable()))
	end

	self:callService("UserDataService", "getAttribute", {
		uid,
		{
			"campCarSyncInfo"
		}
	}, function(result, response)
		local syncData = result.status and response.AttributesMap and response.AttributesMap.campCarSyncInfo or {}
		local syncInfo = require("CustomTypes.CampCarSyncInfo")(syncData)

		callback(syncInfo)
	end, {
		callerId = uid
	})
end

function ClientPlayerHomeCampComponent:getHomeCarLevel()
	if not self.isHomeCampUnlocked then
		return 0
	end

	return self.homeBasicInfo.level
end

function ClientPlayerHomeCampComponent:getHomeCarCompLevel(compId)
	if not self.isHomeCampUnlocked then
		return 0
	end

	return self.homeBasicInfo.carCompsLevel[compId] or 0
end

function ClientPlayerHomeCampComponent:getSelfHomeCampKey()
	return self.campSpaceKeyMap[self.curCampStaticId]
end

function ClientPlayerHomeCampComponent:getCampListN(n, staticId, listType, callback)
	local localCallback = callback or function(result, response)
		if pg.logDebug() then
			self.logger:debug("homeCamp getCampListN, result=%s, response=%s", inspect(result), inspect(response))
		end

		if result.status and response.res and response.resCnt > 0 then
			local spaceKey2LineInfo = response.res
		end
	end

	HomeCampDirectoryCaller.call(self, "CMD_GetRecommendCampLines", {
		self.uid,
		self.serverId,
		staticId,
		n,
		listType
	}, localCallback, {
		hint = self.id,
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:getCampListByIds(spaceKeys, callback)
	local localCallback = callback or function(result, response)
		if pg.logDebug() then
			self.logger:debug("homeCamp getCampListByIds, result=%s, response=%s", inspect(result), inspect(response))
		end

		if result.status and response.res and response.resCnt > 0 then
			local spaceKey2LineInfo = response.res
		end
	end

	HomeCampDirectoryCaller.call(self, "CMD_GetLinesBySpaceKeys", {
		self.uid,
		self.serverId,
		spaceKeys
	}, localCallback, {
		hint = self.id,
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:getAllCampListN(n, listType, callback)
	local localCallback = callback or function(result, response)
		if pg.logDebug() then
			self.logger:debug("homeCamp getAllCampListN, result=%s, response=%s", inspect(result), inspect(response))
		end

		if result.status and response.res and response.resCnt > 0 then
			local spaceKey2LineInfo = response.res
		end
	end

	HomeCampDirectoryCaller.call(self, "CMD_QueryCampLines", {
		self.uid,
		self.serverId,
		0,
		0,
		n,
		listType
	}, localCallback, {
		hint = self.id,
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:findCampByCode(displayCode, callback)
	if not displayCode then
		return
	end

	local localCallback = callback or function(result, response)
		if pg.logDebug() then
			self.logger:debug("homeCamp findCampByCode, result=%s, response=%s", inspect(result), inspect(response))
		end

		if result.status and response.summary then
			local spaceKey2LineInfo = response.res
		end
	end

	HomeCampDirectoryCaller.call(self, "CMD_FindCampByCode", {
		self.uid,
		self.serverId,
		displayCode
	}, localCallback, {
		hint = self.id,
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:queryFriendCampInfo(uids, callback)
	local attributesList = {
		"playerName",
		"uid",
		"homeCampKey",
		"homeUnlocked",
		"homeBasicInfo"
	}

	self:callService("UserDataService", "batchGetAttribute", {
		uids,
		attributesList
	}, CallbackHandler(self, "queryFriendCampInfoCallback", callback), {
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:queryFriendCampInfoCallback(callback, result, resp)
	local playerList = {}
	local spaceKeys = {}

	if result.status then
		for _, item in ipairs(resp.Results) do
			local attributeInfo = item.AttributesMap

			if attributeInfo.homeCampKey then
				playerList[item.Uid] = attributeInfo

				table.insert(spaceKeys, attributeInfo.homeCampKey)
			end
		end
	end

	self.campFriendInfo = playerList
	self.friendCampInfo = {}

	if #spaceKeys <= 0 then
		callback(self.campFriendInfo, self.friendCampInfo)

		return
	end

	self:getCampListByIds(spaceKeys, function(result2, response)
		if pg.logDebug() then
			self.logger:debug("homeCamp getCampListByIds, result=%s, response=%s", inspect(result2), inspect(response))
		end

		if result2.status and response.res and response.resCnt > 0 then
			local spaceKey2LineInfo = response.res

			for spaceKey, lineInfo in pairs(spaceKey2LineInfo) do
				self.friendCampInfo[spaceKey] = lineInfo
			end

			callback(self.campFriendInfo, self.friendCampInfo)
		else
			callback(self.campFriendInfo, self.friendCampInfo)
		end
	end)
end

function ClientPlayerHomeCampComponent:querySinglePlayerCampInfo(uid, callback)
	local attributesList = {
		"playerName",
		"uid",
		"homeCampKey",
		"homeUnlocked",
		"homeBasicInfo",
		"platform",
		"platformUserId",
		"platformFamily",
		"platformDisplayName"
	}

	self:callService("UserDataService", "getAttribute", {
		uid,
		attributesList
	}, CallbackHandler(self, "querySinglePlayerCampInfoCallback", callback), {
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:querySinglePlayerCampInfoCallback(callback, result, resp)
	if not callback then
		return
	end

	if result.status then
		callback(resp.AttributesMap)
	else
		callback(nil)
	end
end

function ClientPlayerHomeCampComponent:queryWorldCampInfo()
	local curStaticId = self.curCampStaticId
	local curSpaceKey = curStaticId and self.campSpaceKeyMap[curStaticId] or nil
	local useRealtimeForCurCamp = CommonSwitch.UseNewHomeCampArch and curSpaceKey ~= nil and self.curCampLineUid and self.curCampLineUid > 0 and self.curCampTenantKey and self.curCampTenantKey ~= "" and self.curCampAreaId and self.curCampAreaId > 0 and self.curCampBucketId and self.curCampBucketId >= 0

	if not useRealtimeForCurCamp then
		local spaceKeys = {}

		for _, spaceKey in pairs(self.campSpaceKeyMap) do
			table.insert(spaceKeys, spaceKey)
		end

		self:getCampListByIds(spaceKeys, function(result, response)
			if result.status and response.res then
				self:onQueryWorldCampLineInfo(response.res)
			end
		end)

		return
	end

	local cachedSpaceKeys = {}

	for _, spaceKey in pairs(self.campSpaceKeyMap) do
		if spaceKey ~= curSpaceKey then
			table.insert(cachedSpaceKeys, spaceKey)
		end
	end

	local merged = {}
	local pending = #cachedSpaceKeys > 0 and 2 or 1

	local function tryFinish()
		pending = pending - 1

		if pending <= 0 then
			self:onQueryWorldCampLineInfo(merged)
		end
	end

	if #cachedSpaceKeys > 0 then
		self:getCampListByIds(cachedSpaceKeys, function(result, response)
			if result.status and response.res then
				for spaceKey, lineInfo in pairs(response.res) do
					merged[spaceKey] = lineInfo
				end
			end

			tryFinish()
		end)
	end

	local hint = HomeCampTenantUtils.getBucketKey(self.curCampTenantKey, self.curCampAreaId, self.curCampBucketId)

	self:callService("HomeCampLineService", "CMD_GetOwnLoginLineInfo", {
		self.uid,
		self.curCampTenantKey,
		self.curCampAreaId,
		self.curCampBucketId,
		self.curCampLineUid
	}, function(result, response)
		if result.status and response.flag and response.lineInfo then
			merged[curSpaceKey] = response.lineInfo
		end

		tryFinish()
	end, {
		hint = hint
	})
end

function ClientPlayerHomeCampComponent:onQueryWorldCampLineInfo(spaceKey2LineInfo)
	self.worldHomeCampData = spaceKey2LineInfo

	local pending = {
		playerUidToStaticId = {}
	}

	self.tempWorldHomeCampInfo = {}
	pending.tempWorldHomeCampInfo = self.tempWorldHomeCampInfo

	local playerUidToStaticId = pending.playerUidToStaticId
	local loginUids = {}

	for spaceKey, lineInfo in pairs(spaceKey2LineInfo) do
		local serverId, uid, sceneId, lineId = Utils.parseSpaceInstanceServiceKey(spaceKey)
		local staticId = HomeLandUtils.getHomeCampStaticId(sceneId)

		if EnableBotTest and staticId == nil then
			return
		end

		local uidToCarId = {}

		for carIndex, loginUid in pairs(lineInfo.loginUids) do
			uidToCarId[loginUid] = HomeLandUtils.getCampCarTmplId(staticId, carIndex)

			table.insert(loginUids, loginUid)

			playerUidToStaticId[loginUid] = staticId
		end

		self.tempWorldHomeCampInfo[staticId] = {
			lineInfo = lineInfo,
			carList = {},
			uidToCarId = uidToCarId
		}
	end

	local attributesList = {
		"uid",
		"homeCampKey",
		"homeBasicInfo"
	}

	self:callService("UserDataService", "batchGetAttribute", {
		loginUids,
		attributesList
	}, CallbackHandler(self, "queryWorldCampInfoCallback", pending), {
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:queryWorldCampInfoCallback(pending, result, resp)
	self.queryWorldCampInfoCallbackInfo = resp

	if not result.status then
		return
	end

	if pending.tempWorldHomeCampInfo ~= self.tempWorldHomeCampInfo then
		return
	end

	self.selfHomeCampCarId = nil

	local playerUidToStaticId = pending.playerUidToStaticId

	for _, item in ipairs(resp.Results) do
		local itemInfo = item.AttributesMap
		local playerUid = item.Uid
		local staticId = playerUidToStaticId[playerUid]

		if staticId then
			local carList = self.tempWorldHomeCampInfo[staticId].carList
			local carId = self.tempWorldHomeCampInfo[staticId].uidToCarId[playerUid]

			itemInfo.playerUid = playerUid

			if carId then
				if playerUid == self.uid then
					self.selfHomeCampCarId = carId
				end

				carList[carId] = itemInfo
			end
		end
	end

	self.worldHomeCampInfo = self.tempWorldHomeCampInfo
	self.worldCampDataReady = true

	pg.game.homeCar:setWorldCampInfo(self.worldHomeCampInfo)
	facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_INFO_REFRESHED)
end

function ClientPlayerHomeCampComponent:getSelfHomeCampPlaceId()
	return self.curCampCarTmplId
end

function ClientPlayerHomeCampComponent:unlockHomeCamp(staticId, name, shapeInfo)
	self:requestHomeCampOp(OpDef.OP.CS_HC_UnlockCamp, {
		staticId = staticId,
		name = name,
		shapeInfo = shapeInfo
	})
end

function ClientPlayerHomeCampComponent:enterSelfHomeCamp()
	self:serverMsg("RPC_CS_ReqEnterSelfHomeCamp")
end

function ClientPlayerHomeCampComponent:enterHomeCamp(homeCampKey, uid)
	local hook = ClientPlayerHomeCampComponent._platformHooks and ClientPlayerHomeCampComponent._platformHooks.canEnterHomeCamp

	if hook and hook(self, uid, {
		action = "home_camp_enter",
		homeCampKey = homeCampKey
	}) == false then
		return false
	end

	self:serverMsg("RPC_CS_ReqEnterHomeCamp", homeCampKey, uid or "")

	return true
end

function ClientPlayerHomeCampComponent:enterHomeCampByUid(uid)
	if not uid then
		return
	end

	local attributesList = {
		"uid",
		"homeCampKey"
	}

	self:callService("UserDataService", "getAttribute", {
		uid,
		attributesList
	}, CallbackHandler(self, "_enterHomeCampByUidQueryCallback", uid), {
		callerId = uid
	})
end

function ClientPlayerHomeCampComponent:_enterHomeCampByUidQueryCallback(uid, result, resp)
	if result.status then
		local respMap = resp.AttributesMap

		if respMap and respMap.homeCampKey then
			self:enterHomeCamp(respMap.homeCampKey, uid)

			return
		end
	end
end

function ClientPlayerHomeCampComponent:requestHomeCampOp(op, params, callback)
	local localCallback = callback or function(noticeId, noticeArgs)
		if pg.logDebug() then
			self.logger:debug("homeCamp op=%s, res=%s", OpDef.repr(op, params), NoticeDef.getRepr(noticeId, noticeArgs), self:repr())
		end
	end

	self:serverMsg("RPC_CS_HomeCampOp", op, params, localCallback)
end

function ClientPlayerHomeCampComponent:setHomeCarShape(shapeInfo, callback)
	self:requestHomeCampOp(OpDef.OP.CS_HC_ChangeShape, {
		shapeInfo = shapeInfo
	}, callback)
end

function ClientPlayerHomeCampComponent:likeHomeCar(playerUid, callback)
	self:requestHomeCampOp(OpDef.OP.CS_HC_Like, {
		carId = playerUid
	}, callback)
end

function ClientPlayerHomeCampComponent:changeCamp(campId, lineId, callback)
	local function opCallback(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			callback()
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
		end
	end

	lineId = lineId or 0
	self.changeCampMark = true

	self:requestHomeCampOp(OpDef.OP.CS_HC_ChangeCamp, {
		carId = pg.me.uid,
		staticId = campId,
		lineId = lineId
	}, opCallback)
end

function ClientPlayerHomeCampComponent:sendDissolvePrivateMessage(callback)
	local function opCallback(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			callback()
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
		end
	end

	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_DissolvePrivateLine, {}, opCallback)
end

function ClientPlayerHomeCampComponent:sendSetLinePermissionMessage(permissions, callback)
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_SetLinePermission, {
		permissions = permissions
	}, callback)
end

function ClientPlayerHomeCampComponent:changeCarIndexMessage(targetCarIndex, callback)
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_ChangeCarIndex, {
		targetCarIndex = targetCarIndex
	}, callback)
end

function ClientPlayerHomeCampComponent:kickLineMemberMessage(targetUid, callback)
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_KickLineMember, {
		targetUid = targetUid
	}, callback)
end

function ClientPlayerHomeCampComponent:RPC_SC_HomeCampOp(op, params)
	if pg.logDebug() then
		self.logger:debug("homeCamp op=%s", OpDef.repr(op, params), self:repr())
	end

	if op == OpDef.OP.SC_HC_UnlockCampSuccess then
		pg.global.ui.homeCarName:onUnlockSucc()
	elseif op == OpDef.OP.SC_HC_ChangeCampSuccess then
		pg.global.ui.homeCampVisit:close()
		pg.global.ui.homeCarCampSwitch:close()

		if self.changeCampMark then
			self.changeCampMark = false

			pg.global.ui.homeCampMoveLoading:open()
		end
	elseif op == OpDef.OP.SC_HC_LoginCampSuccess then
		local lastLineId = params.lastLineId
		local lastStaticId = params.lastStaticId
		local curSceneStaticId = HomeLandUtils.getHomeCampStaticId(pg.space.sceneId)
		local force = params.transferReason == "change_camp" or params.transferReason == "private_line_create"

		if force or curSceneStaticId and curSceneStaticId == lastStaticId and pg.space.lineId == lastLineId then
			pg.global.ui.homeCampMoveLoading:onChangeCampSuccess()
		end
	elseif op == OpDef.OP.SC_HC_Notice then
		local noticeId, noticeArgs = params.noticeId, params.noticeArgs

		if pg.global.ui.homeCarName.view then
			pg.global.ui.homeCarName:onNameResult(noticeId)
		end

		if noticeId == NoticeDef.FAIL then
			local reason = noticeArgs[1]

			if reason and not self:showHomeCampNoticeByReason(reason) then
				ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
			end
		elseif noticeId == NoticeDef.SUCCESS then
			local reason = noticeArgs[1]

			if reason then
				self:showHomeCampNoticeByReason(reason)
			end
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
		end
	elseif op == OpDef.OP.SC_HC_InviteReceived then
		self:onCreateInviteSucc(params)
	elseif op == OpDef.OP.SC_HC_PrivateLineDissolved then
		pg.global.ui.tips:showTextTip(pg.getGameString("HOMECAR_TIPS_STATION_DISBANDED"))
	elseif op == OpDef.OP.SC_HC_PrivateLineKicked then
		pg.global.ui.tips:showTextTip(pg.getGameString("HOMECAR_TIPS_STATION_REMOVE"))
	elseif op == OpDef.OP.SC_HC_PrivateLineMigrated then
		pg.global.ui.tips:showTextTip(pg.getGameString("HOMECAR_TIPS_STATION_CHANGE"))
	elseif op == OpDef.OP.SC_HC_LineInfoChanged then
		local lineInfo = params.lineInfo

		self:refreshCampLinInfo(lineInfo)
	elseif op == OpDef.OP.SC_HC_MembersNotUnlocked then
		local staticId = params.staticId
		local blockedUids = params.blockedUids or {}

		self:showMemberNotUnlockCampInfo(staticId, blockedUids)
	end
end

function ClientPlayerHomeCampComponent:getCampAddOnOwnerDisplayName(ownerUid, ownerName)
	if not string.isNilOrEmpty(ownerName) then
		return ownerName
	end

	ownerName = HomeLandUtils.getCampAddOnOwnerNameFromCreatedMap(pg.space, ownerUid)

	if not string.isNilOrEmpty(ownerName) then
		return ownerName
	end

	ownerName = LuaUIUtils.getPlayerDisplayName(tostring(ownerUid), nil, true)

	if not string.isNilOrEmpty(ownerName) then
		return ownerName
	end

	return tostring(ownerUid or "")
end

function ClientPlayerHomeCampComponent:onCampBuffGained(params)
	local ownerUid = params and params.ownerUid or self.campAddOnOwnerUid or self.uid
	local ownerName = self:getCampAddOnOwnerDisplayName(ownerUid, params and params.ownerName)

	self.campAddOnOwnerUid = ownerUid
	self.campAddOnOwnerName = ownerName

	if tostring(ownerUid) == tostring(self.uid) then
		pg.global.showBubbleMessageById(NoticeDef.HOMECAMP_BUFF_GAINED_SELF)
	else
		pg.global.showBubbleMessageById(NoticeDef.HOMECAMP_BUFF_GAINED_OTHER, ownerName)
	end

	local panel = pg.global.ui.homeCarBuffPanel

	if panel and panel.view and panel.onBuffGained then
		panel:onBuffGained(params)
	end
end

function ClientPlayerHomeCampComponent:refreshCampLinInfo(lineInfo)
	if not lineInfo then
		return
	end

	local staticId = lineInfo.staticId
	local uidToCarId = {}
	local loginUids = {}

	for carIndex, loginUid in pairs(lineInfo.loginUids or EMPTY_TABLE) do
		uidToCarId[loginUid] = HomeLandUtils.getCampCarTmplId(staticId, carIndex)

		table.insert(loginUids, loginUid)
	end

	local pending = {
		lineInfo = lineInfo,
		carList = {},
		uidToCarId = uidToCarId,
		staticId = staticId
	}

	self.tempPlayerHomeCampInfo = pending

	if #loginUids <= 0 then
		self.playerHomeCampInfo = pending

		facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_INFO_REFRESHED)

		return
	end

	local attributesList = {
		"uid",
		"homeCampKey",
		"homeBasicInfo"
	}

	self:callService("UserDataService", "batchGetAttribute", {
		loginUids,
		attributesList
	}, CallbackHandler(self, "refreshCampLinInfoCallback", pending), {
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:refreshCampLinInfoCallback(pending, result, resp)
	if not result.status then
		return
	end

	if pending ~= self.tempPlayerHomeCampInfo then
		return
	end

	for _, item in ipairs(resp.Results) do
		local itemInfo = item.AttributesMap
		local playerUid = item.Uid
		local carId = pending.uidToCarId[playerUid]

		if carId then
			itemInfo.playerUid = playerUid
			pending.carList[carId] = itemInfo
		end
	end

	self.playerHomeCampInfo = pending

	facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_INFO_REFRESHED)
end

function ClientPlayerHomeCampComponent:getPlayerHomeCampInfo()
	if self.playerHomeCampInfo then
		return self.playerHomeCampInfo
	else
		local campInfo = self.worldHomeCampInfo and self.worldHomeCampInfo[self.curCampStaticId] or {}

		return campInfo
	end
end

function ClientPlayerHomeCampComponent:requirePlayerLineInfo()
	self:callService("HomeCampLineService", "CMD_GetOwnLoginLineInfo", {
		pg.me.uid,
		pg.me.curCampTenantKey,
		pg.me.curCampAreaId,
		pg.me.curCampBucketId,
		pg.me.curCampLineUid
	}, CallbackHandler(self, "getOwnLoginLineInfoCallback"), {
		callerId = self.uid
	})
end

function ClientPlayerHomeCampComponent:getOwnLoginLineInfoCallback(result, resp)
	if not result.status then
		return
	end

	local lineInfo = resp.lineInfo

	self:refreshCampLinInfo(lineInfo)
end

function ClientPlayerHomeCampComponent:requireCreatePrivateHomeCamp(campStaticId, callback)
	local function opCallback(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			if callback then
				callback()
			end
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
		end
	end

	self:requestHomeCampOp(OpDef.OP.CS_HC_CreatePrivateLine, {
		staticId = campStaticId
	}, opCallback)
end

function ClientPlayerHomeCampComponent:checkIsPrivateCampOwner()
	local campInfo = self:getPlayerHomeCampInfo()

	if not campInfo then
		return false
	end

	local lineInfo = campInfo.lineInfo

	if not lineInfo then
		return false
	end

	return lineInfo.isPrivate and lineInfo.ownerUid == pg.me.uid
end

function ClientPlayerHomeCampComponent:teleportToCreatePrivateCampPosition(callback)
	pg.global.showConfirmMsgRaw(pg.getGameString("NET_RECONNECT_TITLE"), pg.getGameString("PRIVATE_HOME_CAMP_GO_CREATE_TELEPORT_DESC"), function()
		if callback then
			callback()
		end

		self:confirmTeleportToCreatePrivateCampPosition()
	end)
end

function ClientPlayerHomeCampComponent:confirmTeleportToCreatePrivateCampPosition()
	local campStaticId = self.curCampStaticId
	local staticId = HomeLandUtils.getHomeCampStaticId(pg.space.sceneId)

	if staticId then
		campStaticId = staticId
	end

	local campInfo = HomeCampData[campStaticId] or {}

	if not campInfo then
		return
	end

	local sceneId = HomeLandUtils.getHomeCampSceneId(campStaticId)
	local teleportId = campInfo.createPrivateCampTeleportPos or campStaticId

	pg.me:tryTeleportToScene(pg.game.map:convertSceneId(sceneId), teleportId)
end

function ClientPlayerHomeCampComponent:checkFriendInSelfCamp(friendPlayerUID)
	local campInfo = pg.me:getPlayerHomeCampInfo()

	if campInfo then
		local lineInfo = campInfo.lineInfo or {}

		for _, uid in pairs(lineInfo.loginUids or EMPTY_TABLE) do
			if uid == friendPlayerUID then
				return true
			end
		end
	end

	return false
end

function ClientPlayerHomeCampComponent:showHomeCampNoticeByReason(reason)
	if reason == "invite_not_found" then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_OUTTIME)

		return true
	elseif reason == "invite_already_used" then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_ACCEPTED)

		return true
	elseif reason == "invite_not_for_you" then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_OUTTIME)

		return true
	elseif reason == "invite_expired" then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_OUTTIME)

		return true
	elseif reason == "inviter_not_in_line" then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_PLAYER_LEAVE)

		return true
	elseif reason == "change camp failed" then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_ALREADY_IN_CAMP)

		return true
	elseif reason == "accept_invite_success" then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_ACCEPT_SUCCESS)

		return true
	end
end

function ClientPlayerHomeCampComponent:sendInviteFriendMessage(friendPlayerUID, isOwner)
	if not friendPlayerUID then
		return
	end

	if self:checkFriendInSelfCamp(friendPlayerUID) then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_IN_THIS_CAMP)

		return
	end

	self:querySinglePlayerCampInfo(friendPlayerUID, function(attributeInfo)
		if not attributeInfo or not attributeInfo.homeUnlocked then
			pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_NOT_UNLOCK_CAMP)

			return
		end

		if attributeInfo then
			if pg.game.chat and pg.game.chat.setPlayerData then
				pg.game.chat:setPlayerData(tostring(friendPlayerUID), attributeInfo)
			end

			pg.me:requestHomeCampOp(OpDef.OP.CS_HC_InviteFriend, {
				targetUid = friendPlayerUID
			})
		end
	end)
end

function ClientPlayerHomeCampComponent:onCreateInviteSucc(param)
	local targetUid = param.targetUid
	local targetPlayerInfo = pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(targetUid) or nil

	self:realSendInviteFriendMessage(targetUid, param, targetPlayerInfo)
end

function ClientPlayerHomeCampComponent:realSendInviteFriendMessage(friendPlayerUID, inviteInfo, targetPlayerInfo)
	if not friendPlayerUID then
		return
	end

	local resolvedPlayerInfo = targetPlayerInfo or pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(friendPlayerUID) or nil
	local PlatformShellInviteService = require("SDK.Platform.PlatformShellInviteService")

	if PlatformShellInviteService:sendHomeCampInvite(resolvedPlayerInfo, inviteInfo and inviteInfo.inviteId) then
		return
	end

	local selfCampKey = pg.me:getSelfHomeCampKey()
	local selfCampStaticId = pg.me.curCampStaticId
	local campInfo = self:getPlayerHomeCampInfo()

	if not campInfo then
		return
	end

	local lineInfo = campInfo.lineInfo

	if not lineInfo then
		return
	end

	local playerCount = lineInfo.loginUids and #lineInfo.loginUids or 0
	local extraInfo = {
		[Const.CHAT_EXTRA_TYPE.HomeCampInvite] = {
			campKey = selfCampKey,
			inviteTime = Time.secondCache,
			inviteId = inviteInfo.inviteId,
			playerId = pg.me.uid,
			isOwner = lineInfo.ownerUid == pg.me.uid,
			isPrivate = lineInfo.isPrivate or false,
			campUid = inviteInfo.displayCode,
			maxCount = HomeLandUtils.getHomeCampMaxLoginCount(selfCampStaticId),
			curCount = playerCount
		}
	}

	pg.game.chat:sendMessage(pg.getGameString("HOME_CAMP_INVITE"), pg.game.chat.subMessageType.HomeCampInvite, pg.game.chat.channelType.Player, friendPlayerUID, extraInfo)
	pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_SUCC)
end

function ClientPlayerHomeCampComponent:acceptCampInvite(inviteId, ownerUid)
	local hook = ClientPlayerHomeCampComponent._platformHooks and ClientPlayerHomeCampComponent._platformHooks.canEnterHomeCamp

	if hook and hook(self, ownerUid, {
		action = "home_camp_invite_accept",
		inviteId = inviteId
	}) == false then
		return false
	end

	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_AcceptInvite, {
		inviteId = inviteId
	})

	return true
end

function ClientPlayerHomeCampComponent:showMemberNotUnlockCampInfo(campStaticId, blockedUids)
	local uids = {}

	for _, blockUid in pairs(blockedUids) do
		table.insert(uids, tostring(blockUid))
	end

	pg.me:queryPlayerInfoList(uids, pg.game.chat.queryPlayerInfoType.ShowPlayerInfo, true, nil, function()
		local playerNames = ""
		local campInfo = HomeCampData[campStaticId] or {}
		local campName = pg.getLocalizationText(campInfo.name)

		for _, blockUid in pairs(blockedUids) do
			local playerInfo = pg.game.chat:getPlayerInfo(blockUid)
			local playerName = LuaUIUtils.getPlayerDisplayName(tostring(blockUid), playerInfo.playerName, true)

			playerNames = playerNames .. "  " .. pg.getFormatText("<style=Hint_BgL>{0}</style>", playerName)
		end

		local desc = pg.getFormatText(pg.getGameString("HOME_PRIVATE_CAMP_SWITCH_NOT_UNLCOK_DESC"), playerNames, campName)

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), desc, nil, nil)
	end)
end

return ClientPlayerHomeCampComponent
