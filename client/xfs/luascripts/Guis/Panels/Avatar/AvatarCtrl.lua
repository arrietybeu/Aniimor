-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Avatar\\AvatarCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local json = require("json")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local GlobalData = require("Core.Client.GlobalData")
local Time = require("Core.Common.Time")
local logger = require("Core.Log.LoggerManager").getLogger("Avatar")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientConst = require("Const.ClientConst")
local UICtrl = require("Guis.UICtrl")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AvatarShareService = require("Guis.Utils.AvatarShareService")
local FaceComponent = require("Guis.Panels.Avatar.Component.FaceComponent")
local HairComponent = require("Guis.Panels.Avatar.Component.HairComponent")
local MakeupComponent = require("Guis.Panels.Avatar.Component.MakeupComponent")
local BodyComponent = require("Guis.Panels.Avatar.Component.BodyComponent")
local SliderBubbleComponent = require("Guis.Panels.AppearanceV2.Component.Common.SliderBubbleComponent")
local DownloadProgressComponent = require("Guis.Panels.ResourceDownload.Component.DownloadProgressComponent")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local LuaCSConst = require("Common.Const.LuaCSConst")
local AvatarPresetData = require("Data.avatar_preset_data")
local Const = require("Common.Const.Const")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local FeedLogin = require("GameApp.Feed.FeedLogin")
local AvatarCtrl = Class.LightClass("AvatarCtrl", UICtrl)

AvatarCtrl.messages = {}

function AvatarCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isFeedTrial = info.isFeedTrial == true
	self.openData = info
	self.presetKey = info.presetKey
	self.avatarType = info.avatarType
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.isDesignMode = info.isDesignMode
	self._hairDesignBaselineRecorded = false

	if self.avatarScene then
		self.avatarScene.pauseAutoSave = false
	end

	if self.isDesignMode and self.avatarType == AvatarUtils.AVATAR_TYPE.HAIR and not self.openData.hairId and self.avatarScene then
		local entity = self.avatarScene:getCurEntity()

		if entity then
			self.openData.hairId = LuaUIUtils.tryGetEntityHairSuitId(entity)
		end
	end

	self.components = {}

	self:initComponents()
end

function AvatarCtrl:initComponents()
	self.components = {
		[AvatarUtils.AVATAR_TYPE.BODY] = BodyComponent.new(self),
		[AvatarUtils.AVATAR_TYPE.FACE] = FaceComponent.new(self),
		[AvatarUtils.AVATAR_TYPE.HAIR] = HairComponent.new(self),
		[AvatarUtils.AVATAR_TYPE.MAKEUP] = MakeupComponent.new(self)
	}
	self.bubbleComponent = SliderBubbleComponent.new(self, self.view.bubbleUComponent.transform, {
		type = 0
	})

	if self.view.downloadBtnUButton and pg.game.resourceDownload:isXPartEnabled() then
		self.downloadProgressComponent = DownloadProgressComponent.new(self, self.view.downloadBtnUButton.transform, {
			downloadArg = {
				KeyFrom = LuaCSConst.XPartConst.KeyRole2Novice,
				ToScene = LuaCSConst.XPartConst.SceneNovice
			},
			onDownloadComplete = function()
				pg.global.showBubbleMessageRaw(pg.getGameString("RESOURCE_ALREADY_DOWNLOADED"))
			end
		})
	end
end

function AvatarCtrl:addListener()
	local function onBackClicked()
		local _, page = self.view.rootUComponent:TryGetCurrentPage("Info")

		if page == 6 then
			self.view.rootUComponent:TryChangePage("Info", "Applique")

			return
		end

		self:closePanel()
	end

	self.view.backUButton.luaClick = onBackClicked

	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		onBackClicked()

		return false
	end, self.view.widget.gameObject, "avatarEscBackBind")

	function self.view.tabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUText = objectReference:GetRefValue("nameUText")

		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.text))
	end

	function self.view.tabUList.luaClick(button, data)
		self:refreshPreviewDecal()
		self:switchComponent(data.type)

		local showClothHide = data.type == AvatarUtils.AVATAR_TYPE.BODY

		if not showClothHide then
			self:resetClothesHide()
		end

		self.view.clothHideUButton:SetActive(showClothHide)
	end

	function self.view.firstSortUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local nameUText = objectReference:GetRefValue("nameUText")

		iconUImage.url = data.icon

		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.displayName))
	end

	function self.view.firstSortUList.luaClick(button, data)
		self:refreshPreviewDecal()

		self.firstSortData = data

		local component = self:getCurrentComponent()

		if component and component.onFirstSortSelected then
			component:onFirstSortSelected(data.key)
		end
	end

	function self.view.secondSortUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUText = objectReference:GetRefValue("nameUText")

		button:TryChangePage("State", data.state or 0)
		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.displayName))
	end

	function self.view.secondSortUList.luaClick(button, data)
		if not self.firstSortData or not data then
			return
		end

		local component = self:getCurrentComponent()

		if component and component.onSecondSortSelected then
			component:onSecondSortSelected(self.firstSortData.key, data.key)
		end
	end

	function self.view.firstDesignUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local icon = objectReference:GetRefValue("icon")
		local txtName = objectReference:GetRefValue("txtName")

		icon.url = data.icon

		ClientTextUtils.setText(txtName, pg.getLocalizationText(data.displayName))
	end

	function self.view.firstDesignUList.luaClick(button, data)
		self:refreshPreviewDecal()

		self.firstDesignData = data

		local component = self:getCurrentComponent()

		if component and component.onFirstDesignSelected then
			component:onFirstDesignSelected(data)
		end
	end

	function self.view.secondDesignUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUText = objectReference:GetRefValue("nameUText")

		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.displayName))
		button:TryChangePage("State", data.state or 0)
	end

	function self.view.secondDesignUList.luaClick(button, data)
		if not self.firstDesignData or not data then
			return
		end

		local component = self:getCurrentComponent()

		if component and component.onSecondDesignSelected then
			component:onSecondDesignSelected(self.firstDesignData.key, data.key)
		end
	end

	function self.view.listItemsUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderItemWithCountCheck(button, data, function(numText)
			local ownCount = ItemUtils.getItemCountById(pg.me, data.id)

			LuaUIUtils.renderConsumeText(numText, ownCount, data.num, 1, nil, nil, true)
		end, true)
	end

	function self.view.nextUButton.luaClick()
		self:onNextClicked()
	end

	function self.view.nextStepUButton.luaClick()
		self:onNextClicked()
	end

	function self.view.previewUButton.luaClick()
		self:refreshPreviewDecal()
		self:resetClothesHide()
		pg.global.ui:open(UIConst.UI_ID_AVATAR_PREVIEW, {
			presetKey = self.presetKey
		})
	end

	function self.view.undoUButton.luaClick()
		self:refreshPreviewDecal()
		self:resetClothesHide()
		pg.global.avatarMgr:Undo()

		local component = self:getCurrentComponent()

		if component and component.refreshComponent then
			component:refreshComponent()
		end

		self:refreshButtonState()
	end

	function self.view.redoUButton.luaClick()
		self:refreshPreviewDecal()
		self:resetClothesHide()
		pg.global.avatarMgr:Redo()

		local component = self:getCurrentComponent()

		if component and component.refreshComponent then
			component:refreshComponent()
		end

		self:refreshButtonState()
	end

	function self.view.resetUButton.luaClick()
		self:refreshPreviewDecal()
		self:resetClothesHide()

		local prefsKey = "resetWarn" .. GlobalData.UserName
		local lastTime = pg.global.prefsCacheUtils:getString(prefsKey)
		local curTime = LuaUIUtils.timeStampToUtcString(Time.secondCache)
		local showAlert = AvatarUtils.checkIsShowAlert(lastTime, curTime)

		if showAlert then
			local title = pg.getGameString("APPEARANCE_RESET")
			local desc = pg.getGameString("APPEARANCE_RESET_DESC")

			pg.global.showConfirmMsgRaw(title, desc, function()
				self:reset()
			end, nil, nil, nil, nil, {
				hint = true,
				hintCb = function(isSelected)
					if isSelected then
						pg.global.prefsCacheUtils:setString(prefsKey, LuaUIUtils.timeStampToUtcString(Time.secondCache))
					end
				end
			})
		else
			self:reset()
		end
	end

	function self.view.lookAtUButton.luaClick()
		local enable = not self.avatarScene:isCameraLookAtEnabled()

		self.avatarScene:switchCameraLookAt(enable)
	end

	if pg.me then
		self.view.uploadUButton.gameObject:SetActiveEx(true)
	else
		self.view.uploadUButton.gameObject:SetActiveEx(false)
	end

	self:hidePlatformLockFunc()

	function self.view.uploadUButton.luaClick()
		self:refreshPreviewDecal()
		self:resetClothesHide()

		if self.avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
			AvatarShareService.exportHair()
		else
			AvatarShareService.exportFace()
		end
	end

	local uploadText = self.view.uploadUButton.transform:Find("Text"):GetComponent("USDFText")

	ClientTextUtils.setText(uploadText, pg.getGameString("AVATAR_SAVE_CODE"))

	function self.view.downloadUButton.luaClick()
		self:refreshPreviewDecal()
		self:resetClothesHide()

		if self.avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
			AvatarShareService.openImportPanel(AvatarShareService.SHARE_TYPE.HAIR)
		else
			AvatarShareService.openImportPanel(AvatarShareService.SHARE_TYPE.FACE)
		end
	end

	local downloadText = self.view.downloadUButton.transform:Find("Btn/Text"):GetComponent("USDFText")

	ClientTextUtils.setText(downloadText, pg.getGameString("AVATAR_SHARE_CODE"))

	function self.view.clothHideUButton.luaClick()
		if self.clothHide then
			self.clothHide = false
			self.view.clothHideUButton.isSelected = self.clothHide

			self.avatarScene:showClothes(pg.game.avatar:getAvatarPresetData(self.presetKey).defaultSuit)
		else
			self.clothHide = true
			self.view.clothHideUButton.isSelected = self.clothHide

			self.avatarScene:hideClothes()
		end
	end

	function self.view.btnHairTieUButton.luaClick()
		AvatarUtils.toggleHairTie(self.avatarScene, self.view.btnHairTieUButton)
	end

	function self.view.uiUButton.luaClick()
		AvatarUtils.onHideUIClicked(self.view.uiUButton)
	end

	if not pg.me then
		self.view.backgroundSelectorUSelector.gameObject:SetActiveEx(false)
	else
		self.view.backgroundSelectorUSelector.gameObject:SetActiveEx(true)
		AvatarUtils.renderPhotographyStudioBackgroundSelector(self.view.backgroundSelectorUSelector, self.isDesignMode == nil)
	end
end

function AvatarCtrl:onDestroy()
	AvatarUtils.cancelHairTie()

	self.components = {}
	self.openData = nil

	self:refreshPreviewDecal()
	self:resetClothesHide()
	UICtrl.onDestroy(self)
end

function AvatarCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local objectReference = self.view.nextUButton:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("APPLY"))
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("APPEARANCE_CONSUME_TEXT"))
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)

	if self.openData.isDesignMode then
		self.view.rootUComponent:TryChangePage("buttonType", "Next")
	else
		self.view.rootUComponent:TryChangePage("buttonType", "Fitting")
	end

	if not pg.me then
		self.view.backgroundSelectorUSelector.gameObject:SetActiveEx(false)
	else
		self.view.backgroundSelectorUSelector.gameObject:SetActiveEx(true)
		self.view.leftLayoutBoxUWidget:SetNavGroupDefaultItem(self.view.backgroundSelectorUSelector)
	end
end

function AvatarCtrl:refreshConsoleBarState()
	self:refreshConsoleBarSubState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_PinchFace_CameraMove", true)

	local makeupComponent = self.components[AvatarUtils.AVATAR_TYPE.MAKEUP]

	if makeupComponent and self.avatarType == AvatarUtils.AVATAR_TYPE.MAKEUP then
		makeupComponent:refreshMakeupPageConsoleBarState()
	else
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_PinchFace_Choose", true)
	end
end

function AvatarCtrl:refreshConsoleBarSubState()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local showCameraControl = true

	if CS.XGUI.Navigation.NavManager.Instance and CS.XGUI.Navigation.NavManager.Instance:GetCurrentFocusedItemActionPath() == "Raw/GamepadLeftTrigger" then
		showCameraControl = false
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_PinchFace_CameraZoom", showCameraControl)
end

function AvatarCtrl:onShow()
	self:refreshPage()

	if self.openData.isDesignMode and self.avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
		if pg.global.avatarMgr and pg.global.avatarMgr.globalStack then
			pg.global.avatarMgr.globalStack:Clear()
		end

		self._hairDesignBaselineRecorded = false

		TimerManager.addNextFrameCb(function()
			self:finalizeHairDesignBaseline()
		end)
	end

	self:syncLookAtButton()

	if self.downloadProgressComponent then
		self.downloadProgressComponent:startRefresh()
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		function self.focusChangedCb()
			self:refreshConsoleBarSubState()
		end

		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("UI_PinchFaceFocusChanged", self.focusChangedCb)
	end
end

function AvatarCtrl:syncLookAtButton()
	if not self.view or not self.view.lookAtUButton or not self.avatarScene then
		return
	end

	local enable = self.avatarScene:isCameraLookAtEnabled()

	self.view.lookAtUButton.isSelected = enable

	if enable then
		self.avatarScene:switchCameraLookAt(true)
	end
end

function AvatarCtrl:onHide()
	if self.openData and self.openData.isDesignMode and self.openData.avatarType == AvatarUtils.AVATAR_TYPE.HAIR and self.avatarScene then
		self.avatarScene.hasPendingHairDesignChange = self.avatarScene.useAvatarHairCustomDataCache and self.avatarScene:hasAvatarHairConfigChanged()
		self.avatarScene.pendingHairDesignHairId = self.openData.hairId
	end

	if self.downloadProgressComponent then
		self.downloadProgressComponent:stopRefresh()
	end

	for _, component in pairs(self.components) do
		component:onExitPage()
	end

	if CS.XGUI.Navigation.NavManager.Instance and self.focusChangedCb then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("UI_PinchFaceFocusChanged")

		self.focusChangedCb = nil
	end
end

function AvatarCtrl:onNextClicked()
	if self.isFeedTrial then
		self:finishFeedTrial()

		return
	end

	if not self.openData.isDesignMode and pg.game.resourceDownload and pg.game.resourceDownload:isXPartEnabled() then
		local downloadArg = {
			KeyFrom = LuaCSConst.XPartConst.KeyRole2Novice,
			ToScene = LuaCSConst.XPartConst.SceneNovice
		}
		local downloadDetails = pg.game.resourceDownload:getPartDownloadDetailsByArg(downloadArg)

		for _, detail in ipairs(downloadDetails or EMPTY_TABLE) do
			if detail and detail.needDownload then
				pg.global.showBubbleMessageRaw(pg.getGameString("RESOURCE_NOT_DOWNLOADED"))

				return
			end
		end
	end

	self:refreshPreviewDecal()
	self:resetClothesHide()

	if self.openData.isDesignMode then
		self:finishDesign()
	else
		self:checkServerStart()
	end
end

function AvatarCtrl:finalizeHairDesignBaseline()
	if self._hairDesignBaselineRecorded or not self.openData or not self.openData.isDesignMode or self.openData.avatarType ~= AvatarUtils.AVATAR_TYPE.HAIR or not self.avatarScene then
		return
	end

	local hasPendingChange = self.avatarScene.hasPendingHairDesignChange == true and self.avatarScene.pendingHairDesignHairId == self.openData.hairId and self.avatarScene.useAvatarHairCustomDataCache and self.avatarScene:hasAvatarHairConfigChanged()

	if hasPendingChange then
		self._hairDesignBaselineRecorded = true

		self:refreshButtonState()

		return
	end

	self.avatarScene:recordInitialAvatarConfig()

	self.avatarScene.hasPendingHairDesignChange = false
	self.avatarScene.pendingHairDesignHairId = self.openData.hairId
	self._hairDesignBaselineRecorded = true

	self:refreshButtonState()
end

function AvatarCtrl:finishDesign()
	if self.openData.avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
		local hasChanged = false

		if self.avatarScene and self.avatarScene.useAvatarHairCustomDataCache then
			hasChanged = self.avatarScene:hasAvatarHairConfigChanged()
		end

		if not hasChanged then
			pg.global.ui:close(UIConst.UI_ID_AVATAR)

			return
		end

		local consumes = Utils.calculateWsHairConsume()

		for itemId, itemNum in pairs(consumes) do
			local ownNum = ItemUtils.getItemCountById(pg.me, itemId)

			if ownNum < itemNum then
				pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_PAY_FAIL"), 3)

				return
			end
		end

		self.components[AvatarUtils.AVATAR_TYPE.HAIR]:saveHairPreset()
	elseif self.openData.avatarType == AvatarUtils.AVATAR_TYPE.FACE then
		local hasChanged = true
		local hasMakeUpChanged = true

		if self.avatarScene and self.avatarScene.useAvatarCustomDataCache then
			hasChanged = self.avatarScene:hasAvatarConfigChanged()
			hasMakeUpChanged = self.avatarScene:hasAvatarMakeUpConfigChanged()
		end

		if not hasChanged and hasMakeUpChanged then
			local avatarConfig = AvatarUtils.getCustomDataStringForSave()
			local suitId = pg.global.avatarMgr.avatarMakeup:GetMakeupSuitId()

			pg.me:serverMsg("RPC_CS_SetAvatarMakeupConfig", compressToStr(avatarConfig), suitId, function(res)
				if res then
					pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_SAVE_SUCCESS"), 3)
				end
			end)
			pg.global.ui:close(UIConst.UI_ID_AVATAR)

			return
		end

		if not hasChanged and not hasMakeUpChanged then
			pg.global.ui:close(UIConst.UI_ID_AVATAR)

			return
		end

		local consumes = Utils.calculateWsAvatarConfigConsume()
		local consumeList = {}

		for k, v in pairs(consumes) do
			local ownNum = ItemUtils.getItemCountById(pg.me, k)

			if ownNum < v then
				pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_PAY_FAIL"), 3)

				return
			end

			table.insert(consumeList, {
				k,
				v
			})
		end

		pg.global.ui.commonUseConfirm:open({
			title = pg.getGameString("SAVE_PRESET"),
			tipTop = pg.getGameString("UNLOCK_DESC"),
			data = consumeList,
			confirmCb = function()
				local avatarConfig = AvatarUtils.getCustomDataStringForSave()
				local suitId = pg.global.avatarMgr.avatarMakeup:GetMakeupSuitId()

				pg.me:serverMsg("RPC_CS_SetAvatarConfig", compressToStr(avatarConfig), suitId, function(res)
					if res then
						pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_SAVE_SUCCESS"), 3)
					end
				end)
				pg.global.ui:close(UIConst.UI_ID_AVATAR)
			end,
			cancelCb = function()
				return
			end
		})
	end
end

function AvatarCtrl:checkServerStart()
	if ClientUtils.isServerStartTimeReached() then
		self:finishPinchFace()

		return
	else
		local function getServerStartRemainTimeText()
			local startTimestamp = ClientUtils.getServerStartTimestamp()
			local now = Time.getSecond()
			local remainTime = math.max(0, (startTimestamp or now) - now)

			return LuaUIUtils.getCountDownString(remainTime, UIConst.TimeType.Full, true)
		end

		pg.global.ui.commonConfirm:open({
			tickInterval = 1,
			title = pg.getGameString("SERVER_START_TIP_TITLE"),
			desc = string.format(pg.getGameString("SERVER_START_TIP_DESC"), getServerStartRemainTimeText()),
			okCb = function()
				local ClientRepo = require("Core.Client.ClientRepo")

				ClientRepo.loginAgent:logoutService()
				appFacade.QuitGame()
			end,
			cancelCb = function()
				return
			end,
			extraInfo = {
				okBtnDesc = pg.getFormatText("SERVER_START_TIP_QUIT"),
				cancelBtnDesc = pg.getFormatText("SERVER_START_TIP_BACK")
			},
			tickFunc = function()
				pg.global.ui.commonConfirm:setDesc(string.format(pg.getGameString("SERVER_START_TIP_DESC"), getServerStartRemainTimeText()))
			end
		})
	end
end

function AvatarCtrl:finishPinchFace()
	pg.global.showConfirmMsgRaw(pg.getGameString("FINISH_CREATE_ROLE"), pg.getGameString("FINISH_CREATE_ROLE_TIP"), function()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_CREATE_ROLE_TIMELINE) then
			local avatarCreateRoleScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_CREATE_ROLE_SCENE)

			if avatarCreateRoleScene then
				avatarCreateRoleScene:releaseForSnapshot()
			end

			pg.game.camera:resetUICameraBlendStack()
			pg.global.ui:close(UIConst.UI_ID_CREATE_ROLE_TIMELINE)
		end

		self.avatarScene:setCurEntityRot(0, 0.5)
		self.avatarScene:setAvatarCameraModeCloseHead()
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
		pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.PRESET_SNAPSHOT)
		TimerManager.addTimer(self.avatarScene.cameraDuration, function()
			local sizeDelta = Vector2.New(Screen.height, Screen.height)
			local position = Vector2.New(Screen.width / 2 - sizeDelta.x / 2, Screen.height / 2 - sizeDelta.y / 2)

			Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, _, success, imageKey)
				pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
				pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

				if not success then
					return
				end

				pg.game.avatar:recordHairSnapshotKey(imageKey)
				pg.global.mobileCameraMgr:DestroyCapturedSprite(sprite)

				if not pg.me then
					pg.global.ui.avatarLoading:open()
				end

				self:startTimer(function()
					self:onAdditiveSceneLoaded(function()
						local arg = {
							KeyFrom = LuaCSConst.XPartConst.KeyRole2Novice,
							ToScene = LuaCSConst.XPartConst.SceneNovice
						}
						local ClientRepo = require("Core.Client.ClientRepo")

						ClientRepo.loginAgent:loginImp(arg)
					end)
				end, 1.3)
			end, position, sizeDelta, 3, false, true)
		end)
	end, false, function()
		return
	end)
end

function AvatarCtrl:onAdditiveSceneLoaded(callback)
	local entity = self.avatarScene:getCurEntity()
	local avatarConfig = AvatarUtils.getCustomDataStringForSave()

	GlobalData.AvatarConfig = compressToStr(avatarConfig)
	GlobalData.AvatarPresetKey = self.presetKey
	GlobalData.TemplateId = pg.game.avatar:getTemplateId(entity)

	pg.game.avatar:recordHairCustomData()
	logger:info("@sxy onAdditiveSceneLoaded avatarConfig", GlobalData.AvatarConfig)
	logger:info("@sxy onAdditiveSceneLoaded avatarPresetKey && templateId", GlobalData.AvatarPresetKey, GlobalData.TemplateId)
	logger:info("@sxy onAdditiveSceneLoaded hair selection", inspect(pg.game.avatar.hairSelection))
	logger:info("@sxy onAdditiveSceneLoaded hair customData is empty", Utils.isEmptyTable(pg.game.avatar.hairCustomData))
	entity.eModel.modelShaderView:HideAllHighLight()

	local presetData = pg.game.avatar:getAvatarPresetData(self.presetKey) or {}
	local body = presetData.body or 0
	local fusionData = pg.game.avatar:getFusionData()
	local faceType = fusionData and 2 or 1
	local rolePreset

	if fusionData then
		local p1 = fusionData.slotUp or 0
		local p2 = fusionData.slotBotLeft or 0
		local p3 = fusionData.slotBotRight or 0

		rolePreset = {
			p1,
			p2,
			p3
		}
	else
		rolePreset = {
			self.presetKey
		}
	end

	local useFusionCount = pg.game.avatar.fusionUseCount or 0
	local startTime = pg.game.avatar.createRoleStartTime or Time.realSecondCache
	local createTime = math.max(0, Time.realSecondCache - startTime)
	local createRoleSuccessParams = {
		role_gender = body,
		role_face_type = faceType,
		use_fusion_face = useFusionCount,
		create_time = createTime,
		role_preset = table.concat(rolePreset, ",")
	}

	LuaUIUtils.sendCustomLog(Const.BILogName.CREATE_ROLE_SUCCESS, createRoleSuccessParams)
	pg.global.sdkManager:trackWeGame(Const.BILogName.CREATE_ROLE_SUCCESS, "success", json.encode(createRoleSuccessParams))

	pg.game.avatar.fusionUseCount = nil
	pg.game.avatar.createRoleStartTime = nil

	pg.global.ui:closeAllUIPanel({
		[UIConst.UI_ID_TIPS] = true,
		[UIConst.UI_ID_AVATAR_LOADING] = true,
		[UIConst.UI_ID_TOPLOGO] = true
	})
	csSDKManager.PatchFlowSDKLog(20011, "LoginCreateRole", "", "")

	if callback then
		callback()
	end
end

function AvatarCtrl:switchComponent(avatarType)
	for type, component in pairs(self.components) do
		if type ~= avatarType then
			component:onExitPage()
		else
			self.avatarType = avatarType

			self.view.uploadUButton.gameObject:SetActiveEx(true)
			self.view.downloadUButton.gameObject:SetActiveEx(true)

			if pg.me then
				self.view.uploadUButton.gameObject:SetActiveEx(true)
			else
				self.view.uploadUButton.gameObject:SetActiveEx(false)
			end

			component:onEnterPage()
		end
	end

	self:hidePlatformLockFunc()
	self:refreshButtonState()
	self.view.consumeUWidget.gameObject:SetActiveEx(self.openData.isDesignMode)
end

function AvatarCtrl:hidePlatformLockFunc()
	local _h = AvatarCtrl._platformHooks

	if _h and _h.shouldShowAvatarShareButtons and _h.shouldShowAvatarShareButtons(self) == false then
		self.view.uploadUButton.gameObject:SetActiveEx(false)
		self.view.downloadUButton.gameObject:SetActiveEx(false)
	end
end

function AvatarCtrl:getCurrentComponent()
	return self.components[self.avatarType]
end

function AvatarCtrl:refreshPage()
	if self.openData.isDesignMode then
		self.view.consumeUWidget.gameObject:SetActiveEx(true)

		local consumes = {}

		if self.avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
			self.view.rootUComponent:TryChangePage("tabType", "design")
			self.view.tabUList:SetActiveFastest(false)
			self:switchComponent(self.avatarType)

			local firstDesignList = self.model:getHairFirstDesignList()

			self.view.firstDesignUList:SetList(firstDesignList)

			for index, designInfo in ipairs(firstDesignList) do
				if designInfo.key == self.openData.designType then
					local res, btn = self.view.firstDesignUList:TryGetChildAt(index - 1)

					if res then
						btn:OnClickSimulate()
					end
				end
			end

			consumes = Utils.calculateWsHairConsume()

			self.view.clothHideUButton:SetActive(false)
		elseif self.avatarType == AvatarUtils.AVATAR_TYPE.FACE then
			self.view.rootUComponent:TryChangePage("tabType", "parts")
			self:refreshTabList()

			consumes = Utils.calculateWsAvatarConfigConsume()
		end

		self:refreshConsumeList(consumes)
	else
		self.view.consumeUWidget.gameObject:SetActiveEx(false)
		self.view.rootUComponent:TryChangePage("tabType", "parts")
		self:refreshTabList()
	end

	if not self.openData.isDesignMode or self.avatarType ~= AvatarUtils.AVATAR_TYPE.HAIR then
		self:refreshButtonState()
	end
end

function AvatarCtrl:refreshNextButton()
	if self.openData.isDesignMode then
		-- block empty
	else
		self.view.nextUButton:SetActiveFastest(true)
	end
end

function AvatarCtrl:refreshConsumeList(consumes)
	local consumeList = {}
	local t = {}

	for k, v in pairs(consumes) do
		table.insert(consumeList, {
			id = k,
			num = v,
			owned = ItemUtils.getItemCountById(pg.me, k)
		})
		table.insert(t, k)
	end

	self.view.listItemsUList:SetList(consumeList)
end

function AvatarCtrl:refreshTabList()
	local tabList = {}

	table.insert(tabList, {
		type = AvatarUtils.AVATAR_TYPE.FACE,
		text = pg.getGameString("CREATE_PLAYER_FACE")
	})
	table.insert(tabList, {
		type = AvatarUtils.AVATAR_TYPE.MAKEUP,
		text = pg.getGameString("CREATE_PLAYER_MAKEUP")
	})

	if not self.openData.isDesignMode then
		table.insert(tabList, {
			type = AvatarUtils.AVATAR_TYPE.HAIR,
			text = pg.getGameString("CREATE_PLAYER_HAIR")
		})
	end

	table.insert(tabList, {
		type = AvatarUtils.AVATAR_TYPE.BODY,
		text = pg.getGameString("CREATE_PLAYER_BODY")
	})
	self.view.tabUList:SetList(tabList)

	local tabRes, tabBtn = self.view.tabUList:TryGetChildAt(0)

	if tabRes then
		tabBtn:OnClickSimulate()
	end
end

function AvatarCtrl:refreshButtonState()
	if not self.view then
		return
	end

	local globalStack = pg.global.avatarMgr.globalStack

	self.view.undoUButton.interactable = globalStack:CanBackward()
	self.view.redoUButton.interactable = globalStack:CanForward()
	self.view.resetUButton.interactable = globalStack:CanBackward()

	self:refreshNextButton()

	if self.openData.isDesignMode then
		local hasChanged = false

		if self.openData.avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
			hasChanged = self.avatarScene:hasAvatarHairConfigChanged()
		elseif self.openData.avatarType == AvatarUtils.AVATAR_TYPE.FACE then
			hasChanged = self.avatarScene:hasAvatarConfigChanged()
		end

		self.view.consumeUWidget:SetActiveFastest(hasChanged)
	end
end

function AvatarCtrl:finishFeedTrial()
	pg.global.ui.commonConfirm:open({
		desc = "试玩捏脸结束，是否正式进入游戏游玩？",
		title = pg.getGameString("SERVER_START_TIP_TITLE"),
		okCb = function()
			self:confirmFinishFeedTrial()
		end
	})
end

function AvatarCtrl:confirmFinishFeedTrial()
	AvatarUtils.saveCustomDataToDisk(self.presetKey)
	pg.global.ui.avatarLoading:open()

	if not FeedLogin.login(true) then
		pg.global.ui.avatarLoading:close()
	end
end

function AvatarCtrl:checkSkipBgmAttenuation()
	return true
end

function AvatarCtrl:resetClothesHide()
	if self.clothHide then
		self.clothHide = false
		self.view.clothHideUButton.isSelected = self.clothHide

		self.avatarScene:showClothes(pg.game.avatar:getAvatarPresetData(self.presetKey).defaultSuit)
	end
end

function AvatarCtrl:onVisibleChange(visible)
	if self.avatarScene and self.avatarScene.expire then
		return
	end

	if visible then
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})

		local component = self:getCurrentComponent()
		local skipRefresh = component and component.skipRefreshOnVisible and component:skipRefreshOnVisible()

		if component and component.refreshComponent and not skipRefresh then
			component:refreshComponent()
		end

		self:finalizeHairDesignBaseline()

		if self.bubbleComponent then
			self.bubbleComponent:initHide()
		end

		self:syncLookAtButton()
	else
		self.avatarScene:unRegisterGesture(self.uid)
	end
end

function AvatarCtrl:reset()
	pg.global.avatarMgr:Reset()

	local component = self:getCurrentComponent()

	if component and component.refreshComponent then
		component:refreshComponent()
	end

	self:refreshButtonState()
end

function AvatarCtrl:refreshPreviewDecal()
	pg.global.avatarMgr.avatarMakeup:ClearPreviewDecal()
end

return AvatarCtrl
