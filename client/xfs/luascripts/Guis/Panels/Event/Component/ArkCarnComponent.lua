-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\ArkCarnComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("ArkCarnComponent")
local Class = require("Core.Framework.Class")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local GameEventData = require("Data.game_event_data")
local UIConst = require("Const.UIConst")
local ActivityConst = require("Common.Const.ActivityConst")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local PetPrototypeData = require("Data.pet_prototype_data")
local Const = require("Common.Const.Const")
local EventArkCarnData = require("Data.event_ark_carn_data")
local PuppetData = require("Data.puppet_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ArkCarnComponent = Class.LightClass("ArkCarnComponent", EventContainerComponent)

function ArkCarnComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.tasklistUList = objectReference:GetRefValue("tasklistUList")
	self.btnGotoUButton = objectReference:GetRefValue("btnGotoUButton")
	self.stagelistUList = objectReference:GetRefValue("stagelistUList")
	self.stage1UWidget = objectReference:GetRefValue("stage1UWidget")
	self.stage2UWidget = objectReference:GetRefValue("stage2UWidget")
	self.btnPhotoUButton = objectReference:GetRefValue("btnPhotoUButton")
	self.rootUWidget = objectReference:GetRefValue("rootUWidget")
	self.artist1UButton = objectReference:GetRefValue("artist1UWidget")
	self.artist2UButton = objectReference:GetRefValue("artist2UWidget")
	self.artist3UButton = objectReference:GetRefValue("artist3UWidget")
	self.artist4UButton = objectReference:GetRefValue("artist4UWidget")
	self.emo1UImage = objectReference:GetRefValue("emo1UImage")
	self.emo2UImage = objectReference:GetRefValue("emo2UImage")
	self.emo3UImage = objectReference:GetRefValue("emo3UImage")
	self.emo4UImage = objectReference:GetRefValue("emo4UImage")
	self.rewardContentUWidget = objectReference:GetRefValue("rewardContentUWidget")
	self.todayTimerCountDown = objectReference:GetRefValue("todayTimerCountDown")
	self.notvotedtextUBaseText = objectReference:GetRefValue("notvotedtextUBaseText")
	self.votedtexeUBaseText = objectReference:GetRefValue("votedtexeUBaseText")
	self.dailyTimeUWidget = objectReference:GetRefValue("dailyTimeUWidget")
	self.textDailyUBaseText = objectReference:GetRefValue("textDailyUBaseText")
	self.text2DailyUBaseText = objectReference:GetRefValue("text2DailyUBaseText")
	self.stage1TitleUBaseText = objectReference:GetRefValue("stage1TitleUBaseText")
	self.btnGotoTextUBaseText = objectReference:GetRefValue("btnGotoTextUBaseText")
	self.emophoto1UButton = objectReference:GetRefValue("emophoto1UButton")
	self.emophoto2UButton = objectReference:GetRefValue("emophoto2UButton")
	self.emophoto3UButton = objectReference:GetRefValue("emophoto3UButton")
	self.emophoto4UButton = objectReference:GetRefValue("emophoto4UButton")
	self.emophoto5UButton = objectReference:GetRefValue("emophoto5UButton")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
	self.txtBtnGoto = objectReference:GetRefValue("txtBtnGoto")
	self.emophotos = {
		self.emophoto1UButton,
		self.emophoto2UButton,
		self.emophoto3UButton,
		self.emophoto4UButton,
		self.emophoto5UButton
	}
end

function ArkCarnComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	self.attrBonusType = "arkCarn"

	pg.game.event:pullVoteData()
end

function ArkCarnComponent:addListener()
	function self.btnGotoUButton.luaClick()
		local key = pg.me.uid .. "ArkCarn_GoTo"

		pg.global.prefsCacheUtils:setInt(key, 1)

		local eventArkCarnData = EventArkCarnData[self.phaseId][3]

		pg.me:tryTeleportToScene(eventArkCarnData.petCarnivalId[1], eventArkCarnData.petCarnivalId[2])
	end

	function self.btnPhotoUButton.luaClick()
		local photo = pg.global.ui.photo
		local targetPets = pg.game.event:getVotedPetTemplateIds()

		photo:open({
			snapshot = false,
			photoMode = photo.ModeType.NORMAL_MODE,
			carnTargetIds = targetPets,
			carnCb = function()
				return
			end
		})
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		if data.state == ClientConst.RewardState.ReadyToClaim then
			function data.extraFunc()
				self:onRewardClick(data)
			end
		end

		self.view:onRenderRewardItem(button, index, data)

		local txtName = button:Find("Text"):GetComponent("USDFText")

		ClientTextUtils.setText(txtName, pg.getGameString("VITALITY_SCORE_" .. data.index))
	end

	function self.stagelistUList.luaSelectedChanged(list, isSelected)
		if self.stagelistUList.selectedItem then
			self:selectStageChange(self.stagelistUList.selectedItem.stageId)
		end
	end

	function self.stagelistUList.luaRenderItem(button, index, data)
		local curDate = os.date("*t", data.startTime)
		local year, month, day = curDate.year, curDate.month, curDate.day
		local txtTime = button:Find("Time"):GetComponent("USDFText")

		ClientTextUtils.setText(txtTime, string.format("%s.%s", month, day))

		local txtTitle = button:Find("Title"):GetComponent("USDFText")

		ClientTextUtils.setText(txtTitle, pg.getLocalizationText(data.title))

		button.interactable = data.isOpen

		if data.isFinish then
			button:TryChangePage("Time", 1)
		end

		local treePath = string.format(RedDotConst.RedDotPath.EVENT_ARK_CARN_TAB_ITEM, data.stageId)
		local showRedDot = self.model:hasCanRecvTask(self.eventId, data.stageId * 1000)

		pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)
	end

	function self.tasklistUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			local objectReference = button:GetComponent("ObjectReference")
			local goUButton = objectReference:GetRefValue("goUButton")
			local listUList = objectReference:GetRefValue("listUList")
			local textUBaseText = objectReference:GetRefValue("textUBaseText")
			local iconTrackUImage = objectReference:GetRefValue("iconTrackUImage")
			local rewardData = {}

			rewardData.dropId = data.dropId
			rewardData.canGet = data.state == ActivityConst.TaskState.Finihed_CanRecv
			rewardData.hasGet = data.state == ActivityConst.TaskState.Received

			if rewardData.canGet then
				function rewardData.extraFunc()
					pg.me:serverMsg("RPC_CS_ReqActReceiveTaskReward", data.id)
				end
			end

			LuaUIUtils.setRewardListByDropIds(listUList, {
				rewardData
			})
			button:TryChangePage("Taskstate", data.state - 1)

			local isFinish = false

			if self.stagelistUList.selectedItem then
				isFinish = self.stagelistUList.selectedItem.isFinish
			end

			if isFinish and data.state == ActivityConst.TaskState.UnFinished then
				button:TryChangePage("Taskstate", 4)
			end

			local taskName = pg.getLocalizationText(data.name)

			if data.conditionId == self.photoTaskConfitionId then
				local photoCount = 0

				if pg.me.arkCarnPhotoTakedPets then
					photoCount = #pg.me.arkCarnPhotoTakedPets
				end

				taskName = pg.getFormatText(taskName, photoCount)
			end

			if data.state == 1 then
				goUButton.gameObject:SetActiveEx(data.conditionId ~= self.photoTaskConfitionId)
				iconTrackUImage.gameObject:SetActiveEx(data.conditionId ~= self.photoTaskConfitionId)
			end

			ClientTextUtils.setText(textUBaseText, taskName)

			local treePath = string.format(RedDotConst.RedDotPath.EVENT_ARK_CARN_ITEM, data.index)
			local showRedDot = data.state == ActivityConst.TaskState.Finihed_CanRecv

			pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)

			if showRedDot then
				function button.luaClick()
					pg.me:serverMsg("RPC_CS_ReqActReceiveTaskReward", data.id)
				end
			end

			function button.luaClick()
				if showRedDot then
					pg.me:serverMsg("RPC_CS_ReqActReceiveTaskReward", data.id)
				else
					self:onClickGoto(data)
				end
			end

			function goUButton.luaClick()
				self:onClickGoto(data)
			end
		else
			function button.luaClick()
				local isFinish = self.stagelistUList.selectedItem.isFinish

				pg.global.ui:open(UIConst.UI_ID_ARK_PARTY_CHOICE, {
					phaseId = self.phaseId,
					stageId = self.stageId,
					activityId = self.eventId,
					isFinish = isFinish
				})
			end
		end
	end
end

function ArkCarnComponent:onClickGoto(data)
	if data.state ~= 4 then
		if self.curSelectStageId == 1 then
			local isFinish = self.stagelistUList.selectedItem.isFinish

			pg.global.ui:open(UIConst.UI_ID_ARK_PARTY_CHOICE, {
				phaseId = self.phaseId,
				stageId = self.stageId,
				activityId = self.eventId,
				isFinish = isFinish
			})
		end

		if data.isQRTask then
			pg.global.ui:open(UIConst.UI_ID_QR_CODE)
			pg.me:serverMsg("RPC_CS_ActivityAddedWeCom", self.eventId)
		end

		if data.linkAddress then
			pg.global.sdkManager:openUrl("ArkCarnComponent", "SysConfigData.FEEDBACK_URL", data.linkAddress)
			pg.me:serverMsg("RPC_CS_ActivityAddedWeCom", self.eventId)
		end

		if data.conditionId == self.photoTaskConfitionId then
			local photo = pg.global.ui.photo
			local targetPets = pg.game.event:getVotedPetTemplateIds()

			photo:open({
				snapshot = false,
				photoMode = photo.ModeType.NORMAL_MODE,
				carnTargetIds = targetPets,
				carnCb = function()
					return
				end
			})
		end

		if (data.conditionId == self.npcTaskConfitionId or data.conditionId == self.photoTaskConfitionId2 or data.conditionId == self.npcTaskConfitionId2) and data.taskTrackId then
			local eventArkCarnData = EventArkCarnData[self.phaseId][3]
			local sceneId = eventArkCarnData.petCarnivalId[1]

			pg.game.map:openMapAndLocateMark(sceneId, Const.MAP_MARK_TRACE, data.taskTrackId, true)
		end
	end
end

function ArkCarnComponent:selectStageChange(stageId)
	self.curSelectStageId = stageId

	self.rootUWidget:TryChangePage("Contentstate", stageId - 1)
	self.rewardContentUWidget.gameObject:SetActiveEx(false)

	self.hasVoted = pg.me.arkCarnVotePet and #pg.me.arkCarnVotePet == 4

	local taskOpen = false
	local taskFinish = false

	if self.stagelistUList.selectedItem then
		taskOpen = self.stagelistUList.selectedItem.taskOpen
		taskFinish = self.stagelistUList.selectedItem.isFinish
	end

	self:refreshTask(stageId * 1000, taskOpen)
	self.listRewardUList.gameObject:SetActiveEx(false)

	local photoData = {}

	if stageId == 2 then
		photoData = self.model:getCarnPhotoData(self.phaseId)

		pg.game.audio:triggerEvent("SFX_UI_ArkParty_MoveIn12")
	elseif stageId == 1 then
		self:refreshVotePets()
		self.notvotedtextUBaseText.gameObject:SetActiveEx(not self.hasVoted and self.stageId == 1)
		self.votedtexeUBaseText.gameObject:SetActiveEx(self.hasVoted and self.stageId == 1)

		if self.hasVoted then
			ClientTextUtils.setText(self.stage1TitleUBaseText, pg.getGameString("ARK_CARNIVAL_9"))
		end

		pg.game.audio:triggerEvent("SFX_UI_ArkParty_MoveIn12")
	elseif stageId == 3 then
		if self.stageId == 3 then
			local key = pg.me.uid .. "ArkCarn_GoTo"
			local gotoValue = pg.global.prefsCacheUtils:getInt(key, 0)

			if gotoValue ~= 0 then
				local var_19_0 = false
			else
				local showRedDot = true
			end
		end

		pg.game.audio:triggerEvent("SFX_UI_ArkParty_MoveIn3")
	end

	self:refreshPhotoData(photoData)
	self.btnGotoUButton.gameObject:SetActiveEx(true)
	self.dailyTimeUWidget.gameObject:SetActiveEx(not taskFinish)

	if stageId == 3 and self.stageId ~= 3 then
		local startTime = TimeUtils.timeToFormatString3(self.stagelistUList.selectedItem.startTime)

		ClientTextUtils.setText(self.text2DailyUBaseText, ClientTextUtils.concatByLanguage(startTime, pg.getGameString("ARK_CARNIVAL_14")))
		self.todayTimerCountDown.gameObject:SetActiveEx(false)
		self.textDailyUBaseText.gameObject:SetActiveEx(false)
		self.text2DailyUBaseText.gameObject:SetActiveEx(true)
	else
		self.todayTimerCountDown.gameObject:SetActiveEx(true)
		self.textDailyUBaseText.gameObject:SetActiveEx(true)
		self.text2DailyUBaseText.gameObject:SetActiveEx(false)
	end

	if self.btnGotoTextUBaseText then
		self.btnGotoTextUBaseText.gameObject:SetActiveEx(stageId == 3 and self.stageId == 3)
	end
end

function ArkCarnComponent:refreshPage()
	self.phaseId = pg.me.arkcarnCurPhaseId
	self.photoTaskConfitionId = 9045
	self.photoTaskConfitionId2 = 9048
	self.npcTaskConfitionId = 9047
	self.npcTaskConfitionId2 = 9044
	self.hasVoted = pg.me.arkCarnVotePet and #pg.me.arkCarnVotePet == 4
	self.tabData = self.model:getCarnTabData(self.phaseId)

	self.stagelistUList:SetList(self.tabData)

	self.stageId = 1

	for _, tabInfo in ipairs(self.tabData) do
		if tabInfo.taskOpen then
			self.stageId = tabInfo.stageId
		end
	end

	local eventArkCarnData = EventArkCarnData[self.phaseId][1]

	self:selectStageChange(self.stageId)
	self.stagelistUList:SelectItem(self.stageId - 1)
	LuaUIUtils.setRewardListByDropIds(self.listRewardUList, {
		{
			dropId = eventArkCarnData.showAwardId
		}
	})

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)

	self:setEventTitle(self.eventTitleUContainer, eventTimeCfg.tabEndDayTime)
	ClientTextUtils.setText(self.txtBtnGoto, pg.getGameString("ARK_CARNIVAL_20"))
	self:refreshStageTime()
end

function ArkCarnComponent:refreshPhotoData(photoData)
	for index, data in ipairs(photoData) do
		self:refreshPhotoButton(self.emophotos[index], data)
	end
end

function ArkCarnComponent:refreshPhotoButton(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local emoUImage = objectReference:GetRefValue("emoUImage")
	local jobUBaseText = objectReference:GetRefValue("jobUBaseText")
	local descUBaseText = objectReference:GetRefValue("descUBaseText")
	local photoUImage = objectReference:GetRefValue("photoUImage")

	emoUImage.url = "$UI_Event_GroupPhoto_" .. data.petId .. ".png"

	ClientTextUtils.setText(jobUBaseText, pg.getGameString("ARK_CARNIVAL_" .. data.index))

	local perName = ""
	local pet = PuppetData[data.petId]

	if pet then
		local templateId = pet.petPrototypeId

		perName = pg.getLocalizationText(PetPrototypeData[templateId].name)
	end

	ClientTextUtils.setText(descUBaseText, pg.getFormatText(pg.getGameString("ARK_CARNIVAL_PHOTOGRAPH_PUNK"), perName))

	if data.isFinish then
		photoUImage.sprite = pg.game.event:getPetPhoto(pet.petPrototypeId)

		button:TryChangePage("photostate", 1)
	else
		button:TryChangePage("photostate", 0)
	end

	function button.luaClick()
		if data.isFinish then
			pg.global.ui.tips:showTextTip(pg.getGameString("ARK_CARNIVAL_19"))
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("ARK_CARNIVAL_18"))
		end
	end
end

function ArkCarnComponent:refreshVotePets()
	local eventArkCarnData = EventArkCarnData[self.phaseId][1]

	if self.hasVoted or self.stageId > 1 then
		self.artist1UButton:TryChangePage("Votestate", 1)
		self.artist2UButton:TryChangePage("Votestate", 1)
		self.artist3UButton:TryChangePage("Votestate", 1)
		self.artist4UButton:TryChangePage("Votestate", 1)
	else
		self.artist1UButton:TryChangePage("IconName", 0)
		self.artist2UButton:TryChangePage("IconName", 1)
		self.artist3UButton:TryChangePage("IconName", 2)
		self.artist4UButton:TryChangePage("IconName", 3)
	end

	self:refreshVoteButton(self.artist1UButton, 1, eventArkCarnData.voteDrummerKey)
	self:refreshVoteButton(self.artist2UButton, 2, eventArkCarnData.voteDancerKey)
	self:refreshVoteButton(self.artist3UButton, 3, eventArkCarnData.voteAccompanyKey)
	self:refreshVoteButton(self.artist4UButton, 4, eventArkCarnData.voteAtmosKey)

	if self.curSelectStageId == 2 then
		local photoData = self.model:getCarnPhotoData(self.phaseId)

		if #photoData > 0 then
			self:refreshPhotoData(photoData)
		end
	end
end

function ArkCarnComponent:refreshVoteButton(button, index, voteKey)
	local objectReference = button:GetComponent("ObjectReference")
	local emoUImage = objectReference:GetRefValue("emoUImage")
	local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
	local percentageUBaseText = objectReference:GetRefValue("percentageUBaseText")
	local titleTextUBaseText = objectReference:GetRefValue("titleTextUBaseText")

	ClientTextUtils.setText(titleTextUBaseText, pg.getGameString("ARK_CARNIVAL_" .. index))

	local petId, voteNum = pg.game.event:getArkPartyVoteInfo(voteKey)

	if petId then
		local votePec = voteNum / pg.game.event:getArkPartyVoteSumNum(voteKey) * 100

		emoUImage.url = "$UI_Event_Arkparty_" .. petId .. ".png"

		ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(PuppetData[petId].name))
		ClientTextUtils.setText(percentageUBaseText, string.format("%.1f", votePec) .. "%")
	else
		button:TryChangePage("Votestate", 0)
	end

	if not self.hasVoted and self.stageId == 1 then
		function button.luaClick()
			local isFinish = self.stagelistUList.selectedItem.isFinish

			pg.global.ui:open(UIConst.UI_ID_ARK_PARTY_CHOICE, {
				phaseId = self.phaseId,
				stageId = self.stageId,
				activityId = self.eventId,
				isFinish = isFinish
			})
		end
	end
end

function ArkCarnComponent:refreshTask(groupId, taskOpen)
	local taskData = self.model:getCarnTaskData(self.eventId, groupId, taskOpen)

	if self.curSelectStageId == 1 and (self.hasVoted or self.stageId > 1) then
		local data = {}

		data.tIndex = 1

		table.insert(taskData, data)
	end

	self.tasklistUList:SetList(taskData)
end

function ArkCarnComponent:refreshStageTime()
	for _, tab in pairs(self.tabData) do
		if tab.stageId == self.stageId then
			LuaUIUtils.setCountDownTime(self.todayTimerCountDown, tab.endTime, UIConst.TimeType.Short)
		end
	end
end

function ArkCarnComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return ArkCarnComponent
