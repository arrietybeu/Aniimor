-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerEventDialogue\\TowerEventDialogueCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerEventDialogueCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local RogueRandomEventData = require("Data.rogue_random_event_data")
local RogueRandomEventOptionData = require("Data.rogue_random_event_option_data")
local TowerEventDialogueCtrl = Class.LightClass("TowerEventDialogueCtrl", UICtrl)

TowerEventDialogueCtrl.messages = {
	[MessageName.ROGUE_EVENT_DIALOGUE_DATA_UPDATE] = {
		"onEventInfoUpdate",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"refreshCurrency",
		true
	}
}

function TowerEventDialogueCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.param = info
	self.currencyId = 4000
	self.scrollStep = 0.2
	self.longPressInterval = 0.1
	self.upScrollCount = 0
	self.downScrollCount = 0
	self.isOptionEmpty = false
	self.curOptionData = nil

	if not pg.me.curEventId or pg.me.curEventId == 0 then
		self:close()

		return
	end

	self:handleCamera()
	self:initData()
	self:initUI()
end

function TowerEventDialogueCtrl:addListener()
	function self.view.nextUButton.luaClick()
		self:close()
	end

	function self.view.arrowUpUButton.luaClick()
		local pos = self.view.selectorUList.normalizedScrollPosition

		self.view.selectorUList.normalizedScrollPosition = Vector2(pos.x, math.min(1, pos.y + self.scrollStep))
	end

	self.view.arrowUpUButton.enabledLongPress = true

	function self.view.arrowUpUButton.luaBeginLongPress()
		self.upScrollCount = 0
	end

	function self.view.arrowUpUButton.luaLongPress(pressTime)
		local expected = math.floor(pressTime / self.longPressInterval)

		if expected > self.upScrollCount then
			self.upScrollCount = expected

			local pos = self.view.selectorUList.normalizedScrollPosition

			self.view.selectorUList.normalizedScrollPosition = Vector2(pos.x, math.min(1, pos.y + self.scrollStep))
		end
	end

	function self.view.arrowDownUButton.luaClick()
		local pos = self.view.selectorUList.normalizedScrollPosition

		self.view.selectorUList.normalizedScrollPosition = Vector2(pos.x, math.max(0, pos.y - self.scrollStep))
	end

	self.view.arrowDownUButton.enabledLongPress = true

	function self.view.arrowDownUButton.luaBeginLongPress()
		self.downScrollCount = 0
	end

	function self.view.arrowDownUButton.luaLongPress(pressTime)
		local expected = math.floor(pressTime / self.longPressInterval)

		if expected > self.downScrollCount then
			self.downScrollCount = expected

			local pos = self.view.selectorUList.normalizedScrollPosition

			self.view.selectorUList.normalizedScrollPosition = Vector2(pos.x, math.max(0, pos.y - self.scrollStep))
		end
	end
end

function TowerEventDialogueCtrl:handleCamera()
	local entId = self.param.uiContext.npcGlobalId

	if not entId then
		return
	end

	local ent = pg.getEntity(entId)

	if not ent then
		return
	end

	local curPet = pg.me:getCurPetEntity()

	if curPet then
		curPet:setVisible(ClientConst.MODEL_VISIBLE_KEY.ROGUE, false)
	end

	pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.ROGUE, false)

	local _epx, _epy, _epz = ent.eModel:GetPositionAgentPosEx()
	local pos = Vector3.New(_epx, _epy + 0.72, _epz - 3.6)

	pg.game.camera:cameraBlendToFixed(pos, Quaternion.Euler(0, 14, 0), 45, 0.5)
end

function TowerEventDialogueCtrl:initData()
	self.selectData = {}
	self.curStage = 1

	self:addNewData()
end

function TowerEventDialogueCtrl:addNewData()
	if pg.me.curOptionList and #pg.me.curOptionList > 0 then
		local options = {}

		for _, value in ipairs(pg.me.curOptionList) do
			table.insert(options, {
				id = value
			})
		end

		table.insert(options, {
			tIndex = 1
		})

		self.selectData[#self.selectData + 1] = options
	end
end

function TowerEventDialogueCtrl:onEventInfoUpdate()
	if not pg.me.curOptionList or #pg.me.curOptionList == 0 then
		self:refreshSelectResult(self.curOptionData)

		return
	end

	self:addNewData()

	if #self.selectData == self.curStage then
		self:refreshUI()
	end
end

function TowerEventDialogueCtrl:initUI()
	function self.view.selectorUList.luaRenderItem(button, index, data)
		if data.tIndex == 1 then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local choseTitleUBaseText = objectReference:GetRefValue("choseTitleUBaseText")
		local choseContentUBaseText = objectReference:GetRefValue("choseContentUBaseText")
		local choseUButton = objectReference:GetRefValue("choseUButton")
		local buttonNameUBaseText = objectReference:GetRefValue("buttonNameUBaseText")
		local optionsData = RogueRandomEventOptionData[data.id]

		ClientTextUtils.setText(choseTitleUBaseText, pg.getLocalizationText(optionsData.selectionTitle))
		ClientTextUtils.setText(choseContentUBaseText, pg.getLocalizationText(optionsData.selectionText))
		ClientTextUtils.setText(buttonNameUBaseText, pg.getGameString("COMMON_CONFIRM"))

		function choseUButton.luaClick()
			pg.me:selectRogueEventOption(pg.me.curEventId, data.id)

			self.curStage = self.curStage + 1
			self.curOptionData = data
		end
	end

	self.view.selectorUList:RegisterToScrollEvent(function(pos)
		self:refreshArrowButtons(pos.y)
	end)

	function self.view.selectorUList.luaFinishRender()
		self:refreshArrowButtons(self.view.selectorUList.normalizedScrollPosition.y)
	end

	self:addNavFocusListener(function()
		self:refreshArrowButtons(self.view.selectorUList.normalizedScrollPosition.y)
	end, "TowerEventDialogue")
	ClientTextUtils.setText(self.view.choseUBaseText, pg.getGameString("COMMON_CHOOSE_RESULT"))

	local text = pg.game.input:isUsingGamepad() and pg.getGameString("REUNION_QUEST_CONTINUE") or pg.getGameString("COMMON_CLICK_CONTINUE")

	ClientTextUtils.setText(self.view.closeUBaseText, text)
	self:refreshCurrency()
	self:refreshUI()
end

function TowerEventDialogueCtrl:refreshArrowButtons(normalizedY)
	local scrollable = self.view.selectorUList.needScrollable

	if not scrollable then
		LuaUIUtils.setUIViewVisible(self.view.arrowUpUButton, false)
		LuaUIUtils.setUIViewVisible(self.view.arrowDownUButton, false)

		return
	end

	local showUp = normalizedY < 0.99
	local showDown = normalizedY > 0.01
	local selectedIndex = self.view.selectorUList.selectedIndex

	if pg.game.input:isUsingGamepad() and type(selectedIndex) == "number" and selectedIndex >= 0 then
		local options = self.selectData[self.curStage] or {}
		local lastValidIndex = #options - 2

		showUp = showUp and selectedIndex > 0
		showDown = showDown and selectedIndex < lastValidIndex
	end

	LuaUIUtils.setUIViewVisible(self.view.arrowUpUButton, showUp)
	LuaUIUtils.setUIViewVisible(self.view.arrowDownUButton, showDown)
end

function TowerEventDialogueCtrl:refreshUI()
	if self.curOptionData then
		local optionsDataCfg = RogueRandomEventOptionData[self.curOptionData.id]

		if optionsDataCfg and optionsDataCfg.selectionDelay then
			self:startTimer(function()
				self:refreshEventInfo()
				self:refreshSelectList()
			end, optionsDataCfg.selectionDelay)

			return
		end
	end

	self:refreshEventInfo()
	self:refreshSelectList()
end

function TowerEventDialogueCtrl:refreshEventInfo()
	if pg.me.curEventId and pg.me.curEventId > 0 then
		local eventData = RogueRandomEventData[pg.me.curEventId]

		if eventData then
			ClientTextUtils.setText(self.view.eventTitleUBaseText, pg.getLocalizationText(eventData.eventTitle))
			ClientTextUtils.setText(self.view.eventDescUBaseText, pg.getLocalizationText(eventData.eventText))
		end
	end
end

function TowerEventDialogueCtrl:refreshSelectList()
	if self.selectData[self.curStage] then
		self.hasClickNext = false

		self.view.rootUComponent:TryChangePage("Stage", 0)
		self.view.selectorUList:SetList(self.selectData[self.curStage])
	end
end

function TowerEventDialogueCtrl:refreshSelectResult(data)
	if not data then
		return
	end

	local optionsData = RogueRandomEventOptionData[data.id]

	ClientTextUtils.setText(self.view.resultTitleUBaseText, pg.getLocalizationText(optionsData.selectionTitle))
	ClientTextUtils.setText(self.view.resultContentUBaseText, pg.getLocalizationText(optionsData.selectionText))

	if optionsData.selectionDelay then
		self:startTimer(function()
			self.view.rootUComponent:TryChangePage("Stage", 1)
		end, optionsData.selectionDelay)
	else
		self.view.rootUComponent:TryChangePage("Stage", 1)
	end
end

function TowerEventDialogueCtrl:refreshCurrency()
	LuaUIUtils.setTopCurrencyItem(self.view.currencyItemUButton, self.currencyId)
end

function TowerEventDialogueCtrl:onDestroy()
	local curPet = pg.me:getCurPetEntity()

	if curPet then
		curPet:setVisible(ClientConst.MODEL_VISIBLE_KEY.ROGUE, true)
	end

	pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.ROGUE, true)
	pg.game.camera:cancelBlendToFixed(0.5)
	UICtrl.onDestroy(self)
end

function TowerEventDialogueCtrl:onInputDeviceChanged()
	local text = pg.game.input:isUsingGamepad() and pg.getGameString("REUNION_QUEST_CONTINUE") or pg.getGameString("COMMON_CLICK_CONTINUE")

	ClientTextUtils.setText(self.view.closeUBaseText, text)
end

function TowerEventDialogueCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerEventDialogueCtrl:onShow()
	return
end

function TowerEventDialogueCtrl:onHide()
	return
end

return TowerEventDialogueCtrl
