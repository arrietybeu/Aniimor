-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetReport\\Component\\ResearchPointReportComponent.lua

local PetResearchReportSortData = require("Data.pet_research_report_sort_data")
local Class = require("Core.Framework.Class")
local PetResearchCountryLevelData = require("Data.pet_research_country_level_data")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PlayerLevelData = require("Data.player_level_data")
local HandBookVbData = require("Data.handbook_vb_config_data")
local DoTweenAnimMgr = DoTweenAnimMgr
local FINAL_INCREASE_TWEEN_ID = "finalInCrease"
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local PetResearchContentData = require("Data.pet_research_content_data")
local ResearchPointReportComponent = Class.LightClass("ResearchPointReportComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local CountryAreaIndexData = require("Data.country_area_index_data")
local CountryAreaData = require("Data.country_area_data")
local LevelData = require("Data.player_level_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local UIUtils = UIUtils
local PET_LIST_COUNT = 36
local TOP_PET_COUNT = 3
local MIN_ITEM_COUNT = 9

function ResearchPointReportComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petItem1 = self.objectReference:GetRefValue("petItem1")
	self.petItem2 = self.objectReference:GetRefValue("petItem2")
	self.petItem3 = self.objectReference:GetRefValue("petItem3")
	self.petListUList = self.objectReference:GetRefValue("petListUList")
	self.resultListUList = self.objectReference:GetRefValue("resultListUList")
	self.btnNextStepUButton = self.objectReference:GetRefValue("btnNextStepUButton")
	self.pointFlyNodeUWidget = self.objectReference:GetRefValue("pointFlyNodeUWidget")
	self.btnSkipVxUButton = self.objectReference:GetRefValue("btnSkipVxUButton")
	self.submitText = self.objectReference:GetRefValue("submitText")
	self.researchLevelProgress = self.objectReference:GetRefValue("researchLevelProgress")
	self.researchLvTxt = self.objectReference:GetRefValue("researchLvTxt")
	self.roleExpTxt = self.objectReference:GetRefValue("roleExpTxt")
	self.pointIconTrans = self.objectReference:GetRefValue("pointIconTrans")
	self.btnManualUButton = self.objectReference:GetRefValue("btnManualUButton")
	self.bottomUWidget = self.objectReference:GetRefValue("bottomUWidget")
	self.researchExp = self.objectReference:GetRefValue("researchExp")
	self.maxUWidget = self.objectReference:GetRefValue("maxUWidget")
	self.promoteUWidget = self.objectReference:GetRefValue("promoteUWidget")
	self.txtManualLevelUSDFText = self.objectReference:GetRefValue("txtManualLevelUSDFText")
	self.bottomAnimation = self.bottomUWidget:GetComponent("Animation")
end

function ResearchPointReportComponent:initView()
	function self.petListUList.luaRenderItem(button, idx, data)
		self:renderPetResearchItem(button, data)
	end

	function self.resultListUList.luaRenderItem(button, idx, data)
		self:renderResearchItem(button, data)
	end

	function self.btnNextStepUButton.luaClick()
		if self.hasNextArea == true then
			self:showNextReportCountry()
		else
			self.ctrl:dismiss()
		end
	end

	function self.btnSkipVxUButton.luaClick()
		if self.model.isFirstEnter then
			return
		end

		if self.canSkip then
			self:skipVx()
		end
	end

	self.startResearchExp = 0
	self.researchExp.text = 0
	self.curResearchExp = 0
	self.btnManualUButton.enabledTooltip = false

	function self.btnManualUButton.luaRenderTooltip(button, popup)
		local desc = string.format("%d/%d", self.researchLevelProgress.value, self.researchLevelProgress.maxValue)

		LuaUIUtils.renderCommonSmallTip(popup, pg.getGameString("CURRENT_RESEARCH_EXP"), desc)
	end

	self.btnNextStepUButton:TryChangePage("BtnState", 1)

	self.vxIsCompleted = false

	self:showFirstReportCountry()
	self.view.txtTitleUSDFText:SetActiveFastest(false)
end

function ResearchPointReportComponent:initPlayerLevelData()
	local info = LuaUIUtils.getPlayerInfo()

	self.curPlayerExp = info.curExp
	self.curPlayerLevel = info.curLev
	self.curPlayerStar = info.curSta
	self.playerLevel_Start = self.curPlayerLevel
	self.playerCurExp_Start = self.curPlayerExp
end

function ResearchPointReportComponent:setReportWaitingState()
	self.canSkip = false

	self.view.txtTitleUSDFText:SetActiveFastest(false)
	self.btnNextStepUButton:TryChangePage("BtnState", 1)
	self.btnSkipVxUButton:SetActive(false)

	self.vxIsCompleted = false

	if self.ctrl then
		self.ctrl:refreshConsoleBarState()
	end
end

function ResearchPointReportComponent:startReportVx()
	self.canSkip = true

	self.view.txtTitleUSDFText:SetActiveFastest(true)
	self.btnNextStepUButton:TryChangePage("BtnState", 1)
	self.btnSkipVxUButton:SetActive(self.model.isFirstEnter ~= true)

	self.vxIsCompleted = false

	if self.ctrl then
		self.ctrl:refreshConsoleBarState()
	end

	self:showPetListSequence(1)
end

function ResearchPointReportComponent:setReportCompletedState()
	self.canSkip = false

	self.btnSkipVxUButton:SetActive(false)
	self.btnNextStepUButton:TryChangePage("BtnState", 0)

	self.vxIsCompleted = true

	if self.ctrl then
		self.ctrl:refreshConsoleBarState()
	end
end

function ResearchPointReportComponent:cancelNextReportStartTimer()
	if self.nextReportStartTimer then
		self:killTimer(self.nextReportStartTimer)

		self.nextReportStartTimer = nil
	end
end

function ResearchPointReportComponent:skipVx()
	self:cancelNextReportStartTimer()
	self:setReportCompletedState()

	if self.petTimer then
		self:killTimer(self.petTimer)

		self.petTimer = nil
	end

	for idx = 1, TOP_PET_COUNT do
		if self.top3Pet[idx] then
			self.top3Pet[idx].isShow = true

			self:renderPetResearchItem(self["petItem" .. idx], self.top3Pet[idx])
		end
	end

	for idx, data in ipairs(self.petDatas) do
		data.isShow = true
	end

	self.petListUList:RefreshList()

	if self.itemTimer then
		self:killTimer(self.itemTimer)

		self.itemTimer = nil
	end

	for idx, data in ipairs(self.itemDatas) do
		data.isShow = true
	end

	self.resultListUList:RefreshList()
	self:increaseFinalPoint()
end

function ResearchPointReportComponent:setCurResearchProgress(countryId)
	local curLevel, remain, needExp, isMax = PetResearchUtils.getCountryLevelInfo(countryId)

	self.curCountryLevel = curLevel
	self.researchLevelProgress.maxValue = needExp
	self.researchLevelProgress.value = remain
	self.researchLvTxt.text = curLevel

	self.maxUWidget:SetActiveFastest(isMax)
end

function ResearchPointReportComponent:setCurPlayerLvProgress()
	local levelCfg = LevelData[self.curPlayerLevel + 1]

	if levelCfg == nil then
		levelCfg = LevelData[self.curPlayerLevel]
	end

	self.playerLevelProgress.maxValue = levelCfg.needExp
	self.playerLevelProgress.value = self.curPlayerExp or 0
	self.playerLvTxt.text = self.curPlayerLevel
end

function ResearchPointReportComponent:playStarProgress(level, researchData, curValue, addValue)
	if not researchData or not researchData[level] then
		self.researchExp.text = addValue or 0

		self:_researchLevelVXInner()

		return
	end

	if researchData[level] then
		local targetValue = curValue + addValue
		local nextLevel = level + 1
		local isMax = researchData[nextLevel] == nil
		local needValue

		if isMax then
			needValue = researchData[level].needResearchPoint - (researchData[level - 1].needResearchPoint or 0)
			self.researchLevelProgress.value = needValue
			self.researchLevelProgress.maxValue = needValue
			self.researchLvTxt.text = level

			self.maxUWidget:SetActiveFastest(true)
			self:_playStarTextAnim(curValue, targetValue, 0.5, function()
				self:_researchLevelVXInner()
			end)

			return
		else
			needValue = researchData[nextLevel].needResearchPoint - (researchData[level].needResearchPoint or 0)
			self.researchLevelProgress.value = curValue
			self.researchLevelProgress.maxValue = needValue

			if needValue <= targetValue then
				self:_playStarTextAnim(curValue, needValue, 0.5)
				self.researchLevelProgress:ProgressToValue(needValue, function()
					self.researchLvTxt.text = nextLevel

					self.maxUWidget:SetActiveFastest(researchData[nextLevel + 1] == nil)
					self.btnManualUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

					self.startResearchExp = self.startResearchExp + needValue

					self:playStarProgress(nextLevel, researchData, 0, targetValue - needValue)
				end, 0.5)
			else
				self:_playStarTextAnim(curValue, targetValue, 0.5)
				self.researchLevelProgress:ProgressToValue(targetValue, function()
					self:_researchLevelVXInner()
				end, 0.5)
			end
		end
	end
end

function ResearchPointReportComponent:_playStarTextAnim(curValue, targetValue, duration, callback)
	self:_stopStarTextAnim()

	self.textAnimCurTime = 0
	self.researchExp.text = curValue
	self.textTimerId = self.ctrl:startTimer(function()
		self.textAnimCurTime = Time.unscaledDeltaTime + self.textAnimCurTime

		local t = self.textAnimCurTime / duration

		if t > 1 then
			t = 1
		end

		self.researchExp.text = math.floor(curValue + (targetValue - curValue) * t) + self.startResearchExp - self.curResearchExp

		if t >= 1 then
			if callback then
				callback()
			end

			self:_stopStarTextAnim()
		end
	end, 0, true)
end

function ResearchPointReportComponent:_stopStarTextAnim()
	if self.textTimerId then
		self.ctrl:killTimer(self.textTimerId)

		self.textTimerId = nil
	end
end

function ResearchPointReportComponent:_researchLevelVXInner()
	self:setReportCompletedState()
	self.bottomUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)

	self.btnManualUButton.enabledTooltip = true
end

function ResearchPointReportComponent:_getCurCountryHasLv(areaId)
	if areaId then
		return PetResearchCountryLevelData[areaId] ~= nil
	end

	return false
end

function ResearchPointReportComponent:inCreasePlayerExp()
	local addPlayerExp = self.reportPoint * HandBookVbData.playerExpFromReport

	self.roleExp.text = addPlayerExp

	self.promoteExpUWidget:SetActive(true)

	self.playerLevel_Start = self.curPlayerLevel
	self.playerCurExp_Start = self.curPlayerExp

	self:playPlayerProgress(self.curPlayerLevel, self.curPlayerExp, addPlayerExp, self.curPlayerStar)
end

function ResearchPointReportComponent:playPlayerProgress(level, curValue, addValue, starTitle)
	local curLevelData = PlayerLevelData[level]
	local levelData = PlayerLevelData[level + 1]

	if not curLevelData or not levelData then
		self:setReportCompletedState()

		return
	end

	local curNeedTitle = curLevelData.needTitle

	if levelData then
		local targetValue = curValue + addValue
		local needValue = levelData.needExp

		self.playerLevelProgress.maxValue = needValue
		self.playerLevelProgress.value = curValue
		self.playerLvTxt.text = level

		if needValue <= targetValue and (not curNeedTitle or curNeedTitle <= starTitle) then
			self.playerLevelProgress:ProgressToValue(needValue, function()
				pg.game.audio:playEvent("SFX_UI_Submit_RoleUpgrade")

				self.curPlayerLevel = level + 1

				self.btnRoleUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
				self:playPlayerProgress(self.curPlayerLevel, 0, targetValue - needValue, starTitle)
			end, 0.5)
		else
			self.curPlayerExp = targetValue

			self.playerLevelProgress:ProgressToValue(targetValue, function()
				self:setReportCompletedState()
			end, 0.5)
		end
	end
end

function ResearchPointReportComponent:setPetResearchList(countryId)
	local ret, normalRet = self:getPetResearchDatas(countryId)

	self.top3Pet = ret
	self.petDatas = normalRet

	for idx = 1, TOP_PET_COUNT do
		self:renderPetResearchItem(self["petItem" .. idx], self.top3Pet[idx])
	end

	if normalRet[#normalRet].isEmpty then
		self.petListUList:SetScrollDisabled(true)

		self.petListScrollDisabled = true
	else
		self.petListUList:SetScrollDisabled(false)

		self.petListScrollDisabled = false
	end

	self.petListUList:SetList(normalRet)
end

function ResearchPointReportComponent:onSwitchThisPage()
	self:startReportVx()
	self:setGamepad()
end

function ResearchPointReportComponent:onExitThisPage()
	self:cancelNextReportStartTimer()

	if self.leftMoveTimer then
		self.ctrl:killTimer(self.leftMoveTimer)

		self.leftMoveTimer = nil
	end

	if self.rightMoveTimer then
		self.ctrl:killTimer(self.rightMoveTimer)

		self.rightMoveTimer = nil
	end
end

function ResearchPointReportComponent:showPetListSequence(idx)
	if idx <= self.realPetLen then
		if idx <= TOP_PET_COUNT then
			local button = self["petItem" .. idx]

			if button and self.top3Pet[idx] then
				self:petAppearVx(button, self.top3Pet[idx])
			end
		else
			local index = idx - TOP_PET_COUNT - 1
			local ret, button = self.petListUList:TryGetChildAt(index)
			local _, min, max = self.petListUList:TryGetVisualRange()
			local colCount = self:getColCount()

			if index > max - colCount then
				local targetIdx = min + colCount

				self.petListUList:GoToIndex(targetIdx)
			end

			if ret then
				local data = self.petListUList:GetData(index)

				self:petAppearVx(button, data)
			end
		end

		self.petTimer = self:startTimer(function()
			self:showPetListSequence(idx + 1)
		end, 0.2)
	else
		self:showResultItemSequence(1)
	end
end

function ResearchPointReportComponent:getColCount()
	if not self.colCount then
		self.colCount = self.petListUList:GetCrossAxisRealCount()
	end

	return self.colCount
end

function ResearchPointReportComponent:petAppearVx(button, data)
	button:TryChangePage("IsEmpty", 0)

	data.isShow = true

	pg.game.audio:playEvent("SFX_UI_SubmitUpload_AniimoShow")
	button:TryChangePage("CrownHide", 1)

	if data.starRaise then
		button:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)
	else
		button:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	self:startTimer(function()
		self:crownProgress(button, data)
	end, 0.5)
end

function ResearchPointReportComponent:crownProgress(button, data, final)
	local objectReference = button:GetComponent("ObjectReference")
	local slider = objectReference:GetRefValue("circleSliderUSlider")
	local researchPointInfo = data.researchPointInfo
	local level = researchPointInfo.level
	local templateId = data.templateId
	local point = data.point
	local curExp = researchPointInfo.exp
	local researchContent = PetResearchContentData[templateId]
	local needResearchPoint = researchContent.needResearchPoint or {}
	local remainExp = curExp + point
	local targetLevel = level

	for l = level + 1, Const.PET_RESEARCH_REWARD_LEVEL_MAX do
		local needExp = needResearchPoint[l] or 0

		remainExp = remainExp - needExp

		if remainExp < 0 then
			targetLevel = l

			break
		end
	end

	if final then
		slider:TryChangePage("Crown", PetResearchUtils.LEVEL_QUALITY_NAME[targetLevel - 1])

		slider.maxValue = needResearchPoint[targetLevel] or 0
		slider.value = (needResearchPoint[targetLevel - 1] or 0) + remainExp
	elseif targetLevel - level > 1 then
		slider:ProgressToValue(needResearchPoint[level + 1], function()
			slider:TryChangePage("Crown", PetResearchUtils.LEVEL_QUALITY_NAME[targetLevel - 1])

			slider.maxValue = needResearchPoint[targetLevel]
			slider.value = needResearchPoint[targetLevel] + remainExp
		end, 0.45)
	else
		slider:ProgressToValue(curExp + point, function()
			return
		end, 0.45)
	end
end

function ResearchPointReportComponent:setUpResearchItem(countryId)
	self.itemDatas = self:getResearchItemDatas(countryId)

	self.resultListUList:SetList(self.itemDatas)
end

function ResearchPointReportComponent:findNextCountryHasReport()
	local allCount = #self.model.allReportPointArea

	self.countryIndex = self.countryIndex and self.countryIndex + 1 or 1

	return allCount >= self.countryIndex
end

function ResearchPointReportComponent:showFirstReportCountry()
	local ret = self:findNextCountryHasReport()

	if ret == true then
		self:setupItemAndResultList()
	else
		self.hasNextArea = false

		ClientTextUtils.setText(self.submitText, pg.getGameString("PET_REPORT_SUBMIT"))
	end
end

function ResearchPointReportComponent:showNextReportCountry()
	self:cancelNextReportStartTimer()
	self:setReportWaitingState()
	self:setupItemAndResultList()

	self.nextReportStartTimer = self:startTimer(function()
		self.nextReportStartTimer = nil

		self:startReportVx()
	end, 0.5)
end

function ResearchPointReportComponent:setupItemAndResultList()
	self.researchLevelProgress:KillProcessAnim()
	self:_stopStarTextAnim()

	self.startResearchExp = 0
	self.curResearchExp = 0
	self.researchExp.text = 0
	self.countryIndex = self.countryIndex or 1

	local info = self.model.allReportPointArea[self.countryIndex]

	if info then
		self.inProgress = false
		self.curAreaId = info.areaId
		self.hasCountryLv = self:_getCurCountryHasLv(self.curAreaId)
		self.reportPoint = info.reportPoint

		self.btnManualUButton:SetActive(self.hasCountryLv)
		UIUtils.SampleAnimation(self.bottomAnimation, 0, "VX_Ani_PetManual_SubmitPetReport_GetPoint02")
		self:setUpResearchItem(self.curAreaId)
		self:setPetResearchList(self.curAreaId)
		self:setCurResearchProgress(self.curAreaId)

		local cfgData = CountryAreaData[self.curAreaId]
		local countryName = pg.getLocalizationText(cfgData.name)

		ClientTextUtils.setText(self.view.txtTitleUSDFText, countryName)
		ClientTextUtils.setText(self.txtManualLevelUSDFText, countryName)
	end

	self.hasNextArea = self:findNextCountryHasReport()

	if self.hasNextArea == false then
		ClientTextUtils.setText(self.submitText, pg.getGameString("PET_REPORT_SUBMIT"))
	end
end

function ResearchPointReportComponent:refreshPlayerExpShow()
	if not self.reportPoint or self.reportPoint == 0 then
		return
	end

	local addPlayerExp = self.reportPoint * HandBookVbData.playerExpFromReport
	local curLevel = self.playerLevel_Start
	local curExp = self.playerCurExp_Start
	local maxExp = curExp

	while addPlayerExp > 0 do
		local curLevelData = PlayerLevelData[curLevel]
		local nextLevelData = PlayerLevelData[curLevel + 1]

		if curLevelData and nextLevelData then
			local curNeedTitle = curLevelData.needTitle

			maxExp = nextLevelData.needExp

			local needExp = nextLevelData.needExp - curExp

			if needExp <= addPlayerExp then
				if not curNeedTitle or curNeedTitle <= self.curPlayerStar then
					curLevel = curLevel + 1
					curExp = 0
					addPlayerExp = addPlayerExp - needExp
				else
					curExp = nextLevelData.needExp
					addPlayerExp = 0
				end
			else
				curExp = curExp + addPlayerExp
				addPlayerExp = 0
			end
		else
			addPlayerExp = 0
		end
	end

	self.curPlayerLevel = curLevel
	self.curPlayerExp = curExp
	self.playerLvTxt.text = curLevel
	self.playerLevelProgress.maxValue = maxExp
	self.playerLevelProgress.value = curExp
end

function ResearchPointReportComponent:renderPetResearchItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local pointsUSDFText = objectReference:GetRefValue("pointsUSDFText")
	local circleSliderUSlider = objectReference:GetRefValue("circleSliderUSlider")

	if data.isEmpty then
		button:TryChangePage("IsEmpty", 1)
	else
		if data.isShow then
			button:TryChangePage("IsEmpty", 0)
			button:TryChangePage("CrownHide", 1)
			self:crownProgress(button, data, true)
		else
			button:TryChangePage("IsEmpty", 1)
			button:TryChangePage("CrownHide", 0)

			local researchPointInfo = data.researchPointInfo

			circleSliderUSlider:TryChangePage("Crown", PetResearchUtils.LEVEL_QUALITY_NAME[researchPointInfo.level])

			circleSliderUSlider.maxValue = researchPointInfo.needExp
			circleSliderUSlider.value = researchPointInfo.exp
		end

		iconUImage.url = data.icon

		ClientTextUtils.setText(pointsUSDFText, "+", data.point)
	end
end

function ResearchPointReportComponent:renderResearchItem(button, data)
	if data.isEmpty then
		button:TryChangePage("Empty", 1)
	else
		if data.isShow then
			button:TryChangePage("Empty", 0)
		else
			button:TryChangePage("Empty", 1)
		end

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local titleUSDFText = objectReference:GetRefValue("titleUSDFText")
		local timesUSDFText = objectReference:GetRefValue("timesUSDFText")
		local pointsUSDFText = objectReference:GetRefValue("pointsUSDFText")
		local vXPointGeneralCoinGeneral = objectReference:GetRefValue("vXPointGeneralCoinGeneral")

		function vXPointGeneralCoinGeneral.luaEndFly()
			self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			pg.game.audio:playEvent("SFX_UI_SubmitPoint_03")
			self.bottomUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			self:increaseFinalPoint()
		end

		function vXPointGeneralCoinGeneral.luaGeneralCoin()
			pg.game.audio:playEvent("SFX_UI_SubmitPoint_01")
		end

		function vXPointGeneralCoinGeneral.luaStartFly()
			pg.game.audio:playEvent("SFX_UI_SubmitPoint_02")
		end

		iconUImage.url = data.icon

		ClientTextUtils.setText(titleUSDFText, data.title)
		ClientTextUtils.setText(timesUSDFText, data.count)
		ClientTextUtils.setText(pointsUSDFText, data.researchPoint)
	end
end

function ResearchPointReportComponent:increaseFinalPoint()
	if not self.hasCountryLv then
		self:_researchLevelVXInner()

		return
	end

	if not self.inProgress then
		self.inProgress = true

		local researchData = PetResearchCountryLevelData[self.curAreaId] or {}

		self.promoteUWidget:SetActive(true)

		self.curResearchExp = self.researchLevelProgress.value

		self:playStarProgress(self.curCountryLevel, researchData, self.researchLevelProgress.value, self.reportPoint)
	end
end

function ResearchPointReportComponent:showResultItemSequence(idx)
	if idx > self.realUnlockItemCount then
		local _, min, max = self.resultListUList:TryGetVisualRange()

		self.resultListUList:UnRegisterToScrollEndEvent(self.scrollEnd)

		self.scrollEnd = nil

		if min > self.realUnlockItemCount - 1 then
			self:increaseFinalPoint()
		else
			self:FlyPointSequence(min)
		end

		return
	end

	local _, min, max = self.resultListUList:TryGetVisualRange()
	local index = idx - 1

	if max < index then
		self.resultListUList:GoToIndex(index - 5)

		function self.scrollEnd()
			self:showResultItemSequence(idx)
		end

		self.resultListUList:RegisterToScrollEndEvent(self.scrollEnd)

		return
	end

	if self.scrollEnd then
		self.resultListUList:UnRegisterToScrollEndEvent(self.scrollEnd)

		self.scrollEnd = nil
	end

	local flag, button = self.resultListUList:TryGetChildAt(index)

	if flag then
		local data = self.resultListUList:GetData(index)

		data.isShow = true

		button:TryChangePage("Empty", 0)
		pg.game.audio:playEvent("SFX_UI_SubmitUpload_ClassActive")
		button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

		self.itemTimer = self:startTimer(function()
			self:showResultItemSequence(idx + 1)
		end, 0.5)
	else
		self.itemTimer = self:startTimer(function()
			self:showResultItemSequence(idx + 1)
		end, 0.1)
	end
end

function ResearchPointReportComponent:FlyPointSequence(idx)
	if not self.hasCountryLv or idx > self.realUnlockItemCount - 1 then
		self:increaseFinalPoint()

		return
	end

	local flag, button = self.resultListUList:TryGetChildAt(idx)
	local data = self.resultListUList:GetData(idx)

	if not flag or not button or not data then
		self:increaseFinalPoint()

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local vXPointGeneralCoinGeneral = objectReference:GetRefValue("vXPointGeneralCoinGeneral")
	local pointIconTrans = objectReference:GetRefValue("pointIconTrans")

	vXPointGeneralCoinGeneral.subParent = self.pointFlyNodeUWidget.transform
	vXPointGeneralCoinGeneral.targetPosition = self.pointIconTrans.position
	vXPointGeneralCoinGeneral.sourcePosition = pointIconTrans.position

	local coinCount = math.clamp(math.floor(data.count / 20), 1, 5)

	vXPointGeneralCoinGeneral:PlayCoin(coinCount)

	for _ = 1, coinCount do
		pg.game.audio:playEvent("SFX_UI_SubmitPoint")
	end

	self:startTimer(function()
		self:FlyPointSequence(idx + 1)
	end, 0.2)
end

function ResearchPointReportComponent:getPetResearchDatas(countryId)
	local ret = {}

	for petPrototypeId, prcdd in pairs(PetResearchContentData) do
		local info = pg.me.petHandbookMap[petPrototypeId]

		if info and prcdd.countryId == countryId then
			local point = info.researchPointMap:getTotalPoint()

			if point > 0 then
				local item = {}

				item.icon = LuaUIUtils.getPetIconByTemplateId(petPrototypeId, LuaUIUtils.PET_ICON)
				item.templateId = petPrototypeId

				local researchPointInfo = PetResearchUtils.getPetResearchPoint(petPrototypeId)
				local reportPoint = point

				if reportPoint > researchPointInfo.needExp then
					item.starRaise = true
				end

				item.point = reportPoint
				item.researchPointInfo = researchPointInfo
				ret[#ret + 1] = item
			end
		end
	end

	self.realPetLen = math.min(#ret, TOP_PET_COUNT + PET_LIST_COUNT)

	table.sort(ret, function(a, b)
		if a.starRaise and b.starRaise then
			return a.point > b.point
		elseif a.starRaise then
			return true
		else
			return false
		end
	end)

	local top3Ret = {}

	for idx = 1, TOP_PET_COUNT do
		if ret[idx] then
			top3Ret[idx] = ret[idx]
		else
			top3Ret[idx] = {
				isEmpty = true,
				point = 0
			}
		end
	end

	local normalRet = {}

	for idx = 1, PET_LIST_COUNT do
		if ret[idx + TOP_PET_COUNT] then
			normalRet[idx] = ret[idx + TOP_PET_COUNT]
		else
			normalRet[idx] = {
				isEmpty = true,
				point = 0
			}
		end
	end

	return top3Ret, normalRet
end

function ResearchPointReportComponent:getResearchItemDatas(countryId)
	local researchReportMap = pg.me.petHandbookMap.petCountryMap[countryId].researchReportMap
	local ret = {}

	self.realUnlockItemCount = 0

	for id, info in pairs(PetResearchReportSortData) do
		local serverData = researchReportMap[id]

		if serverData then
			local item = {}

			item.icon = info.icon
			item.title = pg.getLocalizationText(info.desc)
			item.count = serverData.count
			item.researchPoint = serverData.researchPoint
			item.sortId = id
			self.realUnlockItemCount = self.realUnlockItemCount + 1
			ret[#ret + 1] = item
		end
	end

	table.sort(ret, function(a, b)
		return a.sortId < b.sortId
	end)

	for idx = #ret, MIN_ITEM_COUNT do
		local item = {}

		item.isEmpty = true
		ret[#ret + 1] = item
	end

	return ret
end

function ResearchPointReportComponent:onDestroy()
	self.canSkip = nil

	UIComponent.onDestroy(self)
end

function ResearchPointReportComponent:setGamepad()
	self.ctrl:bindHotKeyPerform("Raw/GamepadSelect", function()
		self.btnTooltipGamepad(self.btnRoleUButton)
	end)
	self.ctrl:bindHotKeyPerform("Raw/GamepadStart", function()
		self.btnTooltipGamepad(self.btnManualUButton)
	end)

	local nextBtnOC = self.btnNextStepUButton.transform:GetComponent("ObjectReference")
	local nextBtnKeyContent = nextBtnOC:GetRefValue("keyHotKeyContent")

	nextBtnKeyContent:SetHotKeyPaths("Raw/GamepadButtonNorth")
	self.ctrl:bindHotKeyPerform("Raw/GamepadButtonNorth", function()
		if self.vxIsCompleted == true then
			self.btnNextStepUButton:OnClickSimulate()
		end
	end, self.btnNextStepUButton.gameObject)
	self.ctrl:bindHotKeyPerform("Raw/GamepadButtonSouth", function()
		self.btnSkipVxUButton:OnClickSimulate()
	end, self.btnSkipVxUButton.gameObject)

	local leftMoveGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.petListUList.gameObject, "leftMoveGamepadBinding")

	leftMoveGamepadBinding.actionPath = "Raw/GamepadLeftStickMove"
	leftMoveGamepadBinding.isVirtual = true
	leftMoveGamepadBinding.priority = -1

	function leftMoveGamepadBinding.luaTrigger(inputInfo)
		if self.petListScrollDisabled == true then
			return
		end

		if self.vxIsCompleted == false then
			return
		end

		self.leftDelta = inputInfo.valueVec2.y / 100

		if inputInfo.phase == "Performed" then
			if self.leftMoveTimer == nil then
				self.leftMoveTimer = self.ctrl:startTimer(function()
					local targetPos = self.petListUList.normalizedScrollPosition

					targetPos.y = targetPos.y + self.leftDelta
					targetPos.y = math.clamp(targetPos.y, 0, 1)
					self.petListUList.normalizedScrollPosition = targetPos
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.leftMoveTimer then
			self.ctrl:killTimer(self.leftMoveTimer)

			self.leftMoveTimer = nil
		end
	end

	local rightMoveGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.resultListUList.gameObject, "rightMoveGamepadBinding")

	rightMoveGamepadBinding.actionPath = "Raw/GamepadRightStickMove"
	rightMoveGamepadBinding.isVirtual = true
	rightMoveGamepadBinding.priority = -1

	function rightMoveGamepadBinding.luaTrigger(inputInfo)
		if self.vxIsCompleted == false then
			return
		end

		self.rightDelta = inputInfo.valueVec2.y / 100

		if inputInfo.phase == "Performed" then
			if self.rightMoveTimer == nil then
				self.rightMoveTimer = self.ctrl:startTimer(function()
					local targetPos = self.resultListUList.normalizedScrollPosition

					targetPos.y = targetPos.y + self.rightDelta
					targetPos.y = math.clamp(targetPos.y, 0, 1)
					self.resultListUList.normalizedScrollPosition = targetPos
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.rightMoveTimer then
			self.ctrl:killTimer(self.rightMoveTimer)

			self.rightMoveTimer = nil
		end
	end

	LuaUIUtils.setUIVisible(self.view.consoleBarTransform, true)
	LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, {
		right = {
			{
				path = "Raw/GamepadLeftStickMove",
				label = pg.getGameString("CONSOLE_BAR_SCROLL_LEFT")
			},
			{
				path = "Raw/GamepadRightStickMove",
				label = pg.getGameString("CONSOLE_BAR_SCROLL_RIGHT")
			},
			{
				path = "Raw/GamepadSelect",
				label = pg.getGameString("CONSOLE_BAR_ROLE_LEVEL")
			},
			{
				path = "Raw/GamepadStart",
				label = pg.getGameString("CONSOLE_BAR_RESEARCH_LEVEL")
			}
		}
	})
end

function ResearchPointReportComponent.btnTooltipGamepad(btn)
	local hasOpen = btn.isTooltipOpen

	if hasOpen == true then
		btn:CloseTooltip()
	else
		btn:OnClickSimulate()
	end
end

return ResearchPointReportComponent
