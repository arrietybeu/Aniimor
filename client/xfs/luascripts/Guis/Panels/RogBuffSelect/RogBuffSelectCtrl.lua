-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogBuffSelect\\RogBuffSelectCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RogBuffSelectCtrl = Class.LightClass("RogBuffSelectCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RogueUtils = require("Utils.RogueUtils")
local ExtraRandomBuffCondition = require("Data.extra_random_buff_condition")
local RandomBuffSeriesName = require("Data.random_buff_series_name")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")

RogBuffSelectCtrl.messages = {}
RogBuffSelectCtrl.needCloseUI = {
	UIConst.UI_ID_TOWER_BUFF_DETAIL,
	UIConst.UI_ID_TOWER_STAGE_INFO,
	UIConst.UI_ID_CHAT
}

function RogBuffSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.cacheInfos = {}
	self.maxRefreshCount = RogueTalentUtils.func(pg.me, "rogueRandomCount")
	self.refreshCount = RogueTalentUtils.func(pg.me, "rogueRandomCount")
	self.data = nil
	self.hasRender = false
	self.costCurrency = 4000

	if pg.global.ui:openingUINumWithLayer(UIConst.PANEL_LAYER) > 0 then
		self.view.bgBlurUIBlurEffect.onlyScene = false
	end

	self.view.bgBlurUIBlurEffect.gameObject:SetActiveEx(false)
	self:startTimer(function()
		self.view.bgBlurUIBlurEffect.gameObject:SetActiveEx(true)
	end, 0.2)
end

function RogBuffSelectCtrl:addListener()
	function self.view.btnReset.luaClick()
		self:onBtnReset()
	end

	function self.view.btnConfirm.luaClick()
		self:onBtnConfirm()
	end

	function self.view.btnBuffListUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TOWER_BUFF_DETAIL)
	end

	self:bindHotKey("Hud/RogueBuffDetail", function()
		self.view.btnBuffListUButton.luaClick()
	end, nil, self.view.btnBuffListUButton.gameObject)
end

function RogBuffSelectCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function RogBuffSelectCtrl:onOpen(info)
	if not pg.me or not pg.me.space or not pg.me.space:isRogueEnv() then
		self:close()

		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_SETTLEMENT) then
		self:close()

		return
	end

	for _, id in ipairs(RogBuffSelectCtrl.needCloseUI) do
		if pg.global.ui:checkUIOpen(id) then
			pg.global.ui:close(id)
		end
	end

	pg.game.audio:playEvent("SFX_UI_Rouge_BuffListAppear")

	if self.isResetBuff then
		self.cacheInfos[1] = info
	else
		table.insert(self.cacheInfos, info)
	end

	if #self.cacheInfos == 1 or self.isResetBuff then
		if info.isShow then
			self:refreshShowBuff(info)
		else
			self.isResetBuff = false

			self:refreshSelectBuffs(info)
		end
	end
end

function RogBuffSelectCtrl:renderBuffList(info)
	local extraInfo = {
		needSelect = true,
		isShow = info.isShow,
		curCounts = info.curCounts,
		onBuffSelectChange = function(data)
			if self.selected == data.buffId then
				self.selected = nil
			else
				self.selected = data.buffId
			end

			if self.selected then
				self.selectedSeries = data.buffSeries
			else
				self.selectedSeries = nil
			end

			self:showRogueSkillInfo()

			self.view.btnConfirm.interactable = self.selected ~= nil
		end
	}

	RogueUtils.renderBuffSelectList(self.view.buffList, info.buffs, extraInfo)
end

function RogBuffSelectCtrl:refreshShowBuff(info)
	self.param = info

	self:renderBuffList(info)
	self.view.btnReset:SetActive(false)
	self.view.resetTip:SetActive(false)
	self.view.btnConfirm:SetActive(false)

	local showBuffTitle = pg.getGameString("ROGUE_SHOW_BUFF_TITLE")

	ClientTextUtils.setText(self.view.titleUBaseText, showBuffTitle)
	ClientTextUtils.setText(self.view.title1UBaseText, showBuffTitle)
	ClientTextUtils.setText(self.view.title2UBaseText, showBuffTitle)
	self.view.tipUBaseText:SetActive(false)
	ClientTextUtils.setText(self.view.btnConfirmText, pg.getGameString("ENSURE"))
	self:startTimer(function()
		self.view.btnConfirm:SetActive(true)
	end, 0.3)
end

function RogBuffSelectCtrl:refreshSelectBuffs(info)
	self.selected = nil
	self.selectedSeries = nil
	self.param = info

	self:renderBuffList(info)
	self:showRogueSkillInfo()

	if info.reRandomCount then
		self.refreshCount = info.reRandomCount
	end

	local buffTitle = pg.getGameString("ROGUE_SELECT_BUFF_TITLE")
	local tipTitle = pg.getGameString("ROGUE_SELECT_BUFF_TIP")

	if info.buffSource == Const.ROGUE_BUFF_SOURCE.TALENT_INIT_BUFF or info.buffSource == Const.ROGUE_BUFF_SOURCE.SERIES_INIT_BUFF then
		buffTitle = pg.getGameString("ROGUE_INIT_BUFF_TITLE")
		tipTitle = pg.getGameString("ROGUE_INIT_BUFF_TIP")
	end

	ClientTextUtils.setText(self.view.titleUBaseText, buffTitle)
	ClientTextUtils.setText(self.view.title1UBaseText, buffTitle)
	ClientTextUtils.setText(self.view.title2UBaseText, buffTitle)
	ClientTextUtils.setText(self.view.title3UBaseText, buffTitle)
	self.view.tipUBaseText:SetActive(true)
	ClientTextUtils.setText(self.view.tipUBaseText, tipTitle)

	local showReset = not info.isExtraBuff and RogueTalentUtils.func(pg.me, "rogueRandomCount") > 0 and info.buffSource ~= Const.ROGUE_BUFF_SOURCE.TALENT_INIT_BUFF and info.buffSource ~= Const.ROGUE_BUFF_SOURCE.SERIES_INIT_BUFF

	self.view.btnReset:SetActive(showReset)
	self.view.resetTip:SetActive(showReset)

	if showReset then
		ClientTextUtils.setText(self.view.resetTip, string.format("%d/%d   %s: %d/%d", self:getCurResetCost(self.refreshCount), pg.me:getMoneyNum(self.costCurrency), pg.getGameString("TOWER_ROGUE_BUFF_RESET_TIMES"), self.refreshCount, self.maxRefreshCount))
	end

	self.view.btnReset.interactable = self.refreshCount > 0
	self.view.btnConfirm.interactable = false
end

function RogBuffSelectCtrl:getCurResetCost(curCount)
	local reRandomInitCost = RogueTalentUtils.func(pg.me, "reRandomInitCost")
	local rogueRandomCount = RogueTalentUtils.func(pg.me, "rogueRandomCount")
	local reRandomCost = RogueTalentUtils.func(pg.me, "reRandomCost")
	local res = reRandomInitCost

	for i = 1, rogueRandomCount - curCount do
		res = res + reRandomCost
	end

	return res
end

function RogBuffSelectCtrl:showRogueSkillInfo()
	if not self.view then
		return
	end

	local hasRogueSkill = pg.me.rogueUltimateSeries >= 0

	self.view.rootUComponent:TryChangePage("ModeAdd", hasRogueSkill and 1 or 0)

	if not hasRogueSkill then
		return
	end

	local buffSeriesInfo = RandomBuffSeriesName[pg.me.rogueUltimateSeries]

	if buffSeriesInfo then
		self.view.rogueSkillUImage.url = buffSeriesInfo.buffSeriesIcon
	end

	local buffCount = pg.me.buffSeriesMap[pg.me.rogueUltimateSeries] or 0

	if self.selectedSeries == pg.me.rogueUltimateSeries then
		buffCount = buffCount + 1
	end

	local condition = ExtraRandomBuffCondition[pg.me.rogueUltimateSeries]

	if condition then
		if pg.me.rogueUltimateLevel == #condition.triggerNum then
			self.view.rootUComponent:TryChangePage("ProgressBar", 3)
		else
			local buffSeriesInfo = RandomBuffSeriesName[pg.me.rogueUltimateSeries]

			if buffSeriesInfo then
				local text, _ = string.gsub(pg.getGameString("ROGUE_SKILL_LEVEL_TIP"), "{0}", pg.getLocalizationText(buffSeriesInfo.buffSeriesName))

				ClientTextUtils.setText(self.view.textChoiceUBaseText, text)
			end

			local curLevelCount = condition.triggerNum[pg.me.rogueUltimateLevel]
			local curProgress = buffCount - curLevelCount

			self.view.rootUComponent:TryChangePage("ProgressBar", curProgress)
			self.view.barAddUWidget1:SetActive(self.selectedSeries == pg.me.rogueUltimateSeries and curProgress == 1)
			self.view.barAddUWidget2:SetActive(self.selectedSeries == pg.me.rogueUltimateSeries and curProgress == 2)
			self.view.barAddUWidget3:SetActive(self.selectedSeries == pg.me.rogueUltimateSeries and curProgress == 3)
		end
	end
end

function RogBuffSelectCtrl:onShow()
	return
end

function RogBuffSelectCtrl:onHide()
	return
end

function RogBuffSelectCtrl:onBtnConfirm()
	local isShow = self.param and self.param.isShow

	if isShow or self.selected then
		self:clearListEvent()
	end

	if isShow then
		pg.me.space:nextCacheInfo({
			self.selected
		})
	else
		if not self.selected then
			return
		end

		pg.me.space:selectBuff({
			self.selected
		})
	end

	table.remove(self.cacheInfos, 1)

	if #self.cacheInfos == 0 then
		pg.global.ui:close(UIConst.UI_ID_ROG_BUFF_SELECT)
	elseif self.cacheInfos[1].isShow then
		self:refreshShowBuff(self.cacheInfos[1])
	else
		self.refreshCount = 1

		self:refreshSelectBuffs(self.cacheInfos[1])
	end
end

function RogBuffSelectCtrl:onBtnReset()
	self.refreshCount = self.refreshCount - 1
	self.isResetBuff = true

	pg.me.space:reRandomBuff()
end

function RogBuffSelectCtrl:selectedCount()
	local count = 0

	for _, select in pairs(self.selected) do
		if select then
			count = count + 1
		end
	end

	return count
end

function RogBuffSelectCtrl:clearListEvent()
	if self.view and self.view.buffList then
		self.view.buffList.luaClick = nil
		self.view.buffList.luaRenderItem = nil
		self.view.buffList.luaFinishRender = nil
	end
end

return RogBuffSelectCtrl
