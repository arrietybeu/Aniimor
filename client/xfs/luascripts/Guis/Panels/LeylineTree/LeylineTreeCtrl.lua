-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LeylineTree\\LeylineTreeCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local Lume = require("Core.Common.lume")
local LeylineTreeLevelData = require("Data.leylinetree_level_data")
local EventConst = require("Const.EventConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local PROGRESS_TWEEN_ID = "progress"
local LeylineTreeCtrl = Class.LightClass("LeylineTreeCtrl", UICtrl)

LeylineTreeCtrl.messages = {
	[MessageName.NOURISH_COUNT_CHANGED] = {
		"onNourishCountChanged",
		true
	},
	[MessageName.LEYLINEFLOWER_NOURISH_COUNT_CHANGED] = {
		"onNourishCountChanged",
		true
	}
}
LeylineTreeCtrl.ANI_CLIP_PREFIX = "VX_Pb_Map_LeylinesTree_ClickLeaf_In0%s"

function LeylineTreeCtrl:checkInfoValid(info)
	if not info.leylineTreeId then
		pg.global.showBubbleMessageById(2205)

		return false
	end

	self.leylineTreeId = info.leylineTreeId
	self.muteInject = not self.model:checkSceneIdValid(self.leylineTreeId)

	if not pg.me.leylineTreeInfoMap[self.leylineTreeId] or pg.me.leylineTreeInfoMap[self.leylineTreeId].leylineTreeLevel < 0 then
		pg.global.showBubbleMessageById(2205)

		return false
	end

	return true
end

function LeylineTreeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.onItemObtainPanelClose(data)
		self:onItemObtainPanelCloseFunc(data)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self.onItemObtainPanelClose)

	self.bigPointFragRecord = {}

	self:create(info)
end

function LeylineTreeCtrl:onShow()
	return
end

function LeylineTreeCtrl:onHide()
	return
end

function LeylineTreeCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function LeylineTreeCtrl:_removeItemObtainPanelCloseListener()
	if self.onItemObtainPanelClose then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self.onItemObtainPanelClose)

		self.onItemObtainPanelClose = nil
	end
end

function LeylineTreeCtrl:create(info)
	self.view:generateBuffGroups(self.leylineTreeId)

	self.leylineTreeMaxImprintCount = self.model:getMaxNeededImprintCount(self.leylineTreeId)
	self.usedCount = nil
	self.startDelay = nil
	self.isFake = nil

	self:renderBasicInfo()

	self.gradeIsUp = false
end

function LeylineTreeCtrl:renderBasicInfo()
	local areaName = self.model:getAreaName(self.leylineTreeId)

	ClientTextUtils.setText(self.view.tMPUSDFText, areaName)

	for i = 1, #self.view.pointGroup do
		self.view.pointGroup[i]:TryChangePage("State", 2)
	end

	local progress

	self.imprintList, self.imprintInjectedCount, progress, self.actuallyInUseCount = self.model:getLeylineTreeData(self.leylineTreeId)
	self.requiredNourishPoints = self.model:getNourishRequiredPointsByLeylineTreeLevel(self.leylineTreeId)

	ClientTextUtils.setText(self.view.requiredCount, string.format(pg.getGameString("NOURISH_REQUIRED_COUNT"), self.requiredNourishPoints))

	self.requiredWeatherPoints = self.model:getWeatherRequiredPointsByLeylineTreeLevel(self.leylineTreeId)

	ClientTextUtils.setText(self.view.weatherRequiredTip, string.format(pg.getGameString("NOURISH_REQUIRED_COUNT"), self.requiredWeatherPoints))

	if self.imprintInjectedCount >= self.requiredNourishPoints then
		self.view.btnCultivateUButton:TryChangePage("Unlock", 1)
		self.view.btnCultivateUButton:TryChangePage("vx", 1)
	else
		self.view.btnCultivateUButton:TryChangePage("Unlock", 0)
		self.view.btnCultivateUButton:TryChangePage("vx", 0)
	end

	if self.imprintInjectedCount >= self.requiredWeatherPoints then
		self.view.btnWeatherUButton:TryChangePage("Unlock", 1)
		self.view.btnWeatherUButton:TryChangePage("vx", 1)
	else
		self.view.btnWeatherUButton:TryChangePage("Unlock", 0)
		self.view.btnWeatherUButton:TryChangePage("vx", 0)
	end

	local buffInfo = self.model:getBuffProgress(self.leylineTreeId)
	local curBuffLevel = self.model:getCurBuffLevel(self.leylineTreeId, self.imprintInjectedCount)
	local gearLevel = self.model:getBuffGearLevel(self.leylineTreeId, curBuffLevel)

	self.view.root:TryChangePage("Gear", gearLevel)

	for index, v in pairs(buffInfo) do
		self.view.buffSliderGroup[index].value = v.progress

		local objectReference = self.view.buffBtnGroup[index]:GetComponent("ObjectReference")
		local iconBuffUImage = objectReference:GetRefValue("iconBuffUImage")
		local buffDetails = self.model:getBuffDetails(self.leylineTreeId, index)

		iconBuffUImage.url = buffDetails.buffIcon
		self.view.buffBtnGroup[index].luaTooltipPopup = function(_, flag)
			self.view.buffBtnGroup[index].isSelected = flag

			self.view.buffBtnGroup[index]:TryChangePage("button", flag and 5 or 0)
		end
		self.view.buffBtnGroup[index].luaRenderTooltip = function(_, cmp)
			local objectReference1 = cmp:GetComponent("ObjectReference")
			local txtTitleUSDFText = objectReference1:GetRefValue("txtTitleUSDFText")
			local txtUnlockedUSDFText = objectReference1:GetRefValue("txtUnlockedUSDFText")
			local txtDetailsUSDFText = objectReference1:GetRefValue("txtDetailsUSDFText")
			local listRewardUList = objectReference1:GetRefValue("listRewardUList")
			local btnGetUButton = objectReference1:GetRefValue("btnGetUButton")
			local txtRewardUSDFText = objectReference1:GetRefValue("txtRewardUSDFText")

			ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(buffDetails.buffTitleDesc))
			ClientTextUtils.setText(txtRewardUSDFText, pg.getGameString("ROGUE_DIEC_REWARD"))
			ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(buffDetails.buffDesc))

			if buffDetails.isLargeBuff == 1 then
				local rewardState = pg.game.leylineTree:getLeylineTreeBuffRewardState(self.leylineTreeId, index)

				if rewardState then
					cmp:TryChangePage("Type", 2)
				else
					cmp:TryChangePage("Type", 0)
				end

				local objectReference2 = btnGetUButton:GetComponent("ObjectReference")
				local txtNameUText = objectReference2:GetRefValue("txtNameUText")

				ClientTextUtils.setText(txtNameUText, pg.getGameString("OBTAIN_REWARD"))

				function btnGetUButton.luaClick()
					pg.me:serverMsg("RPC_CS_ClaimLeylineTreeLevelReward", self.leylineTreeId, index)

					local path = string.format(RedDotConst.RedDotPath.LEYLINETREE_BUFF_ITEM, index)

					pg.global.setRedDot(path, self.view.buffBtnGroup[index], false, RedDotConst.RedDotStyle.REWARD)
					self.view.buffBtnGroup[index]:ClosePopup()
				end

				local reward = self.model:getRewardTable(self.leylineTreeId, index)

				function listRewardUList.luaRenderItem(button, idx, data)
					LuaUIUtils.renderRewardItem(button, data)
				end

				listRewardUList:SetList(reward)
			else
				cmp:TryChangePage("Type", 1)
			end

			local curBuffLevelTemp = self.model:getCurBuffLevel(self.leylineTreeId, self.imprintInjectedCount)

			if curBuffLevelTemp >= index then
				cmp:TryChangePage("Unlocked", 1)
			else
				cmp:TryChangePage("Unlocked", 0)
				ClientTextUtils.setText(txtUnlockedUSDFText, string.format("%s/%s", self.imprintInjectedCount, self.model:getNeededImprintCount(self.leylineTreeId, index)))
			end
		end

		if self.view.buffVxDown[index] then
			self.view.buffVxDown[index].localRotation = Quaternion.Euler(0, 0, 60 - 300 * v.progress)
		end

		if index <= curBuffLevel then
			self.view.buffBtnGroup[index]:TryChangePage("State", 2)

			if self.view.buffVxDown[index] then
				self.view.buffVxDown[index].gameObject:SetActiveEx(true)
			end

			if self.view.buffVxPar[index] then
				self.view.buffVxPar[index].gameObject:SetActiveEx(false)
			end
		end
	end

	self:renderNextLargeBuffTip(curBuffLevel)
	ClientTextUtils.setText(self.view.txtNowUSDFText, self.imprintInjectedCount)
	ClientTextUtils.setText(self.view.txtAllUSDFText, self.model:getMaxNeededImprintCount(self.leylineTreeId))

	self.recordBuffLevel = curBuffLevel

	if self.imprintInjectedCount > 0 then
		self.view.root:TryChangePage("NoActive", 0)
	else
		self.view.root:TryChangePage("NoActive", 1)
	end

	self.view.progressAddUSlider.value = progress
	self.view.progressNowUSlider.value = progress

	if progress > 0.003 then
		self.view.pointLUImage.gameObject:SetActiveEx(true)
	end

	if progress >= 1 then
		self.view.pointRUImage.gameObject:SetActiveEx(true)
	end

	local icon, itemId

	self.imprintNum, icon, itemId = self.model:getPlayerOwnedImprintCount(self.leylineTreeId)

	if self.imprintNum <= 0 then
		self.view.btnInjectUButton:TryChangePage("disable", 1)

		self.view.btnInjectUButton.interactable = false

		self.view.txtTipsTransform.gameObject:SetActiveEx(false)
		self:setBtnText()
	end

	local isUp = ClientActivityUtils.isLeylineTreeUp()

	if isUp then
		local cultivateUnlock = self.imprintInjectedCount >= self.requiredNourishPoints

		if cultivateUnlock then
			ClientActivityUtils.setLeylineTreeUpWidget(self.view.btnCultivateIconUpUContainer, false)
			ClientActivityUtils.setLeylineTreeUpWidget(self.view.freeTimeIconUpUContainer, true)
		else
			ClientActivityUtils.setLeylineTreeUpWidget(self.view.freeTimeIconUpUContainer, false)
			ClientActivityUtils.setLeylineTreeUpWidget(self.view.btnCultivateIconUpUContainer, true)
		end
	else
		ClientActivityUtils.setLeylineTreeUpWidget(self.view.btnCultivateIconUpUContainer, false)
		ClientActivityUtils.setLeylineTreeUpWidget(self.view.freeTimeIconUpUContainer, false)
	end

	local costItemId = pg.game.leylineTree:getCurLeylineTreeCostItemId(self.leylineTreeId)

	if costItemId then
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, {
			costItemId
		})
	else
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, UIConst.UI_ID_LEYLINE_TREE)
	end

	self:renderImprintPoints()
	self:checkIfBigPoint()
	self:renderNourishBtn()
end

function LeylineTreeCtrl:renderNourishBtn()
	local freeMaxCount = SysConfigData.LEYLINEFLOWER_NOURISH_FREEMAXCOUNT or 0
	local curCreatePlentyCount = pg.me.nourishCount or -freeMaxCount
	local totalDailySeconds = 86400
	local lastDailyRefreshTs = pg.me.lastDayUpdateTs
	local curTime = lastDailyRefreshTs + totalDailySeconds - Time.secondCache

	if curCreatePlentyCount <= -freeMaxCount then
		self.view.tipsUWidget:SetActive(false)
		self.view.progressCountDown1:Reset(1, 1)
		self.view.progressCountDown2:Reset(1, 1)
		self.view.progressCountDown3:Reset(1, 1)
		self.view.progressCountDown1.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
		self.view.progressCountDown2.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
		self.view.progressCountDown3.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 1)
	else
		LuaUIUtils.setCountDownTime(self.view.countDownUCountDown, lastDailyRefreshTs + totalDailySeconds, UIConst.TimeType.Short)
		self.view.tipsUWidget:SetActive(true)

		if curCreatePlentyCount == -2 then
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
		else
			self.view.progressCountDown1:Play(curTime, totalDailySeconds)
			self.view.progressCountDown2:Reset(0, 1)
			self.view.progressCountDown3:Reset(0, 1)
			self.view.progressCountDown1.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 0)
			self.view.progressCountDown2.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 0)
			self.view.progressCountDown3.transform.parent:GetComponent("UButton"):TryChangePage("Energy", 0)
		end
	end
end

function LeylineTreeCtrl:renderImprintPoints()
	if not self.imprintList or not self.actuallyInUseCount then
		return
	end

	for index, staticId in pairs(self.imprintList) do
		local staticInfo = self.model:getPointAndFragmentIndex(staticId)
		local pointIndex = staticInfo.pointIndex
		local fragmentIndex = staticInfo.fragmentIndex

		if not self.bigPointFragRecord[pointIndex] then
			self.bigPointFragRecord[pointIndex] = 0
		end

		if index <= self.actuallyInUseCount then
			self.bigPointFragRecord[pointIndex] = self.bigPointFragRecord[pointIndex] + 1

			self.view.fragmentGroup[pointIndex][fragmentIndex]:TryChangePage("State", 3)
		else
			self.view.fragmentGroup[pointIndex][fragmentIndex]:TryChangePage("State", 1)
		end
	end
end

function LeylineTreeCtrl:checkIfBigPoint()
	if not self.imprintList then
		return
	end

	local activatedBigPoints = {}

	for _, staticId in pairs(self.imprintList) do
		local staticInfo = self.model:getPointAndFragmentIndex(staticId)
		local pointIndex = staticInfo.pointIndex

		activatedBigPoints[pointIndex] = true
	end

	for k, _ in pairs(activatedBigPoints) do
		self.view.pointGroup[k]:TryChangePage("State", 0)
	end
end

function LeylineTreeCtrl:destroy()
	self:_removeItemObtainPanelCloseListener()

	self.bigPointFragRecord = nil

	if self.delayTimer then
		self:killTimer(self.delayTimer)

		self.delayTimer = nil
	end

	if self.startDelay then
		self:realDoInject()
	end

	self.startDelay = nil
end

function LeylineTreeCtrl:addListener()
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

	function self.view.btnInjectUButton.luaBeginLongPress()
		if self.muteInject then
			pg.global.showBubbleMessageById(12033)

			return
		end
	end

	function self.view.btnInjectUButton.luaLongPress(_)
		if self.muteInject then
			return
		end

		self:inject(true)
	end

	function self.view.btnInjectUButton.luaEndLongPress()
		self:delayRun()
		self.view.vXLeylinesTreeClickLeafAnimation:Stop()
		self.view.loopLeafIconTransform.gameObject:SetActiveEx(false)
	end

	function self.view.btnInjectUButton.luaClick()
		if self.muteInject then
			pg.global.showBubbleMessageById(12033)

			return
		end

		self:inject()
		self:delayRun()
	end

	function self.view.btnRulesUButton.luaRenderTooltip(_, tipItem)
		local objectReference = tipItem:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("LEYLINE_TREE_INSTRUCTION"))
	end

	self.view.btnRulesUButton:SetGamepadAction("Raw/GamepadStart")

	function self.view.btnCultivateUButton.luaClick()
		if pg.game.input:isUsingGamepad() and self.imprintInjectedCount < self.requiredNourishPoints then
			pg.global.showBubbleMessageRaw(pg.getGameString("UNLOCK_LEYLINETREE_SKILL"), 2)

			return
		end

		if self.muteInject then
			pg.global.showBubbleMessageById(12033)

			return
		end

		self:onNourishBtnClick()
	end

	function self.view.btnWeatherUButton.luaClick()
		if pg.game.input:isUsingGamepad() and (self.imprintInjectedCount < self.requiredNourishPoints or self.imprintInjectedCount < self.requiredWeatherPoints) then
			pg.global.showBubbleMessageRaw(pg.getGameString("UNLOCK_LEYLINETREE_SKILL"), 2)

			return
		end

		if self.muteInject then
			pg.global.showBubbleMessageById(12033)

			return
		end

		self:onWeatherBtnClick()
	end

	function self.view.disableButtonUButton.luaClick()
		if self.imprintInjectedCount < self.requiredNourishPoints then
			return
		end

		self.view.disableButtonUButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

function LeylineTreeCtrl:closePanel()
	self:_removeItemObtainPanelCloseListener()
	pg.global.ui:close(UIConst.UI_ID_LEYLINE_TREE)

	if self.gradeIsUp then
		local treeEntId = pg.space.leylineTreeMap[self.leylineTreeId]

		if not treeEntId then
			return
		end

		local ent = pg.getEntity(treeEntId)

		if not ent then
			return
		end

		ent:phaseLevelUp()
	end
end

function LeylineTreeCtrl:inject(isLongPress)
	if self.imprintNum <= 0 then
		return
	end

	self.isFake = false

	if self.actuallyInUseCount >= Lume.count(self.imprintList) then
		self.isFake = true
	end

	if not self.imprintList or not self.imprintInjectedCount or not self.actuallyInUseCount then
		return
	end

	if not self.usedCount then
		self.usedCount = 0
	end

	self.view.root:TryChangePage("NoActive", 0)

	self.usedCount = self.usedCount + 1
	self.imprintInjectedCount = self.imprintInjectedCount + 1

	if isLongPress then
		self.view.loopLeafIconTransform.gameObject:SetActiveEx(true)
		self.view.vXLeylinesTreeClickLeafAnimation:Play("VX_Pb_Map_LeylinesTree_ClickLeaf_Loop")
	else
		self.view.loopLeafIconTransform.gameObject:SetActiveEx(false)

		local idx = math.random(1, 5)

		self.view.vXLeylinesTreeClickLeafAnimation:Play(string.format(LeylineTreeCtrl.ANI_CLIP_PREFIX, idx))
	end

	local suitLevel = self.model:isImprintNumSuitForExactlyBuffLevel(self.leylineTreeId, self.imprintInjectedCount)

	if not self.isFake then
		self.actuallyInUseCount = self.actuallyInUseCount + 1

		local staticInfo = self.model:getPointAndFragmentIndex(self.imprintList[self.actuallyInUseCount])
		local pointIndex = staticInfo.pointIndex
		local fragmentIndex = staticInfo.fragmentIndex
		local _, page = self.view.flowGroup[pointIndex]:TryGetCurrentPage("State")

		if page == 0 then
			pg.game.audio:triggerEvent("SFX_UI_Energy_Flows")
		end

		self.view.flowGroup[pointIndex]:TryChangePage("State", 0)
		self.view.flowGroup[pointIndex]:TryChangePage("State", 1)
		self.view.pointGroup[pointIndex]:TryChangePage("State", 1)
		self.view.fragmentGroup[pointIndex][fragmentIndex]:TryChangePage("State", 3)
		pg.game.audio:triggerEvent("SFX_UI_Energy_Activation")
		self.view.flowBoomTransform.gameObject:SetActiveEx(false)
		self.view.flowBoomTransform.gameObject:SetActiveEx(true)
		self.view.flowDowmTransform.gameObject:SetActiveEx(false)
		self.view.flowDowmTransform.gameObject:SetActiveEx(true)

		if isLongPress then
			self.view.flowBoomUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
			self.view.flowDowmUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		elseif suitLevel then
			self.view.flowBoomUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
			self.view.flowDowmUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		else
			self.view.flowBoomUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			self.view.flowDowmUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end

		if not self.view.pointGroup[pointIndex] then
			self.bigPointFragRecord[pointIndex] = 0

			pg.game.audio:triggerEvent("SFX_UI_Energy_Magnificent")
		end

		self.bigPointFragRecord[pointIndex] = self.bigPointFragRecord[pointIndex] + 1
	end

	local progress = self.imprintInjectedCount / self.leylineTreeMaxImprintCount > 1 and 1 or self.imprintInjectedCount / self.leylineTreeMaxImprintCount

	self.view.progressAddUSlider.value = progress

	DoTweenAnimMgr.DoFloat(self.view.root.gameObject, self.view.progressNowUSlider.value, progress, LuaUIUtils.TweenId(PROGRESS_TWEEN_ID), 0.7, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
		return
	end, function(val)
		self.view.progressNowUSlider.value = val
	end, function()
		return
	end, false)

	if progress > 0.003 then
		self.view.pointLUImage.gameObject:SetActiveEx(true)
	end

	if progress >= 1 then
		self.view.pointRUImage.gameObject:SetActiveEx(true)
	end

	ClientTextUtils.setText(self.view.txtNowUSDFText, self.imprintInjectedCount)

	self.imprintNum = self.imprintNum - 1

	local _, btn = self.view.listCurrencyUList:TryGetChildAt(0)
	local objectReference = btn:GetComponent("ObjectReference")
	local countUText = objectReference:GetRefValue("countUText")

	ClientTextUtils.setText(countUText, self.imprintNum)

	if suitLevel then
		if suitLevel <= #self.view.buffBtnGroup then
			pg.game.audio:triggerEvent("SFX_UI_UnlockBuff")
			self.view.buffBtnGroup[suitLevel]:TryChangePage("State", 1)

			local levelData = LeylineTreeLevelData[self.leylineTreeId] or {}
			local data = levelData[suitLevel]

			if data then
				local path = string.format(RedDotConst.RedDotPath.LEYLINETREE_BUFF_ITEM, suitLevel)
				local show = data.isLargeBuff == 1

				pg.global.setRedDot(path, self.view.buffBtnGroup[suitLevel], show, RedDotConst.RedDotStyle.REWARD)
			end

			if self.view.buffVxDown[suitLevel] then
				self.view.buffVxDown[suitLevel].gameObject:SetActiveEx(true)
			end

			self.view.vXLeylinesTreeNewBuffUpUWidget.gameObject:SetActiveEx(false)
			self.view.vXLeylinesTreeNewBuffUpUWidget.gameObject:SetActiveEx(true)
		end

		self.view.levelUpTransform.gameObject:SetActiveEx(false)
		self.view.levelUpTransform.gameObject:SetActiveEx(true)

		local gearLevel = self.model:getBuffGearLevel(self.leylineTreeId, suitLevel)

		self.view.root:TryChangePage("Gear", gearLevel)
	end

	local curBuffLevel = self.model:getCurBuffLevel(self.leylineTreeId, self.imprintInjectedCount)

	self:renderNextLargeBuffTip(curBuffLevel)

	if self.imprintInjectedCount >= self.requiredNourishPoints then
		self.gradeIsUp = true

		self.view.btnCultivateUButton:TryChangePage("Unlock", 1)

		local _, page = self.view.btnCultivateUButton:TryGetCurrentPage("vx")

		if page == 0 then
			self.view.btnCultivateUButton:TryChangePage("vx", 2)
		end
	else
		self.view.btnCultivateUButton:TryChangePage("Unlock", 0)
		self.view.btnCultivateUButton:TryChangePage("vx", 0)
	end

	if self.imprintInjectedCount >= self.requiredWeatherPoints then
		self.view.btnWeatherUButton:TryChangePage("Unlock", 1)

		local _, page = self.view.btnWeatherUButton:TryGetCurrentPage("vx")

		if page == 0 then
			self.view.btnWeatherUButton:TryChangePage("vx", 2)
		end
	else
		self.view.btnWeatherUButton:TryChangePage("Unlock", 0)
		self.view.btnWeatherUButton:TryChangePage("vx", 0)
	end

	self:checkIfBigPoint()

	if self.imprintNum <= 0 then
		if self.imprintInjectedCount >= self.leylineTreeMaxImprintCount then
			self.gradeIsUp = true
		end

		self.view.btnInjectUButton:TryChangePage("disable", 1)

		self.view.btnInjectUButton.interactable = false

		self.view.txtTipsTransform.gameObject:SetActiveEx(false)
		self.view.vXLeylinesTreeClickLeafAnimation:Stop()
		self.view.loopLeafIconTransform.gameObject:SetActiveEx(false)
		self:setBtnText()

		if isLongPress then
			self:delayRun()
		end
	end
end

function LeylineTreeCtrl:delayRun()
	if self.delayTimer then
		self:killTimer(self.delayTimer)

		self.delayTimer = nil
	end

	self.startDelay = true
	self.delayTimer = self:startTimer(function()
		self:realDoInject()

		self.startDelay = nil
	end, not self.isFake and 3 or 0.5)
end

function LeylineTreeCtrl:realDoInject()
	if not self.usedCount or self.usedCount <= 0 then
		return
	end

	pg.me:serverMsg("RPC_CS_UpgradeLeylineTree", self.leylineTreeId, self.usedCount)

	self.usedCount = nil
end

function LeylineTreeCtrl:setBtnText()
	if self.imprintInjectedCount >= self.leylineTreeMaxImprintCount then
		ClientTextUtils.setText(self.view.txtDisUSDFText, pg.getGameString("LEYLINETREE_SUBMIT_BUTTON_2"))
	elseif self.imprintNum <= 0 then
		ClientTextUtils.setText(self.view.txtDisUSDFText, pg.getGameString("LEYLINETREE_SUBMIT_BUTTON_1"))
	end
end

function LeylineTreeCtrl:showPopup(buffLevel)
	if not buffLevel then
		return
	end

	local objectReference = self.view.popupUComponent:GetComponent("ObjectReference")
	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	local iconBuffUImage = objectReference:GetRefValue("iconBuffUImage")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")
	local consoleUButton = objectReference:GetRefValue("consoleUButton")

	function btnCloseUButton.luaClick()
		self.view.root:TryChangePage("showPopup", 0)

		if self.lastFocus then
			CS.XGUI.Navigation.NavManager.Instance:FocusItem(self.lastFocus)
		end
	end

	local buffDetails = self.model:getBuffDetails(self.leylineTreeId, buffLevel)

	iconBuffUImage.url = buffDetails.buffIcon

	ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(buffDetails.buffTitleDesc))
	ClientTextUtils.setText(txtContentUSDFText, pg.getLocalizationText(buffDetails.buffDesc))
	self.view.root:TryChangePage("showPopup", 1)

	if consoleUButton then
		self.lastFocus = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedUContent

		CS.XGUI.Navigation.NavManager.Instance:FocusItem(consoleUButton)
	end

	pg.game.audio:triggerEvent("SFX_UI_Pb_Map_LeylineTree_Popup_Show")
end

function LeylineTreeCtrl:renderNextLargeBuffTip(curBuffLevel)
	for _, v in pairs(self.view.buffBtnGroup) do
		local objectReference = v:GetComponent("ObjectReference")
		local imgBgNumTransform = objectReference:GetRefValue("imgBgNumTransform")

		if imgBgNumTransform then
			imgBgNumTransform.gameObject:SetActiveEx(false)
		end
	end

	local nexLargeBuffIndex = self.model:getNextLargeBuffIndex(self.leylineTreeId, curBuffLevel)

	if nexLargeBuffIndex then
		local objectReference = self.view.buffBtnGroup[nexLargeBuffIndex]:GetComponent("ObjectReference")
		local imgBgNumTransform = objectReference:GetRefValue("imgBgNumTransform")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

		if imgBgNumTransform then
			imgBgNumTransform.gameObject:SetActiveEx(true)
		end

		if txtNumUSDFText then
			ClientTextUtils.setText(txtNumUSDFText, string.format("%s/%s", self.imprintInjectedCount, self.model:getNeededImprintCount(self.leylineTreeId, nexLargeBuffIndex)))
		end
	end
end

function LeylineTreeCtrl:onItemObtainPanelCloseFunc(data)
	if not self.view or not self.model then
		return
	end

	for i = 1, #self.view.flowGroup do
		self.view.flowGroup[i]:TryChangePage("State", 0)
	end

	local curBuffLevel = self.model:getCurBuffLevel(self.leylineTreeId, self.imprintInjectedCount)

	if curBuffLevel > self.recordBuffLevel then
		self:showPopup(curBuffLevel)

		self.recordBuffLevel = curBuffLevel
	end
end

function LeylineTreeCtrl:onNourishCountChanged(info)
	if info.leylineTreeId and self.leylineTreeId ~= info.leylineTreeId then
		return
	end

	pg.game.audio:triggerEvent("SFX_UI_Energy_Convergence")
	self:renderNourishBtn()
end

function LeylineTreeCtrl:onNourishBtnClick()
	pg.global.ui:open(UIConst.UI_ID_MAP_NOURISH, {
		to = "Nourish",
		leylineTreeId = self.leylineTreeId
	})
end

function LeylineTreeCtrl:onWeatherBtnClick()
	pg.global.ui:open(UIConst.UI_ID_MAP_NOURISH, {
		to = "Weather",
		leylineTreeId = self.leylineTreeId
	})
end

return LeylineTreeCtrl
