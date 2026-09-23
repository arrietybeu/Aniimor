-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\PetSaveComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientUtils = require("Utils.ClientUtils")
local GameEventData = require("Data.game_event_data")
local PetData = require("Data.pet_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local SysConfigData = require("Data.sys_config_data")
local UIComponent = require("Guis.Helper.UIComponent")
local PetSaveComponent = Class.LightClass("PetSaveComponent", UIComponent)
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")

PetSaveComponent.ROOT_SHOW_PAGE = "Show"
PetSaveComponent.FULLSCREEN_BTN_PAGE = "BtnType"

function PetSaveComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.timeUCountDown = self.objectReference:GetRefValue("timeUCountDown")
	self.selectUButton = self.objectReference:GetRefValue("selectUButton")
	self.btnManualUButton = self.objectReference:GetRefValue("btnManualUButton")
	self.petIconUImage = self.objectReference:GetRefValue("petIconUImage")
	self.nameUBaseText = self.objectReference:GetRefValue("nameUBaseText")
	self.infoUButton = self.objectReference:GetRefValue("infoUButton")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.detailsUBaseText = self.objectReference:GetRefValue("detailsUBaseText")
	self.tipsUBaseText = self.objectReference:GetRefValue("tipsUBaseText")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.videoPlayer = self.objectReference:GetRefValue("videoPlayer")
	self.btnSkip = self.objectReference:GetRefValue("btnSkip")
	self.btnFullScreen = self.objectReference:GetRefValue("btnFullScreen")
	self.btnVideo = self.objectReference:GetRefValue("btnVideo")
	self.txtBtnVideo = self.objectReference:GetRefValue("txtBtnVideo")
	self.txtBtnManual = self.objectReference:GetRefValue("txtBtnManual")
	self.txtBtnSkip = self.objectReference:GetRefValue("txtBtnSkip")
	self.txtBtnFullScreen = self.objectReference:GetRefValue("txtBtnFullScreen")

	ClientTextUtils.setText(self.txtBtnVideo, pg.getGameString("PET_SAVE_VIDEO_REPLAY"))
	ClientTextUtils.setText(self.txtBtnManual, pg.getGameString("PET_SAVE_ALBUM_NAME"))
	ClientTextUtils.setText(self.txtBtnSkip, pg.getGameString("PET_SAVE_VIDEO_SKIP"))
	ClientTextUtils.setText(self.txtBtnFullScreen, pg.getGameString("PET_SAVE_VIDEO_FULLSCREEN"))
end

function PetSaveComponent:onCtor(info)
	self.eventId = info.eventId
	self.week = info.week
end

function PetSaveComponent:initView()
	self:addListener()
	self:refreshPage()
end

function PetSaveComponent:addListener()
	function self.selectUButton.luaHover()
		if ClientActivityUtils.checkPetSaveFinish() and ClientActivityUtils.checkPetSaveChangeLimit() then
			self.hover = true

			self.rootUComponent:TryChangePage("State", 3)
		end
	end

	function self.selectUButton.luaUnhover()
		if self.hover == true then
			self.rootUComponent:TryChangePage("State", self.pageIndex)

			self.hover = false
		end
	end

	function self.selectUButton.luaClick()
		local isOpen = ClientActivityUtils.isEventOpen(self.eventId)

		if not isOpen then
			return
		end

		if not ClientActivityUtils.checkPetSaveFinish() then
			self:openSelectPanel()
		else
			local changeLimit = ClientActivityUtils.checkPetSaveChangeLimit()

			if changeLimit and self.pet then
				local cData = PetData[self.pet.templateId] or {}

				ClientUtils.showConfirmRaw(pg.getGameString("PET_SAVE_CHANGE_TITLE"), pg.getFormatText(pg.getGameString("PET_SAVE_CHANGE_DESC"), pg.getLocalizationText(cData.name), SysConfigData.PETSAVE_CHANGE_TIME - pg.me.activityPetSaveData.saveTimes, SysConfigData.PETSAVE_CHANGE_TIME), function()
					self:openSelectPanel()
				end)
			else
				pg.global.ui.tips:showTextTip(pg.getGameString("PET_SAVE_CHANGE_DONE"))
			end
		end
	end

	function self.btnManualUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_Event_PetSave_Manual, {
			weekIndex = self.week,
			eventId = self.eventId
		})
	end

	if self.btnSkip then
		function self.btnSkip.luaClick()
			self:_skipVideo()
		end
	end

	if self.btnFullScreen then
		function self.btnFullScreen.luaClick()
			self:_toggleFullScreen()
		end
	end

	if self.btnVideo then
		function self.btnVideo.luaClick()
			self:_playVideoFullScreen()
		end
	end
end

function PetSaveComponent:openSelectPanel()
	local info = {
		title = pg.getLocalizationText(GameEventData[self.eventId].name),
		confirmTitle = pg.getGameString("PET_SAVE_CONFIRM_TITLE"),
		confirmDesc = pg.getGameString("PET_SAVE_CONFIRM_DESC"),
		confirmCb = function()
			pg.me:reqActivityPetSave(self.eventId, pg.global.ui.petSelect.selectedPetId, function(code)
				pg.game.audio:playEvent("SFX_UI_Event_PetSave_SaveFinish")
				self:refreshPage()
				pg.global.ui:close(UIConst.UI_ID_PET_SELECT)
				facade:sendMsgToUI(MessageName.EVENT_PETSAVE_CHANGE, {})

				local id = 99000135
				local dialogueData = NpcDialogueData[id]

				if dialogueData then
					local param = {
						isDialogueGraph = true,
						intervalTime = 3,
						playType = 0,
						id = id,
						duration = 3 * #dialogueData
					}

					pg.global.ui:open(UIConst.UI_ID_BLACK_SCREEN, param)
				end
			end)
		end
	}

	pg.global.ui:open(UIConst.UI_ID_PET_SELECT, info)
end

function PetSaveComponent:refreshPage()
	ClientTextUtils.setText(self.tipsUBaseText, pg.getGameString("PET_SAVE_DESC"))

	local eventData = GameEventData[self.eventId]

	if not eventData then
		return
	end

	local isOpen = ClientActivityUtils.isEventOpen(self.eventId)
	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)

	if self.ctrl and self.ctrl.setEventTitle then
		self.ctrl:setEventTitle(self.eventTitleUContainer, isOpen and eventTimeCfg.tabEndDayTime or eventTimeCfg.tabStartDayTime, pg.getGameString("PET_SAVE_TITLE"), nil, nil, pg.getGameString("PET_SAVE_INTRODUCTION"))
	end

	if isOpen then
		if not ClientActivityUtils.checkPetSaveFinish() then
			self.pageIndex = 1
		else
			self.pageIndex = 2
			self.pet = pg.me.activityPetSaveData.savePetInfo

			if not self.pet then
				return
			end

			local cData = PetData[self.pet.templateId] or {}
			local petIcon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON, self.pet.label, self.pet.gender)

			self.petIconUImage.url = petIcon

			ClientTextUtils.setText(self.nameUBaseText, pg.getLocalizationText(cData.name))
			self.rootUComponent:TryChangePage("Type", self.pet.label or 0)
		end
	else
		self.pageIndex = 0
	end

	self.rootUComponent:TryChangePage("State", self.pageIndex)

	self.videoName = ClientActivityUtils.getPetSaveVideoName(self.week)

	self:_refreshVideoEntry()
	self:_tryAutoPlayVideo()
	self:refreshNodeRedDot()
end

function PetSaveComponent:_refreshVideoEntry()
	local hasVideo = not string.isNilOrEmpty(self.videoName)

	if self.btnVideo then
		self.btnVideo.gameObject:SetActiveEx(hasVideo)
	end

	if self.btnSkip then
		self.btnSkip.gameObject:SetActiveEx(hasVideo)
	end

	if self.btnFullScreen then
		self.btnFullScreen.gameObject:SetActiveEx(hasVideo)
	end
end

function PetSaveComponent:_tryAutoPlayVideo()
	if not self.videoPlayer or string.isNilOrEmpty(self.videoName) then
		return
	end

	local phase = GameEventData[self.eventId] and GameEventData[self.eventId].phase or 0
	local key = ClientConst.PrefKey.EventPetSaveVideoPlayed .. phase .. pg.me.uid

	if pg.global.prefsCacheUtils:getBool(key, false) then
		return
	end

	pg.global.prefsCacheUtils:setBool(key, true)
	self:_playVideo()
end

function PetSaveComponent:_playVideo()
	if not self.videoPlayer or string.isNilOrEmpty(self.videoName) then
		return
	end

	self.rootUComponent:TryChangePage(self.ROOT_SHOW_PAGE, 1)

	self.videoPlayer.resID = self.videoName

	function self.videoPlayer.luaLoopEnd()
		self:_onVideoEnd()
	end
end

function PetSaveComponent:_onVideoEnd()
	if self.videoPlayer then
		self.videoPlayer:StopVideo()

		self.videoPlayer.resID = ""
	end

	self.isFullScreen = false

	if self.btnFullScreen then
		self.btnFullScreen:TryChangePage(self.FULLSCREEN_BTN_PAGE, 0)
	end

	self:_setTabListVisible(true)
	self.rootUComponent:TryChangePage(self.ROOT_SHOW_PAGE, 0)
end

function PetSaveComponent:_skipVideo()
	self:_onVideoEnd()
end

function PetSaveComponent:_playVideoFullScreen()
	self:_playVideo()
	self:_setFullScreen(true)
end

function PetSaveComponent:_toggleFullScreen()
	self:_setFullScreen(not self.isFullScreen)
end

function PetSaveComponent:_setFullScreen(on)
	if not self.btnFullScreen then
		return
	end

	self.isFullScreen = on

	self.btnFullScreen:TryChangePage(self.FULLSCREEN_BTN_PAGE, on and 1 or 0)
	self:_setTabListVisible(not on)
end

function PetSaveComponent:_setTabListVisible(visible)
	local eventCtrl = self.ctrl and self.ctrl.ctrl
	local str = visible and "PET_SAVE_VIDEO_FULLSCREEN" or "PET_SAVE_VIDEO_RESTORE"

	ClientTextUtils.setText(self.txtBtnFullScreen, pg.getGameString(str))

	if eventCtrl and eventCtrl.setTabListVisible then
		eventCtrl:setTabListVisible(visible)
	end
end

function PetSaveComponent:refreshNodeRedDot()
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_PET_SAVE_SELECT, self.selectUButton, ClientActivityUtils.checkPetSavePoint(self.eventId), RedDotConst.RedDotStyle.POINT)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_PET_SAVE_REWARD, self.btnManualUButton, ClientActivityUtils.checkPetSaveRewardPoint(), RedDotConst.RedDotStyle.REWARD)
end

function PetSaveComponent:onEnterPlayEvent()
	pg.game.audio:playEvent("SFX_UI_Event_PetSave_MoveIn")
end

function PetSaveComponent:stopVideo()
	if not self.videoPlayer then
		return
	end

	self:_onVideoEnd()
end

function PetSaveComponent:onDestroy()
	if self.videoPlayer then
		self.videoPlayer:StopVideo()

		self.videoPlayer.luaLoopEnd = nil
	end

	UIComponent.onDestroy(self)
end

return PetSaveComponent
