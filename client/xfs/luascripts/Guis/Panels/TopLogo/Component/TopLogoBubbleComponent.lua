-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoBubbleComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoBubbleComponent")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local TopLogoConst = require("Const.TopLogoConst")
local Utils = require("Common.Utils.Utils")
local AddressDataConst = require("Const.AddressDataConst")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local pg = pg
local Vector2 = Vector2
local Vector3 = Vector3
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoBubbleComponent = Class.LightClass("TopLogoBubbleComponent", TopLogoItemComponent)
local BUBBLE_SUB_ITEM_UI_OFFSET = Vector2(112, 0)

function TopLogoBubbleComponent:ctor(refUContainer, topLogoItem)
	TopLogoBubbleComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoBubbleComponent:onCtor()
	self.bubbleResMap = {}
	self.isInCd = false
	self.bubbleDistance = SysConfigData.TOPLOGO_BUBBLE_DISTANCE
	self.closeOffset = Vector2(100, -300)
	self.farOffset = Vector2(-50, -300)

	local data = self.entity:getConfigData()

	if data and data.bubbleDistance then
		self.bubbleDistance = data.bubbleDistance
	end

	self.m_cbCacheBubbleInfo = {
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1] = {},
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2] = {}
	}
	self.m_pendingBubbleShow = nil
	self.m_pendingEmojiInfo = nil

	local topLogoData = self.entity and self.entity.topLogoData

	if topLogoData and topLogoData.pendingBubbleInfo then
		self.m_pendingEmojiInfo = topLogoData.pendingBubbleInfo
		topLogoData.pendingBubbleInfo = nil
	end

	function self.m_onEmojiScaleUpdate()
		self:updateEmojiScale()
	end

	function self.m_onGoBubbleTimerEnd()
		self:m_onGoBubbleTimerEndImpl()
	end

	function self.m_onHideEmojiBubble()
		self:m_onEmojiBubbleTimerEndImpl()
	end

	function self.m_onHideEmojiBubbleWithCd()
		self:hideEmojiBubbleWithCd()
	end

	function self.m_onClearCd()
		self:clearCd()
	end

	function self.m_onEmojiInfoContainerLoaded(isSuccess)
		if not isSuccess or not self.m_pendingEmojiInfo then
			return
		end

		self:showEmojiBubbleWithInfo(self.m_pendingEmojiInfo)
	end

	self:refreshVisible()
end

function TopLogoBubbleComponent:m_onGoBubbleTimerEndImpl()
	local emojiName = self.m_timedGoEmojiName
	local playStartTime = self.m_timedGoStartTime

	self.goBubbleTimer = nil
	self.m_timedGoEmojiName = nil
	self.m_timedGoStartTime = nil

	if self.entity and self.entity.clearTimedBubbleDemand then
		self.entity:clearTimedBubbleDemand(emojiName, playStartTime)
	end

	self:hideGoBubble()
	self:notifyMaxDistanceChanged()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoBubbleComponent:m_onEmojiBubbleTimerEndImpl()
	local emojiName = self.m_timedEmojiName
	local playStartTime = self.m_timedEmojiStartTime

	self.emojiBubbleTimer = nil
	self.m_timedEmojiName = nil
	self.m_timedEmojiStartTime = nil

	if self.entity and self.entity.clearTimedBubbleDemand then
		self.entity:clearTimedBubbleDemand(emojiName, playStartTime)
	end

	self:hideEmojiBubble(emojiName)
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoBubbleComponent:m_cleanupBubbleInstances()
	local uiMgr = pg.global.uiMgr

	if self.asyncTaskIdMap then
		for _, taskId in pairs(self.asyncTaskIdMap) do
			if taskId and taskId > 0 then
				uiMgr:CancelUIAsyncTask(taskId)
			end
		end

		self.asyncTaskIdMap = {}
	end

	if self.bubbleResMap then
		for _, go in pairs(self.bubbleResMap) do
			if NotNil(go) then
				uiMgr:DestroyItem(go)
			end
		end

		self.bubbleResMap = {}
	end

	self.curBubble = nil
end

function TopLogoBubbleComponent:m_resetSubItemWorldAnchorState()
	self.m_subItemRegistered = nil
	self.m_subItemWorldAnchorSynced = nil
	self.m_subItemWorldAnchorEntity = nil
	self.m_subItemWorldAnchorStrategy = nil
	self.m_subItemWorldAnchorOffsetY = nil
end

function TopLogoBubbleComponent:m_removeSubItemWorldAnchor()
	local topLogoScript = self.topLogoItem and self.topLogoItem.topLogoScript

	if self.m_subItemRegistered and topLogoScript and NotNil(topLogoScript) then
		topLogoScript:RemoveSubItem(self.compName)
	end

	self:m_resetSubItemWorldAnchorState()
end

function TopLogoBubbleComponent:m_syncSubItemWorldAnchor()
	if not self.m_subItemRegistered then
		return
	end

	local topLogoScript = self.topLogoItem and self.topLogoItem.topLogoScript

	if not topLogoScript or IsNil(topLogoScript) then
		return
	end

	local eModel = self.entity and self.entity.eModel

	if not eModel then
		return
	end

	local topLogoData = self.entity.topLogoData
	local strategy = topLogoData and topLogoData.strategy or 0
	local offsetY = topLogoData and topLogoData.height or 0

	if self.m_subItemWorldAnchorSynced and self.m_subItemWorldAnchorEntity == eModel and self.m_subItemWorldAnchorStrategy == strategy and self.m_subItemWorldAnchorOffsetY == offsetY then
		return
	end

	topLogoScript:SetupSubItemAsEntityAnchor(self.compName, eModel, strategy, offsetY)

	self.m_subItemWorldAnchorSynced = true
	self.m_subItemWorldAnchorEntity = eModel
	self.m_subItemWorldAnchorStrategy = strategy
	self.m_subItemWorldAnchorOffsetY = offsetY
end

function TopLogoBubbleComponent:m_registerSubItemWorldAnchor()
	local topLogoScript = self.topLogoItem and self.topLogoItem.topLogoScript

	if not topLogoScript or IsNil(topLogoScript) then
		return
	end

	if not self.transform or IsNil(self.transform) then
		return
	end

	local compName = self.compName

	topLogoScript:RemoveSubItem(compName)
	topLogoScript:CreateSubItem(compName, self.transform)
	topLogoScript:UpdateSubItemOffset(compName, BUBBLE_SUB_ITEM_UI_OFFSET)
	self:m_resetSubItemWorldAnchorState()

	self.m_subItemRegistered = true

	self:m_syncSubItemWorldAnchor()
end

function TopLogoBubbleComponent:shouldBeActive()
	if self.m_pendingBubbleShow then
		return true
	end

	if self.m_pendingEmojiInfo then
		return true
	end

	if self.goBubbleTimer then
		return true
	end

	if self.animFlag then
		return true
	end

	local emojiName = self.entity and self.entity.topLogoData and self.entity.topLogoData.playingEmojiName

	return emojiName ~= nil
end

function TopLogoBubbleComponent:resetRender()
	if self.scaleTimer then
		pg.game.camera:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	if self.goBubbleTimer then
		self:killTimer(self.goBubbleTimer)

		self.goBubbleTimer = nil
	end

	if self.emojiTimer then
		self:killTimer(self.emojiTimer)

		self.emojiTimer = nil
	end

	if self.emojiBubbleTimer then
		self:killTimer(self.emojiBubbleTimer)

		self.emojiBubbleTimer = nil
	end

	self.animFlag = false
	self.isInCd = false
	self.lastEmojiName = nil
	self.m_timedEmojiName = nil
	self.m_timedEmojiStartTime = nil
	self.m_timedGoEmojiName = nil
	self.m_timedGoStartTime = nil
	self.m_pendingEmojiInfo = nil

	self:m_cleanupBubbleInstances()
	self:m_removeSubItemWorldAnchor()

	if self.m_cbCacheBubbleInfo then
		for _, info in pairs(self.m_cbCacheBubbleInfo) do
			info.cbData = nil
		end
	end

	self.objectReference = nil
	self.bubbleNewUWidget = nil
	self.imgGoUWidget = nil
	self.imgGoUImage = nil
	self.imgGoAnimation = nil

	TopLogoBubbleComponent.super.resetRender(self)
end

function TopLogoBubbleComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.imgGoUWidget = self.objectReference:GetRefValue("imgGoUWidget")
	self.imgGoUImage = self.objectReference:GetRefValue("imgGoUImage")
	self.imgGoAnimation = self.objectReference:GetRefValue("imgGoAnimation")
	self.bubbleNewUWidget = self.objectReference:GetRefValue("bubbleNewUWidget")
end

function TopLogoBubbleComponent:checkContainerLoaded()
	if not TopLogoBubbleComponent.super.checkContainerLoaded(self) then
		return false
	end

	if self.refUContainer ~= nil and IsNil(self.refUContainer) then
		return false
	end

	return true
end

function TopLogoBubbleComponent:initUI()
	self.imgGoUWidget:SetActiveQuickly(false)
end

function TopLogoBubbleComponent:onDestroy()
	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_BUBBLE, self.onBubbleMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_BUBBLE_WITH_INFO, self.onBubbleWithInfoMsg)
	end

	if self.goBubbleTimer then
		self:killTimer(self.goBubbleTimer)

		self.goBubbleTimer = nil
	end

	if self.emojiTimer then
		self:killTimer(self.emojiTimer)

		self.emojiTimer = nil
	end

	if self.emojiBubbleTimer then
		self:killTimer(self.emojiBubbleTimer)

		self.emojiBubbleTimer = nil
	end

	if self.scaleTimer then
		pg.game.camera:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	self.lastEmojiName = nil
	self.m_timedEmojiName = nil
	self.m_timedEmojiStartTime = nil
	self.m_timedGoEmojiName = nil
	self.m_timedGoStartTime = nil
	self.m_pendingBubbleShow = nil
	self.m_pendingEmojiInfo = nil
	self.m_cbCacheBubbleInfo = nil

	self:m_cleanupBubbleInstances()
	self:m_removeSubItemWorldAnchor()
	TopLogoBubbleComponent.super.onDestroy(self)
end

function TopLogoBubbleComponent:addEntityListener()
	function self.onBubbleMsg(isVisible, emojiName, duration, matchMultiple)
		local showBubble = self:innerGetVisible() and isVisible

		duration = tonumber(duration)

		if showBubble then
			if self.entity then
				self:tryToShowBubble(emojiName, duration, matchMultiple)
			end
		else
			self:tryToHideBubble(emojiName)
		end
	end

	function self.onBubbleWithInfoMsg(emojiInfo)
		if self:innerGetVisible() then
			self:showEmojiBubbleWithInfo(emojiInfo)
		end
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_BUBBLE, self.onBubbleMsg)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_BUBBLE_WITH_INFO, self.onBubbleWithInfoMsg)
	end
end

function TopLogoBubbleComponent:addListener()
	return
end

function TopLogoBubbleComponent:onTopLogoCompUpdate()
	self:m_syncSubItemWorldAnchor()
end

function TopLogoBubbleComponent:innerGetVisible()
	if not TopLogoBubbleComponent.super.innerGetVisible(self) then
		return false
	end

	local ignoreVirtualEntity = Utils.isVirtualEntity(self.entity)
	local forceShow = self.entity and self.entity._forceShowBubble == true

	if not self:isInShowBubbleDistance() and not ignoreVirtualEntity and not forceShow then
		return false
	end

	return true
end

function TopLogoBubbleComponent:isInShowBubbleDistance()
	local distance = self.topLogoItem.distance
	local ratio = 1

	if self.entity and self.entity.inFogArea then
		ratio = SysConfigData.BUBBLE_DISTANCE_RATIO
	end

	return distance <= self.bubbleDistance * ratio
end

function TopLogoBubbleComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingEmojiInfo then
		self:showEmojiBubbleWithInfo(self.m_pendingEmojiInfo)

		return
	end

	if self.m_pendingBubbleShow then
		local data = self.m_pendingBubbleShow

		self.m_pendingBubbleShow = nil

		self:tryToShowBubble(data.emojiName, data.duration, data.matchMultiple)

		return
	end

	if callFromUpdate then
		return
	end

	local emojiName = self.entity.topLogoData.playingEmojiName
	local playingDuration = self.entity.topLogoData.playingDuration
	local playStartTime = self.entity.topLogoData.playStartTime
	local matchMultiple = self.entity.topLogoData.matchMultiple

	if emojiName ~= nil and not LuaUIUtils.isGoBubble(emojiName) then
		local duration

		if playingDuration and playingDuration ~= -1 then
			duration = playingDuration - (Time.realSecondCache - playStartTime)

			if duration <= 0 then
				self.entity.topLogoData.playingEmojiName = nil

				return
			end
		end

		if self:checkSelfVisible() then
			if not self.animFlag then
				self:tryToShowBubble(emojiName, duration, matchMultiple)
			end
		elseif self.animFlag then
			self:tryToHideBubble(emojiName)
		end
	end
end

function TopLogoBubbleComponent:tryToShowBubble(emojiName, duration, matchMultiple)
	self.m_pendingBubbleShow = {
		emojiName = emojiName,
		duration = duration,
		matchMultiple = matchMultiple
	}

	self:notifyActiveStateChanged(true)

	if not self.topLogoItem:isTopLogoPrefabReady() then
		return
	end

	self.m_pendingBubbleShow = nil

	if self:checkContainerLoaded() then
		self:m_tryToShowBubble(false, emojiName, duration, matchMultiple)
	else
		local cacheInfo = self.m_cbCacheBubbleInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1]

		cacheInfo.cbData = cacheInfo.cbData or {}
		cacheInfo.cbData.emojiName = emojiName
		cacheInfo.cbData.duration = duration
		cacheInfo.cbData.matchMultiple = matchMultiple

		if not cacheInfo.cbFunc then
			function cacheInfo.cbFunc()
				local cacheInfo = self.m_cbCacheBubbleInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1]

				if cacheInfo.cbData then
					self:m_tryToShowBubble(true, cacheInfo.cbData.emojiName, cacheInfo.cbData.duration, cacheInfo.cbData.matchMultiple)
				end
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(cacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	end
end

function TopLogoBubbleComponent:m_tryToShowBubble(isAsync, emojiName, duration, matchMultiple)
	if LuaUIUtils.isGoBubble(emojiName) then
		self.m_timedGoEmojiName = emojiName
		self.m_timedGoStartTime = self.entity and self.entity.topLogoData and self.entity.topLogoData.playStartTime

		if self.entity and self.entity.topLogoData then
			self.entity.topLogoData.playingDuration = 1
		end

		self:showGoBubble(UIConst.LET_GO_STATE[emojiName])
	else
		self:showEmojiBubble(emojiName, duration, matchMultiple)
	end
end

function TopLogoBubbleComponent:tryToHideBubble(emojiName)
	if self.m_pendingBubbleShow then
		local pendingName = self.m_pendingBubbleShow.emojiName

		if pendingName == emojiName or LuaUIUtils.isGoBubble(emojiName) and LuaUIUtils.isGoBubble(pendingName) then
			self.m_pendingBubbleShow = nil
		end
	end

	if self:checkContainerLoaded() then
		if UIConst.LET_GO_STATE[emojiName] then
			self:hideGoBubble()
		else
			self:hideEmojiBubble(emojiName)
		end
	end

	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoBubbleComponent:onUContainerLoaded(isSuccess)
	TopLogoBubbleComponent.super.onUContainerLoaded(self, isSuccess)

	if isSuccess then
		self:m_registerSubItemWorldAnchor()
	end
end

function TopLogoBubbleComponent:showGoBubble(index)
	if self:checkContainerLoaded() then
		self:m_showGoBubble(false, index)
	else
		local cacheInfo = self.m_cbCacheBubbleInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2]

		cacheInfo.cbData = cacheInfo.cbData or {}
		cacheInfo.cbData.index = index

		if not cacheInfo.cbFunc then
			function cacheInfo.cbFunc()
				local cacheInfo = self.m_cbCacheBubbleInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2]

				self:m_showGoBubble(true, cacheInfo and cacheInfo.cbData and cacheInfo.cbData.index)
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(cacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2)
	end
end

function TopLogoBubbleComponent:m_showGoBubble(isAsync, index)
	if self.goBubbleTimer and index then
		self:killTimer(self.goBubbleTimer)
		self:playGoBubbleAnim(index)
	else
		self:playGoBubbleAnim(index)
	end
end

function TopLogoBubbleComponent:playGoBubbleAnim(index)
	if not self:checkContainerLoaded() then
		self:checkAndLoadUContainerUrlSupportAsync()

		return
	end

	self.imgGoUWidget:SetActiveQuickly(true)

	if index == Const.PET_STATE_GO then
		self.imgGoUImage.url = AddressDataConst.GO_BUBBLE_IMAGE

		self.imgGoAnimation:Play("UI_Ani_Go_Bubble")
	elseif index == Const.PET_STATE_STOP then
		self.imgGoUImage.url = AddressDataConst.STOP_BUBBLE_IMAGE

		self.imgGoAnimation:Play("UI_Ani_Stop_Bubble")
	elseif index == Const.PET_STATE_BACK then
		self.imgGoUImage.url = AddressDataConst.CHAT_BUBBLE_IMAGE

		self.imgGoAnimation:Play("UI_Ani_Back_Bubble")
	end

	self.goBubbleTimer = self:startTimer(self.m_onGoBubbleTimerEnd, 1)

	self:notifyMaxDistanceChanged()
end

function TopLogoBubbleComponent:hideGoBubble()
	if not self:checkContainerLoaded() then
		return
	end

	self.imgGoUWidget:SetActiveQuickly(false)
end

function TopLogoBubbleComponent:showEmojiBubble(emojiName, duration, matchMultiple)
	if not self:checkContainerLoaded() then
		self:checkAndLoadUContainerUrlSupportAsync()

		return
	end

	local cameraSystem = pg.game.camera

	if self.scaleTimer then
		cameraSystem:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	self.scaleTimer = cameraSystem:addLateUpdateTimer(self.m_onEmojiScaleUpdate)
	self.lastEmojiName = emojiName

	local resId = string.format(AddressDataConst.TOPLOGO_EMOJI_PREFAB, emojiName)

	for mapResId, mapBubble in pairs(self.bubbleResMap) do
		if mapResId and mapResId ~= resId and mapBubble then
			mapBubble:SetActiveEx(false)
		end
	end

	if self.bubbleResMap[resId] then
		self.curBubble = self.bubbleResMap[resId]

		self.curBubble:SetActiveEx(true)
		self:setAnimActive(true)
		self:setDuration(emojiName, duration, matchMultiple)
	else
		self:addBubblePrefabWithPathAsync(resId, function()
			self.curBubble = self.bubbleResMap[resId]

			self:setAnimActive(true)
			self:setDuration(emojiName, duration, matchMultiple)
		end)
	end
end

function TopLogoBubbleComponent:setDuration(emojiName, duration, matchMultiple)
	duration = duration or 2

	if ToBool(duration) then
		if self.emojiBubbleTimer then
			self:killTimer(self.emojiBubbleTimer)

			self.emojiBubbleTimer = nil
		end

		if duration ~= -1 then
			if matchMultiple then
				duration = self:getMatchedTime(emojiName, duration)
			end

			self.entity.topLogoData.playingDuration = duration
			self.m_timedEmojiName = emojiName
			self.m_timedEmojiStartTime = self.entity.topLogoData.playStartTime
			self.emojiBubbleTimer = self:startTimer(self.m_onHideEmojiBubble, duration)

			self:notifyMaxDistanceChanged()
		end
	end
end

function TopLogoBubbleComponent:getMatchedTime(emojiName, duration)
	local res = duration
	local clipTime = 1
	local resId = string.format(AddressDataConst.TOPLOGO_EMOJI_PREFAB, emojiName)
	local objectReference = self.bubbleResMap[resId]:GetComponent("ObjectReference")
	local anim = objectReference:GetRefValue("widgetAnimation")

	clipTime = anim.clip.length

	if res < clipTime then
		res = clipTime
	else
		res = math.floor(res / clipTime) * clipTime
	end

	return res
end

function TopLogoBubbleComponent:getCameraPos()
	return pg.game.camera:getSceneViewPos()
end

function TopLogoBubbleComponent:updateEmojiScale()
	if not self:checkParentVisible() then
		return
	end

	if not self.entity then
		return
	end

	if not self:checkContainerLoaded() then
		self:checkAndLoadUContainerUrlSupportAsync()

		return
	end

	local pos = self.entity:getPosition()
	local cameraPos = self:getCameraPos()
	local distance = Utils.distance(pos, cameraPos)
	local distanceThreshold = SysConfigData.toplogoBubbleScaleDefaultDistance
	local distanceMin = SysConfigData.toplogoBubbleScaleMinDistance
	local distanceMax = SysConfigData.TOPLOGO_BUBBLE_DISTANCE
	local scaleMin = SysConfigData.toplogoBubbleScaleLimit[1]
	local scaleMax = SysConfigData.toplogoBubbleScaleLimit[2]
	local scale = 1

	if distance < SysConfigData.toplogoBubbleTooCloseToHideDist then
		scale = 0
	elseif distance < distanceMin then
		scale = scaleMax
	elseif distance < distanceThreshold then
		local percent = (distance - distanceMin) / (distanceThreshold - distanceMin)

		scale = lume.lerp(scaleMax, 1, percent)
	elseif distance < distanceMax then
		local percent = (distance - distanceThreshold) / (distanceMax - distanceThreshold)

		scale = lume.lerp(1, scaleMin, percent)
	else
		scale = scaleMin
	end

	if self.animFlag then
		self:setAnimScale(scale)
	end
end

function TopLogoBubbleComponent:setAnimScale(scale)
	self.animScale = scale

	self:refreshAnimScale()
end

function TopLogoBubbleComponent:setAnimActive(flag)
	self.animFlag = flag

	if NotNil(self.curBubble) then
		local ok = pcall(function()
			local objectReference = self.curBubble:GetComponent("ObjectReference")
			local anim = objectReference:GetRefValue("widgetAnimation")

			if self.animFlag then
				local wrapLoop = CS.UnityEngine.WrapMode.Loop

				anim.wrapMode = wrapLoop

				local clip = anim.clip

				if clip then
					clip.wrapMode = wrapLoop

					local state = anim[clip.name]

					if state then
						state.wrapMode = wrapLoop
					end
				end

				anim:Play()
			else
				anim:Stop()

				local wrapOnce = CS.UnityEngine.WrapMode.Once

				anim.wrapMode = wrapOnce

				local clip = anim.clip

				if clip then
					clip.wrapMode = wrapOnce

					local state = anim[clip.name]

					if state then
						state.wrapMode = wrapOnce
					end
				end
			end
		end)

		if not ok then
			self.curBubble = nil
		end
	end

	self:refreshAnimScale()
end

function TopLogoBubbleComponent:refreshAnimScale()
	if IsNil(self.bubbleNewUWidget) then
		return
	end

	local ok = pcall(function()
		if self.animFlag then
			self.bubbleNewUWidget.transform.localScale = Vector3.one * (self.animScale or 1)
		else
			self.bubbleNewUWidget.transform.localScale = Vector3.zero
		end
	end)

	if not ok then
		self.bubbleNewUWidget = nil
	end
end

function TopLogoBubbleComponent:hideEmojiBubble(emojiName)
	if not self:checkContainerLoaded() then
		return
	end

	if not string.isNilOrEmpty(emojiName) and self.lastEmojiName and emojiName ~= self.lastEmojiName then
		return
	end

	self.lastEmojiName = nil

	self:setAnimActive(false)

	if self.scaleTimer then
		pg.game.camera:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	self:notifyActiveStateChanged(self:shouldBeActive())
end

local function dosth(that)
	return that.bubbleNewUWidget.transform
end

local function getBubbleNewWidgetTransform(component)
	return component.bubbleNewUWidget.transform
end

local function clearBubbleAsyncTask(asyncTaskIdMap, resID)
	if asyncTaskIdMap then
		asyncTaskIdMap[resID] = nil
	end
end

local function reparentBubbleGameObject(gameObject, parentWidget)
	gameObject.transform:SetParent(parentWidget.transform, false)

	gameObject.transform.anchoredPosition = Vector3.zero
end

local function onBubblePrefabInstantiated(component, uiMgr, resID, onResLoaded, gameObject)
	if not component:checkContainerLoaded() or IsNil(component.bubbleNewUWidget) or IsNil(gameObject) then
		clearBubbleAsyncTask(component.asyncTaskIdMap, resID)

		if NotNil(gameObject) then
			uiMgr:DestroyItem(gameObject)
		end

		return
	end

	local pok = pcall(reparentBubbleGameObject, gameObject, component.bubbleNewUWidget)

	if not pok then
		clearBubbleAsyncTask(component.asyncTaskIdMap, resID)
		uiMgr:DestroyItem(gameObject)

		return
	end

	clearBubbleAsyncTask(component.asyncTaskIdMap, resID)

	component.bubbleResMap[resID] = gameObject
	component.curBubble = gameObject

	if onResLoaded then
		onResLoaded()
	end
end

function TopLogoBubbleComponent:addBubblePrefabWithPathAsync(resID, onResLoaded)
	if not resID then
		return
	end

	if IsNil(self.bubbleNewUWidget) then
		return
	end

	local uiMgr = pg.global.uiMgr

	self.asyncTaskIdMap = self.asyncTaskIdMap or {}

	if self.asyncTaskIdMap[resID] and self.asyncTaskIdMap[resID] > 0 then
		return
	end

	local ok, parentTransform = pcall(getBubbleNewWidgetTransform, self)

	if not ok or IsNil(parentTransform) then
		self.bubbleNewUWidget = nil

		return
	end

	local taskId = uiMgr:InstantiateItem(resID, parentTransform, function(gameObject)
		onBubblePrefabInstantiated(self, uiMgr, resID, onResLoaded, gameObject)
	end)

	self.asyncTaskIdMap[resID] = tonumber(tostring(taskId))
end

function TopLogoBubbleComponent:showEmojiBubbleWithInfo(emojiInfo)
	if not emojiInfo then
		return
	end

	local canInterrupt = emojiInfo.interruptSameTagEmoji or self.tag ~= emojiInfo.emojiTag

	if not canInterrupt and (self.isInCd or self.emojiBubbleTimer) then
		return
	end

	if not self.topLogoItem:isTopLogoPrefabReady() then
		self.m_pendingEmojiInfo = emojiInfo

		self:notifyActiveStateChanged(true)

		return
	end

	if not self:checkContainerLoaded() then
		self.m_pendingEmojiInfo = emojiInfo

		self:notifyActiveStateChanged(true)
		self:checkAndLoadUContainerUrlSupportAsync(self.m_onEmojiInfoContainerLoaded, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC3)

		return
	end

	self.m_pendingEmojiInfo = nil

	if self.m_timedEmojiName then
		if self.entity and self.entity.clearTimedBubbleDemand then
			self.entity:clearTimedBubbleDemand(self.m_timedEmojiName, self.m_timedEmojiStartTime)
		end

		self.m_timedEmojiName = nil
		self.m_timedEmojiStartTime = nil
	end

	if self.emojiBubbleTimer then
		self:killTimer(self.emojiBubbleTimer)

		self.emojiBubbleTimer = nil
	end

	self:showEmojiBubble(emojiInfo.emojiRef)

	self.tag = emojiInfo.emojiTag
	self.emojiCd = emojiInfo.emojiCd or 0
	self.emojiBubbleTimer = self:startTimer(self.m_onHideEmojiBubbleWithCd, emojiInfo.emojiTime)

	self:notifyActiveStateChanged(true)
end

function TopLogoBubbleComponent:hideEmojiBubbleWithCd()
	self:hideEmojiBubble()

	if self.emojiBubbleTimer then
		self:killTimer(self.emojiBubbleTimer)

		self.emojiBubbleTimer = nil
	end

	if ToBool(self.emojiCd) then
		self.emojiBubbleTimer = self:startTimer(self.m_onClearCd, self.emojiCd)
		self.isInCd = true
	end

	self:notifyMaxDistanceChanged()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoBubbleComponent:clearCd()
	self.isInCd = false

	if self.emojiBubbleTimer then
		self:killTimer(self.emojiBubbleTimer)

		self.emojiBubbleTimer = nil
	end

	self:notifyMaxDistanceChanged()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoBubbleComponent:getInitMaxDistance()
	return SysConfigData.TOPLOGO_BUBBLE_DISTANCE
end

return TopLogoBubbleComponent
