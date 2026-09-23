-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\MarkShare\\MarkShareSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local AddressDataConst = require("Const.AddressDataConst")
local MarkShareSystemAvatarHelper = require("GameApp.MarkShare.Helper.MarkShareSystemAvatarHelper")
local MarkShareSystemBubbleHelper = require("GameApp.MarkShare.Helper.MarkShareSystemBubbleHelper")
local json = require("json")
local MessageName = require("Const.MessageName")
local SceneUtils = require("Common.Utils.SceneUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local Utils = require("Common.Utils.Utils")
local InfoStampPresetContentData = require("Data.info_stamp_preset_content_data")
local InfoStampConcatContentData = require("Data.info_stamp_concat_content_data")
local InfoStampCustomBubbleConfigData = require("Data.info_stamp_custom_bubble_config_data")
local SysConfigData = require("Data.sys_config_data")
local PuppetName = require("Data.puppet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetData = require("Data.pet_data")
local ItemData = require("Data.item_data")
local AbilityParamData = require("Data.ability_param_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SceneData = require("Data.scene_data")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local Time = require("Core.Common.Time")
local MarkShareSystem = Class.LightClass("MarkShareSystem", SystemBase)
local GameObject = CS.UnityEngine.GameObject
local Object = CS.UnityEngine.Object

MarkShareSystem.AVATAR_TYPE = {
	Self = 2,
	OtherPlayer = 1,
	Preset = 3
}
MarkShareSystem.CLUE_WEIGHT = {
	4,
	5,
	6,
	7,
	8,
	2,
	1,
	3
}
MarkShareSystem.SYS_PRESET_MARK_NEAR_DIS = 100
MarkShareSystem.EXPIRE_STATE = {
	Expired = 2,
	Active = 1,
	Permanent = 0
}
MarkShareSystem.FORCE_HIDE_SCOPE = {
	All = 2,
	PlayerMarkers = 1,
	None = 0
}
MarkShareSystem.FORCE_HIDE_SOURCE = {
	Dialogue = "Dialogue",
	Photo = "Photo",
	Area = "Area"
}

function MarkShareSystem:onCtor()
	SystemBase.onCtor(self)

	if not self.aroundMarkInfoStampGroup then
		self.aroundMarkInfoStampGroup = {}
	end

	self.avatarReplicationGroup = GameObject("AvatarReplicationGroup")

	Object.DontDestroyOnLoad(self.avatarReplicationGroup)

	self.poolParent = GameObject("InfoStampGroup")

	Object.DontDestroyOnLoad(self.poolParent)

	self.poolHelper = {}
	self.avatarHelper = MarkShareSystemAvatarHelper.new()
	self.bubbleHelper = MarkShareSystemBubbleHelper.new()
	self.sceneMarkDataGroup = {}
	self.colorTemp = self:tableToColor(SysConfigData.imgLineColor)
	self.colorTemp1 = self:tableToColor(SysConfigData.imgLineGlowColor)
	self.colorTemp2 = self:tableToColor(SysConfigData.imgBgImageColor)
	self.colorTemp3 = self:tableToColor(SysConfigData.whiteImgBgImageColor)
	self.colorTemp4 = self:tableToColor(SysConfigData.whiteImgLineColor)
	self.likeWhite = self:tableToColor(SysConfigData.whiteLikeColor)
	self.likeGold = self:tableToColor(SysConfigData.likeColor)
	self.focusWhite = self:tableToColor(SysConfigData.focusWhiteColor)
	self.focusGold = self:tableToColor(SysConfigData.focusGoldColor)
	self.mute = false
	self.settingDirty = false
	self.mediaMarkerViewSettingDirty = false
	self.pendingMediaMarkerViewSetting = nil
	self.infoStampRandomValues = {}
	self.infoStampCandidateCache = {
		systemMarkers = {},
		selfMarkers = {},
		friendMarkers = {},
		strangerMarkers = {}
	}
	self.infoStampCandidateCacheReady = false
	self.infoStampCandidateCacheSceneId = nil
	self.forceHideScopes = {}

	local _h = MarkShareSystem._platformHooks

	if _h and _h.onCtor then
		_h.onCtor(self)
	end
end

function MarkShareSystem:tableToColor(t)
	return Color(t[1], t[2], t[3], t[4])
end

function MarkShareSystem:onDestroy()
	self.aroundMarkInfoStampGroup = nil
	self.infoStampInfoTrans = nil
	self.infoStampInfoKeys = nil
	self.infoStampRandomValues = nil
	self.infoStampCandidateCache = nil
	self.infoStampCandidateCacheReady = false
	self.infoStampCandidateCacheSceneId = nil
	self.forceHideScopes = nil

	if self.poolHelper then
		for _, v in pairs(self.poolHelper) do
			v.loader:destroy()
		end
	end

	self.poolHelper = nil

	self:destroyAvatar()
	self.bubbleHelper:destroyBubble()

	self.bubbleHelper = nil
	self.sceneMarkDataGroup = nil

	local _h = MarkShareSystem._platformHooks

	if _h and _h.onDestroy then
		_h.onDestroy(self)
	end
end

function MarkShareSystem:getMessageBindMap()
	return {
		[MessageName.UPDATE_INTERACT_VIEW] = "onInteractionChanged",
		[MessageName.ON_PLAYER_ENTER_SCENE] = "onPlayerEnterScene",
		[MessageName.ON_PLAYER_LEAVE_SCENE] = "onPlayerLeaveScene",
		[MessageName.PLAYER_LEVEL_CHANGE] = "onPlayerLevelChanged",
		[MessageName.UI_ON_CLOSE] = "onUIClose"
	}
end

function MarkShareSystem:markSettingDirty()
	self.settingDirty = true
end

function MarkShareSystem:markMediaMarkerViewSettingDirty(setting)
	self.pendingMediaMarkerViewSetting = setting
	self.mediaMarkerViewSettingDirty = true
	self.settingDirty = true
end

function MarkShareSystem:getMediaMarkerViewSetting()
	if self.pendingMediaMarkerViewSetting ~= nil then
		return self.pendingMediaMarkerViewSetting
	end

	if pg.me and pg.me.mediaMarkerViewSetting ~= nil then
		return pg.me.mediaMarkerViewSetting
	end

	return Const.MARKER_SETTINGS.DEFAULT
end

function MarkShareSystem:shouldShowOwnMediaMarker()
	return self:getForceHideScope() == MarkShareSystem.FORCE_HIDE_SCOPE.None and self:getMediaMarkerViewSetting() ~= Const.MARKER_SETTINGS.SELF_HIDE
end

function MarkShareSystem:getForceHideScope()
	local scope = MarkShareSystem.FORCE_HIDE_SCOPE.None

	for _, value in pairs(self.forceHideScopes or EMPTY_TABLE) do
		scope = math.max(scope, value)
	end

	return scope
end

function MarkShareSystem:setForceHide(source, scope)
	if source == nil or not self.forceHideScopes then
		return
	end

	scope = scope or MarkShareSystem.FORCE_HIDE_SCOPE.None

	if scope ~= MarkShareSystem.FORCE_HIDE_SCOPE.None and scope ~= MarkShareSystem.FORCE_HIDE_SCOPE.PlayerMarkers and scope ~= MarkShareSystem.FORCE_HIDE_SCOPE.All then
		return
	end

	local oldScope = self:getForceHideScope()

	if scope == MarkShareSystem.FORCE_HIDE_SCOPE.None then
		self.forceHideScopes[source] = nil
	else
		self.forceHideScopes[source] = scope
	end

	if oldScope == self:getForceHideScope() then
		return
	end

	self:refreshInfoStampVisibility()
	self:refreshOwnMediaMarkerMapVisibility()
end

function MarkShareSystem:shouldShowSystemMediaMarker()
	return self:getForceHideScope() ~= MarkShareSystem.FORCE_HIDE_SCOPE.All
end

function MarkShareSystem:shouldShowPlayerMediaMarker()
	return self:getForceHideScope() == MarkShareSystem.FORCE_HIDE_SCOPE.None
end

function MarkShareSystem:shouldShowOtherPlayerMediaMarker()
	local minLevel = SysConfigData.INFO_STAMP_PLAYER_LEVEL or 0

	return self:shouldShowPlayerMediaMarker() and pg.me and minLevel <= (pg.me.level or 0)
end

function MarkShareSystem:isInfoStampDisabledArea()
	if not pg.me then
		return false
	end

	local customCheckStates = pg.me.customCheckStates

	return pg.me.specialStateBanOperate == "INFO_DISABLE_ST" or customCheckStates and (customCheckStates.INFO_DISABLE_1_ST or customCheckStates.INFO_DISABLE_2_ST) or false
end

function MarkShareSystem:refreshInfoStampAreaForceHide()
	local scope = self:isInfoStampDisabledArea() and MarkShareSystem.FORCE_HIDE_SCOPE.PlayerMarkers or MarkShareSystem.FORCE_HIDE_SCOPE.None

	self:setForceHide(MarkShareSystem.FORCE_HIDE_SOURCE.Area, scope)
end

function MarkShareSystem:refreshOwnMediaMarkerMapVisibility()
	if not pg.me or not pg.me.mediaMarker or not pg.game or not pg.game.map then
		return
	end

	local visible = self:shouldShowOwnMediaMarker()
	local currentSceneId = pg.space and pg.game.map:convertSceneId(pg.space.sceneId)

	for mediaMarkerId, mediaMarker in pairs(pg.me.mediaMarker) do
		local sceneId = pg.game.map:convertSceneId(mediaMarker.sceneId)

		if not visible then
			pg.game.map:removeTempMark(sceneId, mediaMarkerId)
		elseif sceneId == currentSceneId and mediaMarker.pos then
			pg.game.map:addOrUpdateTempMark(sceneId, mediaMarker.pos[1], mediaMarker.pos[2], mediaMarker.pos[3], mediaMarkerId, Const.MAP_MARK_SHARE)
		end
	end
end

function MarkShareSystem:onUIClose(uid)
	if uid ~= UIConst.UI_ID_SETTING or not self.settingDirty then
		return
	end

	self.settingDirty = false

	if self.mediaMarkerViewSettingDirty then
		self.mediaMarkerViewSettingDirty = false

		if self.pendingMediaMarkerViewSetting ~= nil and pg.me then
			if self.pendingMediaMarkerViewSetting ~= pg.me.mediaMarkerViewSetting then
				pg.me:setMediaMarkerView(self.pendingMediaMarkerViewSetting)
			end

			self:refreshOwnMediaMarkerMapVisibility()
		end
	end

	self:refreshInfoStampSettingValues()
	self:refreshInfoStampVisibility()
end

function MarkShareSystem:refreshInfoStampSettingValues()
	self.infoStampSystemVisible = ClientSettingUtils.getInfoStampSystemVisibleValue() == 0
	self.infoStampFriendCount = ClientSettingUtils.get_infoStampFriendCount()
	self.infoStampStrangerCount = ClientSettingUtils.get_infoStampStrangerCount()
end

function MarkShareSystem:getInfoStampRandomPriority(infoStampId, infoStampValue)
	local randomValue = self.infoStampRandomValues[infoStampId]

	if not randomValue then
		randomValue = math.random()
		self.infoStampRandomValues[infoStampId] = randomValue
	end

	local weight = 1

	if (infoStampValue.encourageDays or 0) > 0 then
		local encourageWeightIncrease = SysConfigData.MARK_SHARE_ENCOURAGE_WEIGHT_INCREASE or 1

		weight = math.max(1 + encourageWeightIncrease, 0.01)
	end

	return randomValue^(1 / weight)
end

function MarkShareSystem.compareInfoStampCandidatePriority(left, right)
	return left.priority > right.priority
end

function MarkShareSystem:checkPlatformInfoStampVisible(infoStampValue)
	local _h = MarkShareSystem._platformHooks

	if _h and _h.checkInfoStampVisible then
		return _h.checkInfoStampVisible(self, infoStampValue)
	end

	return true
end

function MarkShareSystem:addInfoStampGroup(markers)
	for infoStampId, infoStampValue in pairs(markers) do
		self.aroundMarkInfoStampGroup[infoStampId] = infoStampValue

		self:refreshMarkColor(infoStampId)
	end
end

function MarkShareSystem:addInfoStampCandidates(candidates, maxCount)
	if maxCount <= 0 then
		return
	end

	for index = 1, math.min(maxCount, #candidates) do
		local candidate = candidates[index]

		self.aroundMarkInfoStampGroup[candidate.id] = candidate.value

		self:refreshMarkColor(candidate.id)
	end
end

function MarkShareSystem:rebuildInfoStampCandidateCache()
	local cache = self.infoStampCandidateCache

	table.clear(cache.systemMarkers)
	table.clear(cache.selfMarkers)
	table.clear(cache.friendMarkers)
	table.clear(cache.strangerMarkers)

	self.infoStampCandidateCacheReady = false

	local activeInfoStampIds = {}
	local spaceMediaMarkers = pg.space and pg.space.mediaMarkers

	if spaceMediaMarkers then
		for _, infoStamp in pairs(spaceMediaMarkers) do
			for infoStampId, infoStampValue in pairs(infoStamp) do
				if infoStampValue.type == Const.MediaMarkerType.SystemText then
					cache.systemMarkers[infoStampId] = infoStampValue
				else
					activeInfoStampIds[infoStampId] = true

					local newContent = type(infoStampValue.content) == "string" and json.decode(infoStampValue.content) or infoStampValue.content

					infoStampValue.content = newContent

					local isSelf = pg.me.uid == infoStampValue.uid or self:inMyOwnKey(infoStampId)

					if isSelf then
						cache.selfMarkers[infoStampId] = infoStampValue
					else
						local isFriend = pg.game.chat:checkFriendList(infoStampValue.uid)
						local visibility = infoStampValue.setting or Const.MARKER_SETTINGS.DEFAULT
						local canShow = visibility ~= Const.MARKER_SETTINGS.OTHER_HIDE and (visibility ~= Const.MARKER_SETTINGS.STRANGER_HIDE or isFriend) and self:checkPlatformInfoStampVisible(infoStampValue)

						if canShow then
							local candidate = {
								id = infoStampId,
								value = infoStampValue,
								priority = self:getInfoStampRandomPriority(infoStampId, infoStampValue)
							}

							if isFriend then
								table.insert(cache.friendMarkers, candidate)
							else
								table.insert(cache.strangerMarkers, candidate)
							end
						end
					end
				end
			end
		end
	end

	table.sort(cache.friendMarkers, MarkShareSystem.compareInfoStampCandidatePriority)
	table.sort(cache.strangerMarkers, MarkShareSystem.compareInfoStampCandidatePriority)
	self:cleanupInfoStampRandomValues(activeInfoStampIds)

	self.infoStampCandidateCacheSceneId = pg.space.sceneId
	self.infoStampCandidateCacheReady = true
end

function MarkShareSystem:refreshInfoStampVisibility()
	if not pg.space or not pg.me then
		return
	end

	if not self.infoStampCandidateCacheReady or self.infoStampCandidateCacheSceneId ~= pg.space.sceneId then
		return self:refreshAroundInfoStamp()
	end

	local oldKeyStores = {}

	if not self.aroundMarkInfoStampGroup then
		self.aroundMarkInfoStampGroup = {}
	end

	for key, _ in pairs(self.aroundMarkInfoStampGroup) do
		oldKeyStores[key] = true
	end

	table.clear(self.aroundMarkInfoStampGroup)

	local cache = self.infoStampCandidateCache

	if self:checkCanShow() then
		if self.infoStampSystemVisible and self:shouldShowSystemMediaMarker() then
			self:addInfoStampGroup(cache.systemMarkers)
		end

		if self:shouldShowPlayerMediaMarker() then
			if self:getMediaMarkerViewSetting() ~= Const.MARKER_SETTINGS.SELF_HIDE then
				self:addInfoStampGroup(cache.selfMarkers)
			end

			if self:shouldShowOtherPlayerMediaMarker() then
				self:addInfoStampCandidates(cache.friendMarkers, self.infoStampFriendCount)
				self:addInfoStampCandidates(cache.strangerMarkers, self.infoStampStrangerCount)
			end
		end
	end

	self:addPresetMark()
	self:onAroundInfoStampUpdated(oldKeyStores)
end

function MarkShareSystem:cleanupInfoStampRandomValues(activeInfoStampIds)
	for infoStampId, _ in pairs(self.infoStampRandomValues) do
		if not activeInfoStampIds[infoStampId] then
			self.infoStampRandomValues[infoStampId] = nil
		end
	end
end

function MarkShareSystem:onPlayerLevelChanged()
	self:refreshInfoStampVisibility()
end

function MarkShareSystem:onTick()
	if self.bubbleHelper then
		self.bubbleHelper:onTick()
	end
end

function MarkShareSystem:createAvatarReplication(avatarType, optionId, successCb, failedCb)
	local function successCallback(entity)
		if successCb then
			successCb(entity)
		end
	end

	local function failedCallback()
		if failedCb then
			failedCb()
		end
	end

	if avatarType == MarkShareSystem.AVATAR_TYPE.OtherPlayer and optionId then
		self.avatarHelper:createPlayerAvatar(optionId, successCallback, failedCallback, self.avatarReplicationGroup.transform)
	elseif avatarType == MarkShareSystem.AVATAR_TYPE.Self then
		self.avatarHelper:createMainPlayerAvatar(successCallback, failedCallback, self.avatarReplicationGroup.transform)
	elseif avatarType == MarkShareSystem.AVATAR_TYPE.Preset then
		self.avatarHelper:createNpcAvatar(optionId, successCallback, failedCallback, self.avatarReplicationGroup.transform)
	else
		failedCallback()
	end
end

function MarkShareSystem:destroyAvatar()
	self:clearAvatarEntity()

	self.avatarHelper = nil
end

function MarkShareSystem:clearAvatarEntity(cb)
	if self.avatarHelper then
		self.avatarHelper:destroy(cb)
	end
end

function MarkShareSystem:checkCanShow()
	local sceneCfg = SceneData[pg.space.sceneId]
	local sceneShow = sceneCfg and sceneCfg.markShare == 1
	local statusShow = pg.me:checkStatus("INFO_STAMP", nil, nil, true, nil, nil) or self:isInfoStampDisabledArea()

	return sceneShow and statusShow and self:getForceHideScope() ~= MarkShareSystem.FORCE_HIDE_SCOPE.All
end

function MarkShareSystem:_refreshAroundInfoStampImpl()
	if not pg.space then
		return nil
	end

	self:refreshInfoStampSettingValues()
	self:rebuildInfoStampCandidateCache()

	return self:refreshInfoStampVisibility()
end

function MarkShareSystem:refreshAroundInfoStamp()
	return self:_refreshAroundInfoStampImpl()
end

function MarkShareSystem:onAroundInfoStampUpdated(oldKeyStores)
	for key, _ in pairs(oldKeyStores) do
		if not self.aroundMarkInfoStampGroup[key] and self.poolHelper[key] then
			self.poolHelper[key].loader:destroy()
			self:removeKey(key, self.poolHelper[key].info.gameObject)

			self.poolHelper[key] = nil
		end
	end

	for key, _ in pairs(self.aroundMarkInfoStampGroup) do
		if not oldKeyStores[key] then
			local loader = ResLoader.new()

			loader:load(AddressDataConst.INFO_STAMP, function(gameObject)
				local info = {
					gameObject = gameObject
				}

				info.gameObject.name = key

				info.gameObject.transform:SetParent(self.poolParent.transform)

				self.poolHelper[key] = {
					loader = loader,
					info = info
				}

				self:addMark(key, info)
			end)
		end
	end
end

function MarkShareSystem:addPresetMark()
	if not self.infoStampSystemVisible or not self:shouldShowSystemMediaMarker() then
		return
	end

	local sceneId = pg.space.sceneId

	if not self.sceneMarkDataGroup[sceneId] then
		self.sceneMarkDataGroup[sceneId] = SceneUtils.getSceneMarkData(sceneId, pg.space.id)
	end

	if not self.sceneMarkDataGroup[sceneId][Const.MAP_MARK_INFO_STAMP] then
		return
	end

	for _, markData in pairs(self.sceneMarkDataGroup[sceneId][Const.MAP_MARK_INFO_STAMP]) do
		if markData.informationId and InfoStampPresetContentData[markData.informationId] then
			local infoStampMarkId = Utils.getSysMediaMarkerIdByNo(markData.informationId)

			if self.aroundMarkInfoStampGroup[infoStampMarkId] and type(self.aroundMarkInfoStampGroup[infoStampMarkId].content) ~= "table" then
				local presetData = InfoStampPresetContentData[markData.informationId]
				local playerName = pg.getGameString("MYSTERIOUS_ADVENTURER")

				if presetData.playerName then
					playerName = pg.getLocalizationText(presetData.playerName)
				else
					playerName = presetData.npcId and pg.getLocalizationText(PuppetName[presetData.npcId].name) or playerName
				end

				local content = {
					pos = {
						markData.markPosition[1],
						markData.markPosition[2],
						markData.markPosition[3]
					},
					rot = Quaternion.Euler(presetData.rotation[1], presetData.rotation[2], presetData.rotation[3]),
					playerName = playerName,
					informationType = presetData.informationType
				}
				local pos = content.pos

				if not self:checkSysPresetMarkIsAroundSelf(pos[1], pos[3]) then
					self.aroundMarkInfoStampGroup[infoStampMarkId] = nil
				else
					self.aroundMarkInfoStampGroup[infoStampMarkId].content = content
				end
			elseif not self.aroundMarkInfoStampGroup[infoStampMarkId] then
				local presetData = InfoStampPresetContentData[markData.informationId]
				local playerName = pg.getGameString("MYSTERIOUS_ADVENTURER")

				if presetData.playerName then
					playerName = pg.getLocalizationText(presetData.playerName)
				else
					playerName = presetData.npcId and pg.getLocalizationText(PuppetName[presetData.npcId].name) or playerName
				end

				local content = {
					pos = {
						markData.markPosition[1],
						markData.markPosition[2],
						markData.markPosition[3]
					},
					rot = Quaternion.Euler(presetData.rotation[1], presetData.rotation[2], presetData.rotation[3]),
					playerName = playerName,
					informationType = presetData.informationType
				}
				local pos = content.pos

				if self:checkSysPresetMarkIsAroundSelf(pos[1], pos[3]) then
					self.aroundMarkInfoStampGroup[infoStampMarkId] = {
						dislikes = 0,
						content = content,
						likes = presetData.thumbsUp or 0,
						type = Const.MediaMarkerType.SystemText
					}
				end
			else
				local pos = self.aroundMarkInfoStampGroup[infoStampMarkId].content.pos

				if not self:checkSysPresetMarkIsAroundSelf(pos[1], pos[3]) then
					self.aroundMarkInfoStampGroup[infoStampMarkId] = nil
				end
			end
		end
	end
end

function MarkShareSystem:checkSysPresetMarkIsAroundSelf(x, z)
	local playerPos = pg.me:getPosition()

	if math.abs(playerPos.x - x) <= MarkShareSystem.SYS_PRESET_MARK_NEAR_DIS and math.abs(playerPos.z - z) <= MarkShareSystem.SYS_PRESET_MARK_NEAR_DIS then
		return true
	end

	return false
end

function MarkShareSystem:checkId(id)
	if id ~= pg.me.id and id ~= pg.me.curCombatPetId and id ~= pg.me.clientExploreEntId then
		return false
	end

	return true
end

function MarkShareSystem:addMark(key, info)
	if not pg.me.isMainPlayer then
		return
	end

	local infoStampData = self.aroundMarkInfoStampGroup[key]

	if not infoStampData then
		return
	end

	local content = infoStampData.content

	info.gameObject.transform.position = Vector3(content.pos[1], content.pos[2], content.pos[3])

	local objectReference = info.gameObject:GetComponent("ObjectReference")
	local enterInfoStampArea = objectReference:GetRefValue("enterInfoStampArea")
	local exitInfoStampArea = objectReference:GetRefValue("exitInfoStampArea")
	local lookAtInfoStampArea = objectReference:GetRefValue("lookAtInfoStampArea")
	local infoStampLookAtHelper = objectReference:GetRefValue("infoStampLookAtHelper")
	local enterDist = SysConfigData.MARKSHARE_ENTER_DIST
	local exitDist = SysConfigData.MARKSHARE_EXIT_DIST

	enterInfoStampArea:Init(enterDist)
	exitInfoStampArea:Init(exitDist)
	lookAtInfoStampArea:Init(25)

	function enterInfoStampArea.onEnter()
		self:enterInfoStampArea(key, info, content)
	end

	function enterInfoStampArea.onExit()
		self:leaveInfoStampArea(key, info)
	end

	function exitInfoStampArea.onExit()
		self:leaveFarAwayInfoStampArea()
	end

	function lookAtInfoStampArea.onEnter()
		infoStampLookAtHelper.activeLookAt = true
	end

	function lookAtInfoStampArea.onExit()
		infoStampLookAtHelper.activeLookAt = false
	end

	self:refreshMarkColor(key)
end

function MarkShareSystem:enterInfoStampArea(key, info, content)
	if self.mute then
		return
	end

	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
		dist = 1.5,
		actionPrototypeId = 161,
		globalId = key,
		interactionType = InteractionConst.INTERACTION_TYPE_MARK_SHARE,
		interactFunc = function()
			if pg.me:MAGNESIS_READY_ST() or pg.me:MAGNESIS_ST() then
				pg.me:magnesisCancel()
			end

			if pg.me:isControllingPet() and not pg.pawn.isForceControlPet then
				pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.FuncMenu)
			end

			self:openInfoStamp(info.gameObject.name, info.gameObject.transform)
		end,
		targetPos = info.gameObject.transform.position,
		interactName = content.animation == -1 and pg.getGameString("MYSTERIOUS_ADVENTURER") or content.playerName,
		isTip = content.informationType == 2
	})

	if not self.infoStampInfoKeys then
		self.infoStampInfoKeys = {}
	end

	self.infoStampInfoKeys[key] = info
end

function MarkShareSystem:leaveInfoStampArea(key, info)
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = key,
		interactionType = InteractionConst.INTERACTION_TYPE_MARK_SHARE,
		targetPos = info.gameObject.transform.position
	})

	if self.infoStampInfoKeys and self.infoStampInfoKeys[key] then
		self.infoStampInfoKeys[key] = nil
	end
end

function MarkShareSystem:leaveFarAwayInfoStampArea()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_MARK_SHARE_VIEW) then
		pg.global.ui.markShareView:closePanel()
	end
end

function MarkShareSystem:muteInfoStampSystem(mute)
	self.mute = mute

	if mute then
		self:leaveFarAwayInfoStampArea()

		for key, info in pairs(self.infoStampInfoKeys or EMPTY_TABLE) do
			self:leaveInfoStampArea(key, info)
		end

		self.poolParent.transform.localScale = Vector3.zero
	else
		self.poolParent.transform.localScale = Vector3.one
	end
end

function MarkShareSystem:recordInfoStampTrans(infoStampInfoTrans)
	self.infoStampInfoTrans = infoStampInfoTrans
end

function MarkShareSystem:dealInfoStampVisible(enable)
	if not self.infoStampInfoTrans then
		return
	end

	local onjRef = self.infoStampInfoTrans:GetComponent("ObjectReference")
	local markShareSignTransform = onjRef:GetRefValue("markShareSignTransform")
	local markShareSignWidget = markShareSignTransform:GetComponent("UWidget")

	markShareSignWidget:SetActiveFastest(enable)

	if enable then
		self:recordInfoStampTrans(nil)
	end
end

function MarkShareSystem:refreshMarkColor(markId)
	if not self.poolHelper[markId] then
		return
	end

	local info1 = self.poolHelper[markId].info

	if not info1 then
		return
	end

	local infoStampData = self.aroundMarkInfoStampGroup[markId]

	if infoStampData == nil then
		return
	end

	local objRef = info1.gameObject:GetComponent("ObjectReference")
	local imgLineUImage = objRef:GetRefValue("imgLineUImage")
	local imgRoundUImage = objRef:GetRefValue("imgRoundUImage")
	local imgRound1UImage = objRef:GetRefValue("imgRound1UImage")
	local imgLineGlowUImage = objRef:GetRefValue("imgLineGlowUImage")
	local imgGlowUImage = objRef:GetRefValue("imgGlowUImage")
	local imgGlow1UImage = objRef:GetRefValue("imgGlow1UImage")
	local imgBgUImage = objRef:GetRefValue("imgBgUImage")
	local imgBg1UImage = objRef:GetRefValue("imgBg1UImage")
	local txtDetailsUSDFText = objRef:GetRefValue("txtDetailsUSDFText")
	local txtNumUSDFText = objRef:GetRefValue("txtNumUSDFText")
	local iconObjectReference = objRef:GetRefValue("iconObjectReference")
	local iconGoodUImage = objRef:GetRefValue("iconGoodUImage")
	local imgFocusUImage = objRef:GetRefValue("imgFocusUImage")

	self:renderTipFirstIcon(markId, infoStampData, iconObjectReference)

	if infoStampData.likes >= SysConfigData.INFO_STAMP_COLOR_THRESHOLD then
		imgLineUImage.color = self.colorTemp
		imgRoundUImage.color = self.colorTemp
		imgRound1UImage.color = self.colorTemp
		imgLineGlowUImage.color = self.colorTemp1
		imgGlowUImage.color = self.colorTemp1
		imgGlow1UImage.color = self.colorTemp1
		imgBgUImage.color = self.colorTemp2
		imgBg1UImage.color = self.colorTemp2
		iconGoodUImage.color = self.likeGold
		txtNumUSDFText.color = self.likeGold
		imgFocusUImage.color = self.focusGold
	else
		imgLineUImage.color = self.colorTemp4
		imgRoundUImage.color = self.colorTemp4
		imgRound1UImage.color = self.colorTemp4
		imgLineGlowUImage.color = self.colorTemp4
		imgGlowUImage.color = self.colorTemp4
		imgGlow1UImage.color = self.colorTemp4
		imgBgUImage.color = self.colorTemp3
		imgBg1UImage.color = self.colorTemp3
		iconGoodUImage.color = self.likeWhite
		txtNumUSDFText.color = self.likeWhite
		imgFocusUImage.color = self.focusWhite
	end

	local content

	if infoStampData.type == Const.MediaMarkerType.SystemText then
		local presetNo = Utils.getNoBySysMediaMarkerId(markId)

		content = InfoStampPresetContentData[presetNo]
	else
		content = infoStampData.content
	end

	ClientTextUtils.setText(txtDetailsUSDFText, self:getTemplateTxt(content))
	ClientTextUtils.setText(txtNumUSDFText, self.aroundMarkInfoStampGroup[markId].likes)
end

function MarkShareSystem:renderTipFirstIcon(markId, infoStampData, iconObjectReference)
	local iconInfoTransform = iconObjectReference:GetRefValue("iconInfoTransform")
	local iconSkillUImage = iconObjectReference:GetRefValue("iconSkillUImage")
	local elementUButton = iconObjectReference:GetRefValue("elementUButton")
	local petRoundTransform = iconObjectReference:GetRefValue("petRoundTransform")
	local petIcon = iconObjectReference:GetRefValue("petIcon")
	local presetNo = Utils.getNoBySysMediaMarkerId(markId)
	local content

	if presetNo then
		content = InfoStampPresetContentData[presetNo]
	else
		content = infoStampData.content
	end

	local sortT = {}
	local firstClue

	if content.clueList and #content.clueList > 0 and #content.clueList <= 3 then
		for _, v in pairs(content.clueList) do
			sortT[#sortT + 1] = {
				key = v[1],
				sortKey = MarkShareSystem.CLUE_WEIGHT[v[1]],
				value = v[2]
			}
		end

		table.sort(sortT, function(a, b)
			return a.sortKey < b.sortKey
		end)

		if sortT[1] then
			firstClue = {
				sortT[1].key,
				sortT[1].value
			}
		end
	else
		local txtClips = content.txtClips

		if txtClips and #txtClips > 0 and #txtClips <= 3 then
			for _, v in pairs(txtClips) do
				for _, v1 in pairs(v) do
					if InfoStampConcatContentData[v1] and InfoStampConcatContentData[v1].icon then
						local clue = InfoStampConcatContentData[v1].icon

						sortT[#sortT + 1] = {
							key = clue[1],
							sortKey = MarkShareSystem.CLUE_WEIGHT[clue[1]],
							value = clue[2]
						}
					end
				end
			end

			table.sort(sortT, function(a, b)
				return a.sortKey < b.sortKey
			end)

			if sortT[1] then
				firstClue = {
					sortT[1].key,
					sortT[1].value
				}
			end
		else
			return
		end
	end

	iconInfoTransform.gameObject.transform.localScale = Vector3.one
	elementUButton.gameObject.transform.localScale = Vector3.zero
	iconSkillUImage.gameObject.transform.localScale = Vector3.zero
	petRoundTransform.gameObject.transform.localScale = Vector3.zero

	if not firstClue then
		return
	end

	iconInfoTransform.gameObject.transform.localScale = Vector3.zero

	if firstClue[1] == 1 then
		elementUButton.gameObject.transform.localScale = Vector3.one

		LuaUIUtils.setElementButtonNew(elementUButton, firstClue[2] or 0, false)
	elseif firstClue[1] == 2 then
		local defaultVal = "10011"
		local iconName = PetData[firstClue[2]] and PetData[firstClue[2]].iconName or defaultVal

		iconName = iconName or defaultVal
		petRoundTransform.gameObject.transform.localScale = Vector3.one
		petIcon.url = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON)
	elseif firstClue[1] == 3 or firstClue[1] == 4 then
		local defaultVal = "$UI_SkillIcon_Avatar_9000001.png"
		local iconName = AbilityParamData[firstClue[2]] and AbilityParamData[firstClue[2]].icon or defaultVal

		iconName = iconName or defaultVal

		iconSkillUImage.gameObject:SetActiveEx(true)

		iconSkillUImage.gameObject.transform.localScale = Vector3.one
		iconSkillUImage.url = iconName
	elseif firstClue[1] == 5 then
		local defaultVal = "$ui_item_1000.png"
		local iconName = ItemData[firstClue[2]] and ItemData[firstClue[2]].icon or defaultVal

		iconName = iconName or defaultVal

		iconSkillUImage.gameObject:SetActiveEx(true)

		iconSkillUImage.gameObject.transform.localScale = Vector3.one
		iconSkillUImage.url = iconName
	elseif firstClue[1] == 6 or firstClue[1] == 7 or firstClue[1] == 8 then
		iconSkillUImage.gameObject:SetActiveEx(true)

		iconSkillUImage.gameObject.transform.localScale = Vector3.one
		iconSkillUImage.url = AddressDataConst[string.format("UI_MARK_SHARE_CLUE_%s_%s", firstClue[1], firstClue[2])]
	else
		iconInfoTransform.gameObject.transform.localScale = Vector3.one
	end
end

function MarkShareSystem:removeKey(key, gameObject)
	if not pg.me.isMainPlayer then
		return
	end

	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = key,
		interactionType = InteractionConst.INTERACTION_TYPE_MARK_SHARE,
		targetPos = gameObject.transform.position
	})
end

function MarkShareSystem:inMyOwnKey(infoStampKey)
	if not pg.me.mediaMarker or not pg.me.mediaMarker[infoStampKey] then
		return false
	end

	return true
end

function MarkShareSystem:isInfoStampBeLikedOrDislikedByMe(infoStampKey)
	if not pg.me.mediaMarkerOp or not pg.me.mediaMarkerOp[infoStampKey] then
		return false
	end

	return true
end

function MarkShareSystem:openInfoStamp(infoStampId, infoStampInfoTrans)
	pg.global.ui:open(UIConst.UI_ID_MARK_SHARE_VIEW, {
		infoStampId = infoStampId,
		infoStampInfoTrans = infoStampInfoTrans
	})
end

function MarkShareSystem:openInfoStampSimple(infoStampId)
	pg.global.ui:open(UIConst.UI_ID_MARK_SHARE_VIEW_SIMPLE, {
		infoStampId = infoStampId
	})
end

function MarkShareSystem:onInteractionChanged(info)
	local globalId = pg.game.interaction:getCurrentUnitMapGlobalIdByInteractionConstId(InteractionConst.INTERACTION_TYPE_MARK_SHARE)

	if self.currentInteractionGlobalId then
		-- block empty
	end

	self.currentInteractionGlobalId = globalId
end

function MarkShareSystem:onPlayerEnterScene()
	self:refreshInfoStampAreaForceHide()
end

function MarkShareSystem:onPlayerLeaveScene()
	return
end

function MarkShareSystem:getTemplateTxt(content)
	local templateTxt1 = ""
	local templateTxt2 = ""
	local templateTxt3 = ""
	local textGroup = {
		templateTxt1,
		templateTxt2,
		templateTxt3
	}

	for idx, sentenceGroup in pairs(content.txtClips) do
		if #sentenceGroup == 1 then
			if sentenceGroup[1] ~= 0 then
				textGroup[idx] = pg.getLocalizationText(InfoStampConcatContentData[sentenceGroup[1]].categoryName)
			else
				textGroup[idx] = "%s"
			end
		elseif #sentenceGroup == 2 then
			if sentenceGroup[1] ~= 0 and sentenceGroup[2] ~= 0 then
				local txt1 = pg.getLocalizationText(InfoStampConcatContentData[sentenceGroup[1]].categoryName)
				local txt2 = pg.getLocalizationText(InfoStampConcatContentData[sentenceGroup[2]].categoryName)

				textGroup[idx] = string.format(txt1, txt2)
			elseif sentenceGroup[1] ~= 0 and sentenceGroup[2] == 0 then
				local txt1 = pg.getLocalizationText(InfoStampConcatContentData[sentenceGroup[1]].categoryName)

				textGroup[idx] = txt1
			elseif sentenceGroup[1] == 0 then
				textGroup[idx] = "%s"
			end
		end
	end

	return string.format("%s%s%s", textGroup[1], textGroup[2], textGroup[3])
end

function MarkShareSystem:parseInfoStamp(isSys, stampInfoId, infoStampData)
	local ret = {}

	infoStampData = infoStampData or self.aroundMarkInfoStampGroup[stampInfoId]

	local content

	if isSys then
		local presetNo = Utils.getNoBySysMediaMarkerId(stampInfoId)

		content = InfoStampPresetContentData[presetNo]
		ret.txtCustom = pg.getLocalizationText(content.txtCustom)
		ret.rot = Quaternion.Euler(content.rotation[1], content.rotation[2], content.rotation[3])
	else
		content = infoStampData.content
		ret.txtCustom = content.txtCustom
		ret.rot = content.rot
	end

	ret.playerName = pg.getLocalizationText(infoStampData.content.playerName)
	ret.txtClips = self:getTemplateTxt(content)

	if content.animation then
		ret.animation = tonumber(content.animation)

		if content.animation == -1 then
			ret.playerName = pg.getGameString("MYSTERIOUS_ADVENTURER")
		end
	end

	if content.bubbleType then
		ret.bubbleType = InfoStampCustomBubbleConfigData[content.bubbleType].bubbleRes
	end

	ret.likes = infoStampData.likes
	ret.photoTemplate = content.photoTemplate

	if isSys then
		self:injectSysOtherRichInfos(ret, stampInfoId)
	end

	return ret
end

function MarkShareSystem:injectSysOtherRichInfos(ret, stampInfoId)
	local temp = {}
	local presetNo = Utils.getNoBySysMediaMarkerId(stampInfoId)
	local content = InfoStampPresetContentData[presetNo]

	if content.txtClips then
		temp[#temp + 1] = {
			tIndex = 0,
			txtClips = ret.txtClips
		}
	end

	if content.clueList then
		local tmpT = {
			tIndex = 6,
			clueList = content.clueList
		}

		temp[#temp + 1] = tmpT
	end

	if content.picture then
		temp[#temp + 1] = {
			tIndex = 1,
			picture = content.picture
		}
	end

	if content.movie then
		temp[#temp + 1] = {
			tIndex = 1,
			movie = content.movie
		}
	end

	if content.voice then
		temp[#temp + 1] = {
			tIndex = 2,
			voice = content.voice
		}
	end

	if content.course then
		local tmpT = {
			tIndex = 5,
			course = content.course
		}

		if content.courseName then
			tmpT.courseName = pg.getLocalizationText(content.courseName)
		end

		if content.courseDesc then
			tmpT.courseDesc = pg.getLocalizationText(content.courseDesc)
		end

		temp[#temp + 1] = tmpT
	end

	if content.reward then
		temp[#temp + 1] = {
			tIndex = 3,
			reward = content.reward
		}
	end

	if content.pet then
		temp[#temp + 1] = {
			tIndex = 4,
			pet = content.pet
		}
	end

	ret.extraInfos = temp
end

function MarkShareSystem:getSelfMarkSceneId(infoStampId)
	local data = pg.me.mediaMarker[infoStampId]

	if not data then
		return nil
	end

	return data.sceneId
end

function MarkShareSystem:getSelfTxtClips(infoStampId)
	local data = pg.me.mediaMarker[infoStampId]

	if not data then
		return nil
	end

	pg.me:batchFindMediaMarker({
		infoStampId
	})
end

function MarkShareSystem:closeViewUI()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_MARK_SHARE_VIEW) and pg.global.ui.markShareView then
		pg.global.ui.markShareView:closePanel()
	end
end

function MarkShareSystem:onFocusChanged(markShareId)
	local function inner(go, active)
		local objRef = go:GetComponent("ObjectReference")
		local imgFocusAnimation = objRef:GetRefValue("imgFocusAnimation")

		imgFocusAnimation.gameObject:SetActiveEx(active)
	end

	if self.focusedShareId ~= markShareId then
		if self.focusedShareId and self.poolHelper[self.focusedShareId] and self.poolHelper[self.focusedShareId].info then
			inner(self.poolHelper[self.focusedShareId].info.gameObject, false)
		end

		if markShareId and self.poolHelper[markShareId] and self.poolHelper[markShareId].info then
			inner(self.poolHelper[markShareId].info.gameObject, true)
		end

		self.focusedShareId = markShareId
	end
end

function MarkShareSystem:getMyExpireInfoById(infoStampId)
	local data = pg.me.mediaMarker[infoStampId]

	if not data then
		return MarkShareSystem.EXPIRE_STATE.Permanent
	end

	return self:getExpireInfo(data)
end

function MarkShareSystem:getExpireInfo(data)
	if not data then
		return MarkShareSystem.EXPIRE_STATE.Permanent
	end

	if data.isPermanent == 1 then
		return MarkShareSystem.EXPIRE_STATE.Permanent
	end

	if not data.createTs then
		return MarkShareSystem.EXPIRE_STATE.Permanent
	end

	local expireTs = data.createTs + MarkShareSystem.getMaxDayCount() * Const.SECONDS_ONE_DAY
	local remainSeconds = expireTs - Time.secondCache

	if remainSeconds <= 0 then
		return MarkShareSystem.EXPIRE_STATE.Expired, pg.getGameString("MARK_SHARE_EXPIRED")
	end

	local remainDays = math.ceil(remainSeconds / Const.SECONDS_ONE_DAY)

	return MarkShareSystem.EXPIRE_STATE.Active, string.format(pg.getGameString("MARK_SHARE_EXPIRE_DAYS"), remainDays)
end

function MarkShareSystem.getMaxDayCount()
	return SysConfigData.MARKSHARE_ENCOURAGE_DURING_MAX or 10
end

return MarkShareSystem
