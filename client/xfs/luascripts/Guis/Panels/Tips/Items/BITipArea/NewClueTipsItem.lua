-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BITipArea\\NewClueTipsItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local NewClueTipsItem = Class.LightClass("NewClueTipsItem", BaseQueueItem)

function NewClueTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function NewClueTipsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function NewClueTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 5)

	self:addRunItem(data)
	self:initUContainer(data)
end

function NewClueTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function NewClueTipsItem:onClearRunningList(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		self:requestRecycle(data, force, CS.XGUI.EInvokeTime.Custom1)
	end
end

function NewClueTipsItem:recycleToast(data, callback)
	if not data.removing then
		data.recycleCloseCallback = callback
	end

	local event = data.isClick and CS.XGUI.EInvokeTime.Custom2 or CS.XGUI.EInvokeTime.Custom1

	self:requestRecycle(data, false, event)
end

function NewClueTipsItem:destroyContent(data, callback)
	if callback then
		data.recycleCloseCallback = callback
	end

	self:completeRecycle(data)
end

function NewClueTipsItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function NewClueTipsItem:renderItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local titleTxt = oc:GetRefValue("titleTxt")
	local questConfig = QuestUtils.getQuestConfig(data.questId)

	if questConfig then
		ClientTextUtils.setTextWithId(titleTxt, questConfig.name)
	end

	local goBtn = oc:GetRefValue("goBtn")

	goBtn.luaClick = self:guardRunCallback(data, function()
		data.isClick = true

		self:recycleToast(data, function()
			pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
				questId = data.questId
			})
		end)
	end, item)

	local hotKeyOR = oc:GetRefValue("hotKeyOR")
	local goKeyBinding = hotKeyOR:GetRefValue("keyBinding")

	goKeyBinding.isVirtual = true
	goKeyBinding.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GoToNewClue
	goKeyBinding.priority = 100
	goKeyBinding.luaTrigger = self:guardRunCallback(data, function(inputInfo)
		if inputInfo.phase == "Performed" then
			data.isClick = true

			self:recycleToast(data, function()
				pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
					questId = data.questId
				})
			end)
		end
	end, item)

	local keyHotKeyContent = hotKeyOR:GetRefValue("keyHotKeyContent")

	keyHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GoToNewClue)

	local btnTipsUText = hotKeyOR:GetRefValue("btnTipsUText")

	ClientTextUtils.setText(btnTipsUText, pg.getGameString("ITEM_DETAIL_TEXT"))
end

function NewClueTipsItem:onRecycleFinished(data, reason)
	if not self:isQueueEmpty() then
		self:setVisible(false)
	end

	local callback = data.recycleCloseCallback

	data.recycleCloseCallback = nil

	if callback and not self:isRecycleCancelled(reason) then
		callback()
	end
end

return NewClueTipsItem
