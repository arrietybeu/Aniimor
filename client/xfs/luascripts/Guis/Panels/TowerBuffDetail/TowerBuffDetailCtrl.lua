-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerBuffDetail\\TowerBuffDetailCtrl.lua

local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TowerBuffDetailCtrl = Class.LightClass("TowerBuffDetailCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local RandomBuffSeriesName = require("Data.random_buff_series_name")
local DungeonConst = require("Common.Const.DungeonConst")
local RogueUtils = require("Utils.RogueUtils")
local RogueTransformData = require("Data.rogue_transform_data")
local BuffSeriesToExtraRandomBuff = require("Data.buff_series_to_extra_random_buff")
local ExtraRandomBuff = require("Data.extra_random_buff")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ExtraRandomBuffCondition = require("Data.extra_random_buff_condition")
local Const = require("Common.Const.Const")

TowerBuffDetailCtrl.TitleTab = {
	RogueSkill = 1,
	Buff = 0
}
TowerBuffDetailCtrl.messages = {}

function TowerBuffDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI(info)
end

function TowerBuffDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:close()
	end)
	self:bindHotKey("Hud/RogueBuffDetail", function()
		self:close()
	end)
	self:bindGamepadScrollUList(self.view.listBuffUList, nil, true)
end

function TowerBuffDetailCtrl:showRogueSkill()
	self.view.rootUComponent:TryChangePage("Tab", 1)
	self:startTimer(function()
		RogueUtils.renderUltimatePetPropRadar(RogueUtils.getUltimatePetPropRadarBind(self.view.petDemensionUWidget))
	end, 0.1)

	local hasRogueSkill = pg.me.rogueUltimateSeries >= 0

	if self.view.skillEmpty then
		LuaUIUtils.setUIVisible(self.view.skillEmpty, not hasRogueSkill)
	end
end

function TowerBuffDetailCtrl:initUI(info)
	local titleData = {
		{
			selected = true,
			tIndex = 0,
			label = pg.getGameString("ROGUE_BUFF_LIST"),
			tab = self.TitleTab.Buff
		},
		{
			tIndex = 2,
			label = pg.getGameString("ROGUE_TRANSFORM_SKILL"),
			tab = self.TitleTab.RogueSkill
		}
	}

	function self.view.titleTabUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderTitleTab(button, index, data)
	end

	function self.view.titleTabUList.luaClick(button, data)
		self.view.rootUComponent:TryChangePage("Tab", data.tab)

		if data.tab == self.TitleTab.RogueSkill then
			self.view.buffDetailEmptyUWidget:SetActive(false)
			self:showRogueSkill()
		elseif data.tab == self.TitleTab.Buff then
			if self.view.skillEmpty then
				LuaUIUtils.setUIVisible(self.view.skillEmpty, false)
			end

			self:refreshBuffList()
		end

		self:refreshConsoleBarState()
	end

	self:refreshConsoleBarState()
	self.view.titleTabUList:SetList(titleData)

	function self.view.listTabUList.luaRenderItem(button, index, data)
		button.gameObject.name = index

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local numUBaseText = objectReference:GetRefValue("numUBaseText")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")

		ClientTextUtils.setText(nameUBaseText, data.label)
		ClientTextUtils.setText(numUBaseText, data.count)

		local buffSeriesInfo = RandomBuffSeriesName[data.type]

		iconUImage.url = buffSeriesInfo and buffSeriesInfo.buffSeriesIcon or ""

		if data.selected then
			self.selectedButton = button
		end
	end

	function self.view.listTabUList.luaClick(button, data)
		self.curType = data.type

		self:refreshBuffList()
	end

	function self.view.listBuffUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local buffIconUImage = objectReference:GetRefValue("buffIconUImage")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local buffSeriesIconUImage = objectReference:GetRefValue("buffSeriesIconUImage")
		local buffSeriesUWidget = objectReference:GetRefValue("buffSeriesUWidget")
		local txtDetailUBaseText = objectReference:GetRefValue("txtDetailUBaseText")
		local lineUWidget = objectReference:GetRefValue("lineUWidget")
		local qualityUBaseText = objectReference:GetRefValue("qualityUBaseText")

		lineUWidget:SetActive(index ~= self.curStyleBuffCount - 1)

		buffIconUImage.url = data.buffIcon

		ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(data.buffName))
		ClientTextUtils.setText(txtDetailUBaseText, pg.getLocalizationText(data.buffDesc))

		txtDetailUBaseText.enabledHyperlink = true

		function txtDetailUBaseText.luaOnHyperlinkClick(action, content, contentRect)
			LuaUIUtils.clickHyperText(action, content, contentRect)
		end

		RogueUtils.setBuffQuality(button, data)

		if data.buffQuality == Const.RogueBuffQuality.Equipment then
			button:TryChangePage("ProgressBar", data.buffCount)
			ClientTextUtils.setText(qualityUBaseText, pg.getGameString("ROGUE_BUFF_LEVEL_CORE"))
		elseif data.buffQuality == Const.RogueBuffQuality.High then
			ClientTextUtils.setText(qualityUBaseText, pg.getGameString("ROGUE_BUFF_LEVEL_ADVANCED"))
		elseif data.buffQuality == Const.RogueBuffQuality.Normal then
			ClientTextUtils.setText(qualityUBaseText, pg.getGameString("ROGUE_BUFF_LEVEL_NORMAL"))
		end

		buffSeriesUWidget:SetActive(data.buffTagIcon ~= nil and data.buffTagIcon ~= "")

		if data.buffTagIcon then
			buffSeriesIconUImage.url = data.buffTagIcon
		end
	end

	self.curType = info and info.buffSeries

	if self.curType == nil then
		self.curType = DungeonConst.ROGUE_ALL_BUFF_TYPE_ID
	end

	self.buffList = self.model:getBuffLists()
	self.recordFocusMap = {}

	self:refreshBuffPanel()
	self:refreshRogueSkill()

	if info and info.showBoss then
		self:showRogueSkill()
	end
end

function TowerBuffDetailCtrl:refreshBuffPanel()
	self:refreshTypeList()
	self:refreshBuffList()
end

function TowerBuffDetailCtrl:refreshTypeList()
	local types = self.model:getBuffTypes2(self.curType)
	local hasBuff = #types > 1

	self.view.buffPanelUComponent:TryChangePage("empty", hasBuff and 0 or 1)

	if not hasBuff then
		return
	end

	self.view.listTabUList:SetList(types)
	self:startTimer(function()
		if self.selectedButton then
			self.selectedButton:TryChangePage("button", 0)
			self.selectedButton:TryChangePage("button", 5)
		end
	end, 0.1)
end

function TowerBuffDetailCtrl:refreshBuffList()
	local buffList = self.buffList[self.curType] or {}

	self.curStyleBuffCount = #buffList

	self.view.listBuffUList:SetList(buffList)
	self.view.buffDetailEmptyUWidget:SetActive(#buffList == 0)
	self:refreshConsoleBarState()
end

function TowerBuffDetailCtrl:refreshRogueSkill()
	local hasRogueSkill = pg.me.rogueUltimateSeries >= 0

	self.view.skillPanelUComponent:TryChangePage("empty", hasRogueSkill and 0 or 1)

	if not hasRogueSkill then
		return
	end

	self.seriesCfg = RogueTransformData[pg.me.rogueUltimateSeries]
	self.view.imgBossUImage.url = self.seriesCfg and self.seriesCfg.transformVerticalPainting or ""

	if self.seriesCfg then
		RogueUtils.renderSkillBtn(self.view.skilUltimateUButton, self.seriesCfg.bossUltimateSkillId, self.seriesCfg.bossUltimateSkillVideo)
		RogueUtils.renderSkillBtn(self.view.skil1UButton, self.seriesCfg.bossSkill1Id, self.seriesCfg.bossSkill1Video)
		RogueUtils.renderSkillBtn(self.view.skil2UButton, self.seriesCfg.bossSkill2Id, self.seriesCfg.bossSkill2Video)
	end

	RogueUtils.renderUltimatePetPropRadar(RogueUtils.getUltimatePetPropRadarBind(self.view.petDemensionUWidget))

	local buffCount = pg.me.buffSeriesMap[pg.me.rogueUltimateSeries] or 0
	local condition = ExtraRandomBuffCondition[pg.me.rogueUltimateSeries]

	ClientTextUtils.setText(self.view.skillProgressUBaseText, string.format("%d/%d", buffCount, condition.triggerNum[#condition.triggerNum]))

	function self.view.skillProgressUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local textNumberUBaseText = objectReference:GetRefValue("textNumberUBaseText")
		local textDescUBaseText = objectReference:GetRefValue("textDescUBaseText")

		button:TryChangePage("Status", data.hasGet and 0 or 1)
		ClientTextUtils.setText(textNumberUBaseText, condition.triggerNum[index + 2])

		if data.hasGet then
			ClientTextUtils.setText(textDescUBaseText, pg.getLocalizationText(ExtraRandomBuff[data.buffId].buffName))
		else
			ClientTextUtils.setText(textDescUBaseText, "???")
		end
	end

	self.view.skillProgressUList:SetList(self:getRogueSkillBuffData())
end

function TowerBuffDetailCtrl:getRogueSkillBuffData()
	local data = {}

	for _, buffId in ipairs(BuffSeriesToExtraRandomBuff[pg.me.rogueUltimateSeries]) do
		table.insert(data, {
			buffId = buffId,
			hasGet = pg.me.rogueUltimateBuffs[buffId] ~= nil,
			index = pg.me.rogueUltimateBuffs[buffId] or 10
		})
	end

	table.sort(data, function(a, b)
		return a.index < b.index
	end)

	return data
end

function TowerBuffDetailCtrl:getBuffByIndex(index)
	if self.buffList == nil then
		return
	end

	return self.buffList[index]
end

function TowerBuffDetailCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerBuffDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerBuffDetailCtrl:onShow()
	return
end

function TowerBuffDetailCtrl:onHide()
	return
end

function TowerBuffDetailCtrl:refreshConsoleBarState()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local isBuffTab = false
	local ret, page = self.view.rootUComponent:TryGetCurrentPage("Tab")

	if ret then
		isBuffTab = page == self.TitleTab.Buff
	end

	local canScroll = false
	local pageCapacity = self.view.listBuffUList:GetPageCapacity()

	if pageCapacity and pageCapacity > 0 then
		canScroll = pageCapacity < self.view.listBuffUList.itemCount
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Buff_IsScroll", isBuffTab and canScroll)
end

return TowerBuffDetailCtrl
