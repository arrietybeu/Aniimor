-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1ITipArea\\MapTipsItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AddressDataConst = require("Const.AddressDataConst")
local CultivateTipsComponent = require("Guis.Panels.Nourish.Component.CultivateTipsComponent")
local LeylineFlowerPresentUtils = require("Utils.LeylineFlowerPresentUtils")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local SysConfigData = require("Data.sys_config_data")
local MapTipsItem = Class.LightClass("MapTipsItem", BaseQueueItem)
local DEFAULT_RAINBOW_PROGRESS_START_TIME = 0.3333333333333333
local animationClipDurationCache = {}

function MapTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function MapTipsItem:onUpdate()
	self:startPendingCultivateFlow()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function MapTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.animeEnd = false

	if data.cultivateState == LeylineFlowerConst.CULTIVATE_TIP_STATE.RainbowEnergy then
		data.endTime = Time.realSecondCache + (SysConfigData.LEYLINE_FLOWER_RAINBOW_HUD_MAX_DURATION or 30)
	else
		data.endTime = Time.realSecondCache + (data.duration or 8)
	end

	self:addRunItem(data)
	self:initUContainer(data)
end

function MapTipsItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function MapTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if data.animeEnd == true or Time.realSecondCache > data.endTime then
		self:recycleToast(data)
	end
end

function MapTipsItem:initUContainer(data)
	self.uContainer:DestroyContent()
	self.uContainer:SetUrlWithCallback(AddressDataConst.UI_MAP_TIPS, self:guardRunCallback(data, function(content)
		if IsNil(content) or self.uContainer.content ~= content then
			return
		end

		self:renderItem(content, data)
	end))
end

function MapTipsItem:invokeCultivateEvent(widget, eventKey, onFinished)
	if NotNil(widget) and widget:CheckHasEvent(eventKey) then
		widget:InvokeCallbackWithCallback(eventKey, onFinished)

		return
	end

	if onFinished then
		onFinished()
	end
end

function MapTipsItem:getRainbowProgressStartTime()
	return math.max(0, tonumber(SysConfigData.LEYLINE_FLOWER_RAINBOW_HUD_PROGRESS_START_TIME) or DEFAULT_RAINBOW_PROGRESS_START_TIME)
end

function MapTipsItem:invokeAtAnimationTime(item, clipName, time, callback)
	if not callback then
		return
	end

	time = math.max(0, tonumber(time) or 0)

	if time <= 0 then
		callback()

		return
	end

	local animation = item.transform:GetComponent("Animation")
	local clip = NotNil(animation) and animation:GetClip(clipName) or nil

	if IsNil(clip) then
		callback()

		return
	end

	local remainingTime = time

	if animation:IsPlaying(clipName) then
		local state = animation[clipName]
		local currentTime = NotNil(state) and tonumber(state.time) or 0

		remainingTime = math.max(0, time - currentTime)
	end

	TimerManager.addTimer(remainingTime, callback)
end

function MapTipsItem:getAnimationClipDuration(item, clipName)
	local cachedDuration = animationClipDurationCache[clipName]

	if cachedDuration then
		return cachedDuration
	end

	local animation = item.transform:GetComponent("Animation")

	if IsNil(animation) then
		return 0
	end

	local clip = animation:GetClip(clipName)
	local duration = NotNil(clip) and tonumber(clip.length) or 0

	if duration > 0 then
		animationClipDurationCache[clipName] = duration
	end

	return duration
end

function MapTipsItem:getRainbowEnergyClipName(data)
	if data and data.isRainbowSpawn and data.cultivateTipsComponent:shouldPlayRainbowRush(data.rainbowSnapshot) then
		return LeylineFlowerConst.RAINBOW_HUD_VX_CLIP.EnergyRushHandoff
	end

	return LeylineFlowerConst.RAINBOW_HUD_VX_CLIP.EnergyNormal
end

function MapTipsItem:playRainbowEnergyClip(item, data)
	local clipName = self:getRainbowEnergyClipName(data)
	local animation = item.transform:GetComponent("Animation")

	if NotNil(animation) and NotNil(animation:GetClip(clipName)) then
		animation:Play(clipName)
	end

	return clipName
end

function MapTipsItem:showRainbowPetResultText(root, textAvisionUSDFText)
	local animation = root.transform:GetComponent("Animation")

	if NotNil(animation) then
		animation:Stop(LeylineFlowerConst.RAINBOW_HUD_VX_CLIP.PetResult)
	end

	local widgetAvisionTransform = root.transform:Find("Widget/WidgetAvision")
	local widgetAvision = NotNil(widgetAvisionTransform) and widgetAvisionTransform:GetComponent("UWidget") or nil

	if NotNil(widgetAvision) then
		widgetAvision.renderOpacity = 1
	end

	if NotNil(textAvisionUSDFText) then
		textAvisionUSDFText.renderOpacity = 1
	end
end

function MapTipsItem:getRainbowResultTextDuration(data)
	return 0
end

function MapTipsItem:finishCultivateFlow(data, delay)
	if data.removing then
		return
	end

	data.endTime = Time.realSecondCache + math.max(0, tonumber(delay) or 0)
end

function MapTipsItem:playRainbowPetResult(root, objectReference, data)
	self:invokeCultivateEvent(root, CS.XGUI.EInvokeTime.Custom2, function()
		if data.removing then
			return
		end

		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, LeylineFlowerConst.RUMBLE_NAME.AnimoAppear)
		root:TryChangePage("State", LeylineFlowerConst.CULTIVATE_TIP_STATE.RainbowPet)
		pg.game.audio:playEvent(LeylineFlowerConst.FLOWER_AUDIO_EVENT.RainbowPetAppear)

		if data.onRainbowPetShown then
			local onShown = data.onRainbowPetShown

			data.onRainbowPetShown = nil

			onShown()
		end

		local textAvisionUSDFText = objectReference:GetRefValue("textAvisionUSDFText")

		LuaUIUtils.setRainbowPetAppearText(textAvisionUSDFText, data.petTemplateId)
		self:invokeAtAnimationTime(root, LeylineFlowerConst.RAINBOW_HUD_VX_CLIP.PetResult, self:getAnimationClipDuration(root, LeylineFlowerConst.RAINBOW_HUD_VX_CLIP.PetResult), function()
			if data.removing then
				return
			end

			local holdDuration = self:getRainbowResultTextDuration(data)

			if holdDuration > 0 then
				self:showRainbowPetResultText(root, textAvisionUSDFText)
			end

			self:finishCultivateFlow(data, holdDuration)
		end)
	end)
end

function MapTipsItem:startPendingCultivateFlow()
	for _, data in ipairs(self.runList) do
		local startFlow = data.startCultivateFlow

		if startFlow then
			data.startCultivateFlow = nil

			if not data.removing then
				startFlow()
			end
		end
	end
end

function MapTipsItem:getShareSourceInfo(sourceUid)
	if string.isNilOrEmpty(sourceUid) then
		return nil
	end

	local teamInfo = pg.me and pg.me.getCurTeamInfo and pg.me:getCurTeamInfo()
	local memberInfo = teamInfo and teamInfo.membersInfo and teamInfo.membersInfo[sourceUid]

	if not memberInfo or not memberInfo.headIcon or string.isNilOrEmpty(memberInfo.playerName) then
		return nil
	end

	return memberInfo
end

function MapTipsItem:tryContinueAfterEntry(flowContext)
	local data = flowContext.data

	if data.removing or flowContext.entryContinuationStarted or not flowContext.entryClipFinished or not flowContext.normalProgressFinished then
		return
	end

	flowContext.entryContinuationStarted = true

	if flowContext.pendingRush then
		local playRush = flowContext.pendingRush

		flowContext.pendingRush = nil

		if not data.removing then
			if data.onCultivateRushStart then
				local onRushStart = data.onCultivateRushStart

				data.onCultivateRushStart = nil

				onRushStart(flowContext.pendingRushDuration)
			end

			playRush()
		end
	elseif data.isRainbowSpawn then
		self:playRainbowPetResult(flowContext.root, flowContext.objectReference, data)
	else
		self:finishCultivateFlow(data, 0)
	end
end

function MapTipsItem:startProgressFlow(flowContext)
	local data = flowContext.data

	data.cultivateTipsComponent:playRainbowEnergyFlow(data.blockId or 0, data.rainbowSnapshot, data.isRainbowSpawn, function(playRush, rushDuration)
		flowContext.pendingRush = playRush
		flowContext.pendingRushDuration = rushDuration or 0
		flowContext.normalProgressFinished = true

		self:tryContinueAfterEntry(flowContext)
	end, function()
		if data.removing then
			return
		end

		if data.isRainbowSpawn then
			self:playRainbowPetResult(flowContext.root, flowContext.objectReference, data)
		else
			flowContext.normalProgressFinished = true

			self:tryContinueAfterEntry(flowContext)
		end
	end)
end

function MapTipsItem:renderCultivateItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local root = item.transform:GetComponent("UComponent")

	root:TryChangePage("State", data.cultivateState)

	if data.onCultivateRendered then
		local onRendered = data.onCultivateRendered

		data.onCultivateRendered = nil

		onRendered()
	end

	if data.cultivateState == LeylineFlowerConst.CULTIVATE_TIP_STATE.RainbowEnergy then
		local cultivateTipsRectTransform = objectReference:GetRefValue("cultivateTipsRectTransform")

		data.cultivateTipsComponent = CultivateTipsComponent.new(pg.global.ui.tips, cultivateTipsRectTransform, {
			manualDestroy = true
		})

		local playerHeadRectTransform = objectReference:GetRefValue("playerHeadRectTransform")
		local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")

		data.cultivateTipsComponent:prepareRainbowEnergyFlow(data.blockId or 0, data.rainbowSnapshot)

		data.energyClipName = self:playRainbowEnergyClip(item, data)

		local shareInfo = self:getShareSourceInfo(data.sourceUid)

		playerHeadRectTransform.gameObject:SetActiveEx(shareInfo ~= nil)
		textNameUSDFText.gameObject:SetActiveEx(shareInfo ~= nil)

		if shareInfo then
			LuaUIUtils.renderPlayerHeadAvatar(playerHeadRectTransform, shareInfo.headIcon)
			ClientTextUtils.setText(textNameUSDFText, pg.getFormatText(pg.getGameString("FRIEND_WORLD_RAINBOW_SHARE"), shareInfo.playerName))
		end

		local flowContext = {
			entryClipFinished = false,
			entryContinuationStarted = false,
			pendingRushDuration = 0,
			normalProgressFinished = false,
			data = data,
			root = root,
			objectReference = objectReference
		}

		function data.startCultivateFlow()
			local energyClipName = data.energyClipName or LeylineFlowerConst.RAINBOW_HUD_VX_CLIP.EnergyNormal

			self:invokeAtAnimationTime(item, energyClipName, self:getRainbowProgressStartTime(), function()
				if not data.removing then
					self:startProgressFlow(flowContext)
				end
			end)
			self:invokeAtAnimationTime(item, energyClipName, self:getAnimationClipDuration(item, energyClipName), function()
				flowContext.entryClipFinished = true

				self:tryContinueAfterEntry(flowContext)
			end)
		end
	elseif data.cultivateState == LeylineFlowerConst.CULTIVATE_TIP_STATE.RainbowPet then
		LuaUIUtils.setRainbowPetAppearText(objectReference:GetRefValue("textAvisionUSDFText"), data.petTemplateId)
	elseif data.cultivateState == LeylineFlowerConst.CULTIVATE_TIP_STATE.LeylineFlower then
		ClientTextUtils.setText(objectReference:GetRefValue("textTitleUSDFText"), pg.getLocalizationText(data.titleKey))
		ClientTextUtils.setText(objectReference:GetRefValue("textSubUSDFText"), pg.getLocalizationText(data.subTitleKey))
	end
end

function MapTipsItem:renderItem(item, data)
	self:renderCultivateItem(item, data)
end

function MapTipsItem:onSceneUnload()
	LeylineFlowerPresentUtils.clear()
	self:clearDataQueue()
	self:clearRunningList()
end

function MapTipsItem:onRecycleStarted(data, target)
	if data.cultivateTipsComponent then
		data.cultivateTipsComponent:stopRainbowEnergyIncreaseSound()
		data.cultivateTipsComponent:destroy()

		data.cultivateTipsComponent = nil
	end
end

function MapTipsItem:onRecycleFinished(data, reason)
	if data.onCultivateFinished and not data.cultivateFinishedNotified then
		data.cultivateFinishedNotified = true

		local callback = data.onCultivateFinished

		data.onCultivateFinished = nil

		callback()
	end
end

return MapTipsItem
