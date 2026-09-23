-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrowthGiftSelect\\GrowthGiftSelectCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local PetData = require("Data.pet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local GrowthGiftSelectModel = require("Guis.Panels.GrowthGiftSelect.GrowthGiftSelectModel")
local EffectConst = require("Const.EffectConst")
local GrowthGiftSelectCtrl = Class.LightClass("GrowthGiftSelectCtrl", UICtrl)
local PET_VIDEO_LOAD_TIMEOUT = 10
local PreviewPetVideoResumeMode = {
	Restart = 2,
	Resume = 1
}

GrowthGiftSelectCtrl.messages = {}

function GrowthGiftSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.eventId = info and info.eventId
	self.collectionMode = info and info.collectionMode == true
	self.allPetList = self.collectionMode and self.model:getCollectionList(self.eventId) or self.model:getRewardList(self.eventId)

	self:refreshCollectionStates()

	self.filterElements = {}
	self.filterPetTypes = {}
	self.petList = self.allPetList
	self.curPet = self:getDefaultPet()
	self.curForm = self:getDefaultBaseForm(self.curPet)
	self.curShine = false

	self:setVideoPlayerVisible(self.view.videoPlayer, false)
	self:setVideoPlayerVisible(self.view.maxUVideoPlayerX, false)

	if self.view.videoUWidget then
		self.view.videoUWidget.gameObject:SetActiveEx(false)
	end

	self:initStaticTexts()
	self:refreshFilterState()
	self:refreshCollectionModeUI()
	self:refreshPage()
end

function GrowthGiftSelectCtrl:getDefaultPet()
	if self.collectionMode then
		return self.petList[1]
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.GrowthGift)
	local selectedDropId = actData and actData.selectedPetId or 0

	return self.model:findRewardByDropId(self.petList, selectedDropId) or self.petList[1]
end

function GrowthGiftSelectCtrl:refreshCollectionStates()
	if not self.collectionMode then
		return
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.GrowthGift)
	local unlockPetIds = actData and actData.collectUnlockPetIds

	for _, pet in ipairs(self.allPetList) do
		local unlockValue = unlockPetIds and unlockPetIds[pet.rewardPetId]

		pet.isCollected = unlockValue ~= nil and unlockValue ~= 0
	end
end

function GrowthGiftSelectCtrl:refreshCollectionModeUI()
	if not self.collectionMode then
		return
	end

	local hiddenWidgets = {
		self.view.btnChoose,
		self.view.btnFilter,
		self.view.btnFilter2,
		self.view.btnCleanFilter,
		self.view.btnRandomPet,
		self.view.txtGetCondition
	}

	for _, widget in ipairs(hiddenWidgets) do
		if widget and widget.gameObject then
			widget.gameObject:SetActiveEx(false)
		end
	end
end

function GrowthGiftSelectCtrl:getDefaultBaseForm(pet)
	if pet and pet.prismanaPetId then
		return GrowthGiftSelectModel.FormType.Prismana
	end

	return GrowthGiftSelectModel.FormType.Normal
end

function GrowthGiftSelectCtrl:initStaticTexts()
	if self.collectionMode then
		ClientTextUtils.setText(self.view.txtBack, pg.getGameString("PRISMANA_GIFTS_COLLECTION_TITLE"))
		ClientTextUtils.setText(self.view.txtListTitle, pg.getGameString("PRISMANA_GIFTS_COLLECTION_TITLE"))
	else
		ClientTextUtils.setText(self.view.txtBack, pg.getGameString("PRISMANA_GIFTS_ANIIMO_SELF_SELECT"))
		ClientTextUtils.setText(self.view.txtListTitle, pg.getGameString("PRISMANA_GIFTS_CLAIM_RAINBOW_ANIIMO"))
	end

	ClientTextUtils.setText(self.view.txtChoose, pg.getGameString("PRISMANA_GIFTS_SELECTE"))
	ClientTextUtils.setText(self.view.txtGot, pg.getGameString("PRISMANA_GIFTS_SELECTED"))
	ClientTextUtils.setText(self.view.txtPrismana, pg.getGameString("PRISMANA_GIFTS_PRISMANA"))
	ClientTextUtils.setText(self.view.txtShine, pg.getGameString("PRISMANA_GIFTS_SHINE"))
	ClientTextUtils.setText(self.view.txtVideo, pg.getGameString("PRISMANA_GIFTS_VIDEOTXT"))

	if self.view.btnRandomPet then
		local objectReference = self.view.btnRandomPet:GetComponent("ObjectReference")
		local txtNameUText = objectReference and objectReference:GetRefValue("txtNameUText")

		if txtNameUText then
			ClientTextUtils.setText(txtNameUText, pg.getGameString("PRISMANA_GIFTS_RANDOM"))
		end
	end

	local condStr = ""
	local condId = self.model:getReceiveCondId(self.eventId)

	if condId and condId > 0 then
		local triggerCfg = CustomTriggerData[condId]

		if triggerCfg and triggerCfg.note then
			condStr = pg.getLocalizationText(triggerCfg.note)
		end
	end

	ClientTextUtils.setText(self.view.txtGetCondition, pg.getFormatText(pg.getGameString("PRISMANA_GIFTS_CLAIM_CHANGE"), condStr))
end

function GrowthGiftSelectCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:dismiss()
	end

	function self.view.btnChoose.luaClick()
		self:onClickChoose()
	end

	function self.view.btnSearch.luaClick()
		if self.curPet and self.curPet.prismanaPetId then
			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				templateId = self.curPet.prismanaPetId
			})
		end
	end

	function self.view.btnPrismana.luaClick()
		self:togglePrismana()
	end

	function self.view.btnShine.luaClick()
		self:toggleShine()
	end

	function self.view.btnDice.luaClick()
		self:diceShine()
	end

	if self.view.btnRandomPet then
		function self.view.btnRandomPet.luaClick()
			self:randomSelectPet()
		end
	end

	if self.view.btnOpen then
		function self.view.btnOpen.luaClick()
			self:onClickVideo()
		end
	end

	if self.view.btnVideoBack then
		function self.view.btnVideoBack.luaClick()
			self:onClickVideoBack()
		end
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:onRenderPetItem(button, index, data)
	end

	function self.view.listUList.luaClick(button, data)
		self:selectPet(data)
	end

	function self.view.listBuff.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element, true, data.petId)
	end

	function self.view.listTipsUList.luaRenderItem(button, index, data)
		self:renderTipItem(button, index, data)
	end

	if self.view.listPrismanaUList then
		function self.view.listPrismanaUList.luaRenderItem(button, index, data)
			self:onRenderPrismanaTagItem(button, index, data)
		end
	end

	function self.view.btnFilter.luaClick()
		self:openFilterPanel()
	end

	function self.view.btnFilter2.luaClick()
		self:openFilterPanel()
	end

	function self.view.btnCleanFilter.luaClick()
		self:clearFilter()
	end

	self.view.listUList:SetNavGroupItemFocusStateOverride(true, CS.XGUI.Navigation.NavFocusState.Select)

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("GrowthGiftSelectCtrlChange", function()
			self:refreshConsoleBarState()
		end)
	end
end

function GrowthGiftSelectCtrl:renderTipItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtDesc = objectReference:GetRefValue("txtDesc")

	ClientTextUtils.setText(txtDesc, data.text)
end

function GrowthGiftSelectCtrl:refreshTipList(petDesc)
	self.view.listTipsUList:SetList({
		{
			text = petDesc or ""
		}
	})
end

function GrowthGiftSelectCtrl:refreshPage()
	self.view.listUList:SetList(self.petList)
	self:selectCurPetInList()
	self:refreshDetail()
end

function GrowthGiftSelectCtrl:selectCurPetInList()
	if not self.curPet then
		return
	end

	for i, pet in ipairs(self.petList) do
		if pet.listKey == self.curPet.listKey then
			self.view.listUList:SelectItem(i - 1, false)

			return
		end
	end
end

function GrowthGiftSelectCtrl:selectPet(pet)
	if not pet then
		return
	end

	self.curPet = pet
	self.curForm = self:getDefaultBaseForm(pet)
	self.curShine = false

	self:refreshDetail()
end

function GrowthGiftSelectCtrl:randomSelectPet()
	local petCount = #self.petList

	if petCount == 0 then
		return
	end

	local index = math.random(1, petCount)

	self:selectPet(self.petList[index])

	local itemIndex = index - 1

	self.view.listUList:SelectItem(itemIndex, false)
	self.view.listUList:GoToIndexMinCost(itemIndex, false)

	if pg.game.input:isUsingGamepad() then
		local success, focusItem = self.view.listUList:TryGetChildAt(itemIndex)

		if success then
			pg.global.navMgr:FocusItem(focusItem)
		end
	end
end

function GrowthGiftSelectCtrl:refreshDetail()
	local pet = self.curPet

	if not pet then
		self:stopPetVideo()

		return
	end

	local templateId = self:getCurDisplayTemplateId()
	local protoData = templateId and PetPrototypeData[templateId]
	local petName = protoData and pg.getLocalizationText(protoData.name) or ""

	ClientTextUtils.setText(self.view.txtPetName, petName)

	local ratingStr = Const.STAGE_TO_RATING_STR[4] or ""

	ClientTextUtils.setText(self.view.txtQuality, pg.getGameString(ratingStr))

	local researchData = templateId and PetResearchContentData[templateId]
	local descText = researchData and pg.getLocalizationText(researchData.desc) or ""

	self:refreshTipList(descText)
	self:refreshFormButtons(pet)

	local buffList = self:buildBuffList(templateId)

	self.view.listBuff:SetList(buffList)
	self:refreshPrismanaTagList()

	if self.view.typeImage and self.view.typeDesc then
		LuaUIUtils.setPetFunction(self.view.typeImage, self.view.typeDesc, templateId)
	end

	self:refreshPetVideo()
	self:refreshScene()
end

function GrowthGiftSelectCtrl:getPetVideoUrl()
	local pet = self.curPet

	if not pet then
		return nil
	end

	local fieldName = Utils.isOverseas() and "petshowVideoINT" or "petshowVideo"
	local petIds = {}

	if pet.rewardPetId then
		petIds[#petIds + 1] = pet.rewardPetId
	end

	if pet.prismanaPetId and pet.prismanaPetId ~= pet.rewardPetId then
		petIds[#petIds + 1] = pet.prismanaPetId
	end

	if pet.petId and pet.petId ~= pet.rewardPetId and pet.petId ~= pet.prismanaPetId then
		petIds[#petIds + 1] = pet.petId
	end

	local videoName

	for _, petId in ipairs(petIds) do
		local petCfg = PetData[petId]
		local configuredVideo = petCfg and petCfg[fieldName]

		if not string.isNilOrEmpty(configuredVideo) then
			videoName = configuredVideo

			break
		end
	end

	if string.isNilOrEmpty(videoName) then
		return nil
	end

	videoName = string.gsub(videoName, "\\", "/")

	if string.match(videoName, "^https?://") then
		return videoName
	end

	videoName = string.gsub(videoName, "^/+", "")
	videoName = string.gsub(videoName, "^public/video/m/", "")
	videoName = string.gsub(videoName, "^public/video/", "")

	local host = Utils.isOverseas() and ClientConst.SERVER_LIST.GLOBAL_HOST or ClientConst.SERVER_LIST.CN_HOST
	local videoPath = IS_MOBILE and "/public/video/m/" or "/public/video/"

	return "https://" .. host .. videoPath .. videoName
end

function GrowthGiftSelectCtrl:clearPetVideoLoadTimer(timerKey)
	if self[timerKey] then
		self:killTimer(self[timerKey])

		self[timerKey] = nil
	end
end

function GrowthGiftSelectCtrl:setVideoPlayerVisible(videoPlayer, visible)
	if not videoPlayer then
		return
	end

	local color = videoPlayer.color

	videoPlayer.color = Color(color.r, color.g, color.b, visible and 1 or 0)
end

function GrowthGiftSelectCtrl:playPetVideo(videoPlayer, videoUrl, requestKey, onReady, onFailed)
	if not videoPlayer or string.isNilOrEmpty(videoUrl) then
		return false
	end

	self:setVideoPlayerVisible(videoPlayer, false)

	local timerKey = requestKey .. "Timer"

	self:clearPetVideoLoadTimer(timerKey)

	self.videoRequestSerial = (self.videoRequestSerial or 0) + 1

	local requestSerial = self.videoRequestSerial

	self[requestKey] = requestSerial

	local function isCurrentRequest()
		return self.view and self[requestKey] == requestSerial
	end

	local function finishLoad()
		if not isCurrentRequest() then
			return
		end

		self:clearPetVideoLoadTimer(timerKey)
		self:setVideoPlayerVisible(videoPlayer, true)

		if onReady then
			onReady()
		end
	end

	local function failLoad()
		if not isCurrentRequest() then
			return
		end

		self:clearPetVideoLoadTimer(timerKey)

		self[requestKey] = nil
		videoPlayer.luaVideoPrepared = nil
		videoPlayer.luaVideoFirstFrameReady = nil

		self:setVideoPlayerVisible(videoPlayer, false)
		videoPlayer:StopVideo()
		videoPlayer:CloseVideo()

		if onFailed then
			onFailed()
		end
	end

	videoPlayer.videoLoop = true
	videoPlayer.luaVideoFirstFrameReady = finishLoad

	if videoPlayer.url == videoUrl and videoPlayer.firstFrameReady then
		videoPlayer.luaVideoPrepared = nil

		videoPlayer:StopVideo()
		videoPlayer:Seek(0)
		videoPlayer:PlayVideo()
		finishLoad()

		return true
	end

	videoPlayer.autoPlay = false

	function videoPlayer.luaVideoPrepared()
		if not isCurrentRequest() then
			return
		end

		if requestKey == "petVideoRequestSerial" and self.maxPetVideoShowing then
			return
		end

		videoPlayer:PlayVideo()
	end

	if videoPlayer.url == videoUrl then
		videoPlayer.url = ""
	end

	self[timerKey] = self:startTimer(function()
		self[timerKey] = nil

		failLoad()
	end, PET_VIDEO_LOAD_TIMEOUT)

	videoPlayer:SetVideoUrlWithCallback(videoUrl, nil, failLoad)

	return true
end

function GrowthGiftSelectCtrl:stopVideoPlayer(videoPlayer, requestKey)
	self:clearPetVideoLoadTimer(requestKey .. "Timer")

	self[requestKey] = nil

	if videoPlayer then
		videoPlayer.luaVideoPrepared = nil
		videoPlayer.luaVideoFirstFrameReady = nil

		self:setVideoPlayerVisible(videoPlayer, false)
		videoPlayer:StopVideo()
	end
end

function GrowthGiftSelectCtrl:refreshPetVideo()
	self.curPetVideoUrl = self:getPetVideoUrl()

	local videoPlayer = self.view and self.view.videoPlayer

	if not self:playPetVideo(videoPlayer, self.curPetVideoUrl, "petVideoRequestSerial", nil, function()
		self:stopPetVideo()
	end) then
		self:stopPetVideo()

		return
	end

	self.petVideoStopped = false
end

function GrowthGiftSelectCtrl:stopPetVideo()
	local videoPlayer = self.view and self.view.videoPlayer

	self:stopVideoPlayer(videoPlayer, "petVideoRequestSerial")

	self.petVideoStopped = true
end

function GrowthGiftSelectCtrl:onClickVideo()
	local videoUrl = self.curPetVideoUrl or self:getPetVideoUrl()

	if string.isNilOrEmpty(videoUrl) or not self.view.maxUVideoPlayerX or not self.view.videoUWidget then
		return
	end

	if self.maxPetVideoShowing then
		return
	end

	self.maxPetVideoShowing = true
	self.previewPetVideoResumeMode = nil

	local previewVideoPlayer = self.view.videoPlayer

	if previewVideoPlayer and not self.petVideoStopped then
		if previewVideoPlayer.isPlaying and not previewVideoPlayer.isPaused then
			self.previewPetVideoResumeMode = PreviewPetVideoResumeMode.Resume

			previewVideoPlayer:PauseVideo()
		elseif self.petVideoRequestSerial then
			self.previewPetVideoResumeMode = PreviewPetVideoResumeMode.Restart

			self:stopVideoPlayer(previewVideoPlayer, "petVideoRequestSerial")
			previewVideoPlayer:CloseVideo()
		end
	end

	self.view.videoUWidget.gameObject:SetActiveEx(true)

	if not self:playPetVideo(self.view.maxUVideoPlayerX, videoUrl, "maxPetVideoRequestSerial", nil, function()
		self:closeMaxPetVideo()
	end) then
		self:closeMaxPetVideo()
	end
end

function GrowthGiftSelectCtrl:onClickVideoBack()
	self:closeMaxPetVideo()
end

function GrowthGiftSelectCtrl:resumePreviewPetVideo()
	local resumeMode = self.previewPetVideoResumeMode

	self.previewPetVideoResumeMode = nil

	if not resumeMode then
		return
	end

	local videoPlayer = self.view and self.view.videoPlayer

	if not videoPlayer then
		return
	end

	if resumeMode == PreviewPetVideoResumeMode.Resume and videoPlayer.firstFrameReady and videoPlayer.url == self.curPetVideoUrl then
		videoPlayer:ResumeVideo(false)
	else
		self:refreshPetVideo()
	end
end

function GrowthGiftSelectCtrl:closeMaxPetVideo(resumePreview)
	local videoPlayer = self.view and self.view.maxUVideoPlayerX

	self:stopVideoPlayer(videoPlayer, "maxPetVideoRequestSerial")

	self.maxPetVideoShowing = false

	if self.view and self.view.videoUWidget then
		self.view.videoUWidget.gameObject:SetActiveEx(false)
	end

	if resumePreview == false then
		self.previewPetVideoResumeMode = nil
	else
		self:resumePreviewPetVideo()
	end
end

function GrowthGiftSelectCtrl:onRenderPrismanaTagItem(button, index, data)
	LuaUIUtils.renderPetTagList(button, data)

	local templateId = data and data.templateId
	local label = data and data.label
	local bodySizeType = data and data.bodySizeType

	LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(templateId, label, bodySizeType, data.shinyStyle))
end

function GrowthGiftSelectCtrl:buildPrismanaTagList()
	local pet = self.curPet

	if not pet then
		return {}
	end

	local templateId = pet.prismanaPetId or pet.petId

	if not templateId then
		return {}
	end

	return LuaUIUtils.getPetTagList({
		templateId = templateId,
		label = self.curShine and Const.PET_LABEL_MASK.SHINY or 0
	})
end

function GrowthGiftSelectCtrl:refreshPrismanaTagList()
	if not self.view or not self.view.listPrismanaUList then
		return
	end

	self.view.listPrismanaUList:SetList(self:buildPrismanaTagList())
end

function GrowthGiftSelectCtrl:refreshFormButtons(pet)
	self.view.btnPrismana:TryChangePage("Type", self.curForm)
	self.view.btnShine:TryChangePage("Type", self.curShine and 1 or 0)
end

function GrowthGiftSelectCtrl:getCurDisplayTemplateId()
	local pet = self.curPet

	if not pet then
		return nil
	end

	if self.curForm == GrowthGiftSelectModel.FormType.Prismana and pet.prismanaPetId then
		return pet.prismanaPetId
	end

	return pet.petId
end

function GrowthGiftSelectCtrl:getCurDisplayLabel()
	if self.curShine then
		return Const.PET_LABEL_MASK.SHINY
	end

	return 0
end

function GrowthGiftSelectCtrl:setCurForm(formType)
	if self.curForm == formType then
		return
	end

	self.curForm = formType

	self:refreshScene()
end

function GrowthGiftSelectCtrl:togglePrismana()
	if not self.curPet or not self.curPet.prismanaPetId then
		return
	end

	if self.curForm == GrowthGiftSelectModel.FormType.Prismana then
		self:setCurForm(GrowthGiftSelectModel.FormType.Normal)
	else
		self:setCurForm(GrowthGiftSelectModel.FormType.Prismana)
	end

	self.view.btnPrismana:TryChangePage("Type", self.curForm)
end

function GrowthGiftSelectCtrl:toggleShine()
	if not self.curPet or not self.curPet.hasShine then
		return
	end

	self.curShine = not self.curShine

	self:refreshScene()
	self:refreshPrismanaTagList()
	self.view.btnShine:TryChangePage("Type", self.curShine and 1 or 0)
end

function GrowthGiftSelectCtrl:refreshScene()
	local scene = self:getScene()

	if not scene or not scene:isCreated() then
		return
	end

	local templateId = self:getCurDisplayTemplateId()

	if not templateId then
		return
	end

	scene:setSceneDisplayTemplate(templateId, self:getCurDisplayLabel(), 0)
end

function GrowthGiftSelectCtrl:getScene()
	return pg.game.uiScene:getScene(self._uiSceneName)
end

function GrowthGiftSelectCtrl:diceShine()
	local scene = pg.game.uiScene:getScene(self._uiSceneName)

	if not scene or not scene:isCreated() then
		return
	end

	local templateId = self:getCurDisplayTemplateId()

	if not templateId then
		return
	end

	local total = #EffectConst.SHINY_EFFECTS

	if total <= 0 then
		return
	end

	local styleIdx = math.random(1, total)

	if total > 1 and styleIdx == self.curShineStyle then
		styleIdx = styleIdx % total + 1
	end

	local shinnyEffect = EffectConst.SHINY_EFFECTS[styleIdx]

	if not shinnyEffect then
		return
	end

	self.curShineStyle = styleIdx

	scene:playShinnyPreset(templateId, shinnyEffect)
end

function GrowthGiftSelectCtrl:onRenderPetItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local singleElement = objectReference:GetRefValue("singleElement")
	local doubleElement1 = objectReference:GetRefValue("doubleElement1")
	local doubleElement2 = objectReference:GetRefValue("doubleElement2")
	local addOnUComponent = objectReference:GetRefValue("addOnUComponent")
	local rainBowUWidget = objectReference:GetRefValue("rainBowUWidget")
	local displayPetId = data.prismanaPetId or data.petId
	local protoData = displayPetId and PetPrototypeData[displayPetId]

	if iconUImage then
		local petIcon = protoData and protoData.iconName and LuaUIUtils.getPetIcon(protoData.iconName, LuaUIUtils.PET_ICON) or ""

		iconUImage.url = petIcon
	end

	if addOnUComponent then
		local elementNames = protoData and protoData.elementType or {}
		local elementCount = #elementNames

		if elementCount == 0 then
			addOnUComponent:TryChangePage("DetailState", 0)
			LuaUIUtils.setUIViewVisible(singleElement, false)
		elseif elementCount == 1 then
			addOnUComponent:TryChangePage("DetailState", 1)
			LuaUIUtils.setUIViewVisible(singleElement, true)
			LuaUIUtils.setElementButtonNew(singleElement, elementNames[1])
		else
			addOnUComponent:TryChangePage("DetailState", 2)
			LuaUIUtils.setElementButtonNew(doubleElement1, elementNames[1])
			LuaUIUtils.setElementButtonNew(doubleElement2, elementNames[2])
		end
	end

	if rainBowUWidget then
		rainBowUWidget:LoadDefaultUrlManually()
		rainBowUWidget.gameObject:SetActiveEx(true)
	end

	button:TryChangePage("EventRainbowCollected", self.collectionMode and data.isCollected and 0 or 1)
	button:TryChangePage("Selected", self.curPet and self.curPet.listKey == data.listKey and 1 or 0)

	button.draggable = false
end

function GrowthGiftSelectCtrl:buildBuffList(templateId)
	local protoData = templateId and PetPrototypeData[templateId]

	if not protoData then
		return {}
	end

	local list = {}

	for _, elementName in ipairs(protoData.elementType) do
		list[#list + 1] = {
			element = elementName,
			level = protoData.elementLevels and protoData.elementLevels[elementName] or 0,
			petId = templateId
		}
	end

	return list
end

function GrowthGiftSelectCtrl:onClickChoose()
	if self.collectionMode or not self.eventId or not self.curPet or not self.curPet.dropId then
		return
	end

	pg.me:reqGrowthGiftChooseEgg(self.eventId, self.curPet.dropId, function(code)
		if code == 0 or code == true then
			self:dismiss()
		end
	end)
end

function GrowthGiftSelectCtrl:openFilterPanel()
	if self.collectionMode then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_GROW_GIFT_SELECT_FILTER, {
		selectedElements = self.filterElements,
		selectedPetTypes = self.filterPetTypes,
		doFilterCallback = function(elements, petTypes)
			self:applyFilter(elements, petTypes)
		end
	})
end

function GrowthGiftSelectCtrl:applyFilter(elements, petTypes)
	self.filterElements = elements or {}
	self.filterPetTypes = petTypes or {}

	self:refreshFilteredList()
	self:refreshFilterState()
end

function GrowthGiftSelectCtrl:clearFilter()
	self.filterElements = {}
	self.filterPetTypes = {}

	self:refreshFilteredList()
	self:refreshFilterState()
end

function GrowthGiftSelectCtrl:isFiltering()
	return next(self.filterElements) ~= nil or next(self.filterPetTypes) ~= nil
end

function GrowthGiftSelectCtrl:refreshFilterState()
	if self.collectionMode then
		return
	end

	if self.view and self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("State", self:isFiltering() and 1 or 0)
	end
end

function GrowthGiftSelectCtrl:refreshFilteredList()
	if not self:isFiltering() then
		self.petList = self.allPetList
	else
		local list = {}
		local hasElementFilter = next(self.filterElements) ~= nil
		local hasPetTypeFilter = next(self.filterPetTypes) ~= nil

		for _, pet in ipairs(self.allPetList) do
			local templateId = pet.prismanaPetId or pet.petId
			local protoData = templateId and PetPrototypeData[templateId]
			local elementTypes = protoData and protoData.elementType
			local matchElement = not hasElementFilter

			if hasElementFilter and elementTypes then
				for _, elementName in ipairs(elementTypes) do
					if self.filterElements[elementName] ~= nil then
						matchElement = true

						break
					end
				end
			end

			local petData = templateId and PetData[templateId]
			local petType = petData and petData.functionId
			local matchPetType = not hasPetTypeFilter or self.filterPetTypes[petType] ~= nil

			if matchElement and matchPetType then
				list[#list + 1] = pet
			end
		end

		self.petList = list
	end

	local stillIn = false

	if self.curPet then
		for _, pet in ipairs(self.petList) do
			if pet.listKey == self.curPet.listKey then
				stillIn = true

				break
			end
		end
	end

	if not stillIn then
		self.curPet = self.petList[1]

		if self.curPet then
			self.curForm = self:getDefaultBaseForm(self.curPet)
			self.curShine = false
		end
	end

	self.view.listUList:SetList(self.petList)
	self:selectCurPetInList()
	self:refreshDetail()
end

function GrowthGiftSelectCtrl:onDestroy()
	local navMgr = pg.global.navMgr

	if navMgr then
		navMgr:RemoveLuaFocusCursorMovedListener("GrowthGiftSelectCtrlChange")
		navMgr:SetConsoleBarState("UI_Pb_Event_GrowthGift_Info", false)
		navMgr:SetConsoleBarState("UI_Pb_Event_GrowthGift_Check", false)
	end

	self:closeMaxPetVideo(false)
	self:stopPetVideo()

	local scene = self:getScene()

	if scene and scene.unRegisterGesture then
		scene:unRegisterGesture(self.uid, true)
	end

	self.filterElements = nil
	self.filterPetTypes = nil
	self.allPetList = nil

	UICtrl.onDestroy(self)
end

function GrowthGiftSelectCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function GrowthGiftSelectCtrl:onUISceneLoaded()
	UICtrl.onUISceneLoaded(self)
	self:refreshScene()
end

function GrowthGiftSelectCtrl:onShow()
	if not self.view then
		return
	end

	if self.petVideoStopped then
		self:refreshPetVideo()
	end

	local scene = self:getScene()

	if scene and scene.addCameraZoomKeyBinding then
		scene:addCameraZoomKeyBinding(self.view.gameObject)
	end

	if scene and scene.registerGesture then
		scene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})
	end

	self:refreshConsoleBarState()
end

function GrowthGiftSelectCtrl:onHide()
	self:closeMaxPetVideo(false)
	self:stopPetVideo()

	local scene = self:getScene()

	if scene and scene.unRegisterGesture then
		scene:unRegisterGesture(self.uid)
	end

	local navMgr = pg.global.navMgr

	if navMgr then
		navMgr:SetConsoleBarState("UI_Pb_Event_GrowthGift_Info", false)
		navMgr:SetConsoleBarState("UI_Pb_Event_GrowthGift_Check", false)
	end
end

function GrowthGiftSelectCtrl:refreshConsoleBarState()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local groupName = navMgr.CurrentFocusedGroupName

	navMgr:SetConsoleBarState("UI_Pb_Event_GrowthGift_Info", groupName ~= "RightDetails")
	navMgr:SetConsoleBarState("UI_Pb_Event_GrowthGift_Check", not self.collectionMode and groupName == "RightDetails")
end

return GrowthGiftSelectCtrl
