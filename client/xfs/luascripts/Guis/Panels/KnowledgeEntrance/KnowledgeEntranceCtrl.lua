-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\KnowledgeEntrance\\KnowledgeEntranceCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local KnowledgeManager = require("GameApp.Knowledge.KnowledgeManager")
local logger = LoggerManager.getLogger("KnowledgeEntranceCtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local KnowledgeEntranceCtrl = Class.LightClass("KnowledgeEntranceCtrl", UICtrl)
local MAIN_TYPE_COUNT = 6
local MAIN_TYPE_ITEM_ANIMATION_INTERVAL = 0.04
local MAIN_TYPE_ANIMATION_END_DELAY = 0.2

function KnowledgeEntranceCtrl:afterInit()
	self.knowledgeManager = KnowledgeManager.getInstance()
end

function KnowledgeEntranceCtrl:onOpen(info)
	self.knowledgeManager:acquireUIData(self)
	ClientTextUtils.setText(self.view.title, pg.getLocalizationText(pg.getGameString("KNOWLEDGE_TITLE")))

	self.mainTypeButtons = {}
	self.firstVisibleMainTypeButton = nil
	self.isMainTypeButtonInteractable = false

	self.view.tabList:RefreshList()

	local entranceDuration = self.view.tabList.luaPreInterval + MAIN_TYPE_COUNT * MAIN_TYPE_ITEM_ANIMATION_INTERVAL + MAIN_TYPE_ANIMATION_END_DELAY

	self.enableMainTypeButtonsTimer = self:startTimer(function()
		self.enableMainTypeButtonsTimer = nil

		self:setMainTypeButtonsInteractable(true)

		if self.firstVisibleMainTypeButton ~= nil and CS.XGUI.Navigation.NavManager.Instance then
			CS.XGUI.Navigation.NavManager.Instance:FocusItem(self.firstVisibleMainTypeButton)
		end
	end, entranceDuration)
end

function KnowledgeEntranceCtrl:onShow()
	UICtrl.onShow(self)
	self.view.tabList:RefreshList()

	for mainTypeId = 1, MAIN_TYPE_COUNT do
		pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.KNOWLEDGE_MAIN_TYPE, mainTypeId))
	end
end

function KnowledgeEntranceCtrl:setMainTypeButtonsInteractable(interactable)
	self.isMainTypeButtonInteractable = interactable

	for _, button in pairs(self.mainTypeButtons) do
		button.interactable = interactable
	end
end

function KnowledgeEntranceCtrl:onDestroy()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.KNOWLEDGE_ENTRY)
	self.knowledgeManager:releaseUIData(self)
	UICtrl.onDestroy(self)
end

function KnowledgeEntranceCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.closeBtn.luaClick()
		self:dismiss()
	end

	function self.view.tabList.luaRenderItem(button, index, data)
		self:refreshMainTypeItem(button, index, data)
	end

	function self.view.tabList.luaClick(button, data)
		self:onCategoryClick(button, data)
	end
end

function KnowledgeEntranceCtrl:refreshMainTypeItem(button, index, data)
	local mainTypeId = tonumber(data.id)
	local mainTypeData = mainTypeId and self.knowledgeManager:getMainTypeData(mainTypeId)

	if mainTypeData == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("%s 的 mainTypeData 为 nil", tostring(mainTypeId))
		end

		return
	end

	button:SetActive(mainTypeData.maxNum ~= 0)

	self.mainTypeButtons[index] = button
	button.interactable = self.isMainTypeButtonInteractable

	if self.firstVisibleMainTypeButton == nil and mainTypeData.maxNum ~= 0 then
		self.firstVisibleMainTypeButton = button
	end

	local objectReference = button:GetComponent("ObjectReference")
	local name = objectReference:GetRefValue("name")
	local txtNum = objectReference:GetRefValue("txtNum")

	ClientTextUtils.setText(name, pg.getLocalizationText(mainTypeData.title))
	ClientTextUtils.setText(txtNum, string.format("%d/%d", mainTypeData.num, mainTypeData.maxNum))

	local redDotPath = string.format(RedDotConst.RedDotPath.KNOWLEDGE_MAIN_TYPE, mainTypeId)

	pg.global.setPreViewRedDot(redDotPath, button, function()
		local currentMainTypeData = self.knowledgeManager:getMainTypeData(mainTypeId)

		return currentMainTypeData ~= nil and self.knowledgeManager:getMainTypeNewKnowledgeCount(currentMainTypeData) > 0 and RedDotConst.RedDotStyle.NUM or RedDotConst.RedDotStyle.NONE
	end, function()
		local currentMainTypeData = self.knowledgeManager:getMainTypeData(mainTypeId)

		return currentMainTypeData ~= nil and self.knowledgeManager:getMainTypeNewKnowledgeCount(currentMainTypeData) or 0
	end)
end

function KnowledgeEntranceCtrl:onCategoryClick(button, listItem)
	local mainTypeId = tonumber(listItem.id)

	if mainTypeId == nil then
		return
	end

	local mainTypeData = self.knowledgeManager:getMainTypeData(mainTypeId)

	if mainTypeData == nil then
		return
	end

	if mainTypeData.num <= 0 then
		pg.global.showBubbleMessageRaw(pg.getLocalizationText(pg.getGameString("NONE_UNLOCK_KNOWLEDGE_TIP")))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_KNOWLEDGE_Details, {
		mainTypeId = mainTypeId
	})
end

return KnowledgeEntranceCtrl
