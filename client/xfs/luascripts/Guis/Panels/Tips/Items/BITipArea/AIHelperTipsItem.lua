-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BITipArea\\AIHelperTipsItem.lua

local AiAssistantData = require("Data.ai_assistant_data")
local Time = require("Core.Common.Time")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Class = require("Core.Framework.Class")
local PuppetData = require("Data.puppet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local PetData = require("Data.pet_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local AddressDataConst = require("Const.AddressDataConst")
local TimerManager = require("Core.Timer.TimerManager")
local UI_Node_Guide_JumpTo = AddressDataConst.UI_Node_Guide_JumpTo
local UI_Node_Guide_Plot = AddressDataConst.UI_Node_Guide_Plot
local AIHelperTipsItem = Class.LightClass("AIHelperTipsItem", BaseQueueItem)

AIHelperTipsItem.TEXT_BATTLE_PET = 1
AIHelperTipsItem.TEXT_TEAM_PET_HURT = 2
AIHelperTipsItem.TEXT_ALIVE_HEAL_PET = 3
AIHelperTipsItem.TEXT_ENEMY_NAME = 4
AIHelperTipsItem.TEXT_ENEMY_ELEMENT = 5
AIHelperTipsItem.TEXT_ENEMY_RESTRAINT_PET = 6
AIHelperTipsItem.TEXT_DEAD_PET_NAME = 7

function AIHelperTipsItem:onCtor(info)
	AIHelperTipsItem.super.onCtor(self, info)

	self.aiHelperDict = {}
	self.textTable = {
		[self.TEXT_BATTLE_PET] = "getCurPetName",
		[self.TEXT_TEAM_PET_HURT] = "getCurMinxBloodPetName",
		[self.TEXT_ALIVE_HEAL_PET] = "getCurAliveHealPetName",
		[self.TEXT_ENEMY_NAME] = "getEnemyName",
		[self.TEXT_ENEMY_ELEMENT] = "getEnemyElementTypeName",
		[self.TEXT_ENEMY_RESTRAINT_PET] = "getRestraintElementPet",
		[self.TEXT_DEAD_PET_NAME] = "getDeadPetInTeam"
	}
	self.forbidAIHelperTip = false
end

function AIHelperTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function AIHelperTipsItem:initViewManualJump()
	self.titleNameText = nil
	self.objectReference = self.uWidget.content:GetComponent("ObjectReference")
	self.contentTxt = self.objectReference:GetRefValue("contentTxt")
	self.mainCom = self.objectReference:GetRefValue("mainCom")
	self.nextBtn = self.objectReference:GetRefValue("nextBtn")
	self.aiAssistantUContainer = self.objectReference:GetRefValue("aiAssistantUContainer")
	self.hotKeyContent = self.objectReference:GetRefValue("hotKeyContent")
	self.rayBox = self.objectReference:GetRefValue("rayBoxUWidget")

	local contentAnimation = self.objectReference:GetRefValue("contentAnimation")

	self.contentUWidget = contentAnimation.transform:GetComponent("UWidget")

	function self.nextBtn.luaClick()
		self:doAITipEvent()
	end
end

function AIHelperTipsItem:initViewManualPlot()
	self.hotKeyContent = nil
	self.btnTipsUText = nil
	self.objectReference = self.uWidget.content:GetComponent("ObjectReference")
	self.contentTxt = self.objectReference:GetRefValue("contentTxt")
	self.mainCom = self.objectReference:GetRefValue("mainCom")
	self.titleNameText = self.objectReference:GetRefValue("titleNameText")
	self.nextBtn = self.objectReference:GetRefValue("nextBtn")
	self.rayBox = self.objectReference:GetRefValue("rayBoxUWidget")

	local contentAnimation = self.objectReference:GetRefValue("contentAnimation")

	self.contentUWidget = contentAnimation.transform:GetComponent("UWidget")
	self.aiAssistantUContainer = self.objectReference:GetRefValue("aiAssistantUContainer")

	ClientTextUtils.setText(self.titleNameText, pg.getGameString("AI_NAME"))
end

function AIHelperTipsItem:doAITipEvent()
	if self.jumpEvent then
		self:jumpEvent()
	end

	self:closeTips()
end

function AIHelperTipsItem:pushData(data)
	local id = data.id
	local cfgData = AiAssistantData[id]

	if not cfgData then
		return
	end

	if not pg.me:checkAiHelperEnterLimit(cfgData) then
		return
	end

	local priority = cfgData.priority

	self.aiHelperDict[id] = priority

	local insertIndex

	for i = 1, #self.dataQueue do
		local curData = self.dataQueue[i]
		local cuyPriority = self.aiHelperDict[curData.id] or 0

		if priority < cuyPriority then
			insertIndex = i

			break
		end
	end

	if insertIndex then
		table.insert(self.dataQueue, insertIndex, data)
	else
		table.insert(self.dataQueue, data)
	end

	self:refreshRunState()
end

function AIHelperTipsItem:checkIsRunning()
	return self.curAiId ~= nil
end

function AIHelperTipsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function AIHelperTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	if self:isRunning() then
		local data = self:peek()

		if not data then
			return
		end

		local cfgData = AiAssistantData[data.id]
		local curPriority = self.aiHelperDict[self.curAiId]

		if not curPriority or curPriority <= cfgData.priority then
			return
		end
	end

	self:setVisible(true)

	local data = self:dequeue()
	local id = data.id
	local cfgData = AiAssistantData[id]

	data.endTime = Time.realSecondCache + (cfgData.time or 5)
	self.offsetX = 0

	if data.extraInfo and data.extraInfo.offsetX then
		self.offsetX = data.extraInfo.offsetX
	end

	self:addRunItem(data)
	self:showAITip(id)
end

function AIHelperTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function AIHelperTipsItem:onClearRunningList(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		self:recycleToast(data)
	end
end

function AIHelperTipsItem:showAITip(id)
	if self.forbidAIHelperTip then
		return
	end

	local cfgData = AiAssistantData[id]

	self.textParams = {}

	if cfgData.chat_value then
		for idx, chatId in pairs(cfgData.chat_value) do
			local func = self.textTable[chatId]
			local targetText = self[func](self)

			if string.isNilOrEmpty(targetText) then
				self.aiHelperDict[id] = nil

				return
			end

			self.textParams[#self.textParams + 1] = targetText
		end
	end

	if self.curAiId then
		self.aiHelperDict[self.curAiId] = nil
	end

	local event = cfgData.event1
	local resUrl = event and UI_Node_Guide_JumpTo or UI_Node_Guide_Plot

	self:showAITipWithURL(resUrl, id)
end

function AIHelperTipsItem:showAITipWithURL(resUrl, id)
	self:clearCloseTimer()

	if self.uWidget.url == resUrl and self.uWidget:CheckURLLoaded(resUrl) then
		self:_showAIHelperImp(id)
	else
		self.jumpBind = nil
		self.escKB = nil

		self.uWidget:SetUrlWithCallback(resUrl, function()
			if resUrl == UI_Node_Guide_JumpTo then
				self:initViewManualJump()
			else
				self:initViewManualPlot()
			end

			self:_showAIHelperImp(id)
		end)
	end
end

function AIHelperTipsItem:_showAIHelperImp(id)
	if self.contentUWidget then
		local pos = self.contentUWidget.anchoredPosition

		pos.x = self.offsetX or 0
		self.contentUWidget.anchoredPosition = pos
	end

	local cfgData = AiAssistantData[id]

	self.curAiId = id

	local desc = pg.getLocalizationText(cfgData.chat, unpack(self.textParams))

	self.nextBtn.interactable = true

	ClientTextUtils.setText(self.contentTxt, desc)

	if cfgData.event1 then
		pg.game.chat:recvSystemNotice(desc .. string.format(" <link=\"doAction\"><color=#5d90eb><u>%s</u></color></link>", pg.getGameString("AI_CHAT_GOTO")), "AI", function()
			pg.me:doEventByData({
				cfgData.event1,
				cfgData.value1
			})
		end, nil, "other")

		if cfgData.action1 and NotNil(self.hotKeyContent) then
			self.hotKeyContent:SetHotKeyPaths(cfgData.action1)
		end
	else
		pg.game.chat:recvSystemNotice(desc)
	end

	self.rayBox:SetActive(true)

	self.aiAssistantUContainer.url = cfgData.emo
	self.escKB = KeyBindingPro.GetOrAddKeyBindingByName(self.mainCom.gameObject, "esc")
	self.escKB.isVirtual = true
	self.escKB.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel
	self.escKB.priority = 100

	function self.escKB.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closeTips()
		end
	end

	if pg.global.ui:runPlatformByMobile() then
		self.nextBtn:EnableListenNonAOI(function()
			self:closeTips()
			self.nextBtn:DisableListenNonAOI()
		end)
	end

	if cfgData.action1 then
		self.jumpBind = KeyBindingPro.GetOrAddKeyBindingByName(self.nextBtn.gameObject, "jump")
		self.jumpBind.priority = 100
		self.jumpBind.actionPath = cfgData.action1

		function self.jumpEvent()
			pg.me:doEventByData({
				cfgData.event1,
				cfgData.value1
			})
		end
	else
		self.jumpEvent = nil

		if self.jumpBind then
			self.jumpBind.actionPath = nil
		end
	end

	self:show()
	self.uWidget.content:InvokeCallback(CS.XGUI.EInvokeTime.Show)
end

function AIHelperTipsItem:recycleToast(data, force)
	if data.removing then
		return
	end

	data.removing = true

	self:closeTips()
	self:removeItem(data)
end

function AIHelperTipsItem:closeTips()
	if self.curAiId then
		self.aiHelperDict[self.curAiId] = nil
	end

	if self.escKB then
		self.escKB.actionPath = nil
	end

	self:closeCurTips()
end

function AIHelperTipsItem:closeCurTips()
	if self.curAiId then
		self.aiHelperDict[self.curAiId] = nil
		self.curAiId = nil
	end

	self.jumpEvent = nil

	if self.uWidget.content then
		self.uWidget.content:InvokeCallback(CS.XGUI.EInvokeTime.Hide)

		if self.jumpBind ~= nil then
			self.jumpBind.actionPath = ""
		end

		if self.rayBox ~= nil then
			self.rayBox:SetActive(false)
		end

		self:clearCloseTimer()

		self.closeTimer = TimerManager.addTimer(0.3, function()
			if self.uWidget then
				self.uWidget:DestroyContent()
			end
		end)
	else
		self.uWidget:DestroyContent()
	end
end

function AIHelperTipsItem:hideById(groupId)
	for i = #self.dataQueue, 1, -1 do
		local data = self.dataQueue[i]
		local cfgData = data and AiAssistantData[data.id]

		if cfgData and cfgData.group == groupId then
			self.aiHelperDict[data.id] = nil

			table.remove(self.dataQueue, i)
		end
	end

	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]
		local cfgData = data and AiAssistantData[data.id]

		if cfgData and cfgData.group == groupId then
			self.aiHelperDict[data.id] = nil

			table.remove(self.runList, i)
		end
	end

	if self.curAiId then
		self.aiHelperDict[self.curAiId] = nil
		self.curAiId = nil
	end
end

function AIHelperTipsItem:clearAll()
	table.clearArray(self.dataQueue)
	self:onClearRunningList(true)

	self.aiHelperDict = {}
	self.curAiId = nil

	self:refreshRunState()
end

function AIHelperTipsItem:clearCloseTimer()
	if self.closeTimer then
		TimerManager.removeTimer(self.closeTimer)
	end

	self.closeTimer = nil
end

function AIHelperTipsItem:getNeedShowTipId()
	local id
	local priority = -1

	for aid, p in pairs(self.aiHelperDict) do
		if priority < p then
			id = aid
			priority = p
		end
	end

	return id
end

function AIHelperTipsItem:getCurPetName()
	local myCurPet = pg.me:getCurPetEntity()

	return myCurPet:getName()
end

function AIHelperTipsItem:getCurMinxBloodPetName()
	local player = pg.me
	local prepareList = player.petPrepareList
	local ratio = 100
	local petId

	for idx, id in pairs(prepareList) do
		local partnerInfo = player.partnerList[idx]
		local temp = partnerInfo.curHp / partnerInfo.maxHp

		if temp < ratio then
			ratio = temp
			petId = id
		end
	end

	if petId then
		local petEnt = pg.getEntity(petId)

		return petEnt:getName()
	end

	return ""
end

function AIHelperTipsItem:getCurAliveHealPetName()
	local player = pg.me
	local prepareList = player.petPrepareList

	for idx, petId in pairs(prepareList) do
		if petId then
			local petEnt = pg.getEntity(petId)

			if petEnt:isAlive() and PetData[petEnt.templateId].functionId == UIConst.NEW_PET_BATTLE_TYPE.HEAL then
				return petEnt:getName()
			end
		end
	end

	return ""
end

function AIHelperTipsItem:getEnemyElementTypeName()
	local lockedEnemy = pg.getEntityByActorId(pg.me.lockedActorId)

	if lockedEnemy then
		local info = LuaUIUtils.getTargetElementsInfos(lockedEnemy.elementTypes)
		local elementRet = ""

		for idx, eInfo in pairs(info) do
			elementRet = elementRet .. string.format("%s", LuaUIUtils.getElementNameLocalization(eInfo.elementId))
		end

		return elementRet
	end

	return ""
end

function AIHelperTipsItem:getEnemyName()
	local lockedEnemy = pg.getEntityByActorId(pg.me.lockedActorId)

	if lockedEnemy then
		local data = PuppetData[lockedEnemy.templateId]

		return pg.getLocalizationText(data and data.name)
	end

	return ""
end

function AIHelperTipsItem:getRestraintElementPet()
	local lockedEnemy = pg.getEntityByActorId(pg.me.lockedActorId)

	if lockedEnemy then
		local player = pg.me

		for _, petId in pairs(player.petPrepareList) do
			local petEnt = pg.getEntity(petId)
			local pdd = PetData[petEnt.templateId]

			if pdd and Utils.getElementAgainstValue(pdd.mainElementType, lockedEnemy.elementTypes) > 1 and petEnt:isAlive() then
				return petEnt:getName()
			end
		end
	end
end

function AIHelperTipsItem:getDeadPetInTeam()
	local player = pg.me
	local prepareList = player.petPrepareList

	for idx, petId in pairs(prepareList) do
		if petId then
			local petEnt = pg.getEntity(petId)

			if not petEnt:isAlive() then
				return petEnt:getName()
			end
		end
	end

	return ""
end

return AIHelperTipsItem
