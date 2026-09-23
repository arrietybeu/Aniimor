-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\BindAccount\\BindAccountSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Class = require("Core.Framework.Class")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local EventSocialBindData = require("Data.event_social_bind_data")
local SystemBase = require("GameApp.Core.SystemBase")
local logger = LoggerManager.getLogger("BindAccountSystem")
local BindAccountSystem = Class.LightClass("BindAccountSystem", SystemBase)

local function normalizeSocietyID(societyID)
	return tonumber(societyID) or societyID
end

local function buildReceivedAwardChannelMap(awardStatus)
	local receivedMap = {}

	for key, value in pairs(awardStatus or EMPTY_TABLE) do
		local configKey = normalizeSocietyID(key)
		local isStatusMapValue = type(value) == "boolean" or (value == 0 or value == 1) and EventSocialBindData[configKey] ~= nil

		if isStatusMapValue then
			if value == true or value == 1 then
				receivedMap[configKey] = true
			end
		else
			receivedMap[normalizeSocietyID(value)] = true
		end
	end

	return receivedMap
end

function BindAccountSystem:getMessageBindMap()
	return {
		[MessageName.SDK_ACCOUNT_BIND_CHANGED] = "onBindStatusChanged",
		[MessageName.ACTIVITY_STAGE_INFO_UPDATED] = "onActivityStageInfoUpdated"
	}
end

function BindAccountSystem:onCtor()
	self._awardStatusRequestToken = 0
	self._lifecycleToken = 0
	self._awardStatusEventId = nil
	self._receivedAwardChannelMap = nil
	self._awardRequestingEventId = nil
	self._awardRequestingChannelMap = {}
	self._activityStageCheckTimerId = nil
end

function BindAccountSystem:onInit()
	return
end

function BindAccountSystem:onClear()
	self:_invalidateAwardStatusRequest()
end

function BindAccountSystem:onDestroy()
	self:_invalidateAwardStatusRequest()
end

function BindAccountSystem:onLogin()
	self:_invalidateAwardStatusRequest()
end

function BindAccountSystem:onPlayerEnterScene()
	self:checkAndGrantAwards()
end

function BindAccountSystem:onBindStatusChanged()
	self:checkAndGrantAwards()
end

function BindAccountSystem:onActivityStageInfoUpdated()
	if self._activityStageCheckTimerId then
		self:killTimer(self._activityStageCheckTimerId)
	end

	self._activityStageCheckTimerId = self:startTimer(function()
		self._activityStageCheckTimerId = nil

		self:checkAndGrantAwards()
	end, 0)
end

function BindAccountSystem:_invalidateAwardStatusRequest()
	if self._activityStageCheckTimerId then
		self:killTimer(self._activityStageCheckTimerId)

		self._activityStageCheckTimerId = nil
	end

	self._awardStatusRequestToken = (self._awardStatusRequestToken or 0) + 1
	self._lifecycleToken = (self._lifecycleToken or 0) + 1
	self._awardStatusEventId = nil
	self._receivedAwardChannelMap = nil
	self._awardRequestingEventId = nil
	self._awardRequestingChannelMap = {}
end

function BindAccountSystem:_getActiveEventId()
	local isOpen, eventId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.BindAccount, pg and pg.me)

	if isOpen and eventId and eventId > 0 then
		return eventId
	end
end

function BindAccountSystem:_isChannelAvailable(channelConfig)
	local settingSystem = pg and pg.game and pg.game.setting
	local sdkManager = pg and pg.global and pg.global.sdkManager

	if not settingSystem or type(settingSystem.getLanguageType) ~= "function" or not sdkManager then
		return false
	end

	local languageType = settingSystem:getLanguageType()
	local languageMatched = false

	for _, allowedLanguage in ipairs(channelConfig.languageShow or EMPTY_TABLE) do
		if allowedLanguage == languageType then
			languageMatched = true

			break
		end
	end

	if not languageMatched then
		return false
	end

	if languageType == 0 then
		return true
	end

	return type(sdkManager.isSocialTypeSupported) == "function" and sdkManager:isSocialTypeSupported(channelConfig.typeName) == true
end

function BindAccountSystem:_isChannelBound(typeName)
	local sdkManager = pg and pg.global and pg.global.sdkManager

	if not sdkManager or type(sdkManager.getSocialBindInfo) ~= "function" then
		return false
	end

	local isBound = sdkManager:getSocialBindInfo(typeName)

	return isBound == true
end

function BindAccountSystem:_requestUnreceivedAwards(eventId)
	local requestCount = 0
	local receivedMap = self._receivedAwardChannelMap or {}

	if self._awardRequestingEventId ~= eventId then
		self._awardRequestingEventId = eventId
		self._awardRequestingChannelMap = {}
	end

	local requestingMap = self._awardRequestingChannelMap
	local lifecycleToken = self._lifecycleToken

	for rawSocietyID, channelConfig in pairs(EventSocialBindData) do
		local societyID = normalizeSocietyID(rawSocietyID)

		if not receivedMap[societyID] and not requestingMap[societyID] and self:_isChannelAvailable(channelConfig) and self:_isChannelBound(channelConfig.typeName) then
			local requestedSocietyID = societyID
			local requestedTypeName = channelConfig.typeName

			requestingMap[requestedSocietyID] = true

			local sent = pg.me:reqBindAccountGetAward(eventId, requestedSocietyID, function(code)
				if lifecycleToken ~= self._lifecycleToken or eventId ~= self:_getActiveEventId() then
					return
				end

				requestingMap[requestedSocietyID] = nil

				if code == NoticeDef.SUCCESS or code == NoticeDef.ERROR_ALREADY_REWARDED then
					self._receivedAwardChannelMap = self._receivedAwardChannelMap or {}
					self._receivedAwardChannelMap[requestedSocietyID] = true

					self:_notifyAwardStatusChanged()

					return
				end

				if LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:warn("request bind account award failed, eventId=%s, typeName=%s, societyID=%s, code=%s", tostring(eventId), tostring(requestedTypeName), tostring(requestedSocietyID), tostring(code))
				end
			end)

			if sent == false then
				requestingMap[requestedSocietyID] = nil
			else
				requestCount = requestCount + 1
			end
		end
	end

	self._receivedAwardChannelMap = receivedMap

	return requestCount
end

function BindAccountSystem:_notifyAwardStatusChanged()
	facade:SendMessageCommand(MessageName.BIND_ACCOUNT_AWARD_STATUS_CHANGED)
end

function BindAccountSystem:checkAndGrantAwards()
	local eventId = self:_getActiveEventId()

	if not eventId or not pg.me or type(pg.me.reqGetBindAccountAwardStatus) ~= "function" or type(pg.me.reqBindAccountGetAward) ~= "function" then
		return
	end

	self._awardStatusRequestToken = (self._awardStatusRequestToken or 0) + 1

	local requestToken = self._awardStatusRequestToken

	pg.me:reqGetBindAccountAwardStatus(eventId, function(awardStatus)
		if requestToken ~= self._awardStatusRequestToken or eventId ~= self:_getActiveEventId() then
			return
		end

		self._awardStatusEventId = eventId
		self._receivedAwardChannelMap = buildReceivedAwardChannelMap(awardStatus)

		self:_requestUnreceivedAwards(eventId)
		self:_notifyAwardStatusChanged()
	end)
end

function BindAccountSystem:getReceivedAwardChannelMap(eventId)
	if eventId ~= self._awardStatusEventId then
		return nil
	end

	return self._receivedAwardChannelMap
end

function BindAccountSystem:hasReceivedAward(eventId, societyID)
	return self:getAwardReceivedState(eventId, societyID) == true
end

function BindAccountSystem:getAwardReceivedState(eventId, societyID)
	local receivedMap = self:getReceivedAwardChannelMap(eventId)

	if receivedMap == nil then
		return nil
	end

	return receivedMap[normalizeSocietyID(societyID)] == true
end

return BindAccountSystem
