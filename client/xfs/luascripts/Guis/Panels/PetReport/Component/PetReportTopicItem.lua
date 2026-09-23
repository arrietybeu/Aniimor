-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetReport\\Component\\PetReportTopicItem.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local DoTweenAnimMgr = DoTweenAnimMgr
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemConst = require("Common.Const.ItemConst")
local DropData = require("Data.drop_data")
local PetReportTopicItem = Class.LightClass("PetReportTopicItem", UIComponent)
local ANIM_SHINY_TIME_GET = {
	nil,
	"VX_Ani_SubmitPetReport_Capture_ShiningStar_Get",
	nil,
	"VX_Ani_SubmitPetReport_Capture_Boss_Get",
	"VX_Ani_SubmitPetReport_Capture_RainBow_Get",
	"VX_Ani_SubmitPetReport_Capture_Once_Get",
	"VX_Ani_SubmitPetReport_Capture_Group_Get"
}

function PetReportTopicItem:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.nameText = objectReference:GetRefValue("nameText")
	self.coinCount = objectReference:GetRefValue("coinCount")
	self.number = objectReference:GetRefValue("number")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.coinCoinGeneral = objectReference:GetRefValue("coinCoinGeneral")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.getRewardUWidget = objectReference:GetRefValue("getRewardUWidget")
	self.flashNumUWidget = objectReference:GetRefValue("flashNumUWidget")
	self.txtFlashNumUSDFText = objectReference:GetRefValue("txtFlashNumUSDFText")
	self.animRoot = self.transform:GetComponent("Animation")
end

function PetReportTopicItem:registerObjects()
	function self.listRewardUList.luaRenderItem(btn, idx, data)
		self:onRenderCoinItem(btn, idx, data)
	end
end

function PetReportTopicItem:onCtor(info)
	self.id_str = "topic" .. info.topicIdx
end

function PetReportTopicItem:onDestroy()
	self.nameText = nil
	self.coinCount = nil
	self.number = nil
	self.iconUImage = nil
	self.coinCoinGeneral = nil
	self.listRewardUList = nil
	self.rewardCoinData = nil
end

function PetReportTopicItem:initView()
	self:initRewardData()

	self.addCount = 0
	self.extraCount = 0

	ClientTextUtils.setText(self.nameText, self.extInfo.name)
	self:refreshView()
	self.listRewardUList:SetList(self.rewardCoinData)
end

function PetReportTopicItem:initRewardData()
	self.rewardCoinData = {}
	self.rewardData = self:getTopicRewardData(self.extInfo, self.extInfo.otherItem1)

	self:insertTo(self.rewardCoinData, self.rewardData)
	table.sort(self.rewardCoinData, function(a, b)
		return a.itemId < b.itemId
	end)

	self.isEnterShinyTime = false
end

function PetReportTopicItem:initRewardDataInShinyTime()
	self.rewardCoinData = {}
	self.rewardData = self:getTopicRewardData(self.extInfo, self.extInfo.otherItem2)

	self:insertTo(self.rewardCoinData, self.rewardData)
	table.sort(self.rewardCoinData, function(a, b)
		return a.itemId < b.itemId
	end)
end

function PetReportTopicItem:getTopicRewardData(info, dropId)
	local ret = {}

	ret[ItemConst.ITEM_SPECIAL_MONEY_COIN] = {
		count = 0,
		itemId = ItemConst.ITEM_SPECIAL_MONEY_COIN,
		factor = info.factor,
		factorShiny = info.factorShiny
	}

	if dropId and DropData[dropId] then
		local displayReward = DropData[dropId].displayReward

		if displayReward then
			for idx, data in ipairs(displayReward) do
				if self.model.isCurrencyUnlocked(data[1]) then
					ret[data[1]] = {
						count = 0,
						itemId = data[1],
						factor = data[2],
						factorShiny = data[2]
					}
				end
			end
		end
	end

	return ret
end

function PetReportTopicItem:insertTo(targetData, sourceData)
	for id, _ in pairs(sourceData) do
		local isFind = false

		for _, v in ipairs(targetData) do
			if v.itemId == id then
				isFind = true
			end
		end

		if not isFind then
			table.insert(targetData, {
				count = 0,
				itemId = id
			})
		end
	end
end

function PetReportTopicItem:refreshView()
	local hasCount = self.addCount > 0

	self.iconUImage.url = hasCount and self.extInfo.icon or self.extInfo.iconNoNum

	self.uWidget:TryChangePage("Active", hasCount and 0 or 1)
	self.uWidget:TryChangePage("CatchNumber", hasCount and 0 or 1)
	ClientTextUtils.setText(self.number, "x", self.addCount)
end

function PetReportTopicItem:onRenderCoinItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local iconGetUImage = objectReference:GetRefValue("iconGetUImage")
	local vXCoinCoinGeneral = objectReference:GetRefValue("vXCoinCoinGeneral")
	local coinUImage = objectReference:GetRefValue("coinUImage")
	local iconPath = LuaUIUtils.getIconByItemId(data.itemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)

	iconGetUImage.url = iconPath

	ClientTextUtils.setText(txtNumUSDFText, data.count)

	coinUImage.url = iconPath
	vXCoinCoinGeneral.subParent = self.ctrl.coinReport.coinFlyNodeUWidget.transform
	vXCoinCoinGeneral.sourcePosition = vXCoinCoinGeneral.transform.position

	function vXCoinCoinGeneral.luaGeneralCoin()
		pg.game.audio:playEvent("SFX_UI_SubmitCoins_01")
	end

	function vXCoinCoinGeneral.luaStartFly()
		pg.game.audio:playEvent("SFX_UI_SubmitCoins_02")
	end

	function vXCoinCoinGeneral.luaEndFly()
		self.view.getCoinsPanelUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		pg.game.audio:playEvent("SFX_UI_SubmitCoins_03")
		self:playIncreaseFinalCoin(data.itemId)
	end

	data.bindUSDFText = txtNumUSDFText
	data.coinGeneral = vXCoinCoinGeneral
end

function PetReportTopicItem:setActiveState(isActive)
	self.uWidget:SetActive(isActive)
end

function PetReportTopicItem:setRewardActiveState(isActive)
	self.getRewardUWidget:SetActive(isActive)
end

function PetReportTopicItem:addTopicCount(cnt, animDelay)
	self.addCount = self.addCount + cnt

	self:refreshView()
	self:playNormalGetDelay(animDelay)
	pg.game.audio:playEvent("SFX_UI_SubmitUpload_TaskActive")
	self:playRewardNumAnim()
end

function PetReportTopicItem:playRewardNumAnim()
	for idx, v in ipairs(self.rewardCoinData) do
		local animKey = LuaUIUtils.TweenId(self.id_str .. idx)

		DoTweenAnimMgr.Kill(self.uWidget.gameObject, animKey, true)

		local targetCount = self:getRewardTargetCount(v.itemId)

		DoTweenAnimMgr.DoFloat(self.uWidget.gameObject, v.count, targetCount, animKey, 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			return
		end, function(value)
			v.count = math.floor(value)

			ClientTextUtils.setText(v.bindUSDFText, v.count)
		end, nil, false)
	end
end

function PetReportTopicItem:stopRewardNumAnim()
	for idx, v in ipairs(self.rewardCoinData) do
		local animKey = LuaUIUtils.TweenId(self.id_str .. idx)

		DoTweenAnimMgr.Kill(self.uWidget.gameObject, animKey, true)
	end
end

function PetReportTopicItem:refreshRewardCoinData()
	for idx, v in ipairs(self.rewardCoinData) do
		v.count = self:getRewardTargetCount(v.itemId)
	end

	self.listRewardUList:SetList(self.rewardCoinData)
end

function PetReportTopicItem:getRewardTargetCountNotInShinyTime(itemId)
	local targetCount = 0

	if self.rewardData and self.rewardData[itemId] then
		targetCount = targetCount + self.rewardData[itemId].factor * self.addCount
	end

	if self.extraRewardData and self.extraRewardData[itemId] then
		targetCount = targetCount + self.extraRewardData[itemId].factor * self.extraCount
	end

	return targetCount
end

function PetReportTopicItem:playFlyToMainReward()
	if self.addCount == 0 then
		return false
	end

	self:stopRewardNumAnim()
	self:refreshRewardCoinData()

	local hasCoinAnim = false

	for idx, v in ipairs(self.rewardCoinData) do
		local targetPos = self.ctrl.coinReport.coinBindUButton[v.itemId]

		if v.count > 0 and targetPos and v.coinGeneral then
			local coinCount = math.clamp(math.floor(v.count / 100), 1, 5)

			v.coinGeneral.targetPosition = targetPos.position
			v.coinGeneral.sourcePosition = v.coinGeneral.transform.position

			v.coinGeneral:PlayCoin(coinCount)

			hasCoinAnim = true
		end
	end

	return hasCoinAnim
end

function PetReportTopicItem:stopFlyToMainReward()
	for _, v in ipairs(self.rewardCoinData) do
		if v.coinGeneral then
			v.coinGeneral:StopCoin()
		end
	end
end

function PetReportTopicItem:playIncreaseFinalCoin(itemId)
	self.ctrl.coinReport:playIncreaseFinalCoin(itemId)
end

function PetReportTopicItem:setTopicCount(cnt, extraCnt)
	self.addCount = cnt

	local isUse = extraCnt and extraCnt > 0 or false

	self:useShinyFlag(isUse)

	for idx, v in ipairs(self.rewardCoinData) do
		v.count = self:getRewardTargetCount(v.itemId)
	end

	self:refreshView()
	self.listRewardUList:SetList(self.rewardCoinData)
end

function PetReportTopicItem:useShinyFlag(isUse)
	if self.extInfo.topicIdx == self.model.CATCH_NUM_TOPIC_ID then
		if isUse and not self.flashNumUWidget.gameObjectActive then
			pg.game.audio:playEvent("SFX_UI_Report_ShinyPet")
		end

		self.flashNumUWidget.gameObject:SetActiveEx(isUse)
	end
end

function PetReportTopicItem:enterShinyTime()
	self.isEnterShinyTime = true

	self.uWidget:TryChangePage("GlisterTime", 1)

	self.addCount = 0
	self.extraCount = 0

	self:initRewardDataInShinyTime()
	self:refreshView()
	self.listRewardUList:SetList(self.rewardCoinData)
end

function PetReportTopicItem:changeTopicShinyCount(cnt)
	self.addCount = self.addCount + cnt

	self:startTimer(function()
		self:refreshView()
		pg.game.audio:playEvent("SFX_UI_Report_ShinyChain")
	end, 0.15)

	if ANIM_SHINY_TIME_GET[self.extInfo.topicIdx] then
		self.animRoot:Stop()
		self.animRoot:Play(ANIM_SHINY_TIME_GET[self.extInfo.topicIdx])
	end

	pg.game.audio:playEvent("SFX_UI_SubmitUpload_TaskActive")

	for idx, v in ipairs(self.rewardCoinData) do
		local animKey = LuaUIUtils.TweenId(self.id_str .. idx)

		DoTweenAnimMgr.Kill(self.uWidget.gameObject, animKey, true)

		local targetCount = self:getRewardTargetCount(v.itemId)

		if targetCount > 0 then
			DoTweenAnimMgr.DoFloat(self.uWidget.gameObject, v.count, targetCount, animKey, 0.5, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
				return
			end, function(value)
				v.count = math.floor(value)

				ClientTextUtils.setText(v.bindUSDFText, v.count)
			end, nil, false)
		end
	end
end

function PetReportTopicItem:getRewardTargetCount(itemId)
	if self.isEnterShinyTime then
		return self:getRewardTargetCountInShinyTime(itemId)
	else
		return self:getRewardTargetCountNotInShinyTime(itemId)
	end
end

function PetReportTopicItem:getRewardTargetCountInShinyTime(itemId)
	local targetCount = 0

	if self.rewardData and self.rewardData[itemId] then
		targetCount = targetCount + self.rewardData[itemId].factorShiny * self.addCount
	end

	if self.extraRewardData and self.extraRewardData[itemId] then
		targetCount = targetCount + self.extraRewardData[itemId].factorShiny * self.extraCount
	end

	return targetCount
end

function PetReportTopicItem:getRewardCount(itemId)
	for _, v in ipairs(self.rewardCoinData) do
		if v.itemId == itemId then
			return v.count
		end
	end

	return 0
end

function PetReportTopicItem:playNormalGetDelay(delay)
	if self.normalTimer then
		self:killTimer(self.normalTimer)

		self.normalTimer = nil
	end

	if delay and delay > 0 then
		self.normalTimer = self:startTimer(function()
			self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end, delay)
	else
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

return PetReportTopicItem
