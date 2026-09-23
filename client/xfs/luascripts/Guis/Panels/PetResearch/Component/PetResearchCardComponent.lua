-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearch\\Component\\PetResearchCardComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PetData = require("Data.pet_data")
local CountryAreaData = require("Data.country_area_data")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("PetResearchCardComponent")
local PetConfigData = require("Data.pet_config_data")
local PetAvatarData = require("Data.pet_avatar_data")
local NoticeDef = require("Common.NoticeDef")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local PetCountryCollectData = require("Data.pet_research_country_collect_data")
local PetCountrySpeciesCollectData = require("Data.pet_research_country_species_collect_data")
local PetResearchCardComponent = Class.LightClass("Guis.Panels.PetResearch.Component.PetFormComponent", UIComponent)
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local CustomEnData = require("Data.I18N.custom_en_data")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

PetResearchCardComponent.messages = {}

function PetResearchCardComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.rewardList = objectReference:GetRefValue("rewardList")
	self.lastRewardUButton = objectReference:GetRefValue("lastRewardUButton")
	self.totalProgress = objectReference:GetRefValue("totalProgress")
	self.curNum = objectReference:GetRefValue("curNum")
	self.allNum = objectReference:GetRefValue("allNum")
	self.lastProgress = objectReference:GetRefValue("lastProgress")
	self.btnCountryUButton = objectReference:GetRefValue("btnCountryUButton")
	self.countryName = objectReference:GetRefValue("countryName")
	self.countryImage = objectReference:GetRefValue("countryImage")
	self.finalRewardNum = objectReference:GetRefValue("finalRewardNum")
	self.selectedStateConsoleFrameUComponent = objectReference:GetRefValue("selectedStateConsoleFrameUComponent")
	self.progressNumUWidget = objectReference:GetRefValue("progressNumUWidget")
	self.countryLvText = objectReference:GetRefValue("countryLvText")
	self.collectRewardVx = objectReference:GetRefValue("collectRewardVx")
	self.numInfoUList = objectReference:GetRefValue("numInfoUList")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.switchNameUSDFText = objectReference:GetRefValue("switchNameUSDFText")
	self.backToAreaPageUButton = objectReference:GetRefValue("backToAreaPageUButton")
	self.maxUWidget = objectReference:GetRefValue("maxUWidget")
	self.layoutBoxUWidget = objectReference:GetRefValue("layoutBoxUWidget")
end

function PetResearchCardComponent:initView()
	function self.listPetUList.luaRenderItem(button, idx, data)
		self:setPetCardList(button, idx, data)
	end

	function self.listPetUList.luaResetItem(button)
		local objectReference = button:GetComponent("ObjectReference")
		local petIconUImage = objectReference:GetRefValue("petIconUImage")
		local videoPlayerUVideoPlayer = objectReference:GetRefValue("videoPlayerUVideoPlayer")

		petIconUImage.url = nil
		videoPlayerUVideoPlayer.resID = nil
	end

	function self.rewardList.luaRenderItem(button, idx, data)
		self:renderReward(button, idx, data)
	end

	function self.rewardList.luaVirtualListRefreshCb()
		self:refreshGamepadDefaultFocus()
	end

	function self.listPetUList.luaClick(button, data)
		PetResearchUtils.tryOpenPetResearchDetail(data)
	end

	function self.btnCountryUButton.luaClick()
		self:saveListScrollPos()

		if self.model.specialNation then
			pg.global.ui.petResearchCountryPage:open()
		else
			pg.global.ui.petResearchFrontPageV2:open({
				countryId = self.model.areaId
			}, function()
				return
			end)
		end
	end

	function self.btnSwitchUButton.luaClick()
		self:switchShowTab()
	end

	function self.backToAreaPageUButton.luaClick()
		self:saveListScrollPos()
		pg.global.ui.petResearchCountryPage:open()
	end

	function self.numInfoUList.luaRenderItem(numBtn, idx, numData)
		local objectReference = numBtn:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local textUText = objectReference:GetRefValue("textUText")

		numBtn.tooltipId = pg.getGameString(numData.tooltipId)
		iconUImage.url = numData.icon

		ClientTextUtils.setText(textUText, numData.num)
	end
end

function PetResearchCardComponent:refreshGamepadDefaultFocus(groupName, fromNav)
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local curFocusGroup = groupName and groupName or pg.global.navMgr.CurrentFocusedGroupName
	local bottomFocused = curFocusGroup == "LayoutBoxBottom"

	if bottomFocused then
		local rewardDatas, focusIdx, rewardFocus = self:getCurAreaCollectData()

		if rewardDatas then
			if fromNav then
				self.rewardList:StopScroll()
				self.rewardList:GoToIndex(focusIdx, true)
			end

			local res, btn
			local isFinalRewardFocus = false

			if self.finalRewardData.status == Const.REWARD_STATUS_CANREWARD then
				isFinalRewardFocus = rewardFocus and self.finalRewardData.level == rewardFocus + 1
			elseif self.finalRewardData.status == Const.REWARD_STATUS_DONE then
				isFinalRewardFocus = rewardFocus == nil
			end

			if isFinalRewardFocus then
				res = true
				btn = self.lastRewardUButton
			else
				res, btn = self.rewardList:TryGetChildAt(rewardFocus)
			end

			if res then
				local objRef = btn:GetComponent("ObjectReference")
				local defaultItem = objRef:GetRefValue("rewardItemUButton")

				if self.layoutBoxUWidget then
					self.layoutBoxUWidget:SetNavGroupDefaultItem(defaultItem)
				end
			end
		end
	end
end

function PetResearchCardComponent:refreshView()
	self:_refreshBtnSwitch()

	local countryName = CountryAreaData[self.model.areaId].name

	ClientTextUtils.setText(self.countryName, pg.getLocalizationText(countryName))
	self:setUpCountryStar()
	self:setFullProgress()
	self:setUpCardList()
	self:setUpRewardList()
	self:refreshPetNumInfo()
	self:refreshCountryRedDot()
	self:refreshPetRedDot()

	self.countryImage.url = LuaUIUtils.getCountryIconByType(self.model.areaId, LuaUIUtils.PET_ICON)

	self.collectRewardVx:SetActive(self.model:checkCountryReward(self.model.areaId, self.model.REWARD_LEVEL))
end

function PetResearchCardComponent:refreshPetNumInfo()
	local numInfo = self.model.petNumInfo[self.model.showTab]

	self.numInfoUList:SetList(numInfo)
end

function PetResearchCardComponent:openOverviewPanel()
	pg.global.ui.petOverview:open({
		countryId = self.model.areaId
	})
end

function PetResearchCardComponent:switchShowTab()
	local newShowTab = self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and PetResearchUtils.PET_SHOW_TAB.FORM or PetResearchUtils.PET_SHOW_TAB.SPECIES

	PetResearchUtils.savePetShowTab(newShowTab)
	self:onPetShowTabChanged(newShowTab)
end

function PetResearchCardComponent:setCountryBaseProgress()
	local playerHandBookMap = pg.me.petHandbookMap
	local caughtCount = playerHandBookMap:getCountByIdAndStateMask(0, Const.PET_HBMSK_CATCHED, self.model.areaId)
	local normalCount, _ = PetResearchUtils.getPetResearchPetCountSum(self.model.areaId, true)

	ClientTextUtils.setText(self.view.baseProgressText, string.format("%s%s/%s", pg.getGameString("PET_MANUAL_COLLECT_PROGRESS"), caughtCount, normalCount))
end

function PetResearchCardComponent:refreshCountryRedDot()
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PET_RESEARCH_COUNTRY_REWARD, self.btnCountryUButton, function()
		if PetResearchUtils.checkHasStarRaiseInReport(self.model.areaId) then
			return RedDotConst.RedDotStyle.STAR_RAISE
		end

		if self.model:checkCountryReward(self.model.areaId, self.model.REWARD_LEVEL) then
			return RedDotConst.RedDotStyle.REWARD
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function PetResearchCardComponent:refreshPetRedDot()
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PET_RESEARCH_PET_CARD, self.listPetUList, function()
		local reddot = PetResearchUtils.checkHasPetRedDotInCountry(self.model.areaId)

		return reddot
	end)
end

function PetResearchCardComponent:setFullProgress()
	local curNum, sum = PetResearchUtils.getCountryFullProgress(self.model.areaId, self.model.showTab)

	ClientTextUtils.setText(self.curNum, curNum)
	ClientTextUtils.setText(self.allNum, sum)
end

function PetResearchCardComponent:getCurAreaCollectData()
	local isSpecies = self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES
	local countryData = isSpecies and PetCountrySpeciesCollectData[self.model.areaId] or PetCountryCollectData[self.model.areaId]

	if countryData == nil then
		return
	end

	local maxLevel = table.maxn(countryData)
	local ret = {}
	local petHandbookMap = pg.me.petHandbookMap
	local collectLevel, remainCount = isSpecies and petHandbookMap:getCountrySpeciesCollectLevel(self.model.areaId) or petHandbookMap:getCountryCollectLevel(self.model.areaId)
	local focusIdx = 0
	local rewardFocus

	for level = 1, maxLevel do
		local item = {}

		item.num = countryData[level].collectNum
		item.dropId = countryData[level].reward
		item.level = level
		item.status = isSpecies and petHandbookMap:getCountrySpeciesCollectRewardStatus(self.model.areaId, level) or petHandbookMap:getCountryCollectRewardStatus(self.model.areaId, level)

		if item.status == Const.REWARD_STATUS_INIT then
			item.buttonState = 0

			if level - collectLevel == 1 then
				item.progressValue = remainCount
				item.progressMax = item.num
			else
				item.progressValue = 0
				item.progressMax = 1
			end
		elseif item.status == Const.REWARD_STATUS_CANREWARD then
			item.buttonState = 2
			item.progressValue = 1
			item.progressMax = 1

			if not rewardFocus then
				rewardFocus = level - 1
			end
		else
			item.buttonState = 1
			item.progressValue = 1
			item.progressMax = 1
			focusIdx = level - 1
		end

		ret[#ret + 1] = item
	end

	if rewardFocus then
		focusIdx = math.max(0, rewardFocus - 1)
	else
		focusIdx = math.max(0, focusIdx - 1)
	end

	return ret, focusIdx, rewardFocus
end

function PetResearchCardComponent:setUpRewardList()
	local rewardDatas, focusIdx, _ = self:getCurAreaCollectData()

	if rewardDatas then
		self.progressNumUWidget:SetActiveFastest(true)

		self.finalRewardData = table.remove(rewardDatas)

		self:setFinalReward(self.finalRewardData)
		self.rewardList:SetList(rewardDatas)
		self.rewardList:GoToIndex(focusIdx)
		self.view.rootView:TryChangePage("BottomBoxType", 0)
	else
		self.lastRewardUButton:SetActiveFastest(false)
		self.progressNumUWidget:SetActiveFastest(false)
		self.rewardList:SetList({})
		self.view.rootView:TryChangePage("BottomBoxType", 1)
	end

	local progressStr = self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and pg.getGameString("PETMANUAL_COUNT_TXT_5_SPECIES") or pg.getGameString("PETMANUAL_COUNT_TXT_5")

	ClientTextUtils.setText(self.totalProgress, progressStr)
end

function PetResearchCardComponent:setUpCountryStar()
	local curLevel, _, _, isMax = PetResearchUtils.getCountryLevelInfo(self.model.areaId)

	self.countryLvText.text = curLevel

	self.maxUWidget:SetActiveFastest(isMax)
end

function PetResearchCardComponent:setFinalReward(data)
	self.lastRewardUButton:SetActiveFastest(true)
	self:renderReward(self.lastRewardUButton, nil, data)
end

function PetResearchCardComponent:onClickRewardDetail(button)
	button:OnClickSimulate()
end

function PetResearchCardComponent:gotoNextPetCard(forward)
	local cur = self.listPetUList.selectedIndex
	local itemCount = self.listPetUList.itemCount
	local index = forward and cur + 1 or cur - 1

	index = math.clamp(index, 0, itemCount - 1)

	self.listPetUList:GoToIndex(index)
	self.listPetUList:SelectItem(index)
end

function PetResearchCardComponent:saveListScrollPos()
	local scrollPos = self.listPetUList.normalizedScrollPosition

	self.ctrl:setScrollPosLocalCache(scrollPos)
end

function PetResearchCardComponent:onDestroy()
	self:clearCardSequence()
	self:saveListScrollPos()

	if self.listPetUList then
		self.listPetUList.luaRenderItem = nil
		self.listPetUList.luaClick = nil
		self.listPetUList.luaResetItem = nil
	end

	if self.rewardList then
		self.rewardList.luaRenderItem = nil
		self.rewardList.luaVirtualListRefreshCb = nil
	end

	UIComponent.onDestroy(self)
end

function PetResearchCardComponent:renderReward(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")
	local progress2UProgress = objectReference:GetRefValue("progress2UProgress")

	progress2UProgress.maxValue = data.progressMax
	progress2UProgress.value = data.progressValue

	local rewardList = LuaUIUtils.getRewardItemByDropId(data.dropId)
	local redDotTreePath = string.format(RedDotConst.RedDotPath.PET_RESEARCH_COUNTRY_COLLECT, data.level)

	if data.buttonState == 2 then
		pg.global.setRedDot(redDotTreePath, rewardItemUButton, true, RedDotConst.RedDotStyle.REWARD)

		rewardList[1].extraFunc = function()
			if self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
				pg.me:getPetHandbookSpeciesCollectReward(self.model.areaId, -1)
			else
				pg.me:getPetHandbookCountryCollectReward(self.model.areaId, -1)
			end
		end
	else
		pg.global.setRedDot(redDotTreePath, rewardItemUButton, false, RedDotConst.RedDotStyle.NONE)

		rewardList[1].extraFunc = nil
	end

	rewardList[1].state = data.buttonState

	LuaUIUtils.renderRewardItem(rewardItemUButton, rewardList[1])
	ClientTextUtils.setText(numUSDFText, data.num)
	button:TryChangePage("State", data.buttonState)
end

function PetResearchCardComponent:refreshPetRewardRedDot()
	self.collectRewardVx:SetActive(self.model:checkCountryReward(self.model.areaId, self.model.REWARD_LEVEL))
	self:refreshPetCardRedDotData()
	self.listPetUList:RefreshList()
end

function PetResearchCardComponent:setUpCardList()
	local focusIdx
	local startIdx = 0

	self.handleBookInfos, focusIdx = self.model:tryGetPetInfos(nil, nil, self.ctrl.focusTemplateId, self.model.areaId, self.model.showTab)
	self.focusIdx = focusIdx

	self:refreshPetCardRedDotData()
	self.listPetUList:SetList(self.handleBookInfos)
	self.btnCountryUButton:TryChangePage("IsCollection", self.model.isCollection and 1 or 0)

	if focusIdx then
		startIdx = math.max(focusIdx - 4, 0)

		self.listPetUList:GoToIndex(startIdx, true)
		self.listPetUList:SelectItem(focusIdx - 1)
	elseif not self.ctrl.focusTemplateId then
		local pos = self.ctrl:getScrollPosLocalCache()

		if pos then
			self.listPetUList.normalizedScrollPosition = pos

			local ret, minIdx, maxIdx = self.listPetUList:TryGetVisualRange()

			if ret then
				startIdx = minIdx

				local selectIdx = math.clamp(minIdx + 1, minIdx, maxIdx)

				self.listPetUList:SelectItem(selectIdx)
			end
		end
	end

	if focusIdx then
		local ret, button = self.listPetUList:TryGetChildAt(focusIdx - 1)

		if ret then
			button:SetActiveFastest(true)

			local data = self.listPetUList:GetData(button)

			data.hasShow = true

			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

			self.ctrl.focusTemplateId = nil

			self:startTimer(function()
				self:clearCardSequence()
				self:showCardSequence(startIdx)
			end, 1)

			return
		end
	end

	self.cardStartIdx = startIdx

	self:clearCardSequence()
	self:showCardSequence(self.cardStartIdx)
end

function PetResearchCardComponent:playCardAnimationSequence()
	for _, data in ipairs(self.handleBookInfos) do
		data.hasShow = false
	end

	self.listPetUList:RefreshList()
	self:clearCardSequence()

	local ret, minIdx, maxIdx = self.listPetUList:TryGetVisualRange()

	if ret then
		self.cardStartIdx = minIdx

		local selectIdx = math.clamp(minIdx + 1, minIdx, maxIdx)

		self.listPetUList:SelectItem(selectIdx)
	end

	self:showCardSequence(self.cardStartIdx)
end

function PetResearchCardComponent:clearCardSequence()
	if self.showCardTimer then
		self:killTimer(self.showCardTimer)
	end

	self.showCardTimer = nil
end

function PetResearchCardComponent:setAllCardIsShow()
	for idx, data in pairs(self.listPetUList.itemData) do
		data.hasShow = true
	end

	self.listPetUList:RefreshList()
end

function PetResearchCardComponent:showCardSequence(idx)
	local ret, btn = self.listPetUList:TryGetChildAt(idx)

	if not ret then
		self:setAllCardIsShow()

		return
	end

	local data = self.listPetUList:GetData(btn)

	btn:SetActiveFastest(true)

	data.hasShow = true

	if not self.focusIdx or idx ~= self.focusIdx - 1 then
		btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	self.showCardTimer = self:startTimer(function()
		self:showCardSequence(idx + 1)
	end, 0.02)
end

function PetResearchCardComponent:updatePetCardRedDotData(data)
	local reddotStyle
	local hasReward = PetResearchUtils.checkHasTopicRewardByTemplateId(data.templateId) and (data.state == PetResearchUtils.PET_STATE_IS_CATCH or data.state == PetResearchUtils.PET_STATE_IS_AllSTAR)

	if hasReward then
		reddotStyle = RedDotConst.RedDotStyle.REWARD
	end

	data.isShowRedDot = reddotStyle ~= nil
	data.redDotTmpKey = reddotStyle or RedDotConst.RedDotStyle.NONE

	return data.isShowRedDot, data.redDotTmpKey
end

function PetResearchCardComponent:refreshPetCardRedDotData()
	if not self.handleBookInfos then
		return
	end

	for _, data in ipairs(self.handleBookInfos) do
		self:updatePetCardRedDotData(data)
	end
end

function PetResearchCardComponent:setPetCardList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petIconUImage = objectReference:GetRefValue("petIconUImage")
	local enUText = objectReference:GetRefValue("enUText")
	local bottomName = objectReference:GetRefValue("bottomName")
	local numberUText = objectReference:GetRefValue("numberUText")
	local videoPlayerUVideoPlayer = objectReference:GetRefValue("videoPlayerUVideoPlayer")
	local circleSliderUSlider = objectReference:GetRefValue("circleSliderUSlider")
	local mainElement = objectReference:GetRefValue("mainElement")
	local subElement = objectReference:GetRefValue("subElement")
	local pointNumberUBaseText = objectReference:GetRefValue("pointNumberUBaseText")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local collectionProgressUWidget = objectReference:GetRefValue("collectionProgressUWidget")
	local pointLayoutBoxUWidget = objectReference:GetRefValue("pointLayoutBoxUWidget")
	local widgetUWidget = objectReference:GetRefValue("widgetUWidget")

	button:SetActiveFastest(data.hasShow)

	button.name = data.templateId

	if data.state ~= PetResearchUtils.PET_STATE_IS_EMPTY then
		local displayTemplateId, label, shinyStyle = PetResearchUtils.getPetDisplayFormLabelTemplateId(data.templateId, self.model.showTab, data.countryId)
		local elements = PetResearchUtils.getElementsInfo(displayTemplateId)

		LuaUIUtils.setElementButtonNew(mainElement, elements[1].element)

		if elements[2] then
			LuaUIUtils.setElementButtonNew(subElement, elements[2].element)
			subElement:SetActive(true)
		else
			subElement:SetActive(false)
		end

		button:TryChangePage("type", elements[1].element)

		local pData = PetData[displayTemplateId]

		ClientTextUtils.setText(bottomName, pg.getLocalizationText(pData.name))
		ClientTextUtils.setText(enUText, string.upper(CustomEnData[tostring(pData.name)] or ""))

		local resId = PetResearchUtils.getPetDisplayVideoResFromLabelTemplateId(data.templateId, self.model.showTab, data.countryId)

		videoPlayerUVideoPlayer:SetVideoWithCallback(resId)

		if label == Const.PET_LABEL_MASK.SHINY then
			if shinyStyle == Const.PET_SHINY_STYLE.BLACK then
				button:TryChangePage("ShineCard", 2)
			elseif shinyStyle == Const.PET_SHINY_STYLE.WHITE then
				button:TryChangePage("ShineCard", 3)
			else
				button:TryChangePage("ShineCard", 0)
			end
		else
			button:TryChangePage("ShineCard", 1)
		end

		petIconUImage.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK, label)

		local isSpecies = self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES

		if isSpecies then
			local curHasCnt, totalCnt = PetResearchUtils.getPetTypeNum(data.templateId, data.countryId)

			ClientTextUtils.setText(textNumUSDFText, string.format("%d/%d", curHasCnt, totalCnt))
		end

		collectionProgressUWidget:SetActiveFastest(isSpecies)
	else
		button:TryChangePage("ShineCard", 1)
		collectionProgressUWidget:SetActiveFastest(false)
	end

	button:TryChangePage("stage", data.state)

	videoPlayerUVideoPlayer.grayed = data.state == 2

	if not PetAvatarData[data.templateId] then
		logger:info(data.templateId .. " 没配宠物_研究手册配置表.txt / 宠物形态配置表 读不到解锁奖励：")
	else
		pointLayoutBoxUWidget:SetActiveFastest(not self.model.isCollection)

		if not self.model.isCollection then
			local dropId = PetAvatarData[data.templateId][0].reward

			ClientTextUtils.setText(pointNumberUBaseText, "+", PetResearchUtils.getRewardResearchPoint(dropId or 0))
		end
	end

	local displayNumber = data.displayNumber or PetResearchUtils.getResearchDisplayNumber(data.templateId, self.model.areaId, self.model.showTab)

	ClientTextUtils.setText(numberUText, displayNumber)

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(numberUText, numberUText.text, "-", tostring(data.templateId))
	end

	if self.model.isCollection then
		circleSliderUSlider:SetActiveFastest(false)
		widgetUWidget:SetActiveFastest(false)
	else
		circleSliderUSlider:SetActiveFastest(true)
		widgetUWidget:SetActiveFastest(true)

		if data.state == PetResearchUtils.PET_STATE_IS_CATCH or data.state == PetResearchUtils.PET_STATE_IS_AllSTAR then
			circleSliderUSlider.normalizedValue = data.exp / data.needExp

			button:TryChangePage("Crown", PetResearchUtils.LEVEL_QUALITY_NAME[data.level])
		end
	end

	local redDotTreePath = string.format(RedDotConst.RedDotPath.PET_RESEARCH_PET_CARD_ITEM, data.templateId)
	local showRedDot, reddotStyle = self:updatePetCardRedDotData(data)

	if showRedDot then
		pg.global.setRedDot(redDotTreePath, button, true, reddotStyle)
	else
		pg.global.setRedDot(redDotTreePath, button, false, reddotStyle)
	end
end

function PetResearchCardComponent:onPetDisplayChanged(templateId, formTemplateId, label)
	self:refreshPetCardRedDotData()
	self.listPetUList:RefreshList()
end

function PetResearchCardComponent:setRewardList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("icon")
	local countNum = objectReference:GetRefValue("txtNum")

	ClientTextUtils.setText(countNum, data.count)

	icon.url = data.icon

	button:TryChangePage("Quality", data.quality)
	button:TryChangePage("State", data.state)
end

function PetResearchCardComponent:_refreshBtnSwitch()
	local isSpecies = self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES

	self.view.rootView:TryChangePage("Type", isSpecies and 0 or 1)
	ClientTextUtils.setText(self.switchNameUSDFText, pg.getGameString(PetResearchUtils.ShowTabName[self.model.showTab]))
	self:refreshBtnSwitchRedDot()
end

function PetResearchCardComponent:refreshBtnSwitchRedDot()
	local invTab = self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and PetResearchUtils.PET_SHOW_TAB.FORM or PetResearchUtils.PET_SHOW_TAB.SPECIES
	local hasReward = PetResearchUtils.checkCountryReward(self.model.areaId, invTab, PetResearchUtils.REWARD_COLLECT)

	pg.global.setRedDot(RedDotConst.RedDotPath.PET_RESEARCH_SHOW_TAB, self.btnSwitchUButton, hasReward, RedDotConst.RedDotStyle.REWARD)
end

function PetResearchCardComponent:onUICtrlVisible()
	local showTab = PetResearchUtils.getLastPetShowTab()
	local isSame = showTab == self.model.showTab

	self:onPetShowTabChanged(showTab)
	self:refreshCountryRedDot()

	if isSame then
		self:playCardAnimationSequence()
	end
end

function PetResearchCardComponent:onPetShowTabChanged(showTab)
	if self.model.showTab == showTab then
		return
	end

	self:saveListScrollPos()

	self.model.showTab = showTab

	self:_refreshBtnSwitch()
	self:setUpCardList()
	self:setUpRewardList()
	self:refreshPetNumInfo()
	self:setFullProgress()
	self:refreshPetRedDot()
end

return PetResearchCardComponent
