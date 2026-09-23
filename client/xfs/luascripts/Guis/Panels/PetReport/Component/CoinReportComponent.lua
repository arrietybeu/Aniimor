-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetReport\\Component\\CoinReportComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CoinReportComponent")
local lume = require("Core.Common.lume")
local ItemConst = require("Common.Const.ItemConst")
local Utils = require("Common.Utils.Utils")
local DoTweenAnimMgr = DoTweenAnimMgr
local PetCaptureReportSortData = require("Data.pet_capture_report_sort_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local UIComponent = require("Guis.Helper.UIComponent")
local PetReportTopicItem = require("Guis.Panels.PetReport.Component.PetReportTopicItem")
local CallbackHandler = require("Core.Common.CallbackHandler")
local CoinReportComponent = Class.LightClass("CoinReportComponent", UIComponent)
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PET_ITEM_MIN_COUNT = 42
local ClientTextUtils = require("Utils.ClientTextUtils")
local VX_PHASE_1 = 1
local VX_PHASE_2 = 2
local ANIM_SHINY_TIME = "VX_Ani_PetManual_SubmitPetReport_GetFlash"
local ANIM_SHINY_TIME_OUT = "VX_Ani_PetManual_SubmitPetReport_GetFlash_Out"
local PET_GRID = {
	itemWidth = 246,
	colSpacing = 50,
	paddingRight = 20,
	paddingLeft = 30
}

function CoinReportComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnNextStepUButton = self.objectReference:GetRefValue("btnNextStepUButton")
	self.coinFlyNodeUWidget = self.objectReference:GetRefValue("coinFlyNodeUWidget")
	self.btnSkipVxUButton = self.objectReference:GetRefValue("btnSkipVxUButton")
	self.txtReleaseUSDFText = self.objectReference:GetRefValue("txtReleaseUSDFText")
	self.listQualityUList = self.objectReference:GetRefValue("listQualityUList")
	self.listTypeUList = self.objectReference:GetRefValue("listTypeUList")
	self.txtReleaseTipsUSDFText = self.objectReference:GetRefValue("txtReleaseTipsUSDFText")
	self.submitRewardTitleUSDFText = self.objectReference:GetRefValue("submitRewardTitleUSDFText")
	self.togetherRewardTitleUSDFText = self.objectReference:GetRefValue("togetherRewardTitleUSDFText")
	self.listSubmitRewardUList = self.objectReference:GetRefValue("listSubmitRewardUList")
	self.txtTogetherTipsUSDFText = self.objectReference:GetRefValue("txtTogetherTipsUSDFText")
	self.btnTogetherInfoUButton = self.objectReference:GetRefValue("btnTogetherInfoUButton")
	self.togetherUWidget = self.objectReference:GetRefValue("togetherUWidget")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.rainBowUButton = self.objectReference:GetRefValue("rainBowUButton")
	self.shiningStarUButton = self.objectReference:GetRefValue("shiningStarUButton")
	self.groupUButton = self.objectReference:GetRefValue("groupUButton")
	self.onceUButton = self.objectReference:GetRefValue("onceUButton")
	self.bossUButton = self.objectReference:GetRefValue("bossUButton")
	self.catchQuantityUButton = self.objectReference:GetRefValue("catchQuantityUButton")
	self.flashUButton = self.objectReference:GetRefValue("flashUButton")
	self.topic = {
		self.catchQuantityUButton,
		self.shiningStarUButton,
		self.flashUButton,
		self.bossUButton,
		self.rainBowUButton,
		self.onceUButton,
		self.groupUButton
	}
end

function CoinReportComponent:initView()
	function self.listPetUList.luaRenderItem(button, index, data)
		self:renderPetListNew(button, index, data)
	end

	function self.btnNextStepUButton.luaClick()
		self:onClickNextBtn()
	end

	function self.btnSkipVxUButton.luaClick()
		if self.model.isFirstEnter then
			return
		end

		if self.vxPhase == VX_PHASE_1 then
			self:skipVx()
		elseif self.vxPhase == VX_PHASE_2 and self.phase2CanSkip then
			self:skipVX2()
		end
	end

	function self.listQualityUList.luaRenderItem(btn, idx, data)
		self:onRenderPetRelease(btn, idx, data)
	end

	function self.listQualityUList.luaClick(button, data)
		self:onClickPetRelease(button, data)
	end

	function self.listTypeUList.luaRenderItem(btn, idx, data)
		self:onRenderPetNotBeRelease(btn, idx, data)
	end

	function self.listSubmitRewardUList.luaRenderItem(btn, idx, data)
		self:onRenderCoin(btn, idx, data)
	end

	function self.btnTogetherInfoUButton.luaRenderTooltip(btn, tooltip)
		local objectReference = tooltip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if Utils.isTable(self.totalFollowList) and next(self.totalFollowList) then
			local uidList = {}

			for uid, val in pairs(self.totalFollowList) do
				if val then
					uidList[#uidList + 1] = uid
				end
			end

			pg.me:queryPlayerInfoList(uidList, nil, true, nil, function()
				local nameList = {}

				for _, uid in ipairs(uidList) do
					local playerInfo = pg.game.chat:getPlayerInfo(uid) or {}

					if playerInfo and playerInfo.playerName then
						nameList[#nameList + 1] = playerInfo.playerName
					end
				end

				local names = table.concat(nameList, "\n")

				ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("SPACE_FOLLOW_HELP_TIP"), names))
			end)
		else
			ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("SPACE_FOLLOW_HELP_TIP"), ""))
		end
	end

	self.btnNextStepUButton:TryChangePage("BtnState", 1)

	self.vxIsCompleted = false
	self.hasShinyPetCount = 0

	ClientTextUtils.setText(self.text01UBaseText, pg.getGameString("SUBMIT_REPORT"))
	ClientTextUtils.setText(self.txtReleaseUSDFText, pg.getGameString("PET_RELEASE"))
	ClientTextUtils.setText(self.txtReleaseTipsUSDFText, pg.getGameString("PET_NOT_BE_RELEASE"))
	ClientTextUtils.setText(self.submitRewardTitleUSDFText, pg.getGameString("PET_REPORT_COIN_REWARD"))
	ClientTextUtils.setText(self.togetherRewardTitleUSDFText, pg.getGameString("SPACE_FOLLOW_REWARD"))
	ClientTextUtils.setText(self.txtTogetherTipsUSDFText, pg.getGameString("CLICK_SHOW_DETAIL"))
	ClientTextUtils.setText(self.view.txtGliserUSDFText, pg.getGameString("SHINY_TIME"))
	self:setUpPetList()
	self:setUpCoinNum()
	self:renderPetReleaseList()
	self:renderPetNotBeReleaseList()
	self:initTopicItem()
	self.ctrl:addNavFocusListener(CallbackHandler(self, "refreshReleaseConsoleBar"), "PetReport_Coin")
end

function CoinReportComponent:initTopicItem()
	self.topicItem = {}

	local data = self.model:getTopicData()

	for idx, v in ipairs(data) do
		self.topicItem[idx] = PetReportTopicItem.new(self.ctrl, self.topic[idx], v)
	end

	self.topicItem[self.model.SHINY_TOPIC_ID]:setActiveState(false)
end

function CoinReportComponent:setUpCoinNum()
	self.coinUSDFText = {}
	self.coinBindUButton = {}
	self.coinData = self.model:getRewardInitDataInPhase1()

	self.listSubmitRewardUList:SetList(self.coinData)
end

function CoinReportComponent:setUpCoinNumInShinyTime()
	self.coinUSDFText = {}
	self.coinBindUButton = {}

	local itemIdMap = {}

	self.coinData = self.coinData or {}

	for _, v in ipairs(self.coinData) do
		itemIdMap[v.itemId] = true
	end

	local shinyData = self.model:getRewardInitDataInShinyTime()

	for _, v in ipairs(shinyData) do
		if not itemIdMap[v.itemId] then
			self.coinData[#self.coinData + 1] = v
			itemIdMap[v.itemId] = true
		end
	end

	self.listSubmitRewardUList:SetList(self.coinData)
end

function CoinReportComponent:skipVx()
	if self.petTimer then
		self:killTimer(self.petTimer)
	end

	local reportMapAll = {}

	for idx, data in ipairs(self.petDatas) do
		data.isShow = true

		local reportTypes = data.reportTypes

		if reportTypes then
			for _, id in pairs(reportTypes) do
				reportMapAll[id] = (reportMapAll[id] or 0) + 1
			end
		end
	end

	self.listPetUList:RefreshList()
	self:clearIncreaseFinalCoin()
	self:refreshCoinList()

	for idx, item in ipairs(self.topicItem) do
		item:stopRewardNumAnim()
		item:stopFlyToMainReward()

		if idx ~= self.model.SHINY_TOPIC_ID then
			if idx == self.model.CATCH_NUM_TOPIC_ID then
				local shinyCount = reportMapAll[self.model.SHINY_TOPIC_ID] or 0

				item:setTopicCount(reportMapAll[idx] or 0, shinyCount)
			else
				item:setTopicCount(reportMapAll[idx] or 0)
			end
		end
	end

	if self:checkHasPhase2() then
		self:startPhase2()
	else
		self.btnNextStepUButton:TryChangePage("BtnState", 0)
		self.ctrl:refreshConsoleBarState()
		self.btnSkipVxUButton:SetActive(false)

		self.vxIsCompleted = true
	end
end

function CoinReportComponent:skipVX2()
	if self.petTimer then
		self:killTimer(self.petTimer)
	end

	self.view.safeBoxMobileAnimation:Play(ANIM_SHINY_TIME_OUT)
	self.btnNextStepUButton:TryChangePage("BtnState", 0)

	self.vxIsCompleted = true

	self.ctrl:refreshConsoleBarState()
	self.btnSkipVxUButton:SetActive(false)

	local reportTopicMap = {}

	for idx, data in ipairs(self.petDatas) do
		if data.isShiny and not data.isEmpty then
			local reportTypes = data.reportTypes

			for _, id in pairs(reportTypes) do
				reportTopicMap[id] = (reportTopicMap[id] or 0) + 1
			end
		end
	end

	for id, item in pairs(self.topicItem) do
		item:stopRewardNumAnim()
		item:stopFlyToMainReward()

		if id ~= self.model.CATCH_NUM_TOPIC_ID then
			item:setTopicCount(reportTopicMap[id] or 0)
		end
	end

	self:refreshCoinList2()
end

function CoinReportComponent:onClickNextBtn()
	if self.model.hasAnyPoint then
		self.view.widget:TryChangePage("PanelState", 2)
		LuaUIUtils.setUIVisible(self.view.consoleBarTransform, false)
		self:onExitThisPage()
		self:startTimer(function()
			self.ctrl.researchReport:onSwitchThisPage()
		end, 0.5)
	else
		self.ctrl:dismiss()
	end
end

function CoinReportComponent:renderPetListNew(button, index, data)
	if data.tIndex == 1 then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local listPetUList = objectReference:GetRefValue("listPetUList")

	listPetUList.luaClick = nil

	function listPetUList.luaRenderItem(btn, idx, d)
		self:renderPetList(btn, idx, d)

		btn.interactable = false
	end

	listPetUList:SetScrollDisabled(true)
	listPetUList:SetList(data.items or {})
end

function CoinReportComponent:calcPetRowColCount()
	local rect = self.listPetUList.transform:GetComponent("RectTransform")
	local viewWidth = rect and rect.rect.width or 0

	if viewWidth <= 0 then
		return 7
	end

	local usableWidth = viewWidth - PET_GRID.paddingLeft - PET_GRID.paddingRight
	local count = math.floor((usableWidth + PET_GRID.colSpacing) / (PET_GRID.itemWidth + PET_GRID.colSpacing))

	return count
end

function CoinReportComponent:getPetRowColCount()
	return self.petRowColCount or self:calcPetRowColCount()
end

function CoinReportComponent:getColCount()
	return self:getPetRowColCount()
end

function CoinReportComponent:buildPetRows(pets, rowType)
	local rows = {}
	local colCount = self:getPetRowColCount()

	for idx, pet in ipairs(pets or EMPTY_TABLE) do
		local col = (idx - 1) % colCount + 1
		local row = rows[#rows]

		if col == 1 then
			row = {
				tIndex = 0,
				type = rowType,
				items = {}
			}
			rows[#rows + 1] = row
		end

		row.items[col] = pet
	end

	return rows
end

function CoinReportComponent:appendPetRows(listData, pets, rowType)
	self.petRowStartIndex = self.petRowStartIndex or {}
	self.petRowStartIndex[rowType] = #listData

	local rows = self:buildPetRows(pets, rowType)

	for _, row in ipairs(rows) do
		listData[#listData + 1] = row
	end
end

function CoinReportComponent:setPetListNewData(normalPets, shinyPets, colCount)
	local listData = {}

	self.petRowStartIndex = {}
	self.lastPetRowIndex = nil
	self.petRowColCount = colCount or self:calcPetRowColCount()

	if Utils.isTable(shinyPets) and #shinyPets > 0 then
		self:appendPetRows(listData, shinyPets, "shiny")

		listData[#listData + 1] = {
			tIndex = 1,
			type = "divider"
		}
	end

	self:appendPetRows(listData, normalPets, "normal")

	self.petListNewData = listData

	self.listPetUList:SetList(listData)
end

function CoinReportComponent:redirectPetRowToCenter(rowIndex)
	if self.lastPetRowIndex == rowIndex then
		return
	end

	self.lastPetRowIndex = rowIndex

	self.listPetUList:RedirectToCenter(rowIndex, false)
end

function CoinReportComponent:tryGetPetButtonInNewList(rowType, petIndex)
	local colCount = self:getPetRowColCount()
	local rowStartIndex = self.petRowStartIndex and self.petRowStartIndex[rowType]

	if rowStartIndex == nil then
		return false
	end

	local rowIndex = rowStartIndex + math.floor((petIndex - 1) / colCount)
	local colIndex = (petIndex - 1) % colCount

	self:redirectPetRowToCenter(rowIndex)

	local flag, rowButton = self.listPetUList:TryGetChildAt(rowIndex)

	if not flag then
		flag, rowButton = self.listPetUList:TryGetChildAt(rowIndex)
	end

	if not flag then
		return false
	end

	local rowData = self.petListNewData and self.petListNewData[rowIndex + 1]
	local objectReference = rowButton:GetComponent("ObjectReference")
	local listPetUList = objectReference:GetRefValue("listPetUList")
	local petFlag, petButton = listPetUList:TryGetChildAt(colIndex)

	if not petFlag then
		return false
	end

	local petData = rowData and rowData.items and rowData.items[colIndex + 1]

	if not petData then
		return false
	end

	return true, petButton, petData, rowButton
end

function CoinReportComponent:renderPetList(button, idx, data)
	button.draggable = false

	local objectReference = button:GetComponent("ObjectReference")
	local togetherUContainer = objectReference:GetRefValue("togetherUContainer")

	LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, not data.isEmpty and data.isShiny, data.shinyStyle)

	local hasFollow = Utils.isTable(data.followList) and #data.followList > 0

	togetherUContainer:SetActive(hasFollow)

	if data.ratingStr then
		local txtNotVerifiedUBaseText = objectReference:GetRefValue("txtNotVerifiedUBaseText")

		ClientTextUtils.setText(txtNotVerifiedUBaseText, data.ratingStr)
	end

	if data.isEmpty then
		button:TryChangePage("state", 2)
	else
		local icon = objectReference:GetRefValue("icon")
		local rainBowUContainer = objectReference:GetRefValue("rainBowUContainer")
		local umbralUContainer = objectReference:GetRefValue("umbralUContainer")

		rainBowUContainer:SetActive(data.isRainbow)

		if data.isRainbow then
			rainBowUContainer:LoadDefaultUrlManually()
		end

		if data.isDark then
			umbralUContainer:SetActive(true)
			umbralUContainer:LoadDefaultUrlManually()
		else
			umbralUContainer:SetActive(false)
		end

		icon.url = data.icon

		if data.isShow then
			button:TryChangePage("state", 0)
			PetManagementDataHelper.tryChangePetHeadBossTagPage(button, data.label)

			local verifiedUComponent = objectReference:GetRefValue("verifiedUComponent")

			verifiedUComponent:TryChangePage("NotVerified", 1)
			verifiedUComponent:TryChangePage("Quality", data.spPageIndex)
		else
			button:TryChangePage("state", 2)
		end

		if hasFollow then
			if not togetherUContainer:CheckURLLoaded() then
				togetherUContainer:LoadDefaultUrlManually(function(content)
					local objRef = content:GetComponent("ObjectReference")
					local txtNumUSDFText = objRef:GetRefValue("txtNumUSDFText")

					ClientTextUtils.setText(txtNumUSDFText, #data.followList)
				end)
			else
				local objRef = togetherUContainer.content:GetComponent("ObjectReference")
				local txtNumUSDFText = objRef:GetRefValue("txtNumUSDFText")

				ClientTextUtils.setText(txtNumUSDFText, #data.followList)
			end
		end
	end
end

function CoinReportComponent:setUpCoinInfo()
	local reportMap = pg.me.catchReportMap or {}

	self.coinItems = {}

	for id, btn in ipairs(self.topic) do
		local info = self:getCoinData(PetCaptureReportSortData[id], reportMap[id])

		if info then
			self:renderCoinItem(btn, info)

			if info.active then
				self.coinItems[#self.coinItems + 1] = btn
			end
		end
	end
end

function CoinReportComponent:onSwitchThisPage()
	self.vxPhase = VX_PHASE_1

	self:showPetSequence(1)

	if Utils.isTable(self.totalFollowList) and next(self.totalFollowList) then
		self.togetherUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	self:setGamepad()
end

function CoinReportComponent:onExitThisPage()
	if self.leftMoveTimer and self.ctrl then
		self.ctrl:killTimer(self.leftMoveTimer)
	end

	self.leftMoveTimer = nil
	self.coinUSDFText = nil
end

function CoinReportComponent:getCoinData(info, serverData)
	if info == nil then
		return
	end

	local data = lume.clone(info)

	data.number = serverData and serverData.count or 0
	data.coinCount = serverData and serverData.moneyNum or 0
	data.caughtNum = 0

	if data.number > 0 then
		data.active = 0
	else
		data.active = 1
	end

	return data
end

function CoinReportComponent:setUpPetList()
	self.petDatas, self.phase1CountMap = self:getCapturePetInfos()

	self:setPetListNewData(self.petDatas)

	if #self.petDatas < 24 then
		self.listPetUList:SetScrollDisabled(true)

		self.petListScrollDisabled = true
	else
		self.listPetUList:SetScrollDisabled(false)

		self.petListScrollDisabled = false
	end

	self.togetherUWidget:SetActive(Utils.isTable(self.totalFollowList) and next(self.totalFollowList))
end

function CoinReportComponent:showPetSequence(idx)
	if idx > self.realPetLen then
		self:collectCoin()

		return
	end

	local flag, btn, data = self:tryGetPetButtonInNewList("normal", idx)
	local timerDelay = 0.2
	local reportTypes

	if flag and not data.isEmpty then
		btn:TryChangePage("state", 0)
		PetManagementDataHelper.tryChangePetHeadBossTagPage(btn, data.label)

		data.isShow = true

		local objectReference = btn:GetComponent("ObjectReference")
		local verifiedUComponent = objectReference:GetRefValue("verifiedUComponent")

		verifiedUComponent:TryChangePage("NotVerified", 0)
		verifiedUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		verifiedUComponent:TryChangePage("Quality", data.spPageIndex)

		if data.spPageIndex < 2 then
			btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom5)

			if data.spPageIndex == 0 then
				pg.game.audio:playEvent("SFX_UI_Submit_PetN")
			else
				pg.game.audio:playEvent("SFX_UI_Submit_PetR")
			end
		elseif data.spPageIndex == 2 then
			btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom4)

			timerDelay = 0.7

			pg.game.audio:playEvent("SFX_UI_Submit_PetSR")
		else
			btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)

			timerDelay = 2

			pg.game.audio:playEvent("SFX_UI_Submit_PetSSR")
		end

		reportTypes = data.reportTypes
	end

	self.petTimer = self:startTimer(function()
		if reportTypes then
			for _, id in pairs(reportTypes) do
				self:addCoinItemNum(id)
			end
		end

		self:showPetSequence(idx + 1)
	end, timerDelay)
end

function CoinReportComponent:startPhase2()
	if self.vxPhase == VX_PHASE_2 then
		return
	end

	self:setUpCoinNumInShinyTime()

	self.vxPhase = VX_PHASE_2

	self.btnNextStepUButton:TryChangePage("BtnState", 1)

	self.vxIsCompleted = false
	self.phase2CanSkip = false

	local animLength = UIUtils.GetAnimationClipLength(self.view.safeBoxMobileAnimation, ANIM_SHINY_TIME)

	self.view.safeBoxMobileAnimation:Play(ANIM_SHINY_TIME)
	pg.game.audio:playEvent("SFX_UI_Report_ShinyProgress")
	self.topicItem[self.model.SHINY_TOPIC_ID]:setActiveState(true)
	self.topicItem[self.model.SHINY_TOPIC_ID]:setRewardActiveState(true)

	for idx, v in ipairs(self.topicItem) do
		if idx ~= self.model.CATCH_NUM_TOPIC_ID then
			v:enterShinyTime()
		end
	end

	self.coinCountMapPhase2 = {}

	local shinyPets = {}
	local normalPets = {}

	for idx, info in ipairs(self.petDatas) do
		if self:checkPetNeedToShinyTime(info) then
			table.insert(shinyPets, info)
			self.model:calcCoinCountInPhase2(self.coinCountMapPhase2, info.reportTypes)
		else
			normalPets[#normalPets + 1] = info
		end
	end

	local colCount = self:calcPetRowColCount()
	local shinyCount = #shinyPets

	self.hasShinyPetCount = shinyCount

	local remainNum = shinyCount % colCount

	if remainNum > 0 then
		for i = remainNum + 1, colCount do
			table.insert(shinyPets, {
				isEmpty = true
			})
		end
	end

	self.view.rootView:TryChangePage("GlisterTime", 1)

	for idx = #normalPets, PET_ITEM_MIN_COUNT do
		local item = {}

		item.isEmpty = true
		normalPets[#normalPets + 1] = item
	end

	self:setPetListNewData(normalPets, shinyPets, colCount)
	self:startTimer(function()
		self.phase2CanSkip = true

		self:showShinyPetSequence(1)
	end, animLength)
end

function CoinReportComponent:showShinyPetSequence(index)
	if index > self.hasShinyPetCount then
		self.view.safeBoxMobileAnimation:Play(ANIM_SHINY_TIME_OUT)
		self:collectCoin_ShinyPhase()

		return
	end

	local colCount = self:getPetRowColCount()
	local rowIndex = self.petRowStartIndex.shiny + math.floor((index - 1) / colCount)
	local colIndex = (index - 1) % colCount
	local data = self.petListNewData[rowIndex + 1].items[colIndex + 1]

	self:redirectPetRowToCenter(rowIndex)

	local timerDelay = 0.2

	if not data.isEmpty then
		local reportTypes = data.reportTypes

		for _, id in pairs(reportTypes) do
			if id ~= self.model.SHINY_TOPIC_ID then
				self:changeTopicCountShinyTime(id, 1)
			end

			timerDelay = 0.34
		end

		if #reportTypes > 0 then
			self.topicItem[self.model.SHINY_TOPIC_ID]:addTopicCount(1, 0.15)
		end
	end

	self.petTimer = self:startTimer(function()
		self:showShinyPetSequence(index + 1)
	end, timerDelay + 0.1)
end

function CoinReportComponent:changeTopicCountShinyTime(id, cnt)
	if id == self.model.SHINY_TOPIC_ID or id == self.model.CATCH_NUM_TOPIC_ID then
		return
	end

	local item = self.topicItem[id]

	if item then
		item:changeTopicShinyCount(cnt)
	end
end

function CoinReportComponent:checkHasPhase2()
	return self.hasShinyPetCount > 0
end

function CoinReportComponent:getCapturePetInfos()
	local ret = {}
	local phase1CountMap = {}
	local captureInfos = pg.me.catchPetsInfoReportList

	for _, petInfo in pairs(captureInfos) do
		local item = {}
		local label = petInfo.label
		local isShiny = Utils.isLabelShiny(label)
		local pet = pg.me:getPetInfo(petInfo.petId)

		item.isShiny = isShiny
		item.shinyStyle = pet and pet.shinyStyle or 0
		item.label = label
		item.isBoss = Utils.isLabelElite(label)
		item.isMini = Utils.isLabelRainbow(label)
		item.bodySizeType = petInfo.bodySizeType
		item.isRainbow = Utils.isAnyRainbowTypeByTemplateId(petInfo.templateId)
		item.isDark = Utils.isLabelDark(label)
		item.icon = LuaUIUtils.getPetIconByTemplateId(petInfo.templateId, LuaUIUtils.PET_ICON, label)
		item.reportTypes = petInfo.reportTypes
		item.spPageIndex = petInfo.ratingIndex
		item.ratingStr = pg.getGameString(Const.STAGE_TO_RATING_STR[petInfo.ratingIndex + 1] or "")
		item.followList = petInfo.followList
		item.moneyNum = petInfo.moneyNum

		self.model:calcCoinCountInPhase1(phase1CountMap, item.reportTypes)

		item._isNeedToShinyTime = self:checkPetNeedToShinyTime(item)

		if item._isNeedToShinyTime then
			self.hasShinyPetCount = (self.hasShinyPetCount or 0) + 1
		end

		if Utils.isTable(petInfo.followList) and #petInfo.followList > 0 then
			for _, uid in ipairs(petInfo.followList) do
				if not self.totalFollowList then
					self.totalFollowList = {}
				end

				self.totalFollowList[uid] = true
			end
		end

		ret[#ret + 1] = item
	end

	self.realPetLen = #ret

	for idx = #ret, PET_ITEM_MIN_COUNT do
		local item = {}

		item.isEmpty = true
		ret[#ret + 1] = item
	end

	return ret, phase1CountMap
end

function CoinReportComponent:checkPetNeedToShinyTime(petItem)
	return petItem.isShiny
end

function CoinReportComponent:addCoinItemNum(id)
	if id == self.model.SHINY_TOPIC_ID then
		self.topicItem[self.model.CATCH_NUM_TOPIC_ID]:useShinyFlag(true)
	else
		self.topicItem[id]:addTopicCount(1)
	end
end

function CoinReportComponent:collectCoin()
	local hasCoinAnim = false

	for id, item in ipairs(self.topicItem) do
		if id ~= self.model.SHINY_TOPIC_ID then
			local hasAnim = item:playFlyToMainReward()

			if hasAnim then
				hasCoinAnim = true
			end
		end
	end

	if hasCoinAnim == false then
		self:afterIncreaseFinalCoin()
	end
end

function CoinReportComponent:afterIncreaseFinalCoin()
	if self.vxPhase == VX_PHASE_1 and self:checkHasPhase2() then
		self.ctrl:startTimer(function()
			self:startPhase2()
		end, 0.5)
	else
		self.btnNextStepUButton:TryChangePage("BtnState", 0)

		self.vxIsCompleted = true

		self.ctrl:refreshConsoleBarState()
		self.btnSkipVxUButton:SetActive(false)
	end
end

function CoinReportComponent:increaseFinalCoin(index, curCount, targetCount)
	local key = LuaUIUtils.TweenId("finalInCrease_" .. index)

	if not DoTweenAnimMgr.IsTweening(self.uWidget.gameObject, key) then
		local itemId = self.coinData[index].itemId

		DoTweenAnimMgr.DoFloat(self.uWidget.gameObject, curCount, targetCount, key, 0.55, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			return
		end, function(value)
			ClientTextUtils.setText(self.coinUSDFText[itemId], math.floor(value))
		end, function()
			self:afterIncreaseFinalCoin()
		end, false)
	end
end

function CoinReportComponent:playIncreaseFinalCoin(itemId)
	for idx, v in ipairs(self.coinData) do
		if v.itemId == itemId then
			local curCount = self.coinData[idx].originCount
			local targetCount

			if self.vxPhase == VX_PHASE_1 then
				targetCount = curCount + self:getCoinFinalCountInPhase1(itemId)
			else
				targetCount = curCount + self:getCoinFinalCountInPhase1(itemId) + self:getCoinFinalCountInPhase2(itemId)
			end

			self.coinData[idx].count = targetCount

			self:increaseFinalCoin(idx, curCount, targetCount)

			return
		end
	end
end

function CoinReportComponent:clearIncreaseFinalCoin()
	if self.coinData == nil then
		return
	end

	for idx, v in ipairs(self.coinData) do
		DoTweenAnimMgr.Kill(self.uWidget.gameObject, LuaUIUtils.TweenId("finalInCrease_" .. idx), true)
	end
end

function CoinReportComponent:collectCoin_ShinyPhase()
	local hasShinyCoinAnim = false

	for id, item in ipairs(self.topicItem) do
		if id ~= self.model.CATCH_NUM_TOPIC_ID then
			local coinAnim = item:playFlyToMainReward()

			if coinAnim then
				hasShinyCoinAnim = true
			end
		end
	end

	if hasShinyCoinAnim == false then
		self:afterIncreaseFinalCoin()
	end
end

function CoinReportComponent:onDestroy()
	self:clearIncreaseFinalCoin()

	self.vxPhase = nil
	self.coinUSDFText = nil
	self.coinBindUButton = nil
	self.coinData = nil

	UIComponent.onDestroy(self)
end

function CoinReportComponent:setGamepad()
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

	local leftMoveGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.listPetUList.gameObject, "leftMoveGamepadBinding")

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

		if CS.XGUI.Navigation.NavManager.Instance and CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedUContent then
			return true
		end

		self.leftDelta = inputInfo.valueVec2.y / 100

		if inputInfo.phase == "Performed" then
			if self.leftMoveTimer == nil then
				self.leftMoveTimer = self.ctrl:startTimer(function()
					local targetPos = self.listPetUList.normalizedScrollPosition

					targetPos.y = targetPos.y + self.leftDelta
					targetPos.y = math.clamp(targetPos.y, 0, 1)
					self.listPetUList.normalizedScrollPosition = targetPos
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.leftMoveTimer then
			self.ctrl:killTimer(self.leftMoveTimer)

			self.leftMoveTimer = nil
		end
	end

	LuaUIUtils.setUIVisible(self.view.consoleBarTransform, true)
	LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, {
		right = {
			{
				path = "Raw/GamepadButtonSouth",
				label = pg.getGameString("CONSOLE_BAR_SKIP")
			}
		}
	})
end

function CoinReportComponent:onRenderCoin(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local iconGetUImage = objectReference:GetRefValue("iconGetUImage")

	self.coinUSDFText[data.itemId] = txtNumUSDFText
	self.coinBindUButton[data.itemId] = button

	ClientTextUtils.setText(txtNumUSDFText, data.count)

	iconGetUImage.url = LuaUIUtils.getIconByItemId(data.itemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)
end

function CoinReportComponent:getCoinFinalCountInPhase1(itemId)
	return self.phase1CountMap[itemId] or 0
end

function CoinReportComponent:getCoinFinalCountInPhase2(itemId)
	return self.coinCountMapPhase2[itemId] or 0
end

function CoinReportComponent:refreshCoinList()
	for idx, v in ipairs(self.coinData) do
		v.count = v.originCount + self:getCoinFinalCountInPhase1(v.itemId)
	end

	self.listSubmitRewardUList:SetList(self.coinData)
end

function CoinReportComponent:refreshCoinList2()
	for idx, v in ipairs(self.coinData) do
		v.count = v.originCount + self:getCoinFinalCountInPhase1(v.itemId) + self:getCoinFinalCountInPhase2(v.itemId)
	end

	self.listSubmitRewardUList:SetList(self.coinData)
end

function CoinReportComponent:renderPetReleaseList()
	local data = self.model.getPetReleaseData()

	self.listQualityUList:SetList(data)
end

function CoinReportComponent:onRenderPetRelease(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconQualityUImage = objectReference:GetRefValue("iconQualityUImage")

	iconQualityUImage.url = data.icon
	button.isSelected = self.model.getPetReleaseState(data.rating)
end

function CoinReportComponent:onClickPetRelease(button, data)
	local newIsSelected

	newIsSelected = (not button.isSelected or false) and true
	button.isSelected = newIsSelected

	self.model.setPetReleaseState(data.rating, newIsSelected)
end

function CoinReportComponent:renderPetNotBeReleaseList()
	local data = self.model.getPetNotBeReleaseData()

	self.listTypeUList:SetList(data)
end

function CoinReportComponent:onRenderPetNotBeRelease(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUSDFText, data.name)
end

function CoinReportComponent:refreshReleaseConsoleBar()
	local curFocusedGroupName = pg.global.navMgr.CurrentFocusedGroupName
	local isInRelease = curFocusedGroupName == "ListQuality"

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInRelease", isInRelease)
end

return CoinReportComponent
