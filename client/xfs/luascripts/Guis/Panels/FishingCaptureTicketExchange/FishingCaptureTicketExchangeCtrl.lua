-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureTicketExchange\\FishingCaptureTicketExchangeCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local PetData = require("Data.pet_data")
local ItemSourceData = require("Data.item_source_data")
local FishingCaptureTicketExchangeModel = require("Guis.Panels.FishingCaptureTicketExchange.FishingCaptureTicketExchangeModel")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local HotkeyConst = require("Const.HotkeyConst")
local logger = require("Core.Log.LoggerManager").getLogger("FishingCaptureTicketExchangeCtrl")
local BUILD_ANIMATION_DURATION = 3
local FishingCaptureTicketExchangeCtrl = Class.LightClass("FishingCaptureTicketExchangeCtrl", UICtrl)

FishingCaptureTicketExchangeCtrl.messages = {
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onMoneyCountChange",
		true
	},
	[MessageName.EVENT_CUR_PAGE_REFRESH] = {
		"onActivityDataChanged",
		true
	},
	[MessageName.UI_ON_CLOSE] = {
		"onUIClose",
		true
	}
}

function FishingCaptureTicketExchangeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.isDestroyed = false
	self.buildPending = false
	self.buildAnimPlaying = false
	self.buildAnimTimerId = nil
	self.seasonHelpCurrentIndex = nil
	self.seasonHelpInitialized = false
	self.seasonHelpDragging = false
	self.selectedCubeType = info and info.cubeType or FishingCaptureConst.CubeType.LEGEND

	self.model:setInfo(info)
	self:_validateSelectedCubeType()
	self:_loadSelectedCube()
	self:refreshView()
	self:_resetBuildAnimation()
	self:_playOpenAnimation()

	self._lastVisible = nil
end

function FishingCaptureTicketExchangeCtrl:onUIClose(uid)
	if not self._waitItemObtainClose or uid ~= UIConst.UI_ID_COMMON_OBTAIN then
		return
	end

	self._waitItemObtainClose = false

	local ballType = 0
	local pageData = self:getCurrentPageData()

	if pageData and pageData.actionState == FishingCaptureTicketExchangeModel.BuildState.Exhausted then
		ballType = 1
	end

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("BallType", ballType)
		self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	local cubeContainer = self.selectedCubeType == FishingCaptureConst.CubeType.LEGEND and self.view.ball1UContainer or self.view.ball2UContainer

	if cubeContainer and cubeContainer.content and not IsNil(cubeContainer.content) then
		cubeContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	self:_unlockBuildAnimationInput()
end

function FishingCaptureTicketExchangeCtrl:_playOpenAnimation()
	if self.view.rootUComponent then
		self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function FishingCaptureTicketExchangeCtrl:_resetBuildAnimation()
	local pageData = self:getCurrentPageData()
	local isSeasonExhausted = self.selectedCubeType == FishingCaptureConst.CubeType.SEASON and pageData and pageData.actionState == FishingCaptureTicketExchangeModel.BuildState.Exhausted

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("BallType", isSeasonExhausted and 1 or 0)
	end
end

function FishingCaptureTicketExchangeCtrl:_playBuildAnimation()
	if self.view.rootUComponent then
		self._waitItemObtainClose = true

		self.view.rootUComponent:TryChangePage("BallType", 1)
		self:_lockBuildAnimationInput()
	end
end

function FishingCaptureTicketExchangeCtrl:_lockBuildAnimationInput()
	self.buildAnimPlaying = true

	self:killTimer(self.buildAnimTimerId)

	self.buildAnimTimerId = self:startTimer(function()
		self:_unlockBuildAnimationInput()
	end, BUILD_ANIMATION_DURATION)
end

function FishingCaptureTicketExchangeCtrl:_unlockBuildAnimationInput()
	self:killTimer(self.buildAnimTimerId)

	self.buildAnimTimerId = nil
	self.buildAnimPlaying = false
end

function FishingCaptureTicketExchangeCtrl:_isBuildAnimationPlaying()
	return self.buildAnimPlaying == true
end

function FishingCaptureTicketExchangeCtrl:checkCommonQuit()
	if self:_isBuildAnimationPlaying() then
		return false
	end

	return UICtrl.checkCommonQuit(self)
end

function FishingCaptureTicketExchangeCtrl:onShow()
	UICtrl.onShow(self)
	self:_refreshCubeBuildBgm()
end

function FishingCaptureTicketExchangeCtrl:onHide()
	UICtrl.onHide(self)
	self:_stopCubeBuildBgm()
end

function FishingCaptureTicketExchangeCtrl:_refreshCubeBuildBgm()
	local pageData = self:getCurrentPageData()

	if pageData and (pageData.craftedCount or 0) >= 1 then
		pg.game.audio:playBgm(FishingCaptureConst.BGM_CUBE_BUILD_UI, AudioConst.BgmPriority.FishingCaptureCubeUI)
	else
		self:_stopCubeBuildBgm()
	end
end

function FishingCaptureTicketExchangeCtrl:_stopCubeBuildBgm()
	pg.game.audio:stopBgm(AudioConst.BgmPriority.FishingCaptureCubeUI)
end

function FishingCaptureTicketExchangeCtrl:onDestroy()
	self:_stopCubeBuildBgm()
	self:killTimer(self.buildAnimTimerId)

	self.buildAnimTimerId = nil
	self.buildAnimPlaying = false
	self._waitItemObtainClose = nil
	self.isDestroyed = true

	if self.helpTipULoopList and self.helpTipScrollEndCallback then
		self.helpTipULoopList:UnRegisterToScrollEndEvent(self.helpTipScrollEndCallback)
	end

	self.helpTipULoopList = nil
	self.listPointUList = nil
	self.scrollInfoListenersInitialized = nil
	self.helpTipScrollEndCallback = nil

	UICtrl.onDestroy(self)
end

function FishingCaptureTicketExchangeCtrl:onVisibleChange(visible)
	if visible and self._lastVisible == false then
		self:refreshDataAndView()
	end

	self._lastVisible = visible
end

function FishingCaptureTicketExchangeCtrl:addListener()
	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			if self:_isBuildAnimationPlaying() then
				return
			end

			self:dismiss()
		end

		self:bindCloseButton(self.view.btnBackUButton)
	end

	if self.view.btnGainUButton then
		function self.view.btnGainUButton.luaClick()
			if self:_isBuildAnimationPlaying() then
				return
			end

			self:onPetalSourceClick()
		end
	end

	if self.view.btnCreateUButton then
		function self.view.btnCreateUButton.luaClick()
			self:onBuildClick()
		end
	end
end

function FishingCaptureTicketExchangeCtrl:_switchSeasonHelpPage(offset)
	local data = self.seasonHelpData
	local count = data and #data or 0

	if count <= 0 then
		return
	end

	local currentIndex = self.seasonHelpCurrentIndex or 1
	local nextIndex = math.max(1, math.min(count, currentIndex + offset))

	if nextIndex == currentIndex then
		return
	end

	self:_selectSeasonHelpPage(nextIndex)
end

function FishingCaptureTicketExchangeCtrl:_validateSelectedCubeType()
	local data = self.model:getData()
	local CubeType = FishingCaptureConst.CubeType

	if self.selectedCubeType ~= CubeType.LEGEND and self.selectedCubeType ~= CubeType.SEASON then
		self.selectedCubeType = CubeType.LEGEND
	end

	if self.selectedCubeType == CubeType.SEASON and data.stage < FishingCaptureConst.ActivityStage.WindkissCompanion then
		self.selectedCubeType = CubeType.LEGEND
	end
end

function FishingCaptureTicketExchangeCtrl:_loadSelectedCube()
	local cubeContainer = self.selectedCubeType == FishingCaptureConst.CubeType.LEGEND and self.view.ball1UContainer or self.view.ball2UContainer

	if cubeContainer then
		cubeContainer:LoadDefaultUrlManually(function(content)
			if self.isDestroyed or IsNil(content) then
				return
			end

			content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end)
	end
end

function FishingCaptureTicketExchangeCtrl:refreshDataAndView()
	self.model:refreshData()
	self:_validateSelectedCubeType()
	self:refreshView()
end

function FishingCaptureTicketExchangeCtrl:refreshView()
	local pageData = self:getCurrentPageData()

	if not pageData then
		return
	end

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("State", pageData.cubeType - 1)
	end

	self:_refreshCurrencyList()
	self:_refreshCubeInfo(pageData)
	self:_refreshScrollInfo(pageData)
	self:_refreshBuildButton(pageData)
end

function FishingCaptureTicketExchangeCtrl:_refreshCurrencyList()
	local data = self.model:getData()
	local petalItemId = data and data.petalItem and data.petalItem.id

	if not self.view.listCurrencyUList or not petalItemId then
		return
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, {
		petalItemId
	})
end

function FishingCaptureTicketExchangeCtrl:getCurrentPageData(data)
	data = data or self.model:getData()

	return data and data.cubePages and data.cubePages[self.selectedCubeType]
end

function FishingCaptureTicketExchangeCtrl:_refreshScrollInfo(pageData)
	if not self.view.scrollRectUScrollRect or not self.view.scrollRectUScrollRect.content then
		return
	end

	local objectReference = self.view.scrollRectUScrollRect.content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local textDetailUBaseText = objectReference:GetRefValue("textDetailUBaseText")
	local petTitle = objectReference:GetRefValue("petTitle")
	local petNameTxt = objectReference:GetRefValue("petNameTxt")
	local labelBossTxt = objectReference:GetRefValue("labelBossTxt")
	local elementUButton = objectReference:GetRefValue("elementUButton")
	local rainbowUWidget = objectReference:GetRefValue("rainbowUWidget")
	local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	local seasonPetTitle = objectReference:GetRefValue("seasonPetTitle")
	local helpTipULoopList = objectReference:GetRefValue("helpTipULoopList")
	local listPointUList = objectReference:GetRefValue("listPointUList")
	local qualityImg = objectReference:GetRefValue("qualityImg")

	self.helpTipULoopList = helpTipULoopList
	self.listPointUList = listPointUList
	self.qualityImg = qualityImg
	self.rainbowUWidget = rainbowUWidget

	local cubeItem = pageData.cubeItem

	if textDetailUBaseText and cubeItem.descId then
		ClientTextUtils.setText(textDetailUBaseText, pg.getLocalizationText(cubeItem.descId))
	end

	if petTitle then
		ClientTextUtils.setText(petTitle, pg.getGameString("FC_CUBE_EXCLUSIVE_PET"))
	end

	if seasonPetTitle then
		ClientTextUtils.setText(seasonPetTitle, pg.getGameString("FC_CUBE_EXCLUSIVE_SEA"))
	end

	if not self.scrollInfoListenersInitialized then
		self.scrollInfoListenersInitialized = true

		if btnInfoUButton then
			function btnInfoUButton.luaClick()
				if self:_isBuildAnimationPlaying() then
					return
				end

				self:onIrisDetailClick()
			end
		end

		if helpTipULoopList then
			function helpTipULoopList.luaRenderItem(button, index, data)
				self:_renderSeasonHelpItem(button, index, data)
			end

			function helpTipULoopList.luaInitDrag()
				self.seasonHelpDragging = false
			end

			function helpTipULoopList.luaBeginDrag()
				self.seasonHelpDragging = true
			end

			function helpTipULoopList.luaEndDrag()
				self.seasonHelpDragging = false
			end

			function helpTipULoopList.luaClick()
				if self.seasonHelpDragging or self:_isBuildAnimationPlaying() then
					return
				end

				self:onSeasonHelpClick()
			end

			function self.helpTipScrollEndCallback()
				self:_onSeasonHelpScrollEnd()
			end

			helpTipULoopList:RegisterToScrollEndEvent(self.helpTipScrollEndCallback)
			self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftTrigger, function()
				self:_switchSeasonHelpPage(-1)
			end, helpTipULoopList.gameObject)
			self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightTrigger, function()
				self:_switchSeasonHelpPage(1)
			end, helpTipULoopList.gameObject)

			if self.view.titleKeyHotKeyContent then
				self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadSelect, function()
					self:onSeasonHelpClick()
				end, self.view.titleKeyHotKeyContent.gameObject)
			end
		end

		if listPointUList then
			function listPointUList.luaSelectedChanged(uList, isSelected)
				if not isSelected or self:_isBuildAnimationPlaying() then
					return
				end

				local data = uList.selectedItem

				if data then
					self:_selectSeasonHelpPage(data.pageIndex)
				end
			end
		end
	end

	if pageData.cubeType == FishingCaptureConst.CubeType.SEASON then
		self:_refreshSeasonHelp()

		return
	end

	local petConfig = pageData.keyPetType and PetData[pageData.keyPetType]

	if not petConfig then
		return
	end

	if petNameTxt then
		local petNameId = LuaUIUtils.getPetNameWithIdOrTmpId(pageData.keyPetType)

		if petNameId then
			ClientTextUtils.setText(petNameTxt, pg.getLocalizationText(petNameId))
		end
	end

	if labelBossTxt then
		ClientTextUtils.setText(labelBossTxt, pg.getGameString("PET_STAGE_TXT_" .. petConfig.stage))
	end

	if elementUButton then
		local _, elementNames = LuaUIUtils.getElementInfo(petConfig.elementType)
		local element = elementNames and elementNames[1] and elementNames[1].element

		if element then
			LuaUIUtils.setElementButtonNew(elementUButton, element)
		end
	end
end

function FishingCaptureTicketExchangeCtrl:_refreshCubeInfo(pageData)
	local cubeItem = pageData.cubeItem

	if self.view.backTxt then
		ClientTextUtils.setText(self.view.backTxt, pg.getGameString("FC_IRIS_CUBE_BUILD"))
	end

	if self.view.textTitleUBaseText and cubeItem.nameId then
		ClientTextUtils.setText(self.view.textTitleUBaseText, pg.getLocalizationText(cubeItem.nameId))
	end

	if self.view.ballNameTxt and cubeItem.typeNameId then
		ClientTextUtils.setText(self.view.ballNameTxt, pg.getLocalizationText(cubeItem.typeNameId))
	end

	if self.view.ballNumTxt then
		ClientTextUtils.setText(self.view.ballNumTxt, string.format(pg.getGameString("FC_ALREADY_OWNED"), cubeItem.ownedCount))
	end

	local data = self.model:getData()
	local activityConfig = self.model:getActivityConfig()
	local isSeekMode = FishingCaptureTicketExchangeCtrl._isSeekMode(pageData)

	if self.view.imgBgUImage then
		self.view.imgBgUImage:SetActive(not isSeekMode)
	end

	if self.view.btnCreateNumTxt then
		local numText = string.format(pg.getGameString("FC_CUBE_BUILD_COUNT"), pageData.remainingCount, pageData.totalCount)

		if isSeekMode then
			local cubeupText = activityConfig and activityConfig.cubeupText

			if cubeupText then
				numText = pg.getLocalizationText(cubeupText)
			else
				logger:warn("FishingCapture cubeupText missing, eventId=%s", tostring(data and data.eventId))
			end
		end

		ClientTextUtils.setText(self.view.btnCreateNumTxt, numText)
	end

	if self.view.btnCreateNameTxt then
		ClientTextUtils.setText(self.view.btnCreateNameTxt, pg.getGameString(isSeekMode and "FC_GOFIND_TEXT" or "FC_IRIS_CUBE_BUILD"))
	end

	if self.view.btnGainTextPlus and activityConfig and activityConfig.getcoin then
		ClientTextUtils.setText(self.view.btnGainTextPlus, pg.getLocalizationText(activityConfig.getcoin))
	end

	if self.view.btnCreateCostTxt then
		if isSeekMode then
			ClientTextUtils.setText(self.view.btnCreateCostTxt, "")
		elseif data.petalItem.id then
			ClientTextUtils.setText(self.view.btnCreateCostTxt, LuaUIUtils.getItemCountConsumeShowColorRedOnlyText(data.petalItem.id, pageData.cost, false))
		end
	end
end

function FishingCaptureTicketExchangeCtrl:_renderSeasonHelpItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imageUImage = objectReference:GetRefValue("imageUImage")

	imageUImage.url = data.imageUrl
end

function FishingCaptureTicketExchangeCtrl:onSeasonHelpClick()
	local activityConfig = self.model:getActivityConfig()
	local sourceId = activityConfig and activityConfig.helpId
	local sourceData = sourceId and ItemSourceData[sourceId]

	if not sourceData then
		return
	end

	LuaUIUtils.clueSeek(sourceData)
end

function FishingCaptureTicketExchangeCtrl:_refreshSeasonHelp()
	if not self.helpTipULoopList or not self.listPointUList then
		return
	end

	if self.seasonHelpInitialized then
		if self.seasonHelpCurrentIndex then
			self.listPointUList:SelectItem(self.seasonHelpCurrentIndex - 1, false)
		end

		return
	end

	self.seasonHelpInitialized = true

	local activityConfig = self.model:getActivityConfig()
	local cubeShow = activityConfig and activityConfig.cubeShow or {}

	self.seasonHelpData = {}

	for pageIndex, imageUrl in ipairs(cubeShow) do
		self.seasonHelpData[#self.seasonHelpData + 1] = {
			pageIndex = pageIndex,
			imageUrl = imageUrl
		}
	end

	self.helpTipULoopList:SetList(self.seasonHelpData)
	self.listPointUList:SetList(self.seasonHelpData)

	if #self.seasonHelpData > 0 then
		self:_selectSeasonHelpPage(1)
	end
end

function FishingCaptureTicketExchangeCtrl:_selectSeasonHelpPage(pageIndex)
	if not self.seasonHelpData or not self.seasonHelpData[pageIndex] or not self.listPointUList or not self.helpTipULoopList then
		return
	end

	local pageChanged = self.seasonHelpCurrentIndex ~= pageIndex

	self.seasonHelpCurrentIndex = pageIndex

	self.listPointUList:SelectItem(pageIndex - 1, false)

	if pageChanged then
		self.helpTipULoopList:GoToIndex(pageIndex - 1, false)
	end
end

function FishingCaptureTicketExchangeCtrl:_onSeasonHelpScrollEnd()
	local pageIndex = self:_getSeasonHelpCenterPageIndex()

	if not pageIndex then
		return
	end

	self:_selectSeasonHelpPage(pageIndex)
end

function FishingCaptureTicketExchangeCtrl:_getSeasonHelpCenterPageIndex()
	local loopList = self.helpTipULoopList

	if not loopList then
		return nil
	end

	local childButtons = loopList:GetAllChildrenButtons()

	if not childButtons or childButtons.Length <= 0 then
		return nil
	end

	local centerPosX = loopList.transform.position.x
	local nearestButton, nearestChildIndex, nearestDistance

	for i = 0, childButtons.Length - 1 do
		local childButton = childButtons[i]

		if childButton and not IsNil(childButton) then
			local distance = math.abs(childButton.transform.position.x - centerPosX)

			if not nearestDistance or distance < nearestDistance then
				nearestButton = childButton
				nearestChildIndex = loopList:GetChildIndex(childButton)
				nearestDistance = distance
			end
		end
	end

	local data = nearestButton and nearestButton.dataFromUList

	if data and data.pageIndex then
		return data.pageIndex
	end

	return nearestChildIndex and nearestChildIndex >= 0 and nearestChildIndex + 1 or nil
end

function FishingCaptureTicketExchangeCtrl._isSeekMode(pageData)
	local seekState = pageData and pageData.seekState

	return seekState ~= nil and seekState ~= FishingCaptureTicketExchangeModel.SeekState.None
end

function FishingCaptureTicketExchangeCtrl:_refreshBuildButton(pageData)
	local canBuild = pageData.actionState == FishingCaptureTicketExchangeModel.BuildState.CanBuild
	local isExhausted = pageData.actionState == FishingCaptureTicketExchangeModel.BuildState.Exhausted
	local isSeekMode = FishingCaptureTicketExchangeCtrl._isSeekMode(pageData)
	local isSeasonExhausted = pageData.cubeType == FishingCaptureConst.CubeType.SEASON and isExhausted

	if self.view.btnCreateUButton then
		self.view.btnCreateUButton:SetActive(not isSeasonExhausted)

		self.view.btnCreateUButton.interactable = isSeekMode or canBuild or isExhausted

		local showRedDot = pageData.cubeType == FishingCaptureConst.CubeType.LEGEND and canBuild

		pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_EXCHANGE, self.view.btnCreateUButton, showRedDot, RedDotConst.RedDotStyle.POINT)
	end

	if self.view.btnReadyUWidget then
		self.view.btnReadyUWidget:SetActive(isSeasonExhausted)
	end

	if isSeasonExhausted and self.view.btnReadyNameTxt then
		ClientTextUtils.setText(self.view.btnReadyNameTxt, pg.getGameString("FC_ALREADY_MAED"))
	end
end

function FishingCaptureTicketExchangeCtrl:onBuildClick()
	if self:_isBuildAnimationPlaying() then
		return
	end

	if self.buildPending then
		return
	end

	self:refreshDataAndView()

	local pageData = self:getCurrentPageData()

	if not pageData then
		return
	end

	if FishingCaptureTicketExchangeCtrl._isSeekMode(pageData) then
		self:onSeekIrisClick(pageData)

		return
	end

	if pageData.actionState == FishingCaptureTicketExchangeModel.BuildState.Exhausted then
		pg.global.showBubbleMessageRaw(pg.getGameString("FC_CUBE_LIMIT_TEXT"))

		return
	end

	if pageData.actionState ~= FishingCaptureTicketExchangeModel.BuildState.CanBuild then
		return
	end

	self:_resetBuildAnimation()

	self.buildPending = true

	pg.me:requestExchangeCube(pageData.cubeType, function(success)
		self:onBuildResult(success)
	end)
end

function FishingCaptureTicketExchangeCtrl:onSeekIrisClick(pageData)
	if pageData.seekState == FishingCaptureTicketExchangeModel.SeekState.Completed then
		pg.global.showBubbleMessageRaw(pg.getGameString("FC_IRIS_LIMIT_TEXT"))

		return
	end

	local activityConfig = self.model:getActivityConfig()
	local eventId = activityConfig and activityConfig.event1

	if not eventId then
		logger:warn("FishingCapture seek entrance event invalid, eventId=%s", tostring(self.model:getData() and self.model:getData().eventId))

		return
	end

	self:dismiss()
	pg.me:doEvent(eventId)
end

function FishingCaptureTicketExchangeCtrl:onBuildResult(success)
	self.buildPending = false

	if self.isDestroyed or not success then
		return
	end

	self:refreshDataAndView()
	self:_playBuildAnimation()
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "BossCatch_BuildBall")
	pg.game.audio:playEvent(FishingCaptureConst.SFX_CUBE_MADE)
	self:_refreshCubeBuildBgm()
end

function FishingCaptureTicketExchangeCtrl:onPetalSourceClick()
	local data = self.model:getData()

	if data.eventId then
		pg.global.ui:open(UIConst.UI_ID_FISHING_CAPTURE_PETAL_SOURCE, {
			eventId = data.eventId
		})
	end
end

function FishingCaptureTicketExchangeCtrl:onIrisDetailClick()
	local pageData = self:getCurrentPageData()

	if not pageData or pageData.cubeType ~= FishingCaptureConst.CubeType.LEGEND then
		return
	end

	if pageData.keyPetType and PetData[pageData.keyPetType] then
		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			templateId = pageData.keyPetType
		})
	end
end

function FishingCaptureTicketExchangeCtrl:onMoneyCountChange()
	self:refreshDataAndView()
end

function FishingCaptureTicketExchangeCtrl:onActivityDataChanged()
	self.buildPending = false

	self.model:refreshData()
	self:refreshView()
end

return FishingCaptureTicketExchangeCtrl
