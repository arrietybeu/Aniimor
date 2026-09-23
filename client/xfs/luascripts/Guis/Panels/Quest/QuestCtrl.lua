-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quest\\QuestCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local QuestConst = require("Common.Const.QuestConst")
local QuestCatalogConfig = require("Data.quest_catalog")
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local SafeCallback = require("Core.Framework.SafeCallback")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestMainComponent = require("Guis.Panels.Quest.Component.QuestMainComponent")
local RedDotConst = require("Const.RedDotConst")
local AddressDataConst = require("Const.AddressDataConst")
local KnowledgeManager = require("GameApp.Knowledge.KnowledgeManager")
local QuestCtrl = Class.LightClass("QuestCtrl", UICtrl)

function QuestCtrl:afterInit()
	self.knowledgeManager = KnowledgeManager.getInstance()
end

function QuestCtrl:onOpen()
	self.knowledgeManager:acquireUIData(self)
end

QuestCtrl.messages = {
	[MessageName.QUEST_ON_STATE_CHANGE] = {
		"onQuestStateChange",
		true
	},
	[MessageName.QUEST_ON_ADD] = {
		"onAddNewQuest",
		true
	},
	[MessageName.QUEST_ON_TRACE_CHANGE] = {
		"onQuestTraceChange",
		true
	},
	[MessageName.QUEST_ON_CLUE_STATE_CHANGE] = {
		"onQuestTraceChange",
		true
	},
	[MessageName.QUEST_ON_SUBMIT] = {
		"onQuestSubmit",
		true
	},
	[MessageName.LOGIC_TIME_UPDATE] = {
		"onLogicTimeUpdate",
		true
	},
	[MessageName.QUEST_ON_RUN_STATE_CHANGE] = {
		"onQuestRunStateChange",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function QuestCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:init(info)
end

function QuestCtrl:onShow()
	UICtrl.onShow(self)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.KNOWLEDGE_ENTRY)
	self:initTab()
end

function QuestCtrl:init(info)
	self.questMainComponent = QuestMainComponent.new(self)

	self:onLogicTimeUpdate()

	local selectQuestId = self:takeCurSelectQuestId()

	if info ~= nil and type(info) == "table" or selectQuestId then
		self.curSelQuestId = info and tonumber(info.questId) or selectQuestId

		if info and info.mainType then
			self.curSelMainType = info.mainType
		elseif self.curSelQuestId ~= nil then
			local chapterConfig = QuestUtils.getMainQuestChapterConfig(self.curSelQuestId)

			self.curSelMainType = chapterConfig and chapterConfig.mainType or nil
		end
	end
end

function QuestCtrl:takeCurSelectQuestId()
	local selectQuestId = pg.game.quest:getCurSelectQuestId()

	pg.game.quest:setCurSelectQuestId(nil)

	if selectQuestId == nil or selectQuestId == 0 then
		selectQuestId = nil

		local curPage = QuestUtils.getCurSelPage()

		if curPage ~= QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
			local traceQuestId = QuestUtils.getPageTraceQuestId(curPage)

			selectQuestId = traceQuestId and traceQuestId ~= 0 and traceQuestId or nil
		end
	end

	return selectQuestId
end

function QuestCtrl:addListener()
	function self.view.tabList.luaRenderItem(button, index, data)
		self:onRenderTabItem(button, index, data)
	end

	LuaUIUtils.bindHotKey(self.view.widget.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:dismissUI()
	end)
	LuaUIUtils.bindHotKey(self.view.widget.gameObject, LuaUIUtils.getFuncActionPath(Const.FUNCTION_IDS.QUEST), function()
		self:dismissUI()
	end)

	function self.view.closeBtn.luaClick()
		self:dismiss()
	end

	function self.view.knowledgeBtn.luaClick()
		pg.global.ui:open(UIConst.UI_ID_KNOWLEDGE_Entrance)
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.KNOWLEDGE_ENTRY, self.view.knowledgeBtn, function()
		return (self.knowledgeManager.newKnowledgeCount or 0) > 0 and RedDotConst.RedDotStyle.NUM or RedDotConst.RedDotStyle.NONE
	end, function()
		return self.knowledgeManager.newKnowledgeCount or 0
	end)
end

function QuestCtrl:initTab()
	local catalogConfig = QuestCatalogConfig
	local catalogInfo = {}

	for i, v in pairs(catalogConfig) do
		if v.mainType ~= QuestConst.MainType.Clue and catalogInfo[v.mainType] == nil then
			catalogInfo[v.mainType] = {
				id = i,
				mainType = v.mainType,
				mainTypeName = v.mainTypeName
			}
		end
	end

	local maxCount = #catalogInfo

	for i = 1, maxCount do
		local info = catalogInfo[i]

		if i == 1 then
			info.tIndex = 0
		elseif i == maxCount then
			info.tIndex = 2
		else
			info.tIndex = 1
		end
	end

	self.view.tabList:SetList(catalogInfo)
	self:initClueTabButton()
end

function QuestCtrl:selectTabByMainType(jumpType, id)
	if not jumpType or id == nil or not self.view or not self.view.tabList then
		return
	end

	local itemCount = self.view.tabList.itemCount
	local itemData = self.view.tabList.itemData

	for i = 0, itemCount - 1 do
		local _, button = self.view.tabList:TryGetChildAt(i)

		if button and itemData[i] then
			local data = itemData[i]

			if jumpType == QuestConst.QUEST_MANUAL_JUMP_TYPE.QUEST then
				local chapterId = QuestUtils.getQuestChapterIdBySectionId(id)
				local questGroupId = QuestUtils.getQuestMainGroupId(chapterId, id)
				local pageId = QuestUtils.getMainQuestChapterConfig(questGroupId).mainType

				if data and data.mainType == pageId then
					self.curSelMainType = data.mainType
					self.curSelQuestId = questGroupId

					button:OnClickSimulate()

					break
				end
			elseif jumpType == QuestConst.QUEST_MANUAL_JUMP_TYPE.CLUE then
				local questId = QuestUtils.getQuestJumpClueQuestId(id)

				self.curSelMainType = QuestConst.MainType.Clue
				self.curSelQuestId = questId

				if self.view.btnClueUButton then
					self.view.btnClueUButton.luaClick()
				end

				break
			end
		end
	end
end

function QuestCtrl:onRenderTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name1 = objectReference:GetRefValue("name1")
	local name2 = objectReference:GetRefValue("name2")

	ClientTextUtils.setTextWithId(name1, data.mainTypeName)
	ClientTextUtils.setTextWithId(name2, data.mainTypeName)

	function button.luaClick()
		if self.view.btnClueUButton then
			self.view.btnClueUButton.isSelected = false

			self.view.btnClueUButton:TryChangePage("button", 0)
		end

		self.view.clueBtnUWidget:SetActive(false)

		if self.curSelMainType == QuestConst.MainType.Clue and data.mainType ~= QuestConst.MainType.Clue then
			self.model:markAllRevealedCluesSeen()
		end

		self.curIndex = index
		self.curSelMainType = data.mainType

		SafeCallback(self.questMainComponent.onShow, self.questMainComponent, self.curSelMainType, self.curSelQuestId)
	end

	if data then
		local mainType = data.mainType
		local treePath = string.format(RedDotConst.RedDotPath.QUEST_CHAPTER_REWARD_MAINTYPE, mainType)

		pg.global.setPreViewRedDot(treePath, button, function()
			if self.model:isAnyChapterProgressRewardCanClaimByMainType(mainType) then
				return RedDotConst.RedDotStyle.REWARD
			else
				return RedDotConst.RedDotStyle.NONE
			end
		end)
	end

	if self.curIndex == nil and self.curSelMainType == nil or data.mainType == self.curSelMainType then
		button:OnClickSimulate()
	end
end

function QuestCtrl:initClueTabButton()
	local clueBtn = self.view.btnClueUButton

	if not clueBtn then
		return
	end

	self.clueTabButton = clueBtn

	function clueBtn.luaClick()
		self.curSelMainType = QuestConst.MainType.Clue

		self.model:saveClueBubbleBaseline()
		self:refreshCluePopBubble()
		self.view.clueBtnUWidget:SetActive(false)

		if self.view.tabList then
			self.view.tabList:DeselectAll()
		end

		SafeCallback(self.questMainComponent.onShow, self.questMainComponent, self.curSelMainType, nil)
	end

	self:refreshCluePopBubble()

	local treePath = string.format(RedDotConst.RedDotPath.QUEST_CHAPTER_REWARD_MAINTYPE, QuestConst.MainType.Clue)

	pg.global.setPreViewRedDot(treePath, clueBtn, function()
		if self.model:isAnyChapterProgressRewardCanClaimByMainType(QuestConst.MainType.Clue) then
			return RedDotConst.RedDotStyle.REWARD
		else
			return RedDotConst.RedDotStyle.NONE
		end
	end)

	if self.curSelMainType == QuestConst.MainType.Clue then
		clueBtn.luaClick()
	end
end

function QuestCtrl:refreshCluePopBubble()
	local button = self.clueTabButton

	if not button then
		return
	end

	local count = self.model:getNewClueCount()
	local hasNew = count > 0

	if (self.cluePopObj == nil or IsNil(self.cluePopObj)) and self.cluePopTaskId == nil then
		if not hasNew then
			return
		end

		self.cluePopTaskId = self.view:addPrefabWithPathAsync(button.transform, AddressDataConst.QUEST_MANUAL_CLUE_POP, function(obj)
			self.cluePopTaskId = nil

			if not obj or not obj.gameObject then
				return
			end

			self.cluePopObj = obj.gameObject

			local popRect = obj.gameObject:GetComponent("RectTransform")

			if popRect and not IsNil(popRect) then
				popRect.anchorMin = Vector2(0.5, 0)
				popRect.anchorMax = Vector2(0.5, 0)
				popRect.pivot = Vector2(0.5, 1)
				popRect.anchoredPosition = Vector2(0, 0)
			end

			local objRef = obj.gameObject:GetComponent("ObjectReference")

			if objRef then
				self.cluePopCntTxt = objRef:GetRefValue("textUSDFText")
			end

			local curCnt = self.model:getNewClueCount()

			self:setCluePopText(curCnt)
			self.cluePopObj:SetActiveEx(curCnt > 0)
		end, false, true)

		return
	end

	if not IsNil(self.cluePopObj) then
		self.cluePopObj:SetActiveEx(hasNew)
		self:setCluePopText(count)
	end
end

function QuestCtrl:setCluePopText(count)
	if not self.cluePopCntTxt then
		return
	end

	ClientTextUtils.setText(self.cluePopCntTxt, count > 0 and string.format(pg.getGameString("QUEST_MANUAL_CLUE_TIP"), count) or "")
end

function QuestCtrl:onExit(this)
	if self.questMainComponent ~= nil and self.questMainComponent ~= this then
		self.questMainComponent:onExit()
	end
end

function QuestCtrl:onRefreshSkillPoint()
	ClientTextUtils.setText(self.view.skillPointNum, string.format("X%d", pg.me:getSkillPoint()))

	self.view.skillPointImg.url = LuaUIUtils.getIconByItemId(1000)
end

function QuestCtrl:onQuestStateChange(data)
	return
end

function QuestCtrl:onAddNewQuest(data)
	if data.type == QuestConst.QUEST_TYPE.MAIN and self.showTab == 0 then
		self.questMainComponent:onAddNewQuest(data)
	end
end

function QuestCtrl:onQuestTraceChange(data)
	self.questMainComponent:onQuestTraceChange(data)
	self:refreshCluePopBubble()
end

function QuestCtrl:onQuestSubmit(data)
	local questConfig = QuestUtils.getQuestConfig(data.questId)

	if questConfig.questType == QuestConst.QUEST_TYPE.MAIN and self.showTab == 0 then
		self.questMainComponent:onQuestGetReward(data)
	end
end

function QuestCtrl:onQuestRunStateChange(data)
	self:onRefreshQuestStateChange(data)

	if self.questMainComponent ~= nil then
		self.questMainComponent:refreshSourceBtn()
	end
end

function QuestCtrl:onRefreshQuestStateChange(data)
	if self.showTab == 0 then
		self.questMainComponent:onQuestTraceChange(data)
	end
end

function QuestCtrl:onInputDeviceChanged(deviceType)
	if self.showTab == 0 then
		self.questMainComponent:onInputDeviceChanged(deviceType)
	end
end

function QuestCtrl:onHide()
	UICtrl.onHide(self)
	pg.game.quest:setCurSelectQuestId(nil)

	if self.curSelMainType == QuestConst.MainType.Clue then
		self.model:markAllRevealedCluesSeen()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end
end

function QuestCtrl:dismissUI()
	self:dismiss()
end

function QuestCtrl:onLogicTimeUpdate(logicTime)
	local isPeriodDay = pg.timePeriod ~= Const.TimePeriod.Night

	if self.isPeriodDay == isPeriodDay then
		return
	end

	self.isPeriodDay = isPeriodDay

	if self.questMainComponent ~= nil then
		self.questMainComponent:refreshSourceBtn()
	end
end

function QuestCtrl:onDestroy()
	self.knowledgeManager:releaseUIData(self)
	UICtrl.onDestroy(self)

	self.curIndex = nil
end

return QuestCtrl
