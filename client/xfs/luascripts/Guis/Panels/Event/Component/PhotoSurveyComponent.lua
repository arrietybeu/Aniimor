-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\PhotoSurveyComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoSurveyComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local GameEventData = require("Data.game_event_data")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ClientConst = require("Const.ClientConst")
local PetResearchPhotoData = require("Data.pet_research_photo_data")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local AlbumCtrl = require("Guis.Panels.Album.AlbumCtrl")
local PhotoSurveyComponent = Class.LightClass("PhotoSurveyComponent", EventContainerComponent)

function PhotoSurveyComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.curProgressUBaseText = self.objectReference:GetRefValue("curProgressUBaseText")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.imgPetUnfinishedUImage = self.objectReference:GetRefValue("imgPetUnfinishedUImage")
	self.btnShootingUButton = self.objectReference:GetRefValue("btnShootingUButton")
	self.btnAlbumUButton = self.objectReference:GetRefValue("btnAlbumUButton")
	self.btnPhotographUButton = self.objectReference:GetRefValue("btnPhotographUButton")
	self.item1UButton = self.objectReference:GetRefValue("item1UButton")
	self.item2UButton = self.objectReference:GetRefValue("item2UButton")
	self.item3UButton = self.objectReference:GetRefValue("item3UButton")
	self.item4UButton = self.objectReference:GetRefValue("item4UButton")
	self.item5UButton = self.objectReference:GetRefValue("item5UButton")
	self.item6UButton = self.objectReference:GetRefValue("item6UButton")
	self.listDailyRewardUList = self.objectReference:GetRefValue("listDailyRewardUList")
	self.reward1UButton = self.objectReference:GetRefValue("reward1UButton")
	self.reward2UButton = self.objectReference:GetRefValue("reward2UButton")
	self.imgMaskPicUImage = self.objectReference:GetRefValue("imgMaskPicUImage")
	self.stickerRoot = self.objectReference:GetRefValue("stickerRoot")
	self.sticker1UWidget = self.objectReference:GetRefValue("sticker1UWidget")
	self.sticker2UWidget = self.objectReference:GetRefValue("sticker2UWidget")
	self.sticker3UWidget = self.objectReference:GetRefValue("sticker3UWidget")
	self.sticker4UWidget = self.objectReference:GetRefValue("sticker4UWidget")
	self.sticker5UWidget = self.objectReference:GetRefValue("sticker5UWidget")
	self.sticker6UWidget = self.objectReference:GetRefValue("sticker6UWidget")
	self.sticker1Txt = self.objectReference:GetRefValue("sticker1Txt")
	self.sticker2Txt = self.objectReference:GetRefValue("sticker2Txt")
	self.sticker3Txt = self.objectReference:GetRefValue("sticker3Txt")
	self.sticker4Txt = self.objectReference:GetRefValue("sticker4Txt")
	self.sticker5Txt = self.objectReference:GetRefValue("sticker5Txt")
	self.sticker6Txt = self.objectReference:GetRefValue("sticker6Txt")
	self.itemRoot = self.objectReference:GetRefValue("itemRoot")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.btnHotZoneUButton = self.objectReference:GetRefValue("btnHotZoneUButton")
	self.txtAreaPrompt = self.objectReference:GetRefValue("txtAreaPrompt")
	self.btnAreaPrompt = self.objectReference:GetRefValue("btnAreaPrompt")
	self.txtAreaPromptTitle = self.objectReference:GetRefValue("txtAreaPromptTitle")
	self.btnAreaPromptDone = self.objectReference:GetRefValue("btnAreaPromptDone")
	self.listDailyRewardFastUList = self.objectReference:GetRefValue("listDailyRewardFastUList")
	self.txtDailyReward = self.objectReference:GetRefValue("txtDailyReward")
	self.txtDailyRewardFast = self.objectReference:GetRefValue("txtDailyRewardFast")
	self.txtTips = self.objectReference:GetRefValue("txtTips")
	self.cameraUWidget = self.objectReference:GetRefValue("cameraUWidget")
end

function PhotoSurveyComponent:addListener()
	function self.btnPhotographUButton.luaClick()
		self:onBtnShootClick()
	end

	function self.btnAlbumUButton.luaClick()
		self:onBtnPhotoClick()
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		self:onRenderRewardItem(button, index, data)
	end

	function self.listDailyRewardUList.luaRenderItem(button, index, data)
		self:onRenderDailyRewardItem(button, index, data)
	end

	function self.listDailyRewardFastUList.luaRenderItem(button, index, data)
		self:onRenderDailyRewardItem(button, index, data, true)
	end

	if self.reward1UButton then
		function self.reward1UButton.luaClick()
			if not pg.game.input:isUsingGamepad() then
				return
			end

			self:onDailyRewardButtonClick(false)
		end
	end

	if self.reward2UButton then
		function self.reward2UButton.luaClick()
			if not pg.game.input:isUsingGamepad() then
				return
			end

			self:onDailyRewardButtonClick(true)
		end
	end

	function self.btnShootingUButton.luaRenderTooltip(_, tipItem)
		local objectReference = tipItem:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PETSHAPE_TIPS"))
	end

	function self.btnHotZoneUButton.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("PETSHAPE_CLICK_TIP"))
	end

	function self.btnAreaPrompt.luaClick()
		if self.hasMultipleUnlockedSticker then
			if self.bloomIdInfo then
				LuaUIUtils.locateMark(self.bloomIdInfo[1], self.bloomIdInfo[2])
			end
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("PETSHAPE_HABITAT_TIP"), 3)
		end
	end
end

function PhotoSurveyComponent:onBtnShootClick()
	if not self.puppetPhotoData then
		logger:error("PhotoSurveyComponent:onBtnShootClick error! Do not have target puppet!")

		return
	end

	local photo = pg.global.ui.photo

	pg.global.ui:open(UIConst.UI_ID_PHOTO, {
		photoMode = photo.ModeType.NORMAL_MODE,
		investigateId = self.puppetPhotoData.templateId,
		investigateCb = function(templateIds, path, timeStamp, position, sceneId, genderInfos, sprite)
			self:_onShootComplete(templateIds, path, timeStamp, position, sceneId, genderInfos, sprite)
		end
	})
end

function PhotoSurveyComponent:onBtnPhotoClick()
	local targetTemplateId = self.puppetPhotoData.templateId

	pg.global.ui.album:open({
		investigation = true,
		mode = AlbumCtrl.Mode.Investigation,
		investigateCb = function(templateIds, path, timeStamp, position, sceneId, genderInfos, sprite)
			self:_onShootComplete(templateIds, path, timeStamp, position, sceneId, genderInfos, sprite)
		end
	})
end

function PhotoSurveyComponent:_onShootComplete(templateIds, path, timeStamp, position, sceneId, genderInfos, sprite)
	if not templateIds or #templateIds == 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("PETSHAPE_NOPET"), 3)

		return
	end

	local finalTemplateId, correctGender

	for i = 1, #templateIds do
		local templateId = templateIds[i]

		if self.puppetPhotoData.templateId == templateId then
			finalTemplateId = templateId
			correctGender = genderInfos and genderInfos[templateId] and genderInfos[templateId][1] or 0

			break
		elseif not finalTemplateId and PetData[templateId] then
			finalTemplateId = templateId
		end
	end

	if not finalTemplateId then
		pg.global.showBubbleMessageRaw(pg.getGameString("PET_RESEARCH_SHAPE_WRONG"), 3)

		return
	end

	local openInfo = {
		eventId = self.eventId,
		curTemplateId = finalTemplateId,
		targetTemplateId = self.puppetPhotoData.templateId,
		photoPath = path,
		sprite = sprite,
		timeStamp = timeStamp,
		position = position,
		sceneId = sceneId,
		correctGender = correctGender
	}

	pg.global.ui:open(UIConst.UI_ID_EVENT_PHOTO_RECOGNIZE, openInfo)
end

function PhotoSurveyComponent:refreshPage()
	if not self.ctrl._curVisible then
		return
	end

	local eventData = GameEventData[self.eventId]

	if not eventData then
		return
	end

	self.puppetPhotoData = self.model:getPhotoPuppet(self.eventId)

	local state = self.puppetPhotoData and self.puppetPhotoData.state or 0
	local notDone = state == self.model.PuppetPhotoState.Normal

	self.rootWidget:TryChangePage("Morphological", notDone and 0 or 1)

	self.clueData = ClientActivityUtils.getPuppetPhotoClueAllText(self.puppetPhotoData.templateId)

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_PUPPET_PHOTO)
	ClientTextUtils.setText(self.txtDailyReward, pg.getGameString("PETSHAPE_AWARD_TITLE"))
	ClientTextUtils.setText(self.txtDailyRewardFast, pg.getGameString("PETSHAPE_EXTRA_AWARD_TITLE"))
	self.cameraUWidget.gameObject:SetActiveEx(notDone)

	if notDone then
		ClientTextUtils.setText(self.txtTips, pg.getGameString("PETSHAPE_PHOTO_TIP"))
	end

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime)

	local rewardList = self.model:getPuppetPhotoRewardDataList()

	self.listRewardUList:SetList(rewardList)

	local curProgress = ActivityUtils.getFormResearchScore(pg.me)
	local totalProgress = rewardList[#rewardList] and rewardList[#rewardList].targetNum or 0

	ClientTextUtils.setText(self.curProgressUBaseText, pg.getFormatText("<b><color=#f3f5ff>{0}</color></b><size=-4>/{1}</size>", curProgress, totalProgress))

	if self.lastState and self.lastState == self.model.PuppetPhotoState.Normal and state > self.model.PuppetPhotoState.Normal then
		self._pendingCustom1 = true
		self._pendingCustom2 = nil
	end

	self.lastState = state

	if state == self.model.PuppetPhotoState.Normal then
		self.imgPetUnfinishedUImage.url = self.puppetPhotoData.shadowIconName
	else
		self.imgPetUImage.url = self.puppetPhotoData.finishIconName
	end

	self:refreshSticker()

	local dailyRewards = self.model:getPuppetPhotoDailyRewardDataList()

	self.listDailyRewardUList:SetList(dailyRewards)

	local fastRewards = self.model:getPuppetPhotoDailyExtraRewardDataList()

	self.listDailyRewardFastUList:SetList(fastRewards)
	ClientTextUtils.setText(self.txtAreaPromptTitle, pg.getGameString("PETSHAPE_HABITAT"))
end

function PhotoSurveyComponent:refreshSticker()
	local curIdx = 1
	local petResearchCfg = PetResearchPhotoData[self.eventPhase]

	if not petResearchCfg then
		return
	end

	local needPlayUnlock = {}
	local unlockedStickerCount = 0

	self.bloomIdInfo = petResearchCfg.bloomId and petResearchCfg.bloomId

	for i = 1, 6 do
		local stickerWidget = self["sticker" .. i .. "UWidget"]
		local stickerTxt = self["sticker" .. i .. "Txt"]
		local itemWidget = self["item" .. i .. "UButton"]
		local defaultShow = i == petResearchCfg.displayPart

		if defaultShow then
			stickerWidget:SetActive(false)
			itemWidget:SetActive(false)
		else
			local clueUnlock = self.model:getPuppetPhotoClueUnlock(curIdx)
			local itemObjectRef = itemWidget.transform:GetComponent("ObjectReference")
			local itemTextUBaseText = itemObjectRef:GetRefValue("textUBaseText")

			itemWidget:TryChangePage("Information", clueUnlock and 0 or 1)
			ClientTextUtils.setText(itemTextUBaseText, self.clueData[curIdx][2])

			local newUnlock = false

			if clueUnlock then
				local prefix = ClientConst.PrefKey.EventFormResearchClueUnlock

				newUnlock = pg.global.prefsCacheUtils:getBool(prefix .. curIdx .. pg.me.uid, false)

				if newUnlock then
					stickerWidget:SetActive(true)

					needPlayUnlock[#needPlayUnlock + 1] = i

					pg.global.prefsCacheUtils:setBool(prefix .. curIdx .. pg.me.uid, false)
				else
					stickerWidget:SetActive(false)
				end

				unlockedStickerCount = unlockedStickerCount + 1
			else
				stickerWidget:SetActive(true)
			end

			if newUnlock then
				itemWidget:SetActive(false)
			else
				itemWidget:SetActive(clueUnlock)
			end

			if not clueUnlock then
				ClientTextUtils.setText(stickerTxt, self.clueData[curIdx][2])
			end

			curIdx = curIdx + 1
		end
	end

	local playUnlockIdx = 1

	if #needPlayUnlock > 1 then
		self.unlockTimer = self:startTimer(function()
			if playUnlockIdx > #needPlayUnlock then
				self:killTimer(self.unlockTimer)

				self.unlockTimer = nil

				return
			end

			local index = needPlayUnlock[playUnlockIdx]

			self:innerPlayUnlock(index)

			playUnlockIdx = playUnlockIdx + 1
		end, 0.2, true)
	elseif #needPlayUnlock == 1 then
		local index = needPlayUnlock[playUnlockIdx]

		self:innerPlayUnlock(index)
	end

	if self.lastUnlockedStickerCount and self.lastUnlockedStickerCount == 0 and unlockedStickerCount > 0 then
		self._pendingCustom2 = true
	end

	self.lastUnlockedStickerCount = unlockedStickerCount
	self.hasMultipleUnlockedSticker = unlockedStickerCount >= 1

	if self.lastState == self.model.PuppetPhotoState.Normal then
		local areaPromptStr = self.hasMultipleUnlockedSticker and pg.getGameString("PETSHAPE_CLUE_UNLOCK") or pg.getGameString("PETSHAPE_CLUE_LOCK")

		ClientTextUtils.setText(self.txtAreaPrompt, areaPromptStr)
		self.btnAreaPrompt:TryChangePage("type", self.hasMultipleUnlockedSticker and "Unlocked" or "BeforeUnlocking")
	else
		ClientTextUtils.setText(self.btnAreaPromptDone, pg.getGameString("PETSHAPE_HABITAT_FINISHED"))
		self.btnAreaPrompt:TryChangePage("type", "Completed")
	end

	self:tryPlayRootWidgetCallback()
end

function PhotoSurveyComponent:innerPlayUnlock(index)
	local stickerWidget = self["sticker" .. index .. "UWidget"]
	local itemWidget = self["item" .. index .. "UButton"]

	itemWidget:SetActive(true)
	pg.game.audio:playEvent("SFX_UI_ImoSurvey_Uncover")
	self.stickerRoot:InvokeCallback(CS.XGUI.EInvokeTime["Custom" .. index])
	self.itemRoot:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime["Custom" .. index], function()
		stickerWidget:SetActive(false)
	end)
end

function PhotoSurveyComponent:onRenderRewardItem(button, index, data)
	if data.state == ClientConst.RewardState.ReadyToClaim then
		function data.extraFunc()
			local realIdx = index + 1

			if realIdx > 1 then
				local canGetRewardList = ActivityUtils.getFormResearchCanRewardList(pg.me)

				if canGetRewardList[realIdx - 1] == true and pg.me.formResearchStageRewarded[realIdx - 1] ~= true then
					realIdx = -1
				end
			end

			pg.me:reqActivityPhotoStageRewardGet(self.eventId, realIdx)
			self.listRewardUList:RefreshList()
			self:refreshCommonNodeRedDot()
		end
	end

	self.view:onRenderRewardItem(button, index, data)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_PUPPET_PHOTO_REWARD_ITEM, index + 1)
	local showRedDot = ClientActivityUtils.redDotPoint_CheckPetResearchPhotoItem(index + 1)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)
end

function PhotoSurveyComponent:onRenderDailyRewardItem(button, index, data, isExtra)
	if data.canGet and not data.hasGet then
		function data.extraFunc()
			if isExtra then
				pg.me:reqActivityPhotoExtraRewardGet(self.eventId)
			else
				pg.me:reqActivityPhotoRewardGet(self.eventId)
			end

			self.listRewardUList:RefreshList()
			self:refreshCommonNodeRedDot()
		end
	else
		data.extraFunc = nil
	end

	LuaUIUtils.renderRewards(button, index, data)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_PUPPET_PHOTO_DAILY_REWARD, isExtra and 2 or 1)
	local show = data.canGet and not data.hasGet

	pg.global.setRedDot(treePath, button, show, RedDotConst.RedDotStyle.REWARD)
end

function PhotoSurveyComponent:onDailyRewardButtonClick(isExtra)
	local rewardList = isExtra and self.model:getPuppetPhotoDailyExtraRewardDataList() or self.model:getPuppetPhotoDailyRewardDataList()
	local firstReward = rewardList and rewardList[1]

	if not firstReward then
		return
	end

	if firstReward.canGet and not firstReward.hasGet then
		if isExtra then
			pg.me:reqActivityPhotoExtraRewardGet(self.eventId)
		else
			pg.me:reqActivityPhotoRewardGet(self.eventId)
		end

		self.listRewardUList:RefreshList()
		self:refreshCommonNodeRedDot()

		return
	end

	local rewardButton = isExtra and self.reward2UButton or self.reward1UButton

	LuaUIUtils.onRewardItemClick(rewardButton, firstReward)
end

function PhotoSurveyComponent:onBeforeExitPage()
	self._isPageVisible = false
	self._pendingCustom1 = nil
	self._pendingCustom2 = nil

	if self.unlockTimer then
		self:killTimer(self.unlockTimer)

		self.unlockTimer = nil
	end
end

function PhotoSurveyComponent:tryPlayRootWidgetCallback()
	if self.ctrl._curVisible then
		if self._pendingCustom1 then
			self.rootWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		elseif self._pendingCustom2 then
			self.rootWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end

		self._pendingCustom1 = nil
		self._pendingCustom2 = nil
	end
end

function PhotoSurveyComponent:onEnterPlayEvent()
	self._isPageVisible = true

	pg.game.audio:playEvent("SFX_UI_ImoSurvey_MoveIn")
end

function PhotoSurveyComponent:onDestroy()
	self.lastState = nil
	self._pendingCustom1 = nil
	self._pendingCustom2 = nil

	self.model:destroyAllPhotoSprite()
	UIComponent.onDestroy(self)
end

return PhotoSurveyComponent
