-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Nourish\\NourishCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local ClientUtils = require("Utils.ClientUtils")
local SysConfigData = require("Data.sys_config_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local Utils = require("Common.Utils.Utils")
local MapBlockConfigData = require("Data.map_block_config_data")
local ClientConst = require("Const.ClientConst")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local NourishCtrl = Class.LightClass("NourishCtrl", UICtrl)
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local NoticeDef = require("Common.NoticeDef")
local Navigation = CS.XGUI.Navigation
local CultivateTipsComponent = require("Guis.Panels.Nourish.Component.CultivateTipsComponent")
local MapHelper = require("GameApp.Map.MapHelper")

NourishCtrl.messages = {
	[MessageName.LEYLINEFLOWER_NOURISH_COUNT_CHANGED] = {
		"onNourishCountChanged",
		true
	},
	[MessageName.LEYLINEFLOWER_DAILY_NOURISH_COUNT_CHANGED] = {
		"onDailyNourishCountChanged",
		true
	},
	[MessageName.LEYLINEFLOWER_FLOWER_STATE_CHANGED] = {
		"onFlowerStateChanged",
		true
	},
	[MessageName.WEATHER_REFRESH] = {
		"onMeteorologyRefresh",
		true
	},
	[MessageName.LEYLINETREE_METEOROLOGY_COUNT_CHANGED] = {
		"onLeylineTreeMeteorologyCountChanged",
		true
	},
	[MessageName.LEYLINETREE_METEOROLOGY_CD_CHANGED] = {
		"onLeylineTreeMeteorologyCDChanged",
		true
	},
	[MessageName.LEYLINE_MAP_RAINBOW_CHANGED] = {
		"onMapRainbowChanged",
		true
	}
}

local ANGLE_GAP = 12.5
local ANGLE_START = 55

function NourishCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.cultivateTipsComponent = CultivateTipsComponent.new(self, self.view.cultivateTipsUComponent.transform)
	self.curFunc = info.to

	if self.curFunc == "Nourish" then
		local isUp, isNew, activityId = ClientActivityUtils.isLeylineTreeUp()

		if isUp and isNew then
			pg.global.ui.tips:showDropHint("CULTIVATE_UP_TIP", self.view.iconUp3UContainer.position)

			local key = ClientConst.PrefKey.EventIconUpNew .. activityId .. pg.me.uid

			pg.global.prefsCacheUtils:setBool(key, false)
		end
	end

	self:Init(info)
end

function NourishCtrl:onOpen(info)
	return
end

function NourishCtrl:onShow()
	pg.global.navMgr:AddLuaHotkeyActivationChangedListener("UI_NourishCtrl_FocusChanged", function()
		self:refreshConsoleBarState()
	end)
end

function NourishCtrl:onHide()
	pg.global.ui.tips:hideDropHint()
	pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener("UI_NourishCtrl_FocusChanged")
end

function NourishCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function NourishCtrl:refreshNourishBtn()
	local totalDailySeconds = 86400
	local lastDailyRefreshTs = pg.me.lastDayUpdateTs
	local curTime = lastDailyRefreshTs + totalDailySeconds - Time.secondCache
	local enough = true
	local costItemOwnNum = ClientUtils.getItemCountById(self.consumeCostItemId, true)

	if costItemOwnNum < self.consumeCostItemCost then
		enough = false
	end

	local freeMaxCount = SysConfigData.LEYLINEFLOWER_NOURISH_FREEMAXCOUNT or 0
	local curCreatePlentyCount = pg.me.nourishCount or -freeMaxCount
	local dailyNourishCount = pg.me.dailyNourishCount or -1
	local limitCount = dailyNourishCount >= 0 and dailyNourishCount or curCreatePlentyCount
	local maxCount = LeylineFlowerUtils.getNourishMaxCount(pg.me)
	local displayCount
	local displayMaxCount = maxCount

	if curCreatePlentyCount < 0 then
		displayCount = freeMaxCount + curCreatePlentyCount

		self.view.popTransform.gameObject:SetActiveEx(false)
		self.view.root:TryChangePage("State", 1)
		self.view.btnNourishUButton:TryChangePage("enable", (not maxCount or limitCount < maxCount) and 1 or 0)

		if curCreatePlentyCount <= -freeMaxCount then
			self.view.progressCountDown1:Reset(1, 1)
			self.view.progressCountDown2:Reset(1, 1)
			self.view.progressCountDown3:Reset(1, 1)
			self.view.progressCountDown1.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
			self.view.progressCountDown2.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
			self.view.progressCountDown3.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
		elseif curCreatePlentyCount == -2 then
			self.view.progressCountDown1:Reset(1, 1)
			self.view.progressCountDown2:Reset(1, 1)
			self.view.progressCountDown3:Play(curTime, totalDailySeconds)
			self.view.progressCountDown1.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
			self.view.progressCountDown2.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
			self.view.progressCountDown3.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 0)
		elseif curCreatePlentyCount == -1 then
			self.view.progressCountDown1:Reset(1, 1)
			self.view.progressCountDown2:Play(curTime, totalDailySeconds)
			self.view.progressCountDown3:Reset(0, 1)
			self.view.progressCountDown1.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
			self.view.progressCountDown2.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 0)
			self.view.progressCountDown3.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 0)
		end

		ClientTextUtils.setText(self.view.txtFullUSDFText, string.format(pg.getGameString("FREE_REMAINS"), math.abs(curCreatePlentyCount)))
	else
		displayCount = limitCount

		self.view.popTransform.gameObject:SetActiveEx(false)
		self.view.root:TryChangePage("State", 0)

		if enough then
			self.view.btnNourishRecoverUButton:TryChangePage("enable", (not maxCount or limitCount < maxCount) and 1 or 0)
		else
			self.view.btnNourishRecoverUButton:TryChangePage("enable", 0)
		end
	end

	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("DAILY_NON_FREE_NOURISH_COUNT"))
	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%s/%s", displayCount, displayMaxCount))

	if self.cultivateTipsComponent then
		self.cultivateTipsComponent:refreshcountDown(lastDailyRefreshTs + totalDailySeconds, UIConst.TimeType.Short)
	end
end

function NourishCtrl:Init(info)
	self.leylineTreeId = info.leylineTreeId
	self.defaultBlockId = info.blockId
	self.openMapAfterNourish = info.openMapAfterNourish == true
	self.consumeCostItemId = nil
	self.consumeCostItemCost = nil

	local leylineTreeInfo = pg.me.leylineTreeInfoMap[self.leylineTreeId]

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, UIConst.UI_ID_MAP_NOURISH)
	self:refreshTributeText()

	if self.curFunc == "Nourish" then
		self.view.root:TryChangePage("Type", 0)

		for k, v in pairs(SysConfigData.LEYLINEFLOWER_NOURISH_COST) do
			self.consumeCostItemId = k
			self.consumeCostItemCost = v
		end

		if self.consumeCostItemId and self.consumeCostItemCost then
			local itemInfo = self.model:getConsumeCostItemInfo(self.consumeCostItemId)

			self.view.iconUImage.url = itemInfo.icon

			ClientTextUtils.setText(self.view.consumeCostNum, string.format("%s", self.consumeCostItemCost))
		end

		self:refreshNourishBtn()

		function self.view.btnTipsUButton.luaRenderTooltip(_, tipItem)
			local objectReference = tipItem:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("DAILY_NOURISH_INSTRUCTION"))
		end

		local isUp, isNew = ClientActivityUtils.isLeylineTreeUp()

		if isUp then
			if isNew then
				ClientActivityUtils.setLeylineTreeUpWidget(self.view.iconUp3UContainer, false)
				self:startTimer(function()
					ClientActivityUtils.setLeylineTreeUpWidget(self.view.iconUp3UContainer, true)
				end, 3.33)
			else
				ClientActivityUtils.setLeylineTreeUpWidget(self.view.iconUp3UContainer, true)
			end
		else
			ClientActivityUtils.setLeylineTreeUpWidget(self.view.iconUp3UContainer, false)
		end
	elseif self.curFunc == "Weather" then
		self.view.root:TryChangePage("Type", 1)
		ClientTextUtils.setText(self.view.weatherTips, pg.getGameString("METEOROLOGY_GAMEPLAY_INSTRUCTION"))

		for k, v in pairs(SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_COST) do
			self.consumeCostItemId = k
			self.consumeCostItemCost = v
		end

		if self.consumeCostItemId and self.consumeCostItemCost then
			local itemInfo = self.model:getConsumeCostItemInfo(self.consumeCostItemId)

			self.view.weatherIconUImage.url = itemInfo.icon

			ClientTextUtils.setText(self.view.weatherTxtNumUSDFText, string.format("%s", self.consumeCostItemCost))
		end

		if leylineTreeInfo then
			local changeMeteorologyCount = leylineTreeInfo.changeMeteorologyCount or 0

			self:checkWeatherCd()
			ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("DAILY_METEOROLOGY_COUNT"))
			ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%s/%s", changeMeteorologyCount, SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_MAXCOUNT))
		end

		function self.view.btnTipsUButton.luaRenderTooltip(_, tipItem)
			local objectReference = tipItem:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("METEOROLOGY_GAMEPLAY_INSTRUCTION"))
		end
	end

	self:initArea()
	self:initWeatherChoosePanel()
end

function NourishCtrl:initWeatherChoosePanel()
	for i = 0, 3 do
		local weatherBtn = self.view.weatherTransform:GetChild(i):GetComponent("UButton")

		if i == 0 then
			weatherBtn.isSelected = true

			weatherBtn:TryChangePage("button", 5)
		else
			weatherBtn.isSelected = false

			weatherBtn:TryChangePage("button", 0)

			weatherBtn.interactable = false
		end
	end

	for i = 4, 6 do
		local fakeBtn = self.view.weatherTransform:GetChild(i):GetComponent("UButton")

		function fakeBtn.luaPress()
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
		end
	end
end

function NourishCtrl:isAreaUnlocked(blockId)
	if self.curFunc == "Weather" then
		return Utils.isWeatherPetProgressUnlocked(pg.me, blockId)
	else
		return Utils.isSmallAreaPetProgressUnlocked(pg.me, blockId)
	end
end

function NourishCtrl:initArea()
	local leftAreaInfo, rightAreaInfo = self.model:getBlockAreaInfo(self.leylineTreeId)

	local function containsBlockId(areaInfo, blockId)
		if not blockId or blockId == 0 then
			return false
		end

		for _, data in ipairs(areaInfo) do
			if data.blockId == blockId then
				return true
			end
		end

		return false
	end

	local function isTreeBlock(blockId)
		return containsBlockId(leftAreaInfo, blockId) or containsBlockId(rightAreaInfo, blockId)
	end

	local targetBlockId = self.defaultBlockId

	if not isTreeBlock(targetBlockId) then
		targetBlockId = pg.game.map.curBlockId
	end

	if not isTreeBlock(targetBlockId) and self.curFunc == "Weather" then
		local treeInfo = pg.me.leylineTreeInfoMap and pg.me.leylineTreeInfoMap[self.leylineTreeId]
		local pendingMeteo = treeInfo and treeInfo.pendMeteo

		if pendingMeteo then
			for _, areaInfo in ipairs({
				leftAreaInfo,
				rightAreaInfo
			}) do
				for _, data in ipairs(areaInfo) do
					if pendingMeteo[data.blockId] then
						targetBlockId = data.blockId

						break
					end
				end

				if isTreeBlock(targetBlockId) then
					break
				end
			end
		end
	end

	if not isTreeBlock(targetBlockId) then
		for _, areaInfo in ipairs({
			leftAreaInfo,
			rightAreaInfo
		}) do
			for _, data in ipairs(areaInfo) do
				if self:isAreaUnlocked(data.blockId) then
					targetBlockId = data.blockId

					break
				end
			end

			if isTreeBlock(targetBlockId) then
				break
			end
		end
	end

	if not isTreeBlock(targetBlockId) then
		targetBlockId = leftAreaInfo[1] and leftAreaInfo[1].blockId or rightAreaInfo[1] and rightAreaInfo[1].blockId
	end

	self.autoSelectBlockId = targetBlockId

	local function inner(button, index, data, list)
		button.name = data.blockId

		local objectReference = button:GetComponent("ObjectReference")
		local txtNameSelUSDFText = objectReference:GetRefValue("txtNameSelUSDFText")
		local txtNameNmlUSDFText = objectReference:GetRefValue("txtNameNmlUSDFText")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local uPUWidget = objectReference:GetRefValue("uPUWidget")
		local upTxt = objectReference:GetRefValue("upTxt")
		local isCurrentAreaUp = ClientActivityUtils.isLeylineTreeUp(data.blockId)

		uPUWidget:SetActive(isCurrentAreaUp)
		ClientTextUtils.setText(upTxt, pg.getGameString("UP_EVENT_TIP"))

		local unlocked = self:isAreaUnlocked(data.blockId)

		button:TryChangePage("Unlocked", not unlocked and 1 or 0)

		local flowerId = LeylineFlowerUtils.getStaticIdByBlockId(nil, data.blockId)
		local flowerInfo = flowerId and pg.me.leylineFlowerInfoMap and pg.me.leylineFlowerInfoMap[flowerId]

		if unlocked then
			local rainbowStage = LeylineFlowerUtils.getRainbowStageBySmallAreaId(data.blockId)
			local pointType = 0

			if rainbowStage == 1 then
				if LeylineFlowerUtils.getTotalRainbowEnergy(flowerInfo) > 0 then
					pointType = 1
				end
			elseif rainbowStage == 2 then
				pointType = 1
			elseif rainbowStage >= 3 and rainbowStage <= 4 then
				pointType = 2
			elseif rainbowStage >= 5 and rainbowStage <= 6 then
				pointType = 3
			end

			button:TryChangePage("PointType", pointType)
		else
			button:TryChangePage("PointType", 0)
		end

		local isDuringLeylineFlowerCreatePlenty = Utils.isDuringLeylineFlowerCreatePlenty(pg.me, data.blockId)
		local isDuringMeteorology = MapHelper.getAreaMeteorology(data.blockId) > 0
		local pendingCaptureCount = 0

		if flowerInfo then
			pendingCaptureCount = flowerInfo.pendingCaptureBloomCount or 0
		end

		self.view.btnAddPropUButton1.gameObject:SetActiveEx(self.curFunc == "Nourish")

		local hasNourishActivity = isDuringLeylineFlowerCreatePlenty or pendingCaptureCount > 0

		if not hasNourishActivity and not isDuringMeteorology then
			button:TryChangePage("State", 0)
		elseif hasNourishActivity and not isDuringMeteorology then
			button:TryChangePage("State", 1)
		elseif not hasNourishActivity and isDuringMeteorology then
			button:TryChangePage("State", 2)
		else
			button:TryChangePage("State", 3)
		end

		ClientTextUtils.setText(txtNameSelUSDFText, pg.getLocalizationText(data.areaName))
		ClientTextUtils.setText(txtNameNmlUSDFText, pg.getLocalizationText(data.areaName))
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.areaName))

		function button.luaPress()
			self:onSelectArea(button, list)
		end
	end

	function self.view.listLeftUList.luaRenderItem(button, index, data)
		inner(button, index, data, self.view.listLeftUList)
	end

	function self.view.listLeftUList.luaFinishRender(_)
		self:autoSelectArea(self.view.listLeftUList)
	end

	function self.view.listRightUList.luaRenderItem(button, index, data)
		inner(button, index, data, self.view.listRightUList)
	end

	function self.view.listRightUList.luaFinishRender(_)
		self:autoSelectArea(self.view.listRightUList)
	end

	self.view.listLeftUList:SetList(leftAreaInfo)
	self.view.listRightUList:SetList(rightAreaInfo)
end

function NourishCtrl:selectSingleItem(list, index, btn, blockId)
	local leftBtns = self.view.listLeftUList:GetAllButtons()
	local rightBtns = self.view.listRightUList:GetAllButtons()

	for i = 0, leftBtns.Length - 1 do
		if (index and index == i or btn and btn == leftBtns[i] or blockId and blockId == leftBtns[i].dataFromUList.blockId) and list == self.view.listLeftUList then
			leftBtns[i].isSelected = true
			self.view.vXMapCultivateMeshLineRectTransform.localRotation = Quaternion.Euler(0, 0, ANGLE_START + i * ANGLE_GAP)
		else
			leftBtns[i].isSelected = false
		end
	end

	for i = 0, rightBtns.Length - 1 do
		if (index and index == i or btn and btn == rightBtns[i] or blockId and blockId == rightBtns[i].dataFromUList.blockId) and list == self.view.listRightUList then
			rightBtns[i].isSelected = true
			self.view.vXMapCultivateMeshLineRectTransform.localRotation = Quaternion.Euler(0, 0, -ANGLE_START - i * ANGLE_GAP)
		else
			rightBtns[i].isSelected = false
		end
	end
end

function NourishCtrl:onSelectArea(button, list)
	local data = button.dataFromUList
	local unlocked = self:isAreaUnlocked(data.blockId)

	self:selectSingleItem(list, nil, button, nil)

	if not unlocked then
		self.view.root:TryChangePage("Unlocked", 1)
		ClientTextUtils.setText(self.view.lockedTitleTip, string.format(self.curFunc == "Nourish" and pg.getGameString("NOURISH_LOCKED") or pg.getGameString("WEATHER_LOCKED"), data.areaName))
		ClientTextUtils.setText(self.view.txtDetailsUSDFText, string.format(self.curFunc == "Nourish" and pg.getGameString("COPPER_BADGE_TIPS") or pg.getGameString("SILVER_BADGE_TIPS")))
	else
		self.view.root:TryChangePage("Unlocked", 0)
		self:initPetList(data.blockId)
	end

	self.selectedBlockId = data.blockId

	self:clearUselessPropSelect(data.blockId)
	self.view.btnAddPropUButton1.gameObject:SetActiveEx(self.curFunc == "Nourish")

	if self.curFunc == "Nourish" then
		self:refreshNourishBtn()
	elseif self.curFunc == "Weather" then
		self:checkWeatherCd()
	end

	self.view.root:TryChangePage("PhaseOfChange", LeylineFlowerUtils.getRainbowStageBySmallAreaId(data.blockId) - 1)
	self:refreshRainbowStageText(data.blockId)
end

function NourishCtrl:refreshRainbowStageText(blockId)
	self.cultivateTipsComponent:refresh(blockId)
end

function NourishCtrl:autoSelectArea(list)
	local btns = list:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].dataFromUList.blockId == self.autoSelectBlockId then
			self:onSelectArea(btns[i], list)

			return
		end
	end
end

function NourishCtrl:initPetList(blockId)
	function self.view.listPetUList.luaRenderItem(button, _, data)
		LuaUIUtils.renderCultivatePetItem(button, data)
	end

	self:refreshPetList(blockId)
end

function NourishCtrl:refreshPetList(blockId)
	blockId = blockId or self.selectedBlockId

	if not blockId then
		return
	end

	local petData

	if self.curFunc == "Weather" then
		local worldTemplateIds = MapHelper.getAreaRainbowPetTemplates(blockId)

		if worldTemplateIds and next(worldTemplateIds) then
			petData = {}

			for worldTemplateId in pairs(worldTemplateIds) do
				local templateId = LuaUIUtils.getPetTemplateIdByWorldTemplateId(worldTemplateId)

				if templateId then
					petData[#petData + 1] = {
						templateId = templateId,
						worldTemplateId = worldTemplateId
					}
				end
			end
		else
			petData = LuaUIUtils.getAreaRainbowPetData(blockId)
		end
	else
		local ethnicGroups = LeylineFlowerUtils.getDisplayEthnicGroups(blockId, self.model.nourishPropId)

		petData = LuaUIUtils.getEthnicGroupPetData(ethnicGroups)
	end

	self.view.listPetUList:SetList(petData)
end

function NourishCtrl:destroy()
	if self.view and self.view.weatherCountDown then
		self.view.weatherCountDown.luaFinished = nil

		self.view.weatherCountDown:Stop()
	end

	self.model:setNourishProp()

	self.defaultBlockId = nil
	self.autoSelectBlockId = nil
	self.openMapAfterNourish = nil
	self.waitingWeatherBlockId = nil
end

function NourishCtrl:closePanel()
	UIUtils.PlayAnimation(self.view.windowAnimation, "VX_Pb_Map_Nourish_Out", function()
		pg.global.ui:close(UIConst.UI_ID_MAP_NOURISH)
	end)
end

function NourishCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnNourishRecoverUButton.luaClick()
		self:onNourishButtonClick()
	end

	function self.view.btnNourishUButton.luaClick()
		self:onNourishButtonClick()
	end

	function self.view.btnWeatherUButton.luaClick()
		self:onWeatherButtonClick()
	end

	function self.view.btnMapUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_MAP, {
			muteBlackScreen = true,
			focusSmallArea = self.selectedBlockId
		})
	end

	function self.view.btnRulesUButton.luaClick()
		self:onDetailButtonClick()
	end

	self.view.btnRulesUButton:SetGamepadAction("Raw/GamepadStart")
	self.view.btnRulesUButton:SetHotkeyConsoleBar("CONSOLE_BAR_RULES_DESCRIPTION", 0)

	function self.view.btnAddPropUButton1.luaClick()
		self:onPropSelectClick()
	end

	function self.view.btnCleanUButton1.luaClick()
		self:clearPropSelect()
		self:refreshConsoleBarState()
	end
end

function NourishCtrl:refreshConsoleBarState()
	local focusNourishItem = Navigation.NavManager.Instance:IsFocusInNavGroupOf(self.view.addUWidget)

	if focusNourishItem then
		Navigation.ConsoleBar.SetStateForAll("UI_Pb_Map_Cultivate_LeftStickMove", false)
		Navigation.ConsoleBar.SetStateForAll("UI_Pb_Map_Cultivate_Choose", false)

		local addNourishItem = true
		local navItem = Navigation.NavManager.Instance.CurrentFocusedUContent

		if navItem == self.view.btnAddPropUButton1 then
			local _, page = self.view.btnAddPropUButton1:TryGetCurrentPage("State")

			addNourishItem = page == 0
		end
	else
		Navigation.ConsoleBar.SetStateForAll("UI_Pb_Map_Cultivate_LeftStickMove", true)
		Navigation.ConsoleBar.SetStateForAll("UI_Pb_Map_Cultivate_Choose", true)
	end

	Navigation.ConsoleBar.SetStateForAll("UI_Pb_Map_Cultivate_Add_Remove", true)
end

function NourishCtrl:onPropSelectClick()
	if not self.selectedBlockId then
		return
	end

	local propId = self.model.nourishPropId

	if not propId then
		pg.global.ui:open(UIConst.UI_ID_MAP_NOURISH_TRIBUTE, {
			configId = 1,
			blockId = self.selectedBlockId,
			confirmFunc = function(itemId, itemCount)
				self:showPropSelect(itemId, itemCount)
			end
		})
	else
		pg.global.ui.commonItemTip:open({
			id = propId,
			num = ClientUtils.getItemCountById(propId),
			targetRect = self.view.btnAddPropUButton1
		})
	end
end

function NourishCtrl:clearPropSelect()
	self.view.btnAddPropUButton1:TryChangePage("State", 0)
	self.model:setNourishProp()
	self:refreshTributeText()
	self:refreshPetList()
end

function NourishCtrl:clearUselessPropSelect(blockId)
	local propId = self.model.nourishPropId

	if not propId then
		return
	end

	if not LeylineFlowerUtils.isTributeUselessInArea(propId, blockId) then
		return
	end

	self:clearPropSelect()
	pg.global.showBubbleMessageRaw(pg.getGameString("CULTIVATE_TRIBUTE_UNAVAILABLE"))
end

function NourishCtrl:showPropSelect(propId, count)
	if count > 0 then
		local info = LuaUIUtils.getItemInfoById(propId)

		self.view.extraIconPropUImage1.url = info.icon

		self.view.btnAddPropUButton1:TryChangePage("State", 1)
		ClientTextUtils.setText(self.view.extraCount1, count)
		self.model:setNourishProp(propId, count)
		self:refreshPetList()
	else
		self:clearPropSelect()
	end

	self:refreshTributeText()
end

function NourishCtrl:refreshTributeText()
	local textId = self.curFunc == "Weather" and "CAN_ATTRACT_RAINBOW_PET" or "TRIBUTE_ITEM"

	ClientTextUtils.setText(self.view.tributeText, pg.getGameString(textId))
end

function NourishCtrl:onNourishButtonClick()
	if not self.selectedBlockId then
		return
	end

	local isDuringLeylineFlowerCreatePlenty = Utils.isDuringLeylineFlowerCreatePlenty(pg.me, self.selectedBlockId)

	if isDuringLeylineFlowerCreatePlenty then
		pg.global.showBubbleMessageRaw(pg.getGameString("NOURISH_CD"), 2)

		return
	end

	local curCreatePlentyCount = pg.me.nourishCount or -(SysConfigData.LEYLINEFLOWER_NOURISH_FREEMAXCOUNT or 0)
	local dailyNourishCount = pg.me.dailyNourishCount or -1
	local limitCount = dailyNourishCount >= 0 and dailyNourishCount or curCreatePlentyCount
	local maxCount = LeylineFlowerUtils.getNourishMaxCount(pg.me)

	if maxCount and maxCount <= limitCount then
		pg.global.showBubbleMessageRaw(pg.getGameString("LEYLINETREE_NOURISH_MAX"), 2)

		return
	end

	local flowerId = LeylineFlowerUtils.getStaticIdByBlockId(nil, self.selectedBlockId)

	if not flowerId then
		return
	end

	local enough = true
	local costItemOwnNum = ClientUtils.getItemCountById(self.consumeCostItemId, true)

	if costItemOwnNum < self.consumeCostItemCost then
		enough = false
	end

	if not enough and curCreatePlentyCount >= 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("NOURISH_COST_ITEM_NOT_ENOUGH"), 2)

		return
	end

	local costItems = {}

	if self.model.nourishPropId and self.model.nourishPropCount then
		if (ClientUtils.getItemCountById(self.model.nourishPropId, true) or 0) < self.model.nourishPropCount then
			pg.global.showBubbleMessageRaw(pg.getGameString("ITEM_NUM_LESS"))

			return
		end

		costItems[self.model.nourishPropId] = self.model.nourishPropCount
	end

	self:doNourish(flowerId, costItems)
end

function NourishCtrl:doNourish(flowerId, costItems)
	pg.me:serverMsg("RPC_CS_LeylineFlowerNourish", flowerId, costItems)
end

function NourishCtrl:onWeatherButtonClick()
	if not self.selectedBlockId then
		return
	end

	local isDuringMeteorology = MapHelper.getAreaMeteorology(self.selectedBlockId) > 0

	if isDuringMeteorology then
		pg.global.showBubbleMessageRaw(pg.getGameString("IS_DURING_METEOROLOGY"), 2)

		return
	end

	if self.leylineTreeId and pg.me.leylineTreeInfoMap then
		local leylineTreeInfo = pg.me.leylineTreeInfoMap[self.leylineTreeId]

		if leylineTreeInfo then
			local changeMeteorologyCount = leylineTreeInfo.changeMeteorologyCount or 0

			if changeMeteorologyCount >= SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_MAXCOUNT then
				pg.global.showBubbleMessageRaw(pg.getGameString("LEYLINETREE_CHANGEMETEOROLOGY_MAX"), 2)

				return
			end
		end
	end

	if self.consumeCostItemId and self.consumeCostItemCost then
		local costItemOwnNum = ClientUtils.getItemCountById(self.consumeCostItemId, true)

		if costItemOwnNum < self.consumeCostItemCost then
			pg.global.showBubbleMessage(NoticeDef.LEYLINE_TREE_BADGE2_LOCKED)

			return
		end
	end

	self.waitingWeatherBlockId = self.selectedBlockId

	pg.me:serverMsg("RPC_CS_LeylineTreeChangeMeteorology", self.leylineTreeId, self.selectedBlockId)
end

function NourishCtrl:onDetailButtonClick()
	if self.curFunc == "Nourish" then
		local ids = self.model:getLeylineTreeDesc(self.leylineTreeId)

		if ids then
			local isUp = ClientActivityUtils.isLeylineTreeUp()

			pg.global.ui.tips:openNourishDesc(isUp and ids[2] or ids[1])
		end
	else
		local id = self.model:getLeylineTreeWeatherDesc(self.leylineTreeId)

		if id then
			pg.global.ui.tips:openNourishDesc(id)
		end
	end
end

function NourishCtrl:onNourishCountChanged(info)
	pg.game.audio:triggerEvent("SFX_UI_Energy_Convergence")
	self:refreshNourishBtn()
	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, UIConst.UI_ID_MAP_NOURISH)
end

function NourishCtrl:onDailyNourishCountChanged()
	self:refreshNourishBtn()
end

function NourishCtrl:renderAreaStatus(btns, smallAreaId)
	for i = 0, btns.Length - 1 do
		if smallAreaId == nil or btns[i].name == tostring(smallAreaId) then
			local areaId = smallAreaId or tonumber(btns[i].name)
			local rainbowStage = LeylineFlowerUtils.getRainbowStageBySmallAreaId(areaId)
			local flowerId = LeylineFlowerUtils.getStaticIdByBlockId(nil, areaId)
			local flowerInfo = flowerId and pg.me.leylineFlowerInfoMap and pg.me.leylineFlowerInfoMap[flowerId]
			local pointType = 0

			if rainbowStage == 1 then
				if LeylineFlowerUtils.getTotalRainbowEnergy(flowerInfo) > 0 then
					pointType = 1
				end
			elseif rainbowStage == 2 then
				pointType = 1
			elseif rainbowStage >= 3 and rainbowStage <= 4 then
				pointType = 2
			elseif rainbowStage >= 5 and rainbowStage <= 6 then
				pointType = 3
			end

			btns[i]:TryChangePage("PointType", pointType)

			local isDuringLeylineFlowerCreatePlenty = Utils.isDuringLeylineFlowerCreatePlenty(pg.me, areaId)
			local isDuringMeteorology = MapHelper.getAreaMeteorology(areaId) > 0
			local pendingCaptureCount = 0

			if flowerInfo then
				pendingCaptureCount = flowerInfo.pendingCaptureBloomCount or 0
			end

			local hasNourishActivity = isDuringLeylineFlowerCreatePlenty or pendingCaptureCount > 0

			if not hasNourishActivity and not isDuringMeteorology then
				btns[i]:TryChangePage("State", 0)
			elseif hasNourishActivity and not isDuringMeteorology then
				btns[i]:TryChangePage("State", 1)
			elseif not hasNourishActivity and isDuringMeteorology then
				btns[i]:TryChangePage("State", 2)
			else
				btns[i]:TryChangePage("State", 3)
			end
		end
	end
end

function NourishCtrl:onFlowerStateChanged(info)
	if not info.leylineFlowerId then
		return
	end

	local blockId = LeylineFlowerUtils.getBlockIdByStaticId(nil, info.leylineFlowerId)

	if not blockId then
		return
	end

	if self.defaultBlockId and not self.openMapAfterNourish then
		self:closePanel()

		return
	end

	if info.newValue ~= LeylineFlowerConst.FLOWER_STATE.Growing then
		self:clearPropSelect()
	end

	local btnsLeft = self.view.listLeftUList:GetAllButtons()

	self:renderAreaStatus(btnsLeft, blockId)

	local btnsRight = self.view.listRightUList:GetAllButtons()

	self:renderAreaStatus(btnsRight, blockId)

	if info.newValue == LeylineFlowerConst.FLOWER_STATE.Budding then
		local flowerInfo = pg.me:getCurFlowerInfo(info.leylineFlowerId)
		local bloomQuality = flowerInfo and flowerInfo.bloomQuality or 0

		pg.global.ui:open(UIConst.UI_ID_MAP, {}, function()
			local map = pg.global.ui.map

			if not map then
				return
			end

			local markInfo = map:getMarkInfo(info.leylineFlowerId)

			if not markInfo or not markInfo.markType then
				return
			end

			local markName = string.format("mark_%s_%s", markInfo.markType, info.leylineFlowerId)

			map:focusMark({
				markName,
				nil,
				true,
				function()
					map:requestLeylineFlowerQualityVx(info.leylineFlowerId, bloomQuality)
				end
			})
		end)
	end
end

function NourishCtrl:refreshWeatherBtnEnable(changeMeteorologyCount)
	local enough = true

	if self.consumeCostItemId and self.consumeCostItemCost then
		enough = ClientUtils.getItemCountById(self.consumeCostItemId, true) >= self.consumeCostItemCost
	end

	local notMax = changeMeteorologyCount < SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_MAXCOUNT

	self.view.btnWeatherUButton:TryChangePage("enable", notMax and enough and 1 or 0)
end

function NourishCtrl:checkWeatherCd()
	local leylineTreeInfo = pg.me.leylineTreeInfoMap[self.leylineTreeId]

	if leylineTreeInfo then
		local cdTs = leylineTreeInfo.changeMeteorologyCD or Time.secondCache
		local remaining = math.max(0, cdTs - Time.secondCache)

		if remaining <= 0 then
			self.view.weatherCountDown.luaFinished = nil

			self.view.weatherCountDown:Stop()
			self.view.root:TryChangePage("State", 1)
		else
			self.view.root:TryChangePage("State", 0)

			function self.view.weatherCountDown.luaFinished()
				self:checkWeatherCd()
			end

			local total = math.max(remaining, SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_CD)

			self.view.weatherCountDown:Play(remaining, total)
		end

		local changeMeteorologyCount = leylineTreeInfo.changeMeteorologyCount or 0

		self:refreshWeatherBtnEnable(changeMeteorologyCount)
	end
end

function NourishCtrl:onMapRainbowChanged()
	local leftBtns = self.view.listLeftUList:GetAllButtons()

	self:renderAreaStatus(leftBtns)

	local rightBtns = self.view.listRightUList:GetAllButtons()

	self:renderAreaStatus(rightBtns)

	if self.curFunc ~= "Weather" then
		return
	end

	if self.selectedBlockId then
		self:refreshPetList()
	end

	if not self.waitingWeatherBlockId then
		return
	end

	local treeInfo = pg.me.leylineTreeInfoMap and pg.me.leylineTreeInfoMap[self.leylineTreeId]
	local pendingMeteo = treeInfo and treeInfo.pendMeteo and treeInfo.pendMeteo[self.waitingWeatherBlockId]

	if not pendingMeteo then
		return
	end

	local sceneId = MapHelper.getAreaSceneId(self.waitingWeatherBlockId)

	if not sceneId or pg.space and pg.space.sceneId == sceneId then
		return
	end

	local blockConfig = MapBlockConfigData[self.waitingWeatherBlockId]

	if blockConfig then
		local toast = pg.getGameString("HONG_HAPPENED")

		pg.global.showBubbleMessageRaw(pg.getFormatText(toast, pg.getLocalizationText(blockConfig.areaName)), 2)
	end

	self.waitingWeatherBlockId = nil
end

function NourishCtrl:onMeteorologyRefresh(info)
	local leylineTreeInfo = pg.me.leylineTreeInfoMap[self.leylineTreeId]

	if leylineTreeInfo then
		local changeMeteorologyCount = leylineTreeInfo.changeMeteorologyCount or 0

		self:checkWeatherCd()
		ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%s/%s", changeMeteorologyCount, SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_MAXCOUNT))
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, UIConst.UI_ID_MAP_NOURISH)

		local leftBtns = self.view.listLeftUList:GetAllButtons()

		self:renderAreaStatus(leftBtns, info.blockAreaId)

		local rightBtns = self.view.listRightUList:GetAllButtons()

		self:renderAreaStatus(rightBtns, info.blockAreaId)

		local isDuringMeteorology = pg.me:getAreaMeteorology(info.blockAreaId)

		if isDuringMeteorology > 0 then
			local toast = pg.getGameString("HONG_HAPPENED")

			pg.global.showBubbleMessageRaw(pg.getFormatText(toast, pg.getLocalizationText(MapBlockConfigData[info.blockAreaId].areaName)), 2)
		end

		if info.blockAreaId == self.selectedBlockId then
			self:refreshPetList()
		end
	end

	if info.blockAreaId == self.waitingWeatherBlockId then
		self.waitingWeatherBlockId = nil
	end
end

function NourishCtrl:onLeylineTreeMeteorologyCountChanged(info)
	if self.curFunc ~= "Weather" or info.leylineTreeId ~= self.leylineTreeId then
		return
	end

	self:checkWeatherCd()
	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%s/%s", info.newValue >= 0 and info.newValue or 0, SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_MAXCOUNT))
	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, UIConst.UI_ID_MAP_NOURISH)
end

function NourishCtrl:onLeylineTreeMeteorologyCDChanged(info)
	if self.curFunc ~= "Weather" or info.leylineTreeId ~= self.leylineTreeId then
		return
	end

	self:checkWeatherCd()
end

function NourishCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return NourishCtrl
